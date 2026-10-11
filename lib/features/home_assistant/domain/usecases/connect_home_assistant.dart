import '../../../../core/error/failure.dart';
import '../ha_credentials.dart';
import '../ha_endpoint.dart';

/// Validates the address, tests it with the token, and only then stores
/// both in secure storage.
class ConnectHomeAssistant {
  const ConnectHomeAssistant(
    this._tester,
    this._credentials, {
    required this.allowInsecureHttp,
  });

  final HaConnectionTester _tester;
  final CredentialsRepository _credentials;

  /// HTTP is accepted only in debug builds, for a local learning setup.
  final bool allowInsecureHttp;

  Future<HaInstanceInfo> call(String address, String token) async {
    final endpoint = HaEndpoint.parse(address);
    if (!endpoint.isSecure && !allowInsecureHttp) {
      throw const InsecureUrlFailure();
    }
    final trimmed = token.trim();
    if (trimmed.isEmpty) throw const AuthFailure('empty token');
    final credentials = HaCredentials(endpoint, trimmed);
    final info = await _tester.test(credentials);
    await _credentials.save(credentials);
    return info;
  }
}
