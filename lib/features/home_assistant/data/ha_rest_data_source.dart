import 'package:dio/dio.dart';

import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/ha_credentials.dart';
import 'ha_failure_mapper.dart';
import 'json.dart';

/// Home Assistant REST API (developers.home-assistant.io/docs/api/rest).
/// Used for the initial read, fresh reads and service calls.
class HaRestDataSource {
  HaRestDataSource(this._dio);

  /// Builds the Dio client for [credentials]. TLS validation is left at
  /// the platform default and is never disabled.
  factory HaRestDataSource.forCredentials(HaCredentials credentials) {
    final dio = Dio(
      BaseOptions(
        baseUrl: credentials.endpoint.restBase.toString(),
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Authorization': 'Bearer ${credentials.token}'},
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) {
          // Method, path and status only: no headers, no bodies.
          AppLogger.warning(
            'HA REST ${e.requestOptions.method} ${e.requestOptions.path} '
            '→ ${e.response?.statusCode ?? e.type.name}',
          );
          handler.next(e);
        },
      ),
    );
    return HaRestDataSource(dio);
  }

  static final _entityId = RegExp(r'^[a-z0-9_]+\.[a-z0-9_]+$');

  final Dio _dio;

  /// `GET /api/` → `{"message": "API running."}`
  Future<void> ping() => _guard(() async {
    final res = await _dio.get<Object?>('');
    final body = res.data;
    if (body is! Map || body['message'] is! String) {
      throw const ServerFailure('not a Home Assistant API');
    }
  });

  /// `GET /api/config`
  Future<Json> config() => _guard(() async {
    final res = await _dio.get<Object?>('config');
    return _asJson(res.data);
  });

  /// `GET /api/states`
  Future<List<Json>> states() => _guard(() async {
    final res = await _dio.get<Object?>('states');
    return _asJsonList(res.data);
  });

  /// `GET /api/states/<entity_id>`; null when the entity does not exist.
  Future<Json?> state(String entityId) => _guard(() async {
    _checkId(entityId);
    try {
      final res = await _dio.get<Object?>('states/$entityId');
      return _asJson(res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  });

  /// `POST /api/services/<domain>/<service>` with `{"entity_id": …}`.
  /// Returns the states Home Assistant reports as changed during the call.
  /// A 200 here means "accepted", not "the device is now in that state".
  Future<List<Json>> callService(
    String domain,
    String service,
    String entityId,
  ) => _guard(() async {
    _checkId(entityId);
    final res = await _dio.post<Object?>(
      'services/$domain/$service',
      data: {'entity_id': entityId},
    );
    return _asJsonList(res.data);
  });

  void _checkId(String id) {
    if (!_entityId.hasMatch(id)) throw const NotFoundFailure('bad entity id');
  }

  Json _asJson(Object? data) {
    if (data is Map<String, dynamic>) return data;
    throw const ServerFailure('malformed response');
  }

  List<Json> _asJsonList(Object? data) {
    if (data is! List) throw const ServerFailure('malformed response');
    return [
      for (final e in data)
        if (e is Map<String, dynamic>) e,
    ];
  }

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } catch (e) {
      throw mapTransportError(e);
    }
  }
}
