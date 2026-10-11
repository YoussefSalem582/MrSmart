import 'dart:async';

import '../../domain/entities/connection_status.dart';
import '../../domain/entities/entity_snapshot.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/demo_controls.dart';
import '../../domain/repositories/room_backend.dart';

/// A simulated room. Same contract as Home Assistant, no network.
///
/// Deterministic: fixed devices, fixed temperature sequence, configurable
/// latency (zero in tests). Every snapshot is flagged `isSimulated`.
class DemoRoomRepository implements RoomBackend, DemoControls {
  DemoRoomRepository({
    this.latency = const Duration(milliseconds: 400),
    this.driftInterval = const Duration(seconds: 20),
  }) {
    _values.addAll(_initialValues);
  }

  static const lightId = 'light.demo_desk_lamp';
  static const plugId = 'switch.demo_fan_plug';
  static const temperatureId = 'sensor.demo_room_temperature';
  static const entityIds = [lightId, plugId, temperatureId];

  static const _names = {
    lightId: 'Desk lamp',
    plugId: 'Fan plug',
    temperatureId: 'Room temperature',
  };
  static const _kinds = {
    lightId: DeviceKind.light,
    plugId: DeviceKind.switchDevice,
    temperatureId: DeviceKind.temperature,
  };
  static const _initialValues = <String, EntityValue>{
    lightId: OnOffValue(true),
    plugId: OnOffValue(false),
    temperatureId: NumericValue(22.5, '°C'),
  };

  /// Repeating drift so readings change without randomness.
  static const _drift = [0.2, 0.1, -0.1, 0.3, -0.2, -0.3];

  final Duration latency;

  /// Zero disables the automatic temperature drift.
  final Duration driftInterval;

  final _values = <String, EntityValue>{};
  final _unavailable = <String>{};
  final _connection = StreamController<ConnectionStatus>.broadcast();
  final _updates = StreamController<EntityUpdate>.broadcast();
  Set<String> _watched = {};
  bool _online = false;
  bool _failNext = false;
  bool _dropNext = false;
  int _driftStep = 0;
  Timer? _driftTimer;

  @override
  Stream<ConnectionStatus> get connection => _connection.stream;

  @override
  Stream<EntityUpdate> get updates => _updates.stream;

  @override
  bool get isOnline => _online;

  @override
  Future<void> connect(Set<String> entityIds) async {
    _watched = entityIds;
    _connection.add(const ConnectionStatus.connecting());
    await _delay();
    _online = true;
    _connection.add(const ConnectionStatus.connected());
    _driftTimer?.cancel();
    if (driftInterval > Duration.zero) {
      _driftTimer = Timer.periodic(driftInterval, (_) => nudgeTemperature());
    }
  }

  @override
  Future<void> disconnect() async {
    _driftTimer?.cancel();
    if (!_online) return;
    _online = false;
    _connection.add(const ConnectionStatus.disconnected());
  }

  @override
  Future<List<EntitySnapshot>> fetchStates(Set<String> entityIds) async {
    _requireOnline();
    await _delay();
    _requireOnline();
    return [
      for (final id in entityIds)
        if (_values.containsKey(id)) _snapshot(id),
    ];
  }

  @override
  Future<List<EntitySnapshot>> listSupportedEntities() async => [
    for (final id in entityIds) _snapshot(id),
  ];

  @override
  Future<List<EntitySnapshot>> setPower(
    String entityId,
    DeviceKind kind, {
    required bool on,
  }) async {
    _requireOnline();
    await _delay();
    _requireOnline();
    if (_failNext) {
      _failNext = false;
      throw const SimulatedFailure('fail-next-command control');
    }
    if (!_values.containsKey(entityId)) throw const NotFoundFailure();
    if (_unavailable.contains(entityId)) {
      throw const ServerFailure('device unavailable');
    }
    if (_dropNext) {
      // Accepted, but the device never reports back.
      _dropNext = false;
      return const [];
    }
    _set(entityId, OnOffValue(on));
    return const [];
  }

  @override
  Future<void> setOnline(bool online) =>
      online ? connect(_watched) : disconnect();

  @override
  void failNextCommand() => _failNext = true;

  @override
  void dropNextConfirmation() => _dropNext = true;

  @override
  void toggleExternally(String entityId) {
    final v = _values[entityId];
    if (v is OnOffValue) _set(entityId, OnOffValue(!v.isOn));
  }

  @override
  void setUnavailable(String entityId, {required bool unavailable}) {
    unavailable ? _unavailable.add(entityId) : _unavailable.remove(entityId);
    _publish(entityId);
  }

  @override
  bool isUnavailable(String entityId) => _unavailable.contains(entityId);

  @override
  void nudgeTemperature() {
    final v = _values[temperatureId];
    if (v is! NumericValue) return;
    final next = v.value + _drift[_driftStep++ % _drift.length];
    _set(temperatureId, NumericValue((next * 10).round() / 10, v.unit));
  }

  @override
  Future<void> dispose() async {
    _driftTimer?.cancel();
    _online = false;
    await _connection.close();
    await _updates.close();
  }

  void _set(String id, EntityValue value) {
    _values[id] = value;
    _publish(id);
  }

  /// State changes only reach the app while it is "online", like a real
  /// event stream.
  void _publish(String id) {
    if (_online && _watched.contains(id) && !_updates.isClosed) {
      _updates.add(EntityChanged(_snapshot(id)));
    }
  }

  EntitySnapshot _snapshot(String id) => EntitySnapshot(
    id: id,
    name: _names[id]!,
    kind: _kinds[id]!,
    value: _unavailable.contains(id) ? const UnavailableValue() : _values[id]!,
    isSimulated: true,
  );

  void _requireOnline() {
    if (!_online) throw const NotConnectedFailure();
  }

  Future<void> _delay() =>
      latency == Duration.zero ? Future<void>.value() : Future.delayed(latency);
}
