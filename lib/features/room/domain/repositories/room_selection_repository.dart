/// Which entities belong to the room. Never "everything in the house".
abstract interface class RoomSelectionRepository {
  List<String> read();
  Future<void> save(List<String> entityIds);
  Future<void> clear();
}
