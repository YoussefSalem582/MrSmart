import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../core/router/routes.dart';
import '../core/router/stream_listenable.dart';
import '../features/entity_selection/presentation/selection_cubit.dart';
import '../features/entity_selection/presentation/selection_page.dart';
import '../features/home_assistant/presentation/connect_cubit.dart';
import '../features/home_assistant/presentation/connect_page.dart';
import '../features/room/domain/repositories/demo_controls.dart';
import '../features/room/domain/repositories/room_selection_repository.dart';
import '../features/room/presentation/cubit/room_cubit.dart';
import '../features/room/presentation/pages/room_page.dart';
import '../features/session/domain/app_mode.dart';
import '../features/session/presentation/session_cubit.dart';
import '../features/session/presentation/welcome_page.dart';
import '../features/settings/presentation/settings_page.dart';

GoRouter buildRouter(GetIt sl) {
  final session = sl<SessionCubit>();
  return GoRouter(
    initialLocation: Routes.welcome,
    refreshListenable: StreamListenable(session.stream),
    redirect: (context, state) => redirectFor(
      session.state.mode,
      state.matchedLocation,
      hasSelection: sl<RoomSelectionRepository>().read().isNotEmpty,
    ),
    routes: [
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomePage()),
      GoRoute(
        path: Routes.connect,
        builder: (_, _) => BlocProvider(
          create: (_) => ConnectCubit(sl(), sl())..load(),
          child: const ConnectPage(),
        ),
      ),
      GoRoute(
        path: Routes.select,
        builder: (_, _) => BlocProvider(
          key: ValueKey(session.state.epoch),
          create: (_) => SelectionCubit(sl(), sl())..load(),
          child: const SelectionPage(),
        ),
      ),
      GoRoute(
        path: Routes.room,
        // Keyed by session epoch: a mode switch or new selection always
        // gets a fresh cubit bound to the new scope's controller.
        builder: (_, _) => BlocProvider(
          key: ValueKey(session.state.epoch),
          create: (_) => RoomCubit(
            sl(),
            sl(),
            demo: sl.isRegistered<DemoControls>() ? sl<DemoControls>() : null,
          )..start(),
          child: const RoomPage(),
        ),
      ),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsPage()),
    ],
  );
}

/// Pure so it can be unit tested.
String? redirectFor(
  AppMode mode,
  String location, {
  required bool hasSelection,
}) {
  final needsSession = location == Routes.room || location == Routes.select;
  if (mode == AppMode.none && needsSession) return Routes.welcome;
  if (mode == AppMode.demo && location == Routes.select) return Routes.room;
  if (mode == AppMode.homeAssistant &&
      location == Routes.room &&
      !hasSelection) {
    return Routes.select;
  }
  if (mode != AppMode.none && location == Routes.welcome) return Routes.room;
  return null;
}
