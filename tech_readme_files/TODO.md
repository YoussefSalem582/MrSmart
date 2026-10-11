# TODO — MrSmart

Working checklist. Spec: [plan.md](plan.md) (§ refers to it). Snapshot:
[CURRENT_STATUS.md](CURRENT_STATUS.md).

**Rule**: one phase at a time. Done = every box ticked, gate green
(`dart format lib test && flutter analyze && flutter test`), docs updated.

---

## Phase 1 — Scaffold and demo (§7) · done 2026-10-11

- [x] `flutter create` (Android + iOS; app id `dev.mrsmart.app`), git init
- [x] Packages, lints, Tajawal font, l10n.yaml, `tool/gen_arb.py`
- [x] Theme tokens, `ThemeCubit`, `LocaleCubit`, redacting `AppLogger`
- [x] Room domain: entities, contracts, `RoomController`
- [x] `DemoRoomRepository` (lamp, plug, temperature; deterministic)
- [x] Welcome, room dashboard, settings, go_router, GetIt + session scope

## Phase 2 — Reliable controls · done 2026-10-11

- [x] Pending / confirmed / failed / unconfirmed, already-satisfied, timeout + fresh read
- [x] Stale values offline, controls disabled, no offline queue
- [x] Activity list, Leave room + report, demo controls panel
- [x] Tests: controller, leave room, session scope, layer rules, demo contract, Arabic RTL

## Phase 3 — Home Assistant · done 2026-10-11

- [x] `HaEndpoint` normalization + ws/wss mapping
- [x] REST data source + failure mapping
- [x] `HaSocket` (auth, ids, correlation, ping, malformed frames)
- [x] `HaRoomRepository` (subscription, filter, removal, backoff, authFailed)
- [x] Connect page, entity selection (safety note), secure storage, erase
- [x] Android debug-only cleartext, iOS local network description, HTTP debug-only
- [x] Tests with fake HA, shared backend contract, connect error UI

## Phase 4 — Validation and handover · done 2026-10-11

- [x] Gate green (58 tests)
- [x] `flutter build ios --simulator --debug`, `flutter build apk --debug`
- [x] Demo walkthrough on iOS simulator (EN/AR, light/dark)
- [x] README, docs, CHANGELOG, handoff, tag `v0.1.0`
- [x] AI docs: AGENTS.md, CLAUDE.md, INDEX, plan, TODO, ADRs, guides

---

## Phase 5 — Real-world verification (§7) · next

- [ ] Create HA helpers (2 toggles, number, template temperature sensor)
- [ ] Connect a debug build to the real HA over LAN; test → select → toggle
- [ ] Flip a helper in HA web UI → app updates
- [ ] Stop HA / Wi-Fi off → offline + stale; restore → fresh read
- [ ] Wrong token → "Access token rejected"; authFailed banner after revoke
- [ ] Delete a selected helper → "Removed from the source"
- [ ] Run on Android emulator or device; confirm debug HTTP to LAN
- [ ] Record results (date, HA version, device) in `CURRENT_STATUS.md`
- [ ] Optional: replace one helper with one verified local lamp/plug

## Phase 6 — Hardening (optional)

- [ ] `subscribe_trigger` / server-side filtering
- [ ] Bounded persisted activity history
- [ ] Golden + a11y tests, tablet layout check
- [ ] `test/di/di_smoke_test.dart` for the real graph
