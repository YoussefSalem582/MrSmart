import 'dart:async';

import '../entities/connection_status.dart';
import '../entities/entity_snapshot.dart';
import '../../../../core/error/failure.dart';
import '../entities/room_view.dart';
import '../repositories/device_command_repository.dart';
import '../repositories/room_state_repository.dart';

typedef Clock = DateTime Function();

enum CommandOutcome { confirmed, failed, unconfirmed, rejected }

/// Reconciles commands with reported state for the selected entities.
///
/// Rules (see tech_readme_files/docs/architecture.md):
/// * An accepted request is only *pending*. A device is confirmed when the
///   source reports the target state (event, call response or fresh read).
/// * If the target is already the reported state after the request is
///   accepted, it is confirmed at once instead of waiting for an event
///   that will never come.
/// * After [commandTimeout] one fresh read is made; if it still does not
///   match, the command ends as unconfirmed.
/// * Losing the connection marks every value stale and ends pending
///   commands as unconfirmed. Nothing is queued or replayed later.
/// * Reconnecting triggers a fresh read that replaces stale values.
class RoomController {
  RoomController({
    required RoomStateRepository states,
    required DeviceCommandRepository commands,
    required List<String> entityIds,
    this.commandTimeout = const Duration(seconds: 8),
    Clock? clock,
  }) : _states = states,
       _commands = commands,
       _ids = List.unmodifiable(entityIds),
       _now = clock ?? DateTime.now,
       _view = RoomView(
         connection: const ConnectionStatus.connecting(),
         devices: [for (final id in entityIds) DeviceState(id: id)],
       );

  static const int maxActivity = 20;

  final RoomStateRepository _states;
  final DeviceCommandRepository _commands;
  final List<String> _ids;
  final Clock _now;
  final Duration commandTimeout;

  final _viewController = StreamController<RoomView>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];
  final _inFlight = <String, _InFlight>{};
  RoomView _view;
  bool _started = false;
  bool _disposed = false;
  bool _everConnected = false;
  int _refreshGeneration = 0;

  RoomView get current => _view;
  Stream<RoomView> get view => _viewController.stream;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _subscriptions
      ..add(_states.connection.listen(_onConnection))
      ..add(_states.updates.listen(_onUpdate));
    await _states.connect(_ids.toSet());
  }

  /// App went to background: drop the live connection.
  Future<void> pause() => _states.disconnect();

  /// App came back: reconnect; a fresh read follows on connect.
  Future<void> resume() => _states.connect(_ids.toSet());

  bool canControl(String entityId) {
    final d = _view.device(entityId);
    final s = d?.snapshot;
    return d != null &&
        s != null &&
        _view.connection.isConnected &&
        !d.isRemoved &&
        !d.isPending &&
        s.kind.isControllable &&
        s.value is OnOffValue;
  }

  /// Requests [on] for [entityId]. Completes when the command is confirmed,
  /// failed or unconfirmed — never just because the request was accepted.
  Future<CommandOutcome> setPower(String entityId, {required bool on}) async {
    if (!canControl(entityId)) return CommandOutcome.rejected;
    final device = _view.device(entityId)!;
    final flight = _InFlight();
    _inFlight[entityId] = flight;
    _replace(device.copyWith(command: () => CommandPending(on, _now())));
    _log(ActivityType.commandSent, device, targetOn: on);
    flight.timer = Timer(commandTimeout, () => _onTimeout(entityId, flight));

    try {
      final changed = await _commands.setPower(
        entityId,
        device.snapshot!.kind,
        on: on,
      );
      if (_isCurrent(entityId, flight)) {
        changed.forEach(_applySnapshot);
      }
      if (_isCurrent(entityId, flight) &&
          _view.device(entityId)?.snapshot?.isOn == on) {
        _finish(entityId, null, CommandOutcome.confirmed);
      }
    } on Failure catch (f) {
      if (_isCurrent(entityId, flight)) {
        _finish(entityId, CommandFailed(on, f), CommandOutcome.failed);
      }
    } catch (e) {
      if (_isCurrent(entityId, flight)) {
        _finish(
          entityId,
          CommandFailed(on, ServerFailure(e.runtimeType.toString())),
          CommandOutcome.failed,
        );
      }
    }
    return flight.completer.future;
  }

  /// Fresh read of every selected entity.
  Future<void> refresh() async {
    if (!_view.connection.isConnected) return;
    final generation = ++_refreshGeneration;
    try {
      final fresh = await _states.fetchStates(_ids.toSet());
      if (_disposed ||
          generation != _refreshGeneration ||
          !_view.connection.isConnected) {
        return;
      }
      final byId = {for (final s in fresh) s.id: s};
      for (final id in _ids) {
        final s = byId[id];
        if (s == null) {
          _markRemoved(id);
        } else {
          _applySnapshot(s);
        }
      }
      _emit(
        _view.copyWith(
          isLoading: false,
          devices: [for (final d in _view.devices) d.copyWith(isStale: false)],
        ),
      );
    } on Failure {
      if (!_disposed) _emit(_view.copyWith(isLoading: false));
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    // Start every cancel before awaiting any, so all listeners detach now.
    final cancels = [for (final s in _subscriptions) s.cancel()];
    for (final f in _inFlight.values) {
      f.timer?.cancel();
      if (!f.completer.isCompleted) {
        f.completer.complete(CommandOutcome.unconfirmed);
      }
    }
    _inFlight.clear();
    await Future.wait([...cancels, _viewController.close()]);
  }

  void _onConnection(ConnectionStatus status) {
    final wasConnected = _view.connection.isConnected;
    _emit(
      _view.copyWith(
        connection: status,
        isLoading:
            _view.isLoading &&
            (status.isConnected || status.phase == ConnectionPhase.connecting),
      ),
    );
    if (status.isConnected) {
      if (_everConnected && !wasConnected) {
        _log(ActivityType.reconnected, null);
      }
      _everConnected = true;
      unawaited(refresh());
    } else if (wasConnected) {
      _onConnectionLost();
    }
  }

  void _onConnectionLost() {
    _refreshGeneration++;
    _emit(
      _view.copyWith(
        devices: [
          for (final d in _view.devices)
            d.snapshot == null ? d : d.copyWith(isStale: true),
        ],
      ),
    );
    for (final id in _inFlight.keys.toList()) {
      final target = (_view.device(id)?.command)?.targetOn ?? false;
      _finish(
        id,
        CommandUnconfirmed(target, UnconfirmedReason.connectionLost),
        CommandOutcome.unconfirmed,
      );
    }
    _log(ActivityType.connectionLost, null);
  }

  void _onUpdate(EntityUpdate update) {
    switch (update) {
      case EntityChanged(:final snapshot):
        _applySnapshot(snapshot);
      case EntityRemoved(:final entityId):
        _markRemoved(entityId);
    }
  }

  void _applySnapshot(EntitySnapshot s) {
    final d = _view.device(s.id);
    if (d == null) return;
    final previous = d.snapshot;
    _replace(
      d.copyWith(
        snapshot: s,
        lastConfirmedAt: _now(),
        isRemoved: false,
        isStale: _view.connection.isConnected ? false : d.isStale,
      ),
    );
    final command = d.command;
    if (command is CommandPending && s.isOn == command.targetOn) {
      _finish(s.id, null, CommandOutcome.confirmed);
      return;
    }
    if (previous == null || previous.value == s.value) return;
    if (s.value is UnavailableValue) {
      _log(ActivityType.becameUnavailable, _view.device(s.id));
    } else if (command is! CommandPending) {
      _log(ActivityType.externalChange, _view.device(s.id));
    }
  }

  void _markRemoved(String id) {
    final d = _view.device(id);
    if (d == null || d.isRemoved) return;
    _replace(d.copyWith(isRemoved: true));
    final command = d.command;
    if (command is CommandPending) {
      _finish(
        id,
        CommandFailed(command.targetOn, const NotFoundFailure()),
        CommandOutcome.failed,
      );
    }
    _log(ActivityType.removed, _view.device(id));
  }

  Future<void> _onTimeout(String id, _InFlight flight) async {
    if (!_isCurrent(id, flight)) return;
    try {
      final fresh = await _states.fetchStates({id});
      if (!_isCurrent(id, flight)) return;
      if (fresh.isEmpty) {
        _markRemoved(id);
      } else {
        fresh.forEach(_applySnapshot);
      }
    } on Failure {
      // Fall through: still unconfirmed.
    }
    if (_isCurrent(id, flight)) {
      final target = (_view.device(id)?.command)?.targetOn ?? false;
      _finish(
        id,
        CommandUnconfirmed(target, UnconfirmedReason.timeout),
        CommandOutcome.unconfirmed,
      );
    }
  }

  bool _isCurrent(String id, _InFlight flight) =>
      !_disposed && _inFlight[id] == flight && !flight.completer.isCompleted;

  void _finish(String id, CommandState? next, CommandOutcome outcome) {
    final flight = _inFlight.remove(id);
    flight?.timer?.cancel();
    final d = _view.device(id);
    if (d != null) {
      final target = d.command?.targetOn;
      _replace(d.copyWith(command: () => next));
      final type = switch (outcome) {
        CommandOutcome.confirmed => ActivityType.confirmed,
        CommandOutcome.failed => ActivityType.failed,
        _ => ActivityType.unconfirmed,
      };
      _log(type, _view.device(id), targetOn: target);
    }
    if (flight != null && !flight.completer.isCompleted) {
      flight.completer.complete(outcome);
    }
  }

  void _replace(DeviceState device) {
    _emit(
      _view.copyWith(
        devices: [
          for (final d in _view.devices) d.id == device.id ? device : d,
        ],
      ),
    );
  }

  void _log(ActivityType type, DeviceState? device, {bool? targetOn}) {
    final item = ActivityItem(
      at: _now(),
      type: type,
      deviceName: device?.snapshot?.name ?? device?.id,
      targetOn: targetOn,
      value: device?.snapshot?.value,
    );
    _emit(
      _view.copyWith(
        activity: [item, ..._view.activity].take(maxActivity).toList(),
      ),
    );
  }

  void _emit(RoomView view) {
    if (_disposed) return;
    _view = view;
    _viewController.add(view);
  }
}

class _InFlight {
  final completer = Completer<CommandOutcome>();
  Timer? timer;
}
