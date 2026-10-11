import '../entities/entity_snapshot.dart';

abstract interface class DeviceCommandRepository {
  /// Asks the source to switch [entityId] on or off.
  ///
  /// Completing normally means the request was *accepted*, not that the
  /// device changed. Returns any states the source reported as changed
  /// while handling the call (may be empty). Throws a [Failure].
  Future<List<EntitySnapshot>> setPower(
    String entityId,
    DeviceKind kind, {
    required bool on,
  });
}
