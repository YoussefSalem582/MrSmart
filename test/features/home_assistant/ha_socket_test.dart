import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/core/error/failure.dart';
import 'package:mr_smart/features/home_assistant/data/ha_socket.dart';
import 'package:mr_smart/features/home_assistant/data/ha_ws_transport.dart';

/// Transport where the test plays the server by hand.
class ScriptedTransport implements HaWsTransport {
  final toClient = StreamController<String>();
  final sent = <Map<String, dynamic>>[];
  final _sentEvents = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onSent => _sentEvents.stream;

  void server(Object message) => toClient.add(jsonEncode(message));

  @override
  Stream<String> get messages => toClient.stream;

  @override
  void send(String data) {
    final m = jsonDecode(data) as Map<String, dynamic>;
    sent.add(m);
    _sentEvents.add(m);
  }

  @override
  Future<void> close() async {
    if (!toClient.isClosed) await toClient.close();
  }
}

Future<HaSocket> authenticated(ScriptedTransport t) async {
  final opening = HaSocket.open(
    transport: t,
    token: 'secret',
    timeout: const Duration(milliseconds: 200),
  );
  t.server({'type': 'auth_required', 'ha_version': '2026.10.0'});
  await pumpEventQueue();
  expect(t.sent.single, {'type': 'auth', 'access_token': 'secret'});
  t.server({'type': 'auth_ok', 'ha_version': '2026.10.0'});
  return opening;
}

void main() {
  test('auth_invalid fails with AuthFailure', () async {
    final t = ScriptedTransport();
    final opening = HaSocket.open(transport: t, token: 'bad');
    t
      ..server({'type': 'auth_required'})
      ..server({'type': 'auth_invalid', 'message': 'Invalid access token'});
    await expectLater(opening, throwsA(isA<AuthFailure>()));
  });

  test('unique increasing ids; out-of-order results reach the right '
      'caller', () async {
    final t = ScriptedTransport();
    final socket = await authenticated(t);
    final a = socket.request({'type': 'get_config'});
    final b = socket.request({'type': 'get_states'});
    await pumpEventQueue();
    final ids = t.sent.skip(1).map((m) => m['id']).toList();
    expect(ids, [1, 2]);

    t
      ..server({'id': 2, 'type': 'result', 'success': true, 'result': 'B'})
      ..server({'id': 1, 'type': 'result', 'success': true, 'result': 'A'});
    expect(await a, 'A');
    expect(await b, 'B');
  });

  test('error results map to domain failures', () async {
    final t = ScriptedTransport();
    final socket = await authenticated(t);
    final call = socket.request({'type': 'call_service'});
    await pumpEventQueue();
    t.server({
      'id': 1,
      'type': 'result',
      'success': false,
      'error': {'code': 'unauthorized', 'message': 'Unauthorized'},
    });
    await expectLater(call, throwsA(isA<PermissionFailure>()));
  });

  test('a request without a reply times out', () async {
    final t = ScriptedTransport();
    final socket = await authenticated(t);
    await expectLater(
      socket.request({'type': 'ping'}),
      throwsA(isA<TimeoutFailure>()),
    );
  });

  test(
    'malformed frames are ignored; events reach their subscription',
    () async {
      final t = ScriptedTransport();
      final socket = await authenticated(t);
      final subscribing = socket.subscribeEvents('state_changed');
      await pumpEventQueue();
      final subId = t.sent.last['id'];
      t.server({
        'id': subId,
        'type': 'result',
        'success': true,
        'result': null,
      });
      final (_, events) = await subscribing;
      final received = events.first;

      t.toClient
        ..add('not json')
        ..add('42');
      t.server({
        'id': subId,
        'type': 'event',
        'event': {
          'event_type': 'state_changed',
          'data': {'entity_id': 'light.a'},
        },
      });
      expect((await received)['event_type'], 'state_changed');
    },
  );

  test('server close fails pending requests and completes done', () async {
    final t = ScriptedTransport();
    final socket = await authenticated(t);
    final pending = socket.request({'type': 'get_states'});
    await t.close();
    await expectLater(pending, throwsA(isA<Failure>()));
    await socket.done;
  });
}
