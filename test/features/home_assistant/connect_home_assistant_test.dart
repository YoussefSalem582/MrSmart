import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/core/error/failure.dart';
import 'package:mr_smart/core/logging/redaction.dart';
import 'package:mr_smart/features/home_assistant/data/ha_connection_tester_impl.dart';
import 'package:mr_smart/features/home_assistant/domain/ha_credentials.dart';
import 'package:mr_smart/features/home_assistant/domain/ha_endpoint.dart';
import 'package:mr_smart/features/home_assistant/domain/usecases/connect_home_assistant.dart';

import '../../helpers/fake_home_assistant.dart';

class MemoryCredentials implements CredentialsRepository {
  HaCredentials? stored;

  @override
  Future<HaCredentials?> read() async => stored;

  @override
  Future<void> save(HaCredentials c) async => stored = c;

  @override
  Future<void> erase() async => stored = null;
}

void main() {
  late FakeHomeAssistant ha;
  late MemoryCredentials store;

  ConnectHomeAssistant useCase({bool allowHttp = true}) => ConnectHomeAssistant(
    HaConnectionTesterImpl((c) => ha.rest(withToken: c.token)),
    store,
    allowInsecureHttp: allowHttp,
  );

  setUp(() {
    ha = FakeHomeAssistant();
    store = MemoryCredentials();
  });

  test('valid address and token are tested, then stored', () async {
    final info = await useCase()('http://ha.test:8123/', ' test-token ');
    expect(info.locationName, 'Test Home');
    expect(store.stored!.token, 'test-token');
  });

  test(
    'a wrong token is reported as AuthFailure and nothing is stored',
    () async {
      await expectLater(
        useCase()('http://ha.test:8123', 'nope'),
        throwsA(isA<AuthFailure>()),
      );
      expect(store.stored, isNull);
    },
  );

  test('release builds refuse plain HTTP before sending the token', () async {
    await expectLater(
      useCase(allowHttp: false)('http://ha.test:8123', 'test-token'),
      throwsA(isA<InsecureUrlFailure>()),
    );
    expect(ha.restCalls, isEmpty);
  });

  test('tokens never survive redaction or toString', () {
    // Fake JWT shape for the redaction test; not a real token.
    const jwt =
        'eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJhYmNkZWYxMjM0NTYifQ.c2lnbmF0dXJlMTIzNDU2'; // public-ok
    expect(redact('Authorization: Bearer $jwt'), isNot(contains(jwt)));
    expect(redact('{"access_token":"$jwt"}'), isNot(contains(jwt)));
    expect(redact('token was $jwt'), isNot(contains(jwt)));
    expect(
      HaCredentials(HaEndpoint.parse('http://ha.test:8123'), jwt).toString(),
      isNot(contains(jwt)),
    );
  });
}
