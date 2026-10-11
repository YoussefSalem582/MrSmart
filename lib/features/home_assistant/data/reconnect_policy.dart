import 'dart:math';

/// Bounded exponential backoff: 1s, 2s, 4s … capped at [max]. No jitter,
/// so tests are deterministic.
// ponytail: no jitter; add it if many clients reconnect to one hub at once.
class ReconnectPolicy {
  const ReconnectPolicy({
    this.initial = const Duration(seconds: 1),
    this.max = const Duration(seconds: 30),
  });

  final Duration initial;
  final Duration max;

  /// [attempt] is 1-based.
  Duration delayFor(int attempt) {
    final factor = 1 << (attempt - 1).clamp(0, 20);
    return Duration(
      milliseconds: min(initial.inMilliseconds * factor, max.inMilliseconds),
    );
  }
}
