import '../domain/ha_credentials.dart';
import 'ha_rest_data_source.dart';

class HaConnectionTesterImpl implements HaConnectionTester {
  const HaConnectionTesterImpl(this._restFor);

  final HaRestDataSource Function(HaCredentials) _restFor;

  /// `GET /api/` proves address + token; `GET /api/config` gives a name and
  /// version to show the user.
  @override
  Future<HaInstanceInfo> test(HaCredentials credentials) async {
    final rest = _restFor(credentials);
    await rest.ping();
    final config = await rest.config();
    return HaInstanceInfo(
      version: '${config['version'] ?? '?'}',
      locationName: '${config['location_name'] ?? 'Home Assistant'}',
    );
  }
}
