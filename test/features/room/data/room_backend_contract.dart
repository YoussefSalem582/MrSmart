import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/features/room/domain/entities/connection_status.dart';
import 'package:mr_smart/features/room/domain/entities/entity_snapshot.dart';
import 'package:mr_smart/features/room/domain/repositories/room_backend.dart';

/// Behaviour every [RoomBackend] must share (Liskov): the room controller
/// cannot tell the simulator from Home Assistant.
void roomBackendContract({
  required Future<RoomBackend> Function() create,
  required String lightId,
  required bool lightInitiallyOn,
}) {
  late RoomBackend backend;

  setUp(() async => backend = await create());
  tearDown(() => backend.dispose());

  test('connect reports connected', () async {
    final status = backend.connection.firstWhere((s) => s.isConnected);
    await backend.connect({lightId});
    expect(await status.timeout(const Duration(seconds: 2)), isNotNull);
  });

  test(
    'fetchStates returns only requested ids and omits unknown ones',
    () async {
      await backend.connect({lightId});
      final states = await backend.fetchStates({
        lightId,
        'light.does_not_exist',
      });
      expect(states.map((s) => s.id), [lightId]);
      expect(states.single.isOn, lightInitiallyOn);
    },
  );

  test('a confirmed command is observable as an update or a returned '
      'state', () async {
    await backend.connect({lightId});
    final target = !lightInitiallyOn;
    final event = backend.updates
        .whereType<EntityChanged>()
        .firstWhere((u) => u.snapshot.id == lightId)
        .then((u) => u.snapshot);
    final returned = await backend.setPower(
      lightId,
      DeviceKind.light,
      on: target,
    );
    final seen = returned.isNotEmpty
        ? returned.single
        : await event.timeout(const Duration(seconds: 2));
    expect(seen.isOn, target);
  });

  test('disconnect reports a non-connected status', () async {
    await backend.connect({lightId});
    final status = backend.connection.firstWhere((s) => !s.isConnected);
    await backend.disconnect();
    expect(
      (await status.timeout(const Duration(seconds: 2))).phase,
      isNot(ConnectionPhase.connected),
    );
  });
}

extension<T> on Stream<T> {
  Stream<S> whereType<S>() => where((e) => e is S).cast<S>();
}
