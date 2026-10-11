import 'device_command_repository.dart';
import 'entity_catalog_repository.dart';
import 'room_state_repository.dart';

/// One concrete source (simulator or Home Assistant). Consumers depend on
/// the narrow interfaces; only the composition root sees this one.
abstract interface class RoomBackend
    implements
        RoomStateRepository,
        DeviceCommandRepository,
        EntityCatalogRepository {
  /// Releases sockets, timers and stream controllers.
  Future<void> dispose();
}
