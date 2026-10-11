# Changelog

## 0.1.0 — 2026-10-11

First public release.

### Added
- `LICENSE`: source-available, all rights reserved; contributions licensed
  to the owner. `CONTRIBUTING.md`. `assets/fonts/OFL.txt` for Tajawal.
- Public-repo safety: rules in AGENTS.md/CLAUDE.md, pre-commit guard
  `tool/check_public.sh`, git-ignored `CLAUDE.local.md` for private notes.

### Changed
- Renamed RoomLink → **MrSmart**: package `mr_smart`, app id
  `dev.mrsmart.app` (Android + iOS), display name and all docs.
- Git history rebuilt for the public repository as a clean
  `develop`/`main` branch-and-merge history (no earlier history is
  published).
- `redaction.dart` rewritten from scratch (with its own test).
- Removed private paths and project names from docs.

### Docs
- Adopted a structured documentation layout: `AGENTS.md` + `CLAUDE.md` at
  the root; `tech_readme_files/` with `INDEX.md`, AI build brief
  `plan.md`, `TODO.md`, `CURRENT_STATUS.md`, ADRs 001–006 and guides.
- Moved `docs/*` to `tech_readme_files/docs/` (kebab-case names).

### Phase 4 — Validation and handover
- README, learning guide, Home Assistant setup, architecture and security docs.
- Checks: `dart format`, `flutter analyze` (0 issues), `flutter test` (all
  passing), `flutter build ios --simulator --debug`, `flutter build apk --debug`.
- Demo walked through on the iOS simulator (EN/AR, light/dark).

### Phase 3 — Home Assistant integration
- `HaEndpoint`: URL normalization, http/https → ws/wss mapping.
- REST client (Dio): connection test, state reads, domain service calls
  (`light|switch|input_boolean.turn_on/turn_off`), typed failures.
- `HaSocket`: auth handshake, unique increasing ids, result/event
  correlation, malformed-frame tolerance, ping.
- `HaRoomRepository`: `state_changed` subscription filtered to selected
  entities, removal handling, bounded exponential backoff (1 → 30 s),
  stop on `auth_invalid`, lifecycle disconnect/reconnect.
- Connect screen (HTTP warning, token field hardening), explicit entity
  selection with safety note, secure credential storage, erase flow.
- HTTP allowed only in debug builds; Android debug-only cleartext config;
  iOS local network usage description.
- Tests with an in-memory fake Home Assistant, shared backend contract.

### Phase 2 — Reliable controls
- `RoomController`: pending / confirmed / failed / unconfirmed, already-
  satisfied targets, timeout with one fresh read, stale-while-offline, no
  offline queue, fresh read on reconnect, removal and unavailable handling.
- `LeaveRoom` use case with per-device report.
- Tests: command semantics, leave room, session scope disposal, layer
  rules, demo contract, Arabic RTL and offline UI.

### Phase 1 — Scaffold and demo
- Flutter app for Android/iOS: go_router, get_it, flutter_bloc, gen-l10n
  (EN/AR), Material 3 light/dark themes with central tokens, Talker logger
  with redaction.
- Domain contracts and deterministic simulated room (lamp, plug,
  temperature) with labelled demo controls.
