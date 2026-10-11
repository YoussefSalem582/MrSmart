import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/entity_snapshot.dart';
import '../../domain/entities/room_view.dart';
import '../cubit/room_cubit.dart';
import '../widgets/activity_list.dart';
import '../widgets/connection_banner.dart';
import '../widgets/demo_controls_panel.dart';
import '../widgets/device_card.dart';
import '../widgets/leave_room_sheet.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Background: close the socket. Foreground: reconnect + fresh read.
    _lifecycle = AppLifecycleListener(
      onPause: () => context.read<RoomCubit>().pause(),
      onResume: () => context.read<RoomCubit>().resume(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<RoomCubit>();
    final isDemo = cubit.demo != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.roomTitle),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
            child: Chip(
              label: Text(isDemo ? l10n.modeDemo : l10n.modeHomeAssistant),
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: BlocBuilder<RoomCubit, RoomUiState>(
        builder: (context, state) => _Body(state: state, cubit: cubit),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.cubit});

  final RoomUiState state;
  final RoomCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final view = state.view;
    final demo = cubit.demo;
    final hasControllable = view.devices.any(
      (d) => d.snapshot?.kind.isControllable ?? false,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= AppSpacing.tabletBreakpoint
            ? 2
            : 1;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                ConnectionBanner(status: view.connection),
                if (demo != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.simulatedNotice,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppSemanticColors.of(context).simulated,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Skeletonizer(
                  enabled: view.isLoading,
                  child: _Grid(
                    columns: columns,
                    children: [
                      for (final d
                          in view.isLoading
                              ? _placeholders(view)
                              : view.devices)
                        DeviceCard(
                          key: ValueKey(d.id),
                          device: d,
                          canControl: cubit.canControl(d.id),
                          onToggle: () => cubit.toggle(d.id),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.leaveRoom),
                  onPressed: hasControllable
                      ? () => showLeaveRoomSheet(context)
                      : null,
                ),
                if (demo != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  DemoControlsPanel(demo: demo, devices: view.devices),
                ],
                const SizedBox(height: AppSpacing.lg),
                ActivityList(items: view.activity),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Fake cards with plausible shapes for the skeleton.
  List<DeviceState> _placeholders(RoomView view) => [
    for (final d in view.devices)
      d.snapshot != null
          ? d
          : DeviceState(
              id: d.id,
              snapshot: EntitySnapshot(
                id: d.id,
                name: 'Loading device',
                kind: DeviceKind.light,
                value: const OnOffValue(false),
                isSimulated: false,
              ),
            ),
  ];
}

class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (columns == 1) {
      return Column(
        children: [
          for (final c in children)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: c,
            ),
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - AppSpacing.md * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final c in children) SizedBox(width: width, child: c),
          ],
        );
      },
    );
  }
}
