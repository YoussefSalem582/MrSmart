import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/entity_snapshot.dart';
import '../../domain/entities/room_view.dart';
import '../../domain/repositories/demo_controls.dart';

/// Clearly labelled buttons that fake real-world events in demo mode.
class DemoControlsPanel extends StatefulWidget {
  const DemoControlsPanel({
    super.key,
    required this.demo,
    required this.devices,
  });

  final DemoControls demo;
  final List<DeviceState> devices;

  @override
  State<DemoControlsPanel> createState() => _DemoControlsPanelState();
}

class _DemoControlsPanelState extends State<DemoControlsPanel> {
  bool _failArmed = false;
  bool _dropArmed = false;

  @override
  void didUpdateWidget(DemoControlsPanel old) {
    super.didUpdateWidget(old);
    // A command consumed the armed flag once it left the pending state.
    final anyPending = widget.devices.any((d) => d.isPending);
    final hadPending = old.devices.any((d) => d.isPending);
    if (hadPending && !anyPending) {
      _failArmed = false;
      _dropArmed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = AppSemanticColors.of(context).simulated;
    final demo = widget.demo;
    final controllable = widget.devices
        .where((d) => d.snapshot?.kind.isControllable ?? false)
        .toList();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science_outlined, color: color),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.demoControlsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.demoControlsHint, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ActionChip(
                  avatar: Icon(demo.isOnline ? Icons.wifi_off : Icons.wifi),
                  label: Text(
                    demo.isOnline ? l10n.demoGoOffline : l10n.demoGoOnline,
                  ),
                  onPressed: () => _run(() => demo.setOnline(!demo.isOnline)),
                ),
                FilterChip(
                  label: Text(l10n.demoFailNext),
                  selected: _failArmed,
                  onSelected: _failArmed
                      ? null
                      : (_) {
                          demo.failNextCommand();
                          setState(() => _failArmed = true);
                        },
                ),
                FilterChip(
                  label: Text(l10n.demoDropNext),
                  selected: _dropArmed,
                  onSelected: _dropArmed
                      ? null
                      : (_) {
                          demo.dropNextConfirmation();
                          setState(() => _dropArmed = true);
                        },
                ),
                for (final d in controllable)
                  ActionChip(
                    avatar: const Icon(Icons.touch_app_outlined),
                    label: Text(l10n.demoFlip(d.snapshot!.name)),
                    onPressed: () => _run(() => demo.toggleExternally(d.id)),
                  ),
                for (final d in widget.devices.where((d) => d.snapshot != null))
                  ActionChip(
                    avatar: const Icon(Icons.portable_wifi_off),
                    label: Text(
                      demo.isUnavailable(d.id)
                          ? l10n.demoMakeAvailable(d.snapshot!.name)
                          : l10n.demoMakeUnavailable(d.snapshot!.name),
                    ),
                    onPressed: () => _run(
                      () => demo.setUnavailable(
                        d.id,
                        unavailable: !demo.isUnavailable(d.id),
                      ),
                    ),
                  ),
                if (widget.devices.any(
                  (d) => d.snapshot?.kind == DeviceKind.temperature,
                ))
                  ActionChip(
                    avatar: const Icon(Icons.thermostat),
                    label: Text(l10n.demoNudgeTemperature),
                    onPressed: () => _run(demo.nudgeTemperature),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _run(FutureOr<void> Function() action) {
    unawaited(
      Future.sync(action).then((_) => mounted ? setState(() {}) : null),
    );
  }
}
