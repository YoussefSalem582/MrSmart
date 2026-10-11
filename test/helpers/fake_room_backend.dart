import 'dart:async';

import 'package:mr_smart/core/error/failure.dart';
import 'package:mr_smart/features/room/domain/entities/connection_status.dart';
import 'package:mr_smart/features/room/domain/entities/entity_snapshot.dart';
import 'package:mr_smart/features/room/domain/repositories/room_backend.dart';

EntitySnapshot snap(String id, EntityValue value, {DeviceKind? kind}) =>
    EntitySnapshot(
      id: id,
      name: id.split('.').last,
      kind:
          kind ??
          switch (id.split('.').first) {
            'light' => DeviceKind.light,
            'switch' => DeviceKind.switchDevice,
            'input_boolean' => DeviceKind.inputBoolean,
            _ => DeviceKind.temperature,
          },
      value: value,
      isSimulated: false,
    );

/// Scriptable backend. Streams are synchronous so tests stay deterministic.
class FakeRoomBackend implements RoomBackend {
  FakeRoomBackend(Iterable<EntitySnapshot> initial) {
    for (final s in initial) {
      states[s.id] = s;
    }
  }

  final states = <String, EntitySnapshot>{};
  final connectionController = StreamController<ConnectionStatus>.broadcast(
    sync: true,
  );
  final updatesController = StreamController<EntityUpdate>.broadcast(
    sync: true,
  );

  /// Every setPower call, in order.
  final commands = <(String, bool)>[];

  /// Decides what setPower does. Default: accept, change nothing, report
  /// nothing (like a device that has not reported back yet).
  Future<List<EntitySnapshot>> Function(String id, bool on)? onSetPower;

  int connectCalls = 0;
  int disconnectCalls = 0;
  int fetchCalls = 0;
  Failure? fetchFailure;
  bool disposed = false;

  bool get hasListeners =>
      connectionController.hasListener || updatesController.hasListener;

  void emitStatus(ConnectionStatus s) => connectionController.add(s);

  void push(EntitySnapshot s) {
    states[s.id] = s;
    updatesController.add(EntityChanged(s));
  }

  @override
  Stream<ConnectionStatus> get connection => connectionController.stream;

  @override
  Stream<EntityUpdate> get updates => updatesController.stream;

  @override
  Future<void> connect(Set<String> entityIds) async {
    connectCalls++;
    emitStatus(const ConnectionStatus.connected());
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    emitStatus(const ConnectionStatus.disconnected());
  }

  @override
  Future<List<EntitySnapshot>> fetchStates(Set<String> entityIds) async {
    fetchCalls++;
    if (fetchFailure != null) throw fetchFailure!;
    return [
      for (final id in entityIds)
        if (states[id] != null) states[id]!,
    ];
  }

  @override
  Future<List<EntitySnapshot>> listSupportedEntities() async =>
      states.values.toList();

  @override
  Future<List<EntitySnapshot>> setPower(
    String entityId,
    DeviceKind kind, {
    required bool on,
  }) async {
    commands.add((entityId, on));
    return onSetPower?.call(entityId, on) ?? const [];
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await connectionController.close();
    await updatesController.close();
  }
}
