import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/locale/locale_cubit.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/session/presentation/session_cubit.dart';
import '../l10n/generated/app_localizations.dart';

class MrSmartApp extends StatelessWidget {
  const MrSmartApp({
    super.key,
    required this.router,
    required this.themeCubit,
    required this.localeCubit,
    required this.sessionCubit,
  });

  final GoRouter router;
  final ThemeCubit themeCubit;
  final LocaleCubit localeCubit;
  final SessionCubit sessionCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: themeCubit),
        BlocProvider.value(value: localeCubit),
        BlocProvider.value(value: sessionCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) => BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) => MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            locale: locale,
            supportedLocales: LocaleCubit.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(locale),
            darkTheme: AppTheme.dark(locale),
            themeMode: themeMode,
          ),
        ),
      ),
    );
  }
}
