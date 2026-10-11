import '../entities/entity_snapshot.dart';

abstract interface class EntityCatalogRepository {
  /// Entities of a supported kind that the user may add to the room.
  Future<List<EntitySnapshot>> listSupportedEntities();
}
