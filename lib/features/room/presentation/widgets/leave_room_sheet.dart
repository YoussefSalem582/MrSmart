import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/leave_room_report.dart';
import '../cubit/room_cubit.dart';

Future<void> showLeaveRoomSheet(BuildContext context) {
  final cubit = context.read<RoomCubit>()..clearLeaveReport();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _LeaveRoomSheet()),
  );
}

class _LeaveRoomSheet extends StatelessWidget {
  const _LeaveRoomSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: BlocBuilder<RoomCubit, RoomUiState>(
          builder: (context, state) {
            final report = state.leaveReport;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.leaveRoom, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.leaveRoomExplain, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                if (state.isLeaving) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.leaveRoomRunning),
                ] else if (report != null)
                  _Report(report: report)
                else
                  FilledButton.icon(
                    icon: const Icon(Icons.power_settings_new),
                    label: Text(l10n.leaveRoomConfirm),
                    onPressed: () => context.read<RoomCubit>().leaveRoom(),
                  ),
                if (report != null || !state.isLeaving) ...[
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(report == null ? l10n.cancel : l10n.close),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Report extends StatelessWidget {
  const _Report({required this.report});

  final LeaveRoomReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppSemanticColors.of(context);
    final theme = Theme.of(context);
    final (summary, color) = report.notConnected
        ? (l10n.leaveRoomNotConnected, colors.warning)
        : report.entries.isEmpty
        ? (l10n.leaveRoomNothing, theme.colorScheme.onSurfaceVariant)
        : report.allOff
        ? (l10n.leaveRoomAllOff, colors.success)
        : (l10n.leaveRoomPartial, colors.warning);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            summary,
            style: theme.textTheme.titleSmall?.copyWith(color: color),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final e in report.entries)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(_icon(e.outcome), color: _color(e.outcome, colors)),
            title: Text(e.name),
            trailing: Text(_label(e.outcome, l10n)),
          ),
      ],
    );
  }

  IconData _icon(LeaveOutcome o) => switch (o) {
    LeaveOutcome.confirmed || LeaveOutcome.alreadyOff => Icons.check_circle,
    LeaveOutcome.failed => Icons.error,
    LeaveOutcome.unconfirmed => Icons.help,
    LeaveOutcome.skipped => Icons.remove_circle_outline,
  };

  Color _color(LeaveOutcome o, AppSemanticColors c) => switch (o) {
    LeaveOutcome.confirmed || LeaveOutcome.alreadyOff => c.success,
    LeaveOutcome.failed => c.danger,
    LeaveOutcome.unconfirmed || LeaveOutcome.skipped => c.warning,
  };

  String _label(LeaveOutcome o, AppLocalizations l10n) => switch (o) {
    LeaveOutcome.confirmed => l10n.leaveOutcomeConfirmed,
    LeaveOutcome.alreadyOff => l10n.leaveOutcomeAlreadyOff,
    LeaveOutcome.failed => l10n.leaveOutcomeFailed,
    LeaveOutcome.unconfirmed => l10n.leaveOutcomeUnconfirmed,
    LeaveOutcome.skipped => l10n.leaveOutcomeSkipped,
  };
}
