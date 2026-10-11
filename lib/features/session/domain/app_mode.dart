enum AppMode { none, demo, homeAssistant }

/// Remembers which mode the app was last in (not secret).
abstract interface class AppModeRepository {
  AppMode read();
  Future<void> save(AppMode mode);
}

/// Opens and closes the per-mode object graph (backend, room controller).
/// Closing must release every socket, timer and subscription.
abstract interface class SessionScope {
  /// Throws a `Failure` when the mode cannot start (e.g. no credentials).
  Future<void> open(AppMode mode);
  Future<void> close();

  /// Drops the room controller so the next room screen uses a fresh
  /// selection.
  Future<void> resetRoom();
}
