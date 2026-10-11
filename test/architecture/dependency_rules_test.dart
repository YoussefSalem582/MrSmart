import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Clean Architecture dependency rule, enforced on imports:
/// presentation → domain ← data, and core never depends on features.
void main() {
  List<(String, String)> imports(bool Function(String path) where) => [
    for (final f in Directory('lib').listSync(recursive: true))
      if (f is File && f.path.endsWith('.dart') && where(f.path))
        for (final line in f.readAsLinesSync())
          if (line.startsWith('import ')) (f.path, line),
  ];

  test('domain is pure Dart: no Flutter, transport, storage, data or UI', () {
    final bad = imports((p) => p.contains('/domain/')).where(
      (i) => RegExp(
        r"package:(flutter|dio|web_socket_channel|shared_preferences|"
        r"flutter_secure_storage|talker)|/data/|/presentation/",
      ).hasMatch(i.$2),
    );
    expect(bad, isEmpty);
  });

  test('presentation never imports data implementations', () {
    final bad = imports(
      (p) => p.contains('/presentation/'),
    ).where((i) => i.$2.contains('/data/'));
    expect(bad, isEmpty);
  });

  test('core never imports features', () {
    final bad = imports(
      (p) => p.startsWith('lib/core/'),
    ).where((i) => i.$2.contains('features/'));
    expect(bad, isEmpty);
  });

  test('both ARB files define the same keys', () {
    Set<String> keys(String lang) =>
        RegExp(r'^  "([a-zA-Z]\w*)":', multiLine: true)
            .allMatches(File('lib/l10n/arb/app_$lang.arb').readAsStringSync())
            .map((m) => m[1]!)
            .toSet();
    expect(keys('ar'), keys('en'));
  });
}
