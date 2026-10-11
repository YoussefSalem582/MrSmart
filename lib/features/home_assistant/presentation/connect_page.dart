import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/failure_l10n.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../session/presentation/session_cubit.dart';
import 'connect_cubit.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _token = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _address.dispose();
    _token.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ConnectCubit>().submit(_address.text, _token.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppSemanticColors.of(context);

    return BlocConsumer<ConnectCubit, ConnectState>(
      listenWhen: (a, b) =>
          a.status != b.status || a.storedAddress != b.storedAddress,
      listener: (context, state) async {
        if (state.storedAddress != null && _address.text.isEmpty) {
          _address.text = state.storedAddress!;
        }
        if (state.status == ConnectStatus.success) {
          _token.clear();
          await context.read<SessionCubit>().startHomeAssistant();
          if (context.mounted) context.go(Routes.select);
        }
      },
      builder: (context, state) {
        final testing = state.status == ConnectStatus.testing;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.connectTitle)),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Text(l10n.connectIntro, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _address,
                      enabled: !testing,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: l10n.haUrlLabel,
                        hintText: l10n.haUrlHint,
                        prefixIcon: const Icon(Icons.link),
                      ),
                      onChanged: context.read<ConnectCubit>().addressChanged,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.failureInvalidUrl
                          : null,
                    ),
                    AnimatedSize(
                      duration: AppMotion.normal,
                      child: state.isInsecure
                          ? _Notice(
                              icon: Icons.lock_open,
                              color: colors.warning,
                              text: l10n.insecureHttpWarning,
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _token,
                      enabled: !testing,
                      obscureText: _obscure,
                      autocorrect: false,
                      enableSuggestions: false,
                      enableIMEPersonalizedLearning: false,
                      keyboardType: TextInputType.visiblePassword,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        labelText: l10n.haTokenLabel,
                        prefixIcon: const Icon(Icons.key),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? l10n.showToken : l10n.hideToken,
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.haTokenRequired
                          : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(l10n.haTokenHelp, style: theme.textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.xl),
                    if (state.status == ConnectStatus.failure &&
                        state.failure != null)
                      _Notice(
                        icon: Icons.error_outline,
                        color: colors.danger,
                        text: state.failure!.message(l10n),
                      ),
                    if (state.status == ConnectStatus.success &&
                        state.info != null)
                      _Notice(
                        icon: Icons.check_circle_outline,
                        color: colors.success,
                        text: l10n.connectedTo(
                          state.info!.locationName,
                          state.info!.version,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      icon: testing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.wifi_tethering),
                      label: Text(testing ? l10n.testing : l10n.testAndSave),
                      onPressed: testing ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.sm),
    child: Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
