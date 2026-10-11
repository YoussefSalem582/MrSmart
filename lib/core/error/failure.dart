/// Domain errors. Data sources translate transport exceptions (Dio,
/// sockets, TLS) into one of these; presentation maps them to text.
sealed class Failure implements Exception {
  const Failure([this.detail]);

  /// Technical detail for logs. Never contains credentials.
  final String? detail;

  @override
  String toString() => '$runtimeType${detail == null ? '' : ': $detail'}';
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.detail]);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.detail]);
}

final class TlsFailure extends Failure {
  const TlsFailure([super.detail]);
}

/// Token missing, wrong or revoked (HTTP 401 / WebSocket auth_invalid).
final class AuthFailure extends Failure {
  const AuthFailure([super.detail]);
}

/// Authenticated but not allowed (HTTP 403 / `unauthorized` result).
final class PermissionFailure extends Failure {
  const PermissionFailure([super.detail]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.detail]);
}

final class InvalidUrlFailure extends Failure {
  const InvalidUrlFailure([super.detail]);
}

/// HTTP refused because this build only allows HTTPS.
final class InsecureUrlFailure extends Failure {
  const InsecureUrlFailure([super.detail]);
}

final class NotConnectedFailure extends Failure {
  const NotConnectedFailure([super.detail]);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.detail]);
}

/// Raised on purpose by the demo's "fail next command" control.
final class SimulatedFailure extends Failure {
  const SimulatedFailure([super.detail]);
}
