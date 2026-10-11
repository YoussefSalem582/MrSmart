# plan.md — Build brief for MrSmart

> **This file is the prompt.** Give it to the implementing AI agent as is.
> It says what to build, how, and what "done" means. Phases 1–4 are built
> (v0.1.0, 2026-10-11); phases 5+ are the roadmap. Progress is tracked in
> [TODO.md](TODO.md), not here.

---

## 0. Agent operating instructions

**Package**: `mr_smart` · app id `dev.mrsmart.app`. Private, machine-specific
notes (local paths, reference projects) live in the git-ignored
`CLAUDE.local.md`, never here.

**Rules of engagement**

1. Read the newest file in `handoff/` first. Then [AGENTS.md](../AGENTS.md).
2. One phase at a time. Restate its deliverables and acceptance criteria, implement, finish it.
3. Read the official Home Assistant docs before touching the integration. Never invent APIs, entity ids, credentials or test results.
4. Ask only when blocked (credentials, hardware, an irreversible choice). Otherwise decide, write an ADR, continue.
5. Every phase ends green: `dart format lib test && flutter analyze && flutter test`.
6. Docs are part of done: CHANGELOG, TODO, CURRENT_STATUS, handoff.
7. Git: `develop` integrates, `main` releases; one `<type>/<slug>` branch per piece of work off `develop`, Conventional Commits, `--no-ff` merges, release `develop → main` + tag. See [CLAUDE.md](../CLAUDE.md).

---

## 1. What you are building

A learning app that controls **one room**.

- **Demo mode**: works immediately, no hardware, credentials or network.
- **Home Assistant mode**: connects to the user's existing instance on the LAN; the user explicitly selects the room's entities.
- Live states, on/off control, a *Leave room* action, clear pending / failed / disconnected / unknown / unavailable states.
- Arabic + English (RTL), light + dark, phones and tablets.

**Out of scope**: custom backend, registration, subscriptions, cloud, cameras, locks, voice, AI, remote access.

**Supported entities**: `light`, `switch`, `input_boolean`, `sensor` with `device_class: temperature` (numeric, reported unit).

## 2. Domain primer

- **Entity** `domain.object_id`; **state** is text + attributes; `unknown`/`unavailable` are special.
- **Service/action** (`light.turn_on`) asks HA to operate a device. HTTP 200 = accepted, not done.
- **Event** `state_changed` reports a new state from any cause.
- `POST /api/states` rewrites HA's record only. Never use it for control.
- See [docs/learning-guide.md](docs/learning-guide.md).

## 3. Principles, in order

1. **Never lie about device state.** Unconfirmed is never shown as success.
2. **Never touch what the user didn't select.**
3. **Safe by default**: tokens are secrets; HTTPS preferred; HTTP debug-only.
4. **Learnable**: simulated data labelled; concepts explained where they appear.
5. **Simple**: no abstraction without a second use.

## 4. Non-negotiables

- Separate: last confirmed state · requested target · pending · failure/timeout · connectivity/freshness.
- Already-satisfied targets confirm immediately; timeout (8 s) → one fresh read → *not confirmed*.
- Offline: controls disabled, values stale with "last confirmed" time, no queue, no replay.
- Reconnect: bounded exponential backoff (1 → 30 s) + fresh read.
- Leave room: selected controllable entities only; per-device report; explains app-initiated vs automations.
- Credentials only in secure storage; erase flow; nothing secret logged.

## 5. Architecture

Clean Architecture, feature-first — see [AGENTS.md](../AGENTS.md) and
[docs/architecture.md](docs/architecture.md). Decisions:
[docs/decisions/](docs/decisions/).

Packages: flutter_bloc, get_it, go_router, dio, web_socket_channel,
flutter_secure_storage, shared_preferences, talker_flutter, skeletonizer,
intl, equatable · dev: bloc_test, mocktail, fake_async, flutter_lints.

## 6. Home Assistant contract (from developers.home-assistant.io)

- REST `Authorization: Bearer <token>`: `GET /api/`, `GET /api/config`, `GET /api/states`, `GET /api/states/<id>` (404 = gone), `POST /api/services/<domain>/<service>` → changed states.
- WebSocket `/api/websocket`: `auth_required` → `auth` → `auth_ok`/`auth_invalid`; integer ids; `subscribe_events` (`state_changed`); `result`/`event`/`pong`; `{success:false, error:{code,message}}`.

## 7. Build phases

### Phase 1 — Scaffold and demo · **done**
Navigation, themes, localization, repository contracts, simulated room.
*Accept*: demo launches offline; EN/AR + light/dark switch.

### Phase 2 — Reliable controls · **done**
Command states, activity, disconnect handling, Leave room, demo controls.
*Accept*: tests for ack≠confirmed, already satisfied, timeout, failure, offline no-replay, leave-room partial failure.

### Phase 3 — Home Assistant · **done**
REST, WebSocket, selection, secure credentials, reconnect, reconciliation, lifecycle.
*Accept*: contract tests pass for both backends; HTTP blocked in release.

### Phase 4 — Validation and handover · **done**
Format, analyze, tests, iOS + Android builds, docs.

### Phase 5 — Real-world verification · **next**
- Connect to a real HA (helpers first, per [docs/home-assistant-setup.md](docs/home-assistant-setup.md)); record results in `CURRENT_STATUS.md`.
- Run on an Android emulator/device (debug HTTP to LAN).
- Swap one helper for one verified local lamp/plug; observe latency, unavailable, unconfirmed.
*Accept*: a dated verification table with what was run on what.

### Phase 6 — Hardening (optional)
- Server-side event filtering (`subscribe_trigger`) for large installations.
- Persist activity history (bounded).
- Golden + a11y tests for the dashboard; tablet layout check.
- `di_smoke_test` that builds the real GetIt graph.

### Phase 7 — Beyond the MVP (only if the user asks)
- HA OAuth2 login instead of pasted tokens.
- Brightness for lights, multiple rooms.
- A backend relay — see "Where a commercial backend could fit" in [docs/architecture.md](docs/architecture.md).

## 8. Definition of done (any phase)

Gate green · docs updated · CHANGELOG entry · TODO ticked · handoff written ·
verification status stated honestly (what ran, where, what didn't).
