import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/locale_cubit.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../session/domain/app_mode.dart';
import '../../session/presentation/session_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final session = context.watch<SessionCubit>().state;
    final mode = session.mode;
    final modeName = switch (mode) {
      AppMode.none => l10n.modeNone,
      AppMode.demo => l10n.modeDemo,
      AppMode.homeAssistant => l10n.modeHomeAssistant,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _Section(l10n.settingsLanguage),
              BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) => SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'en',
                      label: Text(l10n.languageEnglish),
                    ),
                    ButtonSegment(
                      value: 'ar',
                      label: Text(l10n.languageArabic),
                    ),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (s) =>
                      context.read<LocaleCubit>().setLocale(Locale(s.first)),
                ),
              ),
              _Section(l10n.settingsTheme),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) => SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.themeSystem),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.themeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeDark),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (s) =>
                      context.read<ThemeCubit>().setThemeMode(s.first),
                ),
              ),
              _Section(l10n.settingsMode),
              Text(
                l10n.currentMode(modeName),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (mode != AppMode.demo)
                ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: Text(l10n.switchToDemo),
                  onTap: () async {
                    await context.read<SessionCubit>().startDemo();
                    if (context.mounted) context.go(Routes.room);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: Text(
                  mode == AppMode.homeAssistant
                      ? l10n.reconfigureConnection
                      : l10n.connectHomeAssistant,
                ),
                onTap: () => context.push(Routes.connect),
              ),
              if (mode == AppMode.homeAssistant)
                ListTile(
                  leading: const Icon(Icons.checklist),
                  title: Text(l10n.chooseDevices),
                  onTap: () => context.push(Routes.select),
                ),
              if (mode != AppMode.none)
                ListTile(
                  leading: const Icon(Icons.first_page),
                  title: Text(l10n.leaveMode),
                  onTap: () async {
                    await context.read<SessionCubit>().exit();
                    if (context.mounted) context.go(Routes.welcome);
                  },
                ),
              if (session.hasStoredCredentials)
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    l10n.disconnectErase,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () => _confirmErase(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmErase(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.disconnectErase),
        content: Text(l10n.disconnectEraseBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              minimumSize: const Size(0, AppSpacing.minTouchTarget),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.erase),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final wasHomeAssistant =
        context.read<SessionCubit>().state.mode == AppMode.homeAssistant;
    await context.read<SessionCubit>().disconnectAndErase();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.credentialsErased)));
    if (wasHomeAssistant) context.go(Routes.welcome);
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
