import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/core/logging/redaction.dart';

void main() {
  // Fake values shaped like secrets. public-ok
  const jwt =
      'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0ZXN0LXVzZXIifQ.ZmFrZS1zaWduYXR1cmU'; // public-ok

  test('masks bearer credentials, secret JSON fields and JWTs', () {
    expect(redact('Authorization: Bearer $jwt'), isNot(contains(jwt)));
    expect(
      redact('{"access_token": "$jwt"}'),
      contains('"access_token": "eyJh…[redacted]"'),
    );
    expect(redact('{"password":"hunter2"}'), '{"password":"[redacted]"}');
    expect(redact('token was $jwt here'), isNot(contains(jwt)));
  });

  test('leaves ordinary text alone', () {
    const text = 'GET states/light.desk → 404';
    expect(redact(text), text);
  });
}
