/// Keys for non-secret preferences (shared_preferences).
/// Secrets live in flutter_secure_storage, see `SecureCredentialsStore`.
abstract final class StorageKeys {
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String appMode = 'app_mode';
  static const String haSelectedEntities = 'ha_selected_entities';
}
