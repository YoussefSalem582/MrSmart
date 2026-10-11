import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/ha_credentials.dart';
import '../domain/ha_endpoint.dart';

/// Keychain (iOS) / Keystore-backed storage (Android). On iOS the item is
/// readable after first unlock and never leaves this device (no iCloud
/// Keychain sync, not restored to another phone).
class SecureCredentialsStore implements CredentialsRepository {
  const SecureCredentialsStore([
    this._storage = const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  ]);

  static const _urlKey = 'ha_base_url';
  static const _tokenKey = 'ha_access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<HaCredentials?> read() async {
    final url = await _storage.read(key: _urlKey);
    final token = await _storage.read(key: _tokenKey);
    if (url == null || token == null || token.isEmpty) return null;
    return HaCredentials(HaEndpoint.parse(url), token);
  }

  @override
  Future<void> save(HaCredentials credentials) async {
    await _storage.write(key: _urlKey, value: credentials.endpoint.toString());
    await _storage.write(key: _tokenKey, value: credentials.token);
  }

  @override
  Future<void> erase() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _urlKey);
  }
}
