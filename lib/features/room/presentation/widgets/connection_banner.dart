import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/connection_status.dart';

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key, required this.status});

  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppSemanticColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (icon, color, text) = switch (status.phase) {
      ConnectionPhase.connected => (
        Icons.wifi_tethering,
        colors.success,
        l10n.connectionConnected,
      ),
      ConnectionPhase.connecting => (
        Icons.sync,
        scheme.primary,
        l10n.connectionConnecting,
      ),
      ConnectionPhase.reconnecting => (
        Icons.wifi_off,
        colors.warning,
        l10n.connectionReconnecting(
          status.retryIn?.inSeconds ?? 0,
          status.attempt,
        ),
      ),
      ConnectionPhase.disconnected => (
        Icons.wifi_off,
        colors.warning,
        l10n.connectionDisconnected,
      ),
      ConnectionPhase.authFailed => (
        Icons.lock_outline,
        colors.danger,
        l10n.connectionAuthFailed,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
