/// Learning controls that only the simulator implements.
abstract interface class DemoControls {
  bool get isOnline;

  /// Simulates the hub going offline / coming back.
  Future<void> setOnline(bool online);

  /// The next command is rejected with an error.
  void failNextCommand();

  /// The next command is accepted but the device never reports the new
  /// state, so it ends as "not confirmed".
  void dropNextConfirmation();

  /// Someone flips the device with a wall switch or another app.
  void toggleExternally(String entityId);

  /// Device stops (or resumes) reporting.
  void setUnavailable(String entityId, {required bool unavailable});

  bool isUnavailable(String entityId);

  /// The simulated thermometer reports a new reading.
  void nudgeTemperature();
}
