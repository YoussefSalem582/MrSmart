import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/features/room/data/demo/demo_room_repository.dart';
import 'package:mr_smart/features/room/domain/entities/entity_snapshot.dart';

import 'room_backend_contract.dart';

void main() {
  group('DemoRoomRepository contract', () {
    roomBackendContract(
      create: () async => DemoRoomRepository(
        latency: Duration.zero,
        driftInterval: Duration.zero,
      ),
      lightId: DemoRoomRepository.lightId,
      lightInitiallyOn: true,
    );
  });

  test('every demo snapshot is flagged as simulated', () async {
    final demo = DemoRoomRepository(
      latency: Duration.zero,
      driftInterval: Duration.zero,
    );
    await demo.connect(DemoRoomRepository.entityIds.toSet());
    final states = await demo.fetchStates(DemoRoomRepository.entityIds.toSet());
    expect(states, hasLength(3));
    expect(states.every((s) => s.isSimulated), isTrue);
    expect(
      states.firstWhere((s) => s.kind == DeviceKind.temperature).value,
      const NumericValue(22.5, '°C'),
    );
    await demo.dispose();
  });

  test('temperature drift is deterministic', () async {
    final demo = DemoRoomRepository(
      latency: Duration.zero,
      driftInterval: Duration.zero,
    );
    await demo.connect({DemoRoomRepository.temperatureId});
    demo
      ..nudgeTemperature()
      ..nudgeTemperature();
    final t = await demo.fetchStates({DemoRoomRepository.temperatureId});
    expect(t.single.value, const NumericValue(22.8, '°C'));
    await demo.dispose();
  });
}
