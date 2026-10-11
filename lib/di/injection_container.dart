import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../core/error/failure.dart';
import '../core/locale/locale_cubit.dart';
import '../core/logging/app_logger.dart';
import '../core/theme/theme_cubit.dart';
import '../features/home_assistant/data/ha_connection_tester_impl.dart';
import '../features/home_assistant/data/ha_rest_data_source.dart';
import '../features/home_assistant/data/ha_room_repository.dart';
import '../features/home_assistant/data/ha_ws_transport.dart';
import '../features/home_assistant/data/secure_credentials_store.dart';
import '../features/home_assistant/domain/ha_credentials.dart';
import '../features/home_assistant/domain/usecases/connect_home_assistant.dart';
import '../features/home_assistant/domain/usecases/erase_home_assistant.dart';
import '../features/room/data/demo/demo_room_repository.dart';
import '../features/room/data/prefs_room_selection_repository.dart';
import '../features/room/domain/repositories/room_selection_repository.dart';
import '../features/session/data/prefs_app_mode_repository.dart';
import '../features/session/domain/app_mode.dart';
import '../features/session/presentation/session_cubit.dart';
import 'get_it_session_scope.dart';

final GetIt sl = GetIt.instance;

/// Composition root: the only place that knows concrete classes.
Future<void> initDependencies() async {
  sl.registerSingleton<Talker>(AppLogger.create());

  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton(() => ThemeCubit(sl()))
    ..registerLazySingleton(
      () => LocaleCubit(sl(), deviceLocale: PlatformDispatcher.instance.locale),
    )
    // Home Assistant
    ..registerLazySingleton<CredentialsRepository>(
      () => const SecureCredentialsStore(),
    )
    ..registerLazySingleton<RoomSelectionRepository>(
      () => PrefsRoomSelectionRepository(sl()),
    )
    ..registerLazySingleton<HaConnectionTester>(
      () => const HaConnectionTesterImpl(HaRestDataSource.forCredentials),
    )
    ..registerFactory(
      () => ConnectHomeAssistant(
        sl(),
        sl(),
        // Plain HTTP only in debug builds; release requires HTTPS.
        allowInsecureHttp: !kReleaseMode,
      ),
    )
    ..registerFactory(() => EraseHomeAssistant(sl(), sl()))
    // Session
    ..registerLazySingleton<AppModeRepository>(
      () => PrefsAppModeRepository(sl()),
    )
    ..registerLazySingleton<SessionScope>(
      () => GetItSessionScope(
        sl,
        factories: {
          AppMode.demo: () async => (
            backend: DemoRoomRepository(),
            ids: () => DemoRoomRepository.entityIds,
          ),
          AppMode.homeAssistant: () async {
            final credentials = await sl<CredentialsRepository>().read();
            if (credentials == null) throw const AuthFailure('no credentials');
            return (
              backend: HaRoomRepository(
                rest: HaRestDataSource.forCredentials(credentials),
                credentials: credentials,
                connector: WebSocketChannelTransport.connect,
              ),
              ids: () => sl<RoomSelectionRepository>().read(),
            );
          },
        },
      ),
    )
    ..registerLazySingleton(() => SessionCubit(sl(), sl(), sl(), sl()));
}
