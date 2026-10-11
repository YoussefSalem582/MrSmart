import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/storage_keys.dart';
import '../domain/app_mode.dart';

class PrefsAppModeRepository implements AppModeRepository {
  const PrefsAppModeRepository(this._prefs);

  final SharedPreferences _prefs;

  @override
  AppMode read() => AppMode.values.firstWhere(
    (m) => m.name == _prefs.getString(StorageKeys.appMode),
    orElse: () => AppMode.none,
  );

  @override
  Future<void> save(AppMode mode) =>
      _prefs.setString(StorageKeys.appMode, mode.name);
}
