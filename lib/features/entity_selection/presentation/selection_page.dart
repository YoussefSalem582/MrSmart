import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/error/failure_l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../room/domain/entities/entity_snapshot.dart';
import '../../room/presentation/widgets/room_formatters.dart';
import '../../session/presentation/session_cubit.dart';
import 'selection_cubit.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppSemanticColors.of(context);
    final locale = Localizations.localeOf(context);

    return BlocBuilder<SelectionCubit, SelectionState>(
      builder: (context, state) {
        final cubit = context.read<SelectionCubit>();
        final entities = state.isLoading ? _placeholders : state.entities;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.selectTitle)),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: FilledButton(
                onPressed: state.selected.isEmpty
                    ? null
                    : () async {
                        await cubit.save();
                        if (!context.mounted) return;
                        await context
                            .read<SessionCubit>()
                            .roomSelectionChanged();
                        if (context.mounted) context.go(Routes.room);
                      },
                child: Text(l10n.selectSave(state.selected.length)),
              ),
            ),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.health_and_safety, color: colors.warning),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text(l10n.selectSafety)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.selectHint, style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.lg),
                  if (state.failure != null) ...[
                    Text(
                      state.failure!.message(l10n),
                      style: TextStyle(color: colors.danger),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: cubit.load,
                      child: Text(l10n.retry),
                    ),
                  ] else if (!state.isLoading && entities.isEmpty)
                    Text(l10n.selectEmpty)
                  else
                    Skeletonizer(
                      enabled: state.isLoading,
                      child: Column(
                        children: [
                          for (final e in entities)
                            CheckboxListTile(
                              value: state.selected.contains(e.id),
                              onChanged: state.isLoading
                                  ? null
                                  : (_) => cubit.toggle(e.id),
                              secondary: Icon(kindIcon(e.kind)),
                              title: Text(e.name),
                              subtitle: Text(
                                '${l10n.kindText(e.kind)} · '
                                '${l10n.valueText(e.value, locale)}\n${e.id}',
                              ),
                              isThreeLine: true,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static final _placeholders = [
    for (var i = 0; i < 4; i++)
      EntitySnapshot(
        id: 'light.placeholder_$i',
        name: 'Loading entity name',
        kind: DeviceKind.light,
        value: const OnOffValue(false),
        isSimulated: false,
      ),
  ];
}
