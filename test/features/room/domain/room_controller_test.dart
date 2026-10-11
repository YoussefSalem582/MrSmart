import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/core/error/failure.dart';
import 'package:mr_smart/features/room/domain/entities/connection_status.dart';
import 'package:mr_smart/features/room/domain/entities/entity_snapshot.dart';
import 'package:mr_smart/features/room/domain/entities/room_view.dart';
import 'package:mr_smart/features/room/domain/services/room_controller.dart';

import '../../../helpers/fake_room_backend.dart';

const lamp = 'light.lamp';
const plug = 'switch.plug';
const temp = 'sensor.temp';
const timeout = Duration(seconds: 8);

void main() {
  late FakeRoomBackend backend;
  late RoomController room;

  /// Builds and starts a controller inside [fake], then settles microtasks.
  void start(FakeAsync fake, {List<String> ids = const [lamp, plug, temp]}) {
    room = RoomController(
      states: backend,
      commands: backend,
      entityIds: ids,
      commandTimeout: timeout,
    );
    room.start();
    fake.flushMicrotasks();
  }

  DeviceState device(String id) => room.current.device(id)!;

  setUp(() {
    backend = FakeRoomBackend([
      snap(lamp, const OnOffValue(false)),
      snap(plug, const OnOffValue(true)),
      snap(temp, const NumericValue(21.5, '°F')),
    ]);
  });

  test('initial fresh read loads states and keeps the reported unit', () {
    fakeAsync((fake) {
      start(fake);
      expect(room.current.isLoading, isFalse);
      expect(device(lamp).snapshot!.isOn, isFalse);
      expect(device(temp).snapshot!.value, const NumericValue(21.5, '°F'));
      expect(device(lamp).lastConfirmedAt, isNotNull);
    });
  });

  group('command acknowledgement vs confirmed state', () {
    test('an accepted request stays pending until the state is reported', () {
      fakeAsync((fake) {
        start(fake);
        CommandOutcome? outcome;
        room.setPower(lamp, on: true).then((o) => outcome = o);
        fake.flushMicrotasks();

        expect(backend.commands, [(lamp, true)]);
        expect(device(lamp).command, isA<CommandPending>());
        expect(device(lamp).snapshot!.isOn, isFalse);
        expect(outcome, isNull);

        backend.push(snap(lamp, const OnOffValue(true)));
        fake.flushMicrotasks();

        expect(device(lamp).command, isNull);
        expect(device(lamp).snapshot!.isOn, isTrue);
        expect(outcome, CommandOutcome.confirmed);
        expect(room.current.activity.first.type, ActivityType.confirmed);
      });
    });

    test('states returned by the service call confirm without an event', () {
      fakeAsync((fake) {
        start(fake);
        backend.onSetPower = (id, on) async => [snap(id, OnOffValue(on))];
        CommandOutcome? outcome;
        room.setPower(lamp, on: true).then((o) => outcome = o);
        fake.flushMicrotasks();
        expect(outcome, CommandOutcome.confirmed);
      });
    });

    test('already-satisfied target resolves at once, not after timeout', () {
      fakeAsync((fake) {
        start(fake);
        CommandOutcome? outcome;
        // Plug is already on; the source reports no change.
        room.setPower(plug, on: true).then((o) => outcome = o);
        fake.flushMicrotasks();
        expect(outcome, CommandOutcome.confirmed);
        expect(device(plug).command, isNull);
        expect(fake.pendingTimers, isEmpty);
      });
    });
  });

  group('timeouts and failures', () {
    test('no report within the timeout ends as unconfirmed, not success', () {
      fakeAsync((fake) {
        start(fake);
        CommandOutcome? outcome;
        room.setPower(lamp, on: true).then((o) => outcome = o);
        fake.elapse(timeout);
        fake.flushMicrotasks();

        expect(outcome, CommandOutcome.unconfirmed);
        expect(
          device(lamp).command,
          const CommandUnconfirmed(true, UnconfirmedReason.timeout),
        );
        expect(device(lamp).snapshot!.isOn, isFalse);
        // One fresh read was attempted before giving up.
        expect(backend.fetchCalls, 2);
      });
    });

    test('timeout fresh read can still confirm a missed event', () {
      fakeAsync((fake) {
        start(fake);
        CommandOutcome? outcome;
        room.setPower(lamp, on: true).then((o) => outcome = o);
        fake.flushMicrotasks();
        backend.states[lamp] = snap(lamp, const OnOffValue(true)); // no event
        fake.elapse(timeout);
        expect(outcome, CommandOutcome.confirmed);
      });
    });

    test('a rejected request is failed and keeps the confirmed value', () {
      fakeAsync((fake) {
        start(fake);
        backend.onSetPower = (_, _) async => throw const PermissionFailure();
        CommandOutcome? outcome;
        room.setPower(lamp, on: true).then((o) => outcome = o);
        fake.flushMicrotasks();

        expect(outcome, CommandOutcome.failed);
        final command = device(lamp).command as CommandFailed;
        expect(command.failure, isA<PermissionFailure>());
        expect(device(lamp).snapshot!.isOn, isFalse);
      });
    });
  });

  test('external changes update state and are logged', () {
    fakeAsync((fake) {
      start(fake);
      backend.push(snap(plug, const OnOffValue(false)));
      expect(device(plug).snapshot!.isOn, isFalse);
      expect(room.current.activity.first.type, ActivityType.externalChange);
    });
  });

  group('unknown, unavailable and removed entities', () {
    test('unavailable and unknown are shown but not controllable', () {
      fakeAsync((fake) {
        start(fake);
        backend.push(snap(lamp, const UnavailableValue()));
        backend.push(snap(plug, const UnknownValue()));
        expect(device(lamp).snapshot!.value, const UnavailableValue());
        expect(room.canControl(lamp), isFalse);
        expect(room.canControl(plug), isFalse);
        expect(
          room.current.activity.map((a) => a.type),
          contains(ActivityType.becameUnavailable),
        );
      });
    });

    test('a removed entity is flagged and fails its pending command', () {
      fakeAsync((fake) {
        start(fake);
        CommandOutcome? outcome;
        room.setPower(lamp, on: true).then((o) => outcome = o);
        fake.flushMicrotasks();
        backend.states.remove(lamp);
        backend.updatesController.add(const EntityRemoved(lamp));
        fake.flushMicrotasks();

        expect(device(lamp).isRemoved, isTrue);
        expect(room.canControl(lamp), isFalse);
        expect(outcome, CommandOutcome.failed);
      });
    });

    test('an entity missing from a fresh read is marked removed', () {
      fakeAsync((fake) {
        backend.states.remove(plug);
        start(fake);
        expect(device(plug).isRemoved, isTrue);
      });
    });
  });

  group('connectivity', () {
    test('disconnect marks values stale and disables control', () {
      fakeAsync((fake) {
        start(fake);
        backend.emitStatus(const ConnectionStatus.disconnected());
        expect(device(lamp).isStale, isTrue);
        expect(device(lamp).lastConfirmedAt, isNotNull);
        expect(room.canControl(lamp), isFalse);
      });
    });

    test('pending command becomes unconfirmed on disconnect and is never '
        'replayed after reconnect', () {
      fakeAsync((fake) {
        start(fake);
        CommandOutcome? outcome;
        room.setPower(lamp, on: true).then((o) => outcome = o);
        fake.flushMicrotasks();
        backend.emitStatus(const ConnectionStatus.disconnected());
        fake.flushMicrotasks();
        expect(outcome, CommandOutcome.unconfirmed);
        expect(
          device(lamp).command,
          const CommandUnconfirmed(true, UnconfirmedReason.connectionLost),
        );

        // Offline attempts are rejected, not queued.
        room.setPower(plug, on: false).then((o) => outcome = o);
        fake.flushMicrotasks();
        expect(outcome, CommandOutcome.rejected);

        backend.emitStatus(const ConnectionStatus.connected());
        fake.elapse(timeout * 2);
        expect(backend.commands, [(lamp, true)]);
      });
    });

    test('reconnect does a fresh read that replaces stale values', () {
      fakeAsync((fake) {
        start(fake);
        backend.emitStatus(const ConnectionStatus.disconnected());
        // Changed while we were offline; no event reached us.
        backend.states[lamp] = snap(lamp, const OnOffValue(true));
        final readsBefore = backend.fetchCalls;

        backend.emitStatus(const ConnectionStatus.connected());
        fake.flushMicrotasks();

        expect(backend.fetchCalls, readsBefore + 1);
        expect(device(lamp).isStale, isFalse);
        expect(device(lamp).snapshot!.isOn, isTrue);
        expect(
          room.current.activity.map((a) => a.type),
          contains(ActivityType.reconnected),
        );
      });
    });
  });

  test('dispose cancels subscriptions and pending timers', () {
    fakeAsync((fake) {
      start(fake);
      room.setPower(lamp, on: true);
      fake.flushMicrotasks();
      room.dispose();
      fake.flushMicrotasks();
      expect(backend.hasListeners, isFalse);
      expect(fake.pendingTimers, isEmpty);
    });
  });
}
