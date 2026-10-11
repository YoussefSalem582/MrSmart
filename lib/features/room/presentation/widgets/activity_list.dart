import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/entity_snapshot.dart';
import '../../domain/entities/room_view.dart';
import 'room_formatters.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key, required this.items});

  final List<ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.activityTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (items.isEmpty)
              Text(l10n.activityEmpty, style: theme.textTheme.bodySmall)
            else
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatTime(item.at, locale),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _text(l10n, item, locale),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  String _text(AppLocalizations l10n, ActivityItem item, Locale locale) {
    final device = item.deviceName ?? '';
    final value = item.value == null ? '' : l10n.valueText(item.value!, locale);
    return switch (item.type) {
      ActivityType.commandSent =>
        item.targetOn ?? false
            ? l10n.activityCommandSentOn(device)
            : l10n.activityCommandSentOff(device),
      ActivityType.confirmed => l10n.activityConfirmed(device, value),
      ActivityType.failed => l10n.activityFailed(device),
      ActivityType.unconfirmed => l10n.activityUnconfirmed(device),
      ActivityType.externalChange when item.value is NumericValue =>
        l10n.activityReading(device, value),
      ActivityType.externalChange => l10n.activityExternal(device, value),
      ActivityType.becameUnavailable => l10n.activityUnavailable(device),
      ActivityType.removed => l10n.activityRemoved(device),
      ActivityType.connectionLost => l10n.activityConnectionLost,
      ActivityType.reconnected => l10n.activityReconnected,
    };
  }
}
