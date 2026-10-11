import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/core/error/failure.dart';
import 'package:mr_smart/features/room/domain/entities/connection_status.dart';
import 'package:mr_smart/features/room/domain/entities/entity_snapshot.dart';
import 'package:mr_smart/features/room/domain/entities/leave_room_report.dart';
import 'package:mr_smart/features/room/domain/services/room_controller.dart';
import 'package:mr_smart/features/room/domain/usecases/leave_room.dart';

import '../../../helpers/fake_room_backend.dart';

void main() {
  const lamp = 'light.lamp';
  const plug = 'switch.plug';
  const helper = 'input_boolean.helper';
  const temp = 'sensor.temp';
  const heater = 'switch.heater'; // exists in the house, not in the room

  late FakeRoomBackend backend;

  setUp(() {
    backend = FakeRoomBackend([
      snap(lamp, const OnOffValue(true)),
      snap(plug, const OnOffValue(true)),
      snap(helper, const OnOffValue(false)),
      snap(temp, const NumericValue(20, '°C')),
      snap(heater, const OnOffValue(true)),
    ]);
  });

  RoomController controller(FakeAsync fake) {
    final room = RoomController(
      states: backend,
      commands: backend,
      entityIds: const [lamp, plug, helper, temp],
    );
    room.start();
    fake.flushMicrotasks();
    return room;
  }

  test('targets only selected controllable entities and reports partial '
      'failure', () {
    fakeAsync((fake) {
      final room = controller(fake);
      backend.onSetPower = (id, on) async {
        if (id == plug) throw const NetworkFailure();
        return [snap(id, OnOffValue(on))];
      };

      LeaveRoomReport? report;
      LeaveRoom(room)().then((r) => report = r);
      fake.flushMicrotasks();

      expect(backend.commands, [(lamp, false), (plug, false)]);
      expect(backend.commands.map((c) => c.$1), isNot(contains(heater)));
      expect(report!.allOff, isFalse);
      expect(
        {for (final e in report!.entries) e.entityId: e.outcome},
        {
          lamp: LeaveOutcome.confirmed,
          plug: LeaveOutcome.failed,
          helper: LeaveOutcome.alreadyOff,
        },
      );
    });
  });

  test('offline: sends nothing and says so', () {
    fakeAsync((fake) {
      final room = controller(fake);
      backend.emitStatus(const ConnectionStatus.disconnected());
      LeaveRoomReport? report;
      LeaveRoom(room)().then((r) => report = r);
      fake.flushMicrotasks();
      expect(backend.commands, isEmpty);
      expect(report!.notConnected, isTrue);
    });
  });
}
