import 'package:equatable/equatable.dart';

import 'ha_endpoint.dart';

class HaCredentials extends Equatable {
  const HaCredentials(this.endpoint, this.token);

  final HaEndpoint endpoint;

  /// Long-lived access token. Secret: never log, never persist outside
  /// secure storage.
  final String token;

  @override
  List<Object?> get props => [endpoint, token];

  @override
  String toString() => 'HaCredentials($endpoint, token: ***)';
}

class HaInstanceInfo extends Equatable {
  const HaInstanceInfo({required this.version, required this.locationName});

  final String version;
  final String locationName;

  @override
  List<Object?> get props => [version, locationName];
}

abstract interface class CredentialsRepository {
  Future<HaCredentials?> read();
  Future<void> save(HaCredentials credentials);
  Future<void> erase();
}

/// Checks that an address + token reach a Home Assistant API.
abstract interface class HaConnectionTester {
  /// Throws a `Failure` describing why the connection does not work.
  Future<HaInstanceInfo> test(HaCredentials credentials);
}
