import '../../l10n/generated/app_localizations.dart';
import 'failure.dart';

extension FailureL10n on Failure {
  String message(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.failureNetwork,
    TimeoutFailure() => l10n.failureTimeout,
    TlsFailure() => l10n.failureTls,
    AuthFailure() => l10n.failureAuth,
    PermissionFailure() => l10n.failurePermission,
    NotFoundFailure() => l10n.failureNotFound,
    InvalidUrlFailure() => l10n.failureInvalidUrl,
    InsecureUrlFailure() => l10n.failureInsecureUrl,
    NotConnectedFailure() => l10n.failureNotConnected,
    ServerFailure() => l10n.failureServer,
    SimulatedFailure() => l10n.failureSimulated,
  };
}
