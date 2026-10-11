import 'dart:async';

import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../../room/domain/entities/connection_status.dart';
import '../../room/domain/entities/entity_snapshot.dart';
import '../../room/domain/repositories/room_backend.dart';
import '../domain/ha_credentials.dart';
import 'ha_failure_mapper.dart';
import 'ha_rest_data_source.dart';
import 'ha_socket.dart';
import 'ha_state_mapper.dart';
import 'ha_ws_transport.dart';
import 'json.dart';
import 'reconnect_policy.dart';

/// Home Assistant as a [RoomBackend]:
/// REST for reads and service calls, WebSocket `state_changed` events for
/// live updates, bounded exponential backoff on disconnect. Fresh state
/// after a reconnect is read by the room controller.
class HaRoomRepository implements RoomBackend {
  HaRoomRepository({
    required HaRestDataSource rest,
    required HaCredentials credentials,
    required HaWsConnector connector,
    this.policy = const ReconnectPolicy(),
    this.pingInterval = const Duration(seconds: 30),
    this.requestTimeout = const Duration(seconds: 10),
  }) : _rest = rest,
       _credentials = credentials,
       _connector = connector;

  final HaRestDataSource _rest;
  final HaCredentials _credentials;
  final HaWsConnector _connector;
  final ReconnectPolicy policy;
  final Duration pingInterval;
  final Duration requestTimeout;

  final _connection = StreamController<ConnectionStatus>.broadcast();
  final _updates = StreamController<EntityUpdate>.broadcast();
  Set<String> _watched = {};

  /// Bumped by connect/disconnect/dispose; a run loop whose generation is
  /// outdated stops at its next checkpoint.
  int _generation = 0;
  HaSocket? _socket;
  Timer? _pingTimer;
  Completer<void>? _wake;
  bool _disposed = false;

  @override
  Stream<ConnectionStatus> get connection => _connection.stream;

  @override
  Stream<EntityUpdate> get updates => _updates.stream;

  @override
  Future<void> connect(Set<String> entityIds) async {
    _watched = entityIds;
    final generation = await _stop();
    unawaited(_run(generation));
  }

  @override
  Future<void> disconnect() async {
    await _stop();
    _emit(const ConnectionStatus.disconnected());
  }

  @override
  Future<List<EntitySnapshot>> fetchStates(Set<String> entityIds) async {
    final raw = entityIds.length == 1
        ? [?await _rest.state(entityIds.single)]
        : (await _rest.states()).where(
            (s) => entityIds.contains(s['entity_id']),
          );
    return [for (final json in raw) ?HaStateMapper.toSnapshot(json)];
  }

  @override
  Future<List<EntitySnapshot>> listSupportedEntities() async {
    final all = [
      for (final json in await _rest.states()) ?HaStateMapper.toSnapshot(json),
    ];
    return all..sort(
      (a, b) => a.kind.index != b.kind.index
          ? a.kind.index.compareTo(b.kind.index)
          : a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
  }

  @override
  Future<List<EntitySnapshot>> setPower(
    String entityId,
    DeviceKind kind, {
    required bool on,
  }) async {
    if (!kind.isControllable) throw const PermissionFailure('read-only');
    // Domain-specific action: light.turn_on, switch.turn_off, … Never
    // POST /api/states, which only rewrites HA's record of the state.
    final changed = await _rest.callService(
      kind.domain,
      on ? 'turn_on' : 'turn_off',
      entityId,
    );
    return [
      for (final json in changed)
        if (json['entity_id'] == entityId) ?HaStateMapper.toSnapshot(json),
    ];
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _stop();
    await _connection.close();
    await _updates.close();
  }

  Future<void> _run(int generation) async {
    bool current() => generation == _generation && !_disposed;
    var attempt = 0;
    _emit(const ConnectionStatus.connecting());
    while (current()) {
      HaSocket? socket;
      try {
        final transport = await _connector(_credentials.endpoint.websocket);
        if (!current()) {
          await transport.close();
          return;
        }
        socket = await HaSocket.open(
          transport: transport,
          token: _credentials.token,
          timeout: requestTimeout,
        );
        if (!current()) {
          await socket.close();
          return;
        }
        final (_, events) = await socket.subscribeEvents('state_changed');
        events.listen(_onEvent);
        _socket = socket;
        attempt = 0;
        _emit(const ConnectionStatus.connected());
        _startPing(socket);
        await socket.done;
        AppLogger.warning('HA WS closed');
      } on AuthFailure {
        await socket?.close();
        if (current()) _emit(const ConnectionStatus.authFailed());
        return;
      } catch (e) {
        await socket?.close();
        AppLogger.warning('HA WS connect failed: ${mapTransportError(e)}');
      } finally {
        _pingTimer?.cancel();
        if (identical(_socket, socket)) _socket = null;
      }
      if (!current()) return;
      attempt++;
      final delay = policy.delayFor(attempt);
      _emit(
        ConnectionStatus(
          ConnectionPhase.reconnecting,
          attempt: attempt,
          retryIn: delay,
        ),
      );
      await _sleep(delay);
    }
  }

  void _onEvent(Json event) {
    final data = event['data'];
    if (data is! Map) return;
    final id = data['entity_id'];
    if (id is! String || !_watched.contains(id)) return;
    final newState = data['new_state'];
    if (newState == null) {
      _add(EntityRemoved(id));
    } else if (newState is Json) {
      final snapshot = HaStateMapper.toSnapshot(newState);
      if (snapshot != null) _add(EntityChanged(snapshot));
    }
  }

  void _startPing(HaSocket socket) {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(pingInterval, (_) async {
      try {
        await socket.ping();
      } on Failure {
        await socket.close(); // run loop notices and reconnects
      }
    });
  }

  /// Ends the current run loop and socket; returns the new generation.
  Future<int> _stop() async {
    final generation = ++_generation;
    _pingTimer?.cancel();
    if (_wake?.isCompleted == false) _wake!.complete();
    final socket = _socket;
    _socket = null;
    await socket?.close();
    return generation;
  }

  Future<void> _sleep(Duration delay) async {
    final wake = _wake = Completer<void>();
    final timer = Timer(delay, () {
      if (!wake.isCompleted) wake.complete();
    });
    await wake.future;
    timer.cancel();
  }

  void _emit(ConnectionStatus status) {
    if (!_connection.isClosed) _connection.add(status);
  }

  void _add(EntityUpdate update) {
    if (!_updates.isClosed) _updates.add(update);
  }
}
