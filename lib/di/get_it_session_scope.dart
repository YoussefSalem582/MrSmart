import 'package:get_it/get_it.dart';

import '../features/room/domain/repositories/demo_controls.dart';
import '../features/room/domain/repositories/device_command_repository.dart';
import '../features/room/domain/repositories/entity_catalog_repository.dart';
import '../features/room/domain/repositories/room_backend.dart';
import '../features/room/domain/repositories/room_state_repository.dart';
import '../features/room/domain/services/room_controller.dart';
import '../features/room/domain/usecases/leave_room.dart';
import '../features/session/domain/app_mode.dart';

/// A backend plus the entity ids its room shows.
typedef SessionBackend = ({RoomBackend backend, List<String> Function() ids});

typedef BackendFactory = Future<SessionBackend> Function();

/// [SessionScope] on top of a GetIt scope: everything registered here is
/// disposed when the scope pops.
class GetItSessionScope implements SessionScope {
  GetItSessionScope(
    this._getIt, {
    required Map<AppMode, BackendFactory> factories,
    this.commandTimeout = const Duration(seconds: 8),
  }) : _factories = factories;

  static const scopeName = 'session';

  final GetIt _getIt;
  final Map<AppMode, BackendFactory> _factories;
  final Duration commandTimeout;

  @override
  Future<void> open(AppMode mode) async {
    await close();
    final created = await _factories[mode]!();
    final backend = created.backend;
    _getIt.pushNewScope(
      scopeName: scopeName,
      init: (g) {
        g
          ..registerSingleton<RoomBackend>(backend, dispose: (b) => b.dispose())
          ..registerSingleton<RoomStateRepository>(backend)
          ..registerSingleton<DeviceCommandRepository>(backend)
          ..registerSingleton<EntityCatalogRepository>(backend)
          ..registerLazySingleton<RoomController>(
            () => RoomController(
              states: g(),
              commands: g(),
              entityIds: created.ids(),
              commandTimeout: commandTimeout,
            ),
            dispose: (c) => c.dispose(),
          )
          ..registerFactory<LeaveRoom>(() => LeaveRoom(g()));
        if (backend is DemoControls) {
          g.registerSingleton<DemoControls>(backend as DemoControls);
        }
      },
    );
  }

  @override
  Future<void> close() async {
    if (_getIt.hasScope(scopeName)) await _getIt.popScopesTill(scopeName);
  }

  @override
  Future<void> resetRoom() async {
    if (_getIt.isRegistered<RoomController>()) {
      await _getIt.resetLazySingleton<RoomController>();
    }
  }
}
