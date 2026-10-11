import '../../room/domain/entities/entity_snapshot.dart';

/// Maps a Home Assistant state object to a domain snapshot. Returns null
/// for unsupported or malformed objects instead of throwing.
abstract final class HaStateMapper {
  static EntitySnapshot? toSnapshot(Map<String, dynamic> json) {
    final id = json['entity_id'];
    final state = json['state'];
    if (id is! String || state is! String || !id.contains('.')) return null;
    final rawAttributes = json['attributes'];
    final attributes = rawAttributes is Map ? rawAttributes : const {};

    final kind = switch (id.split('.').first) {
      'light' => DeviceKind.light,
      'switch' => DeviceKind.switchDevice,
      'input_boolean' => DeviceKind.inputBoolean,
      'sensor' when attributes['device_class'] == 'temperature' =>
        DeviceKind.temperature,
      _ => null,
    };
    if (kind == null) return null;

    final name = attributes['friendly_name'];
    return EntitySnapshot(
      id: id,
      name: name is String && name.trim().isNotEmpty ? name : id,
      kind: kind,
      value: _value(kind, state, attributes['unit_of_measurement']),
      isSimulated: false,
    );
  }

  static EntityValue _value(DeviceKind kind, String state, Object? unit) {
    if (state == 'unavailable') return const UnavailableValue();
    if (state == 'unknown') return const UnknownValue();
    if (kind.isControllable) {
      return switch (state) {
        'on' => const OnOffValue(true),
        'off' => const OnOffValue(false),
        _ => const UnknownValue(),
      };
    }
    final number = double.tryParse(state);
    return number == null || !number.isFinite
        ? const UnknownValue()
        : NumericValue(number, unit is String ? unit : null);
  }
}
