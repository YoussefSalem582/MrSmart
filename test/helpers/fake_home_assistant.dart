import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mr_smart/core/error/failure.dart';
import 'package:mr_smart/features/home_assistant/data/ha_rest_data_source.dart';
import 'package:mr_smart/features/home_assistant/data/ha_ws_transport.dart';

typedef Json = Map<String, dynamic>;

/// In-memory Home Assistant speaking the documented REST and WebSocket
/// shapes. Good enough to exercise our client; not a real server.
class FakeHomeAssistant {
  FakeHomeAssistant({this.token = 'test-token'});

  final String token;
  final states = <String, Json>{};
  final transports = <FakeHaTransport>[];
  final restCalls = <String>[];
  int connectAttempts = 0;
  bool refuseConnections = false;

  void put(String id, String state, [Json attributes = const {}]) {
    final old = states[id];
    final next = {
      'entity_id': id,
      'state': state,
      'attributes': {'friendly_name': id.split('.').last, ...attributes},
      'last_changed': '2026-10-11T10:00:00+00:00',
      'last_updated': '2026-10-11T10:00:00+00:00',
      'context': {'id': 'x', 'parent_id': null, 'user_id': null},
    };
    states[id] = next;
    _broadcast(id, old, next);
  }

  void remove(String id) => _broadcast(id, states.remove(id), null);

  void dropConnections() {
    for (final t in [...transports]) {
      t.serverClose();
    }
  }

  HaRestDataSource rest({String? withToken}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://ha.test:8123/api/',
        headers: {'Authorization': 'Bearer ${withToken ?? token}'},
      ),
    )..httpClientAdapter = _Adapter(this);
    return HaRestDataSource(dio);
  }

  Future<HaWsTransport> connect(Uri uri) async {
    connectAttempts++;
    if (refuseConnections) throw const NetworkFailure('refused');
    final t = FakeHaTransport(this);
    transports.add(t);
    t._start();
    return t;
  }

  void _broadcast(String id, Json? old, Json? next) {
    for (final t in transports) {
      t._event({
        'event_type': 'state_changed',
        'data': {'entity_id': id, 'old_state': old, 'new_state': next},
        'origin': 'LOCAL',
        'time_fired': '2026-10-11T10:00:00+00:00',
      });
    }
  }
}

class FakeHaTransport implements HaWsTransport {
  FakeHaTransport(this._ha);

  final FakeHomeAssistant _ha;
  final _toClient = StreamController<String>();
  final sent = <Json>[];
  final _subscriptions = <int>{};
  bool closed = false;

  /// Server sends whatever the test wants (e.g. malformed frames).
  void raw(String frame) => _toClient.add(frame);

  void serverClose() {
    if (closed) return;
    closed = true;
    _ha.transports.remove(this);
    _toClient.close();
  }

  @override
  Stream<String> get messages => _toClient.stream;

  @override
  Future<void> close() async => serverClose();

  @override
  void send(String data) {
    final m = jsonDecode(data) as Json;
    sent.add(m);
    final id = m['id'];
    switch (m['type']) {
      case 'auth':
        if (m['access_token'] == _ha.token) {
          _reply({'type': 'auth_ok', 'ha_version': '2026.10.0'});
        } else {
          _reply({'type': 'auth_invalid', 'message': 'Invalid access token'});
          serverClose();
        }
      case 'subscribe_events':
        _subscriptions.add(id as int);
        _reply({'id': id, 'type': 'result', 'success': true, 'result': null});
      case 'unsubscribe_events':
        _subscriptions.remove(m['subscription']);
        _reply({'id': id, 'type': 'result', 'success': true, 'result': null});
      case 'ping':
        _reply({'id': id, 'type': 'pong'});
      default:
        _reply({
          'id': id,
          'type': 'result',
          'success': false,
          'error': {'code': 'unknown_command', 'message': 'Unknown command.'},
        });
    }
  }

  void _start() => _reply({'type': 'auth_required', 'ha_version': '2026.10.0'});

  void _event(Json event) {
    for (final id in _subscriptions) {
      _reply({'id': id, 'type': 'event', 'event': event});
    }
  }

  void _reply(Json m) {
    if (!closed) _toClient.add(jsonEncode(m));
  }
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this._ha);

  final FakeHomeAssistant _ha;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path.replaceFirst('/api/', '');
    _ha.restCalls.add('${options.method} $path');
    if (options.headers['Authorization'] != 'Bearer ${_ha.token}') {
      return _json({'message': '401: Unauthorized'}, 401);
    }
    if (options.method == 'GET' && path == '') {
      return _json({'message': 'API running.'});
    }
    if (options.method == 'GET' && path == 'config') {
      return _json({'version': '2026.10.0', 'location_name': 'Test Home'});
    }
    if (options.method == 'GET' && path == 'states') {
      return _json(_ha.states.values.toList());
    }
    if (options.method == 'GET' && path.startsWith('states/')) {
      final s = _ha.states[path.substring('states/'.length)];
      return s == null
          ? _json({'message': 'Entity not found.'}, 404)
          : _json(s);
    }
    final service = RegExp(
      r'^services/(\w+)/(turn_on|turn_off)$',
    ).firstMatch(path);
    if (options.method == 'POST' && service != null) {
      final id = (options.data as Map)['entity_id'] as String;
      if (!_ha.states.containsKey(id) || !id.startsWith('${service[1]}.')) {
        return _json({'message': 'Service not found.'}, 400);
      }
      _ha.put(id, service[2] == 'turn_on' ? 'on' : 'off');
      // Real HA lists changed states; an empty list is also valid.
      return _json(const []);
    }
    return _json({'message': 'Not found'}, 404);
  }

  ResponseBody _json(Object body, [int status = 200]) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}
