import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_router.dart';
import 'core/logging/app_logger.dart';
import 'di/injection_container.dart';
import 'features/session/presentation/session_cubit.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initDependencies();
    FlutterError.onError = (details) =>
        AppLogger.error('Flutter error', details.exception, details.stack);

    final session = sl<SessionCubit>();
    await session.restore();

    runApp(
      MrSmartApp(
        router: buildRouter(sl),
        themeCubit: sl(),
        localeCubit: sl(),
        sessionCubit: session,
      ),
    );
  }, (error, stack) => AppLogger.error('Uncaught error', error, stack));
}
