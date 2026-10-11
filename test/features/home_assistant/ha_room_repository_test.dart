import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/features/home_assistant/data/ha_room_repository.dart';
import 'package:mr_smart/features/home_assistant/data/reconnect_policy.dart';
import 'package:mr_smart/features/home_assistant/domain/ha_credentials.dart';
import 'package:mr_smart/features/home_assistant/domain/ha_endpoint.dart';
import 'package:mr_smart/features/room/domain/entities/connection_status.dart';
import 'package:mr_smart/features/room/domain/entities/entity_snapshot.dart';

import '../../helpers/fake_home_assistant.dart';
import '../room/data/room_backend_contract.dart';

const _fast = ReconnectPolicy(
  initial: Duration(milliseconds: 10),
  max: Duration(milliseconds: 40),
);

HaRoomRepository repoFor(FakeHomeAssistant ha, {String? token}) =>
    HaRoomRepository(
      rest: ha.rest(withToken: token),
      credentials: HaCredentials(
        HaEndpoint.parse('http://ha.test:8123'),
        token ?? ha.token,
      ),
      connector: ha.connect,
      policy: _fast,
      requestTimeout: const Duration(milliseconds: 500),
    );

FakeHomeAssistant seeded() => FakeHomeAssistant()
  ..put('light.desk', 'off')
  ..put('switch.heater', 'on')
  ..put('sensor.temp', '21.5', {
    'device_class': 'temperature',
    'unit_of_measurement': '°C',
  });

Future<ConnectionStatus> next(
  HaRoomRepository repo,
  bool Function(ConnectionStatus) test,
) => repo.connection.firstWhere(test).timeout(const Duration(seconds: 2));

void main() {
  group('HaRoomRepository contract', () {
    roomBackendContract(
      create: () async => repoFor(seeded()),
      lightId: 'light.desk',
      lightInitiallyOn: false,
    );
  });

  late FakeHomeAssistant ha;
  late HaRoomRepository repo;

  setUp(() {
    ha = seeded();
    repo = repoFor(ha);
  });
  tearDown(() => repo.dispose());

  test('uses the domain service, never POST /api/states', () async {
    await repo.setPower('light.desk', DeviceKind.light, on: true);
    expect(ha.restCalls, ['POST services/light/turn_on']);
    expect(ha.restCalls.any((c) => c.startsWith('POST states')), isFalse);
  });

  test(
    'forwards only selected entities; new_state null means removed',
    () async {
      final updates = <EntityUpdate>[];
      repo.updates.listen(updates.add);
      final connected = next(repo, (s) => s.isConnected);
      await repo.connect({'light.desk'});
      await connected;

      ha
        ..put('switch.heater', 'off') // not in the room
        ..put('light.desk', 'on')
        ..remove('light.desk');
      await pumpEventQueue();

      expect(updates, hasLength(2));
      expect((updates[0] as EntityChanged).snapshot.isOn, isTrue);
      expect(updates[1], isA<EntityRemoved>());
    },
  );

  test('a rejected token stops with authFailed and does not retry', () async {
    final bad = repoFor(ha, token: 'wrong');
    final failed = next(bad, (s) => s.phase == ConnectionPhase.authFailed);
    await bad.connect({'light.desk'});
    await failed;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(ha.connectAttempts, 1);
    await bad.dispose();
  });

  test('reconnects with backoff and resubscribes after a drop', () async {
    final updates = <EntityUpdate>[];
    repo.updates.listen(updates.add);
    var connected = next(repo, (s) => s.isConnected);
    await repo.connect({'light.desk'});
    await connected;

    final reconnecting = next(
      repo,
      (s) => s.phase == ConnectionPhase.reconnecting,
    );
    connected = next(repo, (s) => s.isConnected);
    ha.dropConnections();
    final status = await reconnecting;
    expect(status.attempt, 1);
    expect(status.retryIn, const Duration(milliseconds: 10));
    await connected;

    ha.put('light.desk', 'on');
    await pumpEventQueue();
    expect(updates.whereType<EntityChanged>(), isNotEmpty);
  });

  test(
    'keeps retrying while the hub is unreachable, with capped delays',
    () async {
      ha.refuseConnections = true;
      final delays = <Duration?>[];
      repo.connection
          .where((s) => s.phase == ConnectionPhase.reconnecting)
          .listen((s) => delays.add(s.retryIn));
      await repo.connect({'light.desk'});
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(delays.take(4), const [
        Duration(milliseconds: 10),
        Duration(milliseconds: 20),
        Duration(milliseconds: 40),
        Duration(milliseconds: 40),
      ]);
    },
  );

  test('disconnect and dispose close the socket and stop retrying', () async {
    final connected = next(repo, (s) => s.isConnected);
    await repo.connect({'light.desk'});
    await connected;
    await repo.disconnect();
    expect(ha.transports, isEmpty);
    final attempts = ha.connectAttempts;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(ha.connectAttempts, attempts);
  });

  test('ReconnectPolicy default is 1, 2, 4 … capped at 30 seconds', () {
    const p = ReconnectPolicy();
    expect(
      [for (var i = 1; i <= 7; i++) p.delayFor(i).inSeconds],
      [1, 2, 4, 8, 16, 30, 30],
    );
  });
}
