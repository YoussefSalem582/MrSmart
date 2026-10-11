/// Removes secrets from text before it reaches a log line.
///
/// Masks, in order:
/// * the credential after `Bearer `;
/// * the value of any JSON key that ends in `token`, `secret` or contains
///   `password` (the key itself stays, so the payload shape is readable);
/// * anything shaped like a JWT. Home Assistant long-lived access tokens
///   are JWTs and can show up outside JSON.
///
/// Regex-based so it works on any string and never throws.
String redact(String input) =>
    _rules.fold(input, (text, rule) => text.replaceAllMapped(rule.$1, rule.$2));

final List<(RegExp, String Function(Match))> _rules = [
  (
    RegExp(r'(bearer\s+)([\w\-.=]+)', caseSensitive: false),
    (m) => '${m[1]}${_hide(m[2]!)}',
  ),
  (
    RegExp(
      r'("[\w-]*(?:token|secret|password[\w-]*)")(\s*:\s*)"((?:\\.|[^"\\])*)"',
      caseSensitive: false,
    ),
    (m) => '${m[1]}${m[2]}"${_hide(m[3]!)}"',
  ),
  (RegExp(r'\beyJ[\w-]{8,}\.[\w-]{8,}\.[\w-]{8,}'), (m) => _hide(m[0]!)),
];

/// Keeps a short prefix so two different secrets can still be told apart
/// in a log, without revealing enough to use either.
String _hide(String secret) =>
    secret.length < 12 ? '[redacted]' : '${secret.substring(0, 4)}…[redacted]';
