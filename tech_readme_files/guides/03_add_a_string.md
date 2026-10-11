# Add or change a string

1. Edit the table in `tool/gen_arb.py` (English, Arabic). Placeholders
   `{name}`; ints listed in `TYPED`.
2. `python3 tool/gen_arb.py && flutter gen-l10n`
3. Use `AppLocalizations.of(context).<key>`.
4. Numbers + units inside Arabic text: wrap in `⁦…⁩` (see `room_formatters.dart`).
5. `test/architecture/dependency_rules_test.dart` checks EN/AR key parity.
