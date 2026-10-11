import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_keys.dart';
import '../domain/repositories/room_selection_repository.dart';

/// Entity ids are not secret; plain preferences are fine.
class PrefsRoomSelectionRepository implements RoomSelectionRepository {
  const PrefsRoomSelectionRepository(this._prefs);

  final SharedPreferences _prefs;

  @override
  List<String> read() =>
      _prefs.getStringList(StorageKeys.haSelectedEntities) ?? const [];

  @override
  Future<void> save(List<String> entityIds) =>
      _prefs.setStringList(StorageKeys.haSelectedEntities, entityIds);

  @override
  Future<void> clear() => _prefs.remove(StorageKeys.haSelectedEntities);
}
