# AGENTS.md — conventions for MrSmart

Canonical convention doc for this repo. Read this before touching code; the
build brief and rationale live in
[tech_readme_files/plan.md](tech_readme_files/plan.md), the working
checklist in [tech_readme_files/TODO.md](tech_readme_files/TODO.md).
Scaled down for a learning MVP.

Before planning or any work, read the newest session handoff in
[tech_readme_files/handoff/](tech_readme_files/handoff/), and write or update
this session's file (`<main-work>-<YYYY-MM-DD>.md`) before you stop.

## PUBLIC REPOSITORY — read before every commit

This repo is published publicly (source-available, all rights reserved —
see [LICENSE](LICENSE)). Anything committed is visible to everyone, forever
(git history). **Never commit**:

- Secrets: Home Assistant tokens, API keys, passwords, signing keys,
  `key.properties`, `.env`, `google-services.json`, keystores.
- Real network details: real IPs, hostnames, URLs of the owner's home or
  any HA instance. Use placeholders (`http://homeassistant.local:8123`,
  `http://192.168.1.20:8123`, `ha.example.org`, `test-token`).
- Personal data: emails, phone numbers, real names other than the
  copyright line, screenshots with any of these.
- Private machine details: absolute paths (`/Volumes/…`, `/Users/…`), <!-- public-ok -->
  names or code of private/work/client projects, the owner's notes vault.
  Those belong in the git-ignored `CLAUDE.local.md` only.
- Code copied from other repositories whose license doesn't allow
  publishing it. Copy patterns, write the code fresh.

Fake values that look like secrets (test JWTs) must carry `public-ok` on
the same line. `tool/check_public.sh` runs as the pre-commit hook
(`git config core.hooksPath tool/hooks`) and blocks the obvious cases — it
is a safety net, not a substitute for reading `git diff --cached`.

## What this is

A Flutter (Android + iOS) app that controls **one room**: a simulated room
(demo) or user-selected entities from the user's own Home Assistant.
No backend, accounts, cloud, cameras, locks, voice or AI. Learning project:
non-critical loads only.

## Architecture

Clean Architecture, feature-first, dependency rule
`presentation → domain ← data`.

```
lib/
├── main.dart, app/            # app widget, go_router (composition root side)
├── di/                        # GetIt wiring + per-mode GetIt scope
├── core/                      # theme tokens, locale/theme cubits, Failure, logger, routes
├── l10n/                      # arb/ (generated from tool/gen_arb.py) + generated/
└── features/
    ├── room/                  # domain (entities, contracts, RoomController, LeaveRoom), data (demo), presentation
    ├── home_assistant/        # domain (HaEndpoint, credentials, use cases), data (REST, WS, repo), connect UI
    ├── entity_selection/      # presentation only (uses room contracts)
    ├── session/               # AppMode, SessionScope, welcome
    └── settings/              # presentation only
```

`test/architecture/dependency_rules_test.dart` enforces:

1. `domain/` imports no Flutter, Dio, web_socket_channel, storage, talker,
   `data/` or `presentation/`. Allowed: `dart:`, `equatable`, `core/error`.
2. `presentation/` never imports `data/`.
3. `core/` never imports `features/`.
4. Both ARB files have the same keys.

Only the composition root (`lib/di/`, `lib/app/`, `main.dart`) calls `sl`.

## SOLID, applied

- **S** — `HaSocket` = one authenticated socket + id correlation.
  `HaRoomRepository` = reconnect loop + mapping. `ReconnectPolicy` = delays.
  `RoomController` = command reconciliation. Cubits only adapt state for UI.
- **O** — a new controllable kind = one `DeviceKind` value (its HA domain)
  plus one `HaStateMapper` case. Callers don't change.
- **L** — every `RoomBackend` (demo, Home Assistant) passes
  `test/features/room/data/room_backend_contract.dart`. No `is DemoX` checks.
- **I** — narrow contracts: `RoomStateRepository`, `DeviceCommandRepository`,
  `EntityCatalogRepository`, `RoomSelectionRepository`,
  `CredentialsRepository`, `DemoControls`.
- **D** — cubits and use cases receive interfaces through constructors.

Use cases exist where there is logic (`LeaveRoom`, `ConnectHomeAssistant`,
`EraseHomeAssistant`). No pass-through use-case classes (ADR 006).

## Command correctness — the rule of this app

Accepted is not done. A device is **confirmed** only when an event, a
service-call response or a fresh read reports the target. Otherwise it is
pending → failed / not confirmed. Never queue commands offline, never
replay after reconnect, never show unconfirmed as success. All of it lives
in `RoomController`; see ADR 002 and
[docs/architecture.md](tech_readme_files/docs/architecture.md).

Home Assistant control uses domain services (`light|switch|input_boolean`
`.turn_on/turn_off`). **Never `POST /api/states`** for control.

## Token layer — no literals downstream

`AppColors` · `AppSemanticColors` · `AppSpacing` (incl. radius,
breakpoints) · `AppMotion` · `AppTheme` · `Routes`. No raw `Color(...)`,
literal spacing or route strings in widgets. Every user-facing string is
`AppLocalizations.of(context).<key>`, defined in `tool/gen_arb.py` for both
`en` and `ar`. Numbers with units inside Arabic text are wrapped in an LTR
isolate (see `room_formatters.dart`).

## State management

`flutter_bloc` Cubits. Long-lived: `ThemeCubit`, `LocaleCubit`,
`SessionCubit` (lazy singletons). Per-screen: `RoomCubit`,
`ConnectCubit`, `SelectionCubit`, created in the router's
`BlocProvider(create:)` and keyed by `SessionState.epoch`.
No business logic or `Future` calls in `build`.

## Data and networking

- `HaRestDataSource.forCredentials` is the only place that builds a `Dio`.
  TLS validation is never touched.
- WebSocket via `web_socket_channel` behind `HaWsTransport`; tests use a fake.
- Transport errors → domain `Failure` in `ha_failure_mapper.dart` only.
- Per-mode objects live in a GetIt scope (`GetItSessionScope`); switching
  mode pops it and disposes sockets and subscriptions.

## Logging and security

- `AppLogger` (Talker) is the only logger; every message goes through
  `redact()`. Never log headers, bodies or tokens.
- Token + URL in `flutter_secure_storage` only (iOS `first_unlock_this_device`).
- `http://` only in debug builds (`ConnectHomeAssistant.allowInsecureHttp`).
- Details: [docs/security.md](tech_readme_files/docs/security.md).

## Naming

| Item | Convention |
| --- | --- |
| Files | `snake_case.dart` |
| Classes | `PascalCase` |
| Variables/functions/constants | `camelCase` |
| Private members | `_prefixed` |
| Docs | `kebab-case.md` under `tech_readme_files/` |
| ADRs | `docs/decisions/NNN-title.md` |

## Commands

```bash
flutter pub get
dart format lib test && flutter analyze && flutter test   # quality gate
python3 tool/gen_arb.py && flutter gen-l10n                # after string changes
flutter run                                                # demo works offline
flutter build ios --simulator --debug && flutter build apk --debug
```

## Where to look first

- Build brief: [tech_readme_files/plan.md](tech_readme_files/plan.md) · checklist: [TODO.md](tech_readme_files/TODO.md) · snapshot: [CURRENT_STATUS.md](tech_readme_files/CURRENT_STATUS.md)
- Why a decision was made: [tech_readme_files/docs/decisions/](tech_readme_files/docs/decisions/)
- How-to recipes: [tech_readme_files/guides/](tech_readme_files/guides/)
- Shared test doubles: `test/helpers/fake_room_backend.dart`,
  `test/helpers/fake_home_assistant.dart`. Import them; don't redeclare.
- Full navigation: [tech_readme_files/INDEX.md](tech_readme_files/INDEX.md)
