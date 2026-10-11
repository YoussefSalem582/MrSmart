import '../entities/connection_status.dart';
import '../entities/entity_snapshot.dart';

/// Live state of the selected entities. Implemented by the simulator and
/// by Home Assistant, with identical semantics.
abstract interface class RoomStateRepository {
  Stream<ConnectionStatus> get connection;

  /// Pushed changes, already filtered to the ids passed to [connect].
  Stream<EntityUpdate> get updates;

  /// Starts (or restarts) the live connection. Returns once the attempt
  /// has started; progress is reported on [connection].
  Future<void> connect(Set<String> entityIds);

  /// Stops the live connection and cancels its subscriptions.
  Future<void> disconnect();

  /// Fresh read. Ids that no longer exist are absent from the result.
  /// Throws a [Failure].
  Future<List<EntitySnapshot>> fetchStates(Set<String> entityIds);
}
