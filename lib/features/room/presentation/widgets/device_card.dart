import 'package:flutter/material.dart';

import '../../../../core/error/failure_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/entity_snapshot.dart';
import '../../domain/entities/room_view.dart';
import 'room_formatters.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.device,
    required this.canControl,
    required this.onToggle,
  });

  final DeviceState device;
  final bool canControl;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final colors = AppSemanticColors.of(context);
    final s = device.snapshot;
    final name = s?.name ?? device.id;
    final isOn = s?.isOn ?? false;

    final valueText = device.isRemoved
        ? l10n.deviceRemoved
        : s == null
        ? l10n.deviceLoading
        : l10n.valueText(s.value, locale);
    final valueColor = device.isRemoved || s?.value is UnavailableValue
        ? colors.danger
        : s?.value is UnknownValue
        ? colors.warning
        : theme.colorScheme.onSurface;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedSwitcher(
                  duration: AppMotion.normal,
                  child: Icon(
                    s == null
                        ? Icons.devices_other
                        : kindIcon(s.kind, on: isOn),
                    key: ValueKey('${s?.kind}-$isOn'),
                    color: isOn
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: theme.textTheme.titleMedium),
                      Wrap(
                        spacing: AppSpacing.sm,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (s != null)
                            Text(
                              l10n.kindText(s.kind),
                              style: theme.textTheme.bodySmall,
                            ),
                          if (s?.isSimulated ?? false)
                            _Badge(l10n.simulatedBadge, colors.simulated),
                        ],
                      ),
                    ],
                  ),
                ),
                if (s != null && s.kind.isControllable)
                  Switch(
                    value: device.command is CommandPending
                        ? (device.command!.targetOn)
                        : isOn,
                    onChanged: canControl ? (_) => onToggle() : null,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedSwitcher(
              duration: AppMotion.normal,
              child: Text(
                valueText,
                key: ValueKey(valueText),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: valueColor,
                ),
              ),
            ),
            if (device.isStale && device.lastConfirmedAt != null)
              Text(
                l10n.staleNote(formatTime(device.lastConfirmedAt!, locale)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.warning,
                ),
              )
            else if (device.lastConfirmedAt != null)
              Text(
                l10n.lastConfirmed(formatTime(device.lastConfirmedAt!, locale)),
                style: theme.textTheme.bodySmall,
              ),
            AnimatedSize(
              duration: AppMotion.normal,
              child: _CommandLine(command: device.command),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandLine extends StatelessWidget {
  const _CommandLine({required this.command});

  final CommandState? command;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppSemanticColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final c = command;
    if (c == null) return const SizedBox(width: double.infinity);
    final (Widget leading, Color color, String text) = switch (c) {
      CommandPending(:final targetOn) => (
        const SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        scheme.primary,
        targetOn ? l10n.commandPendingOn : l10n.commandPendingOff,
      ),
      CommandFailed(:final targetOn, :final failure) => (
        Icon(Icons.error_outline, size: 18, color: colors.danger),
        colors.danger,
        targetOn
            ? l10n.commandFailedOn(failure.message(l10n))
            : l10n.commandFailedOff(failure.message(l10n)),
      ),
      CommandUnconfirmed(:final reason) => (
        Icon(Icons.help_outline, size: 18, color: colors.warning),
        colors.warning,
        reason == UnconfirmedReason.timeout
            ? l10n.commandUnconfirmedTimeout
            : l10n.commandUnconfirmedConnection,
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Semantics(
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
    ),
  );
}
