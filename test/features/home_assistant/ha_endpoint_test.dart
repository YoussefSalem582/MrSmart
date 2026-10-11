import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/core/error/failure.dart';
import 'package:mr_smart/features/home_assistant/domain/ha_endpoint.dart';

void main() {
  test('normalizes common inputs and maps http→ws, https→wss', () {
    final cases = {
      'http://homeassistant.local:8123': (
        'http://homeassistant.local:8123/api/',
        'ws://homeassistant.local:8123/api/websocket',
      ),
      ' https://ha.example.org/ ': (
        'https://ha.example.org/api/',
        'wss://ha.example.org/api/websocket',
      ),
      'http://192.168.1.20:8123/api': (
        'http://192.168.1.20:8123/api/',
        'ws://192.168.1.20:8123/api/websocket',
      ),
      'ws://192.168.1.20:8123/api/websocket': (
        'http://192.168.1.20:8123/api/',
        'ws://192.168.1.20:8123/api/websocket',
      ),
      'https://proxy.example.org/ha//': (
        'https://proxy.example.org/ha/api/',
        'wss://proxy.example.org/ha/api/websocket',
      ),
    };
    cases.forEach((input, expected) {
      final e = HaEndpoint.parse(input);
      expect(e.restBase.toString(), expected.$1, reason: input);
      expect(e.websocket.toString(), expected.$2, reason: input);
    });
  });

  test('missing scheme defaults to https', () {
    final e = HaEndpoint.parse('homeassistant.local:8123');
    expect(e.isSecure, isTrue);
    expect(e.websocket.scheme, 'wss');
  });

  test('rejects garbage, other schemes and credentials in the URL', () {
    for (final bad in [
      '',
      '   ',
      'ftp://ha.local',
      'http://',
      'http://u:p@ha.local',
    ]) {
      expect(() => HaEndpoint.parse(bad), throwsA(isA<InvalidUrlFailure>()));
    }
  });
}
