import 'dart:async';
import 'dart:convert';

import '../../../core/error/failure.dart';
import '../../../core/logging/app_logger.dart';
import 'ha_ws_transport.dart';
import 'json.dart';

/// One authenticated Home Assistant WebSocket session
/// (developers.home-assistant.io/docs/api/websocket).
///
/// * Auth: `auth_required` → `auth` → `auth_ok` | `auth_invalid`.
/// * Every command gets a unique, increasing integer `id`; `result` and
///   `pong` messages are matched back to their request by that id.
/// * `event` messages carry the id of the subscription that produced them.
/// * Malformed frames are logged and ignored.
///
/// It never reconnects; [HaRoomRepository] owns that.
class HaSocket {
  HaSocket._(this._transport, this._token, this._timeout);

  /// Connects and authenticates. Throws [AuthFailure] on a rejected
  /// token, [TimeoutFailure] if the handshake stalls.
  static Future<HaSocket> open({
    required HaWsTransport transport,
    required String token,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final socket = HaSocket._(transport, token, timeout).._listen();
    try {
      await socket._authenticated.future.timeout(
        timeout,
        onTimeout: () => throw const TimeoutFailure('auth handshake'),
      );
    } catch (_) {
      await socket.close();
      rethrow;
    }
    return socket;
  }

  final HaWsTransport _transport;
  final Duration _timeout;
  String? _token;

  final _authenticated = Completer<void>();
  final _done = Completer<void>();
  final _pending = <int, Completer<Object?>>{};
  final _subscriptions = <int, StreamController<Json>>{};
  StreamSubscription<String>? _inbound;
  int _nextId = 1;
  bool _closed = false;

  String? haVersion;

  /// Completes when the socket closes for any reason.
  Future<void> get done => _done.future;

  /// Sends [command] and waits for its `result` (or `pong`).
  Future<Object?> request(Map<String, Object?> command) =>
      _request(_nextId++, command);

  Future<void> ping() => request({'type': 'ping'});

  /// `subscribe_events`; returns the subscription id and its event stream.
  Future<(int, Stream<Json>)> subscribeEvents(String eventType) async {
    final id = _nextId++;
    final events = StreamController<Json>.broadcast();
    _subscriptions[id] = events;
    try {
      await _request(id, {'type': 'subscribe_events', 'event_type': eventType});
    } catch (_) {
      _subscriptions.remove(id);
      await events.close();
      rethrow;
    }
    return (id, events.stream);
  }

  Future<void> unsubscribe(int subscriptionId) async {
    final events = _subscriptions.remove(subscriptionId);
    if (!_closed) {
      try {
        await request({
          'type': 'unsubscribe_events',
          'subscription': subscriptionId,
        });
      } on Failure {
        // Closing anyway; the server drops subscriptions with the socket.
      }
    }
    await events?.close();
  }

  Future<void> close() async {
    _shutdown(const NotConnectedFailure('closed'));
    await _transport.close();
  }

  void _listen() {
    _inbound = _transport.messages.listen(
      _onFrame,
      onError: (Object e) => _shutdown(const NetworkFailure('socket error')),
      onDone: () => _shutdown(const NetworkFailure('socket closed')),
    );
  }

  Future<Object?> _request(int id, Map<String, Object?> command) {
    if (_closed) return Future.error(const NotConnectedFailure());
    final completer = Completer<Object?>();
    _pending[id] = completer;
    _transport.send(jsonEncode({...command, 'id': id}));
    return completer.future.timeout(
      _timeout,
      onTimeout: () {
        _pending.remove(id);
        throw TimeoutFailure('${command['type']}');
      },
    );
  }

  void _onFrame(String frame) {
    final Object? decoded;
    try {
      decoded = jsonDecode(frame);
    } on FormatException {
      AppLogger.warning('HA WS: ignored non-JSON frame');
      return;
    }
    // With coalescing, the server may batch messages in a JSON array.
    for (final message in decoded is List ? decoded : [decoded]) {
      if (message is Json) {
        _onMessage(message);
      } else {
        AppLogger.warning('HA WS: ignored malformed message');
      }
    }
  }

  void _onMessage(Json m) {
    final id = m['id'];
    switch (m['type']) {
      case 'auth_required':
        final token = _token;
        if (token != null) {
          _transport.send(jsonEncode({'type': 'auth', 'access_token': token}));
        }
      case 'auth_ok':
        _token = null; // no longer needed in memory here
        haVersion = m['ha_version'] as String?;
        if (!_authenticated.isCompleted) _authenticated.complete();
      case 'auth_invalid':
        _token = null;
        if (!_authenticated.isCompleted) {
          _authenticated.completeError(const AuthFailure('auth_invalid'));
        }
      case 'result' when id is int:
        final completer = _pending.remove(id);
        if (completer == null) return;
        if (m['success'] == true) {
          completer.complete(m['result']);
        } else {
          completer.completeError(_resultError(m['error']));
        }
      case 'pong' when id is int:
        _pending.remove(id)?.complete(null);
      case 'event' when id is int:
        final event = m['event'];
        if (event is Json) _subscriptions[id]?.add(event);
      default:
        AppLogger.warning('HA WS: ignored message type ${m['type']}');
    }
  }

  Failure _resultError(Object? error) {
    final code = error is Map ? error['code'] : null;
    return switch (code) {
      'unauthorized' => const PermissionFailure(),
      'not_found' => const NotFoundFailure(),
      'timeout' => const TimeoutFailure(),
      _ => ServerFailure('$code'),
    };
  }

  void _shutdown(Failure reason) {
    if (_closed) return;
    _closed = true;
    _token = null;
    unawaited(_inbound?.cancel());
    if (!_authenticated.isCompleted) _authenticated.completeError(reason);
    for (final c in _pending.values) {
      c.completeError(reason);
    }
    _pending.clear();
    for (final s in _subscriptions.values) {
      unawaited(s.close());
    }
    _subscriptions.clear();
    if (!_done.isCompleted) _done.complete();
  }
}
