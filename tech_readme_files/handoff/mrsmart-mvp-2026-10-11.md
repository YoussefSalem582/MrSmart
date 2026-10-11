## 1. Goal
Build "MrSmart", a Flutter (Android/iOS) smart-home learning MVP: a
simulated room first, then Home Assistant (REST + WebSocket) for one room
of user-selected entities. Clean Architecture, SOLID, clean git workflow,
EN/AR + RTL, light/dark, honest command states (never show unconfirmed as
success).

## 2. Current status
2026-10-11, branch `main`, tag `v0.1.0` (source-available license; repo will be public). All four phases done.
- Demo mode: done, checked on the iOS simulator.
- HA integration: implemented and unit-tested against an in-memory fake.
  NOT yet tested against a real HA instance or a physical device.
- Android: debug APK builds; not run on a device/emulator.

## 3. Active files
- `tech_readme_files/TODO.md` — Phase 5 checklist is the next work.
- `lib/features/room/domain/services/room_controller.dart` — command reconciliation (core logic).
- `lib/features/home_assistant/data/ha_room_repository.dart` — reconnect loop, events, service calls.
- `lib/features/home_assistant/data/ha_socket.dart` — WS auth + id correlation.
- `lib/di/injection_container.dart`, `lib/di/get_it_session_scope.dart` — wiring, per-mode scope.
- `tool/gen_arb.py` — single source for EN/AR strings.

## 4. Changes made
- Renamed to MrSmart (package `mr_smart`, app id `dev.mrsmart.app`);
  history rebuilt as a clean develop/main workflow, tagged `v0.1.0`.
- Public-repo hygiene: source-available LICENSE, CONTRIBUTING, pre-commit
  guard (`tool/check_public.sh`), private notes moved to git-ignored
  `CLAUDE.local.md`, redaction rewritten from scratch.
- Docs: AI docs (AGENTS.md, CLAUDE.md, INDEX, plan.md, TODO.md,
  CURRENT_STATUS, ADRs 001–006, guides); docs moved under `tech_readme_files/docs/`.
- Phase 4: docs (README, docs/*, CHANGELOG), builds, handoff.
- Phase 3: HA domain/data/presentation, platform network config, HA tests.
- Phase 2: RoomController tests, leave room, session-scope leak test, layer rules.
- Phase 1: scaffold, core, room domain, demo backend, UI, routing.
History rebuilt on 2026-10-11 as `develop`/`main` with one branch per
  piece of work (`git log --graph`); release `v0.1.0` on `main`.

## 5. Failed attempts
- `fake_async` cannot drain root-zone futures returned by
  `StreamSubscription.cancel()` / GetIt `popScope`; awaiting cancels one by
  one looked like a hang. Fix: start all cancels synchronously, await
  together; GetIt scope test uses real async.
- Simulator text injection (`control text`) does not reach Flutter text
  fields; the connect error UI is covered by a widget test instead.
- The booted "iPhone 17" simulator showed an Apple Account system prompt;
  used a separate "iPhone 17 Pro" simulator.

## 6. Next steps
1. Point the app at a real Home Assistant (debug build, `http://<lan-ip>:8123`)
   with helpers from tech_readme_files/docs/home-assistant-setup.md and record what works.
2. Run on an Android emulator/device; confirm debug HTTP to LAN works.
3. Consider `subscribe_trigger`/server-side filtering for large installations.
