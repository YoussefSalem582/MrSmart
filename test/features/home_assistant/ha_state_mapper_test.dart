import 'package:flutter_test/flutter_test.dart';
import 'package:mr_smart/features/home_assistant/data/ha_state_mapper.dart';
import 'package:mr_smart/features/room/domain/entities/entity_snapshot.dart';

void main() {
  Map<String, dynamic> state(String id, String s, [Map<String, dynamic>? a]) =>
      {'entity_id': id, 'state': s, 'attributes': a ?? {}};

  test('maps supported domains and special states', () {
    expect(
      HaStateMapper.toSnapshot(
        state('light.desk', 'on', {'friendly_name': 'Desk'}),
      ),
      isA<EntitySnapshot>()
          .having((s) => s.name, 'name', 'Desk')
          .having((s) => s.value, 'value', const OnOffValue(true))
          .having((s) => s.isSimulated, 'simulated', false),
    );
    expect(
      HaStateMapper.toSnapshot(state('switch.plug', 'unavailable'))!.value,
      const UnavailableValue(),
    );
    expect(
      HaStateMapper.toSnapshot(state('input_boolean.x', 'unknown'))!.value,
      const UnknownValue(),
    );
  });

  test('temperature keeps the reported unit and tolerates non-numbers', () {
    final attrs = {'device_class': 'temperature', 'unit_of_measurement': '°F'};
    expect(
      HaStateMapper.toSnapshot(state('sensor.t', '71.6', attrs))!.value,
      const NumericValue(71.6, '°F'),
    );
    expect(
      HaStateMapper.toSnapshot(state('sensor.t', 'n/a', attrs))!.value,
      const UnknownValue(),
    );
  });

  test('ignores unsupported and malformed objects', () {
    expect(HaStateMapper.toSnapshot(state('lock.front', 'locked')), isNull);
    expect(HaStateMapper.toSnapshot(state('sensor.humidity', '40')), isNull);
    expect(HaStateMapper.toSnapshot({'entity_id': 3}), isNull);
    expect(HaStateMapper.toSnapshot({'state': 'on'}), isNull);
  });
}
