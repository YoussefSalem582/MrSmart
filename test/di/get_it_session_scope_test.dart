import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mr_smart/di/get_it_session_scope.dart';
import 'package:mr_smart/features/room/domain/entities/entity_snapshot.dart';
import 'package:mr_smart/features/room/domain/repositories/room_state_repository.dart';
import 'package:mr_smart/features/room/domain/services/room_controller.dart';
import 'package:mr_smart/features/session/domain/app_mode.dart';

import '../helpers/fake_room_backend.dart';

void main() {
  test(
    'switching modes disposes the old backend and its subscriptions',
    () async {
      {
        final getIt = GetIt.asNewInstance();
        final demo = FakeRoomBackend([snap('light.a', const OnOffValue(true))]);
        final ha = FakeRoomBackend([snap('light.b', const OnOffValue(false))]);
        final scope = GetItSessionScope(
          getIt,
          factories: {
            AppMode.demo: () async => (backend: demo, ids: () => ['light.a']),
            AppMode.homeAssistant: () async =>
                (backend: ha, ids: () => ['light.b']),
          },
        );

        await scope.open(AppMode.demo);
        await getIt<RoomController>().start();
        expect(demo.hasListeners, isTrue);

        await scope.open(AppMode.homeAssistant);

        expect(demo.disposed, isTrue);
        expect(demo.hasListeners, isFalse);
        expect(identical(getIt<RoomStateRepository>(), ha), isTrue);

        await scope.close();
        expect(ha.disposed, isTrue);
        expect(getIt.isRegistered<RoomController>(), isFalse);
      }
    },
  );
}
