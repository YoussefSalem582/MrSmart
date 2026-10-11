import 'package:equatable/equatable.dart';

/// Kinds of entity this MVP supports. Anything else is ignored.
enum DeviceKind {
  light('light'),
  switchDevice('switch'),
  inputBoolean('input_boolean'),
  temperature('sensor');

  const DeviceKind(this.domain);

  /// Home Assistant domain, i.e. the part of the entity id before the dot.
  final String domain;

  bool get isControllable => this != DeviceKind.temperature;
}

/// What an entity reported. `unknown` and `unavailable` are Home Assistant's
/// special state values and are never treated as on/off.
sealed class EntityValue extends Equatable {
  const EntityValue();

  @override
  List<Object?> get props => [];
}

final class OnOffValue extends EntityValue {
  const OnOffValue(this.isOn);
  final bool isOn;

  @override
  List<Object?> get props => [isOn];
}

final class NumericValue extends EntityValue {
  const NumericValue(this.value, this.unit);
  final double value;

  /// Unit exactly as reported (e.g. °C, °F). Null when the source omits it.
  final String? unit;

  @override
  List<Object?> get props => [value, unit];
}

final class UnknownValue extends EntityValue {
  const UnknownValue();
}

final class UnavailableValue extends EntityValue {
  const UnavailableValue();
}

/// One entity's state as reported by the source (simulator or Home
/// Assistant). This is Home Assistant's view of the device, not proof of
/// what the physical device is doing.
class EntitySnapshot extends Equatable {
  const EntitySnapshot({
    required this.id,
    required this.name,
    required this.kind,
    required this.value,
    required this.isSimulated,
  });

  final String id;
  final String name;
  final DeviceKind kind;
  final EntityValue value;
  final bool isSimulated;

  bool? get isOn => switch (value) {
    OnOffValue(:final isOn) => isOn,
    _ => null,
  };

  EntitySnapshot copyWith({EntityValue? value, String? name}) => EntitySnapshot(
    id: id,
    name: name ?? this.name,
    kind: kind,
    value: value ?? this.value,
    isSimulated: isSimulated,
  );

  @override
  List<Object?> get props => [id, name, kind, value, isSimulated];
}

/// A change pushed by the source.
sealed class EntityUpdate {
  const EntityUpdate();
}

final class EntityChanged extends EntityUpdate {
  const EntityChanged(this.snapshot);
  final EntitySnapshot snapshot;
}

final class EntityRemoved extends EntityUpdate {
  const EntityRemoved(this.entityId);
  final String entityId;
}
