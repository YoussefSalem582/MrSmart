import 'package:talker_flutter/talker_flutter.dart';

import 'redaction.dart';

/// The only entry point for diagnostics. Every message passes through
/// [redact] so access tokens never reach a log line.
abstract final class AppLogger {
  static Talker _talker = Talker(settings: TalkerSettings(enabled: false));

  static Talker get talker => _talker;

  static Talker create() {
    _talker = Talker(
      settings: TalkerSettings(useHistory: true, maxHistoryItems: 200),
    );
    return _talker;
  }

  static void info(String message) => _talker.info(redact(message));

  static void warning(String message) => _talker.warning(redact(message));

  static void error(String message, [Object? error, StackTrace? stack]) =>
      _talker.error(
        redact(message),
        error == null ? null : redact(error.toString()),
        stack,
      );
}
