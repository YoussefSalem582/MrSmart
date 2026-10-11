# Architecture

Feature-first Clean Architecture. Dependency rule:
**presentation → domain ← data**, enforced by
`test/architecture/dependency_rules_test.dart`.

```
lib/
  main.dart, app/            app widget, router (composition root side)
  di/                        GetIt wiring + per-mode GetIt scope
  core/                      theme tokens, l10n cubits, Failure, redacting logger
  features/
    room/                    domain (entities, contracts, RoomController, LeaveRoom),
                             data (demo backend, selection prefs), presentation
    home_assistant/          domain (endpoint, credentials, use cases),
                             data (REST, WebSocket, mapper, repository), connect UI
    entity_selection/        choose the room's entities
    session/                 app mode + scope lifecycle, welcome screen
    settings/                language, theme, mode, erase
```

## Contracts (SOLID)

- **Interface segregation**: `RoomStateRepository` (connection, updates,
  fresh reads), `DeviceCommandRepository` (setPower),
  `EntityCatalogRepository`, `RoomSelectionRepository`,
  `CredentialsRepository`, `DemoControls` (demo only).
- **Liskov**: `DemoRoomRepository` and `HaRoomRepository` both implement
  `RoomBackend` and pass the same contract suite
  (`test/features/room/data/room_backend_contract.dart`).
- **Single responsibility**: `HaSocket` = one authenticated socket with id
  correlation; `HaRoomRepository` = reconnect loop + mapping;
  `ReconnectPolicy` = delays; `RoomController` = command reconciliation;
  `RoomCubit` = UI adapter only.
- **Dependency inversion**: cubits and use cases see interfaces; only
  `di/` knows concrete classes.

## Data flow (Home Assistant mode)

```
RoomPage ─ RoomCubit ─ RoomController ─┬─ RoomStateRepository ─ HaRoomRepository ─┬─ HaRestDataSource (Dio) ── GET /api/states, POST /api/services/…
                                       └─ DeviceCommandRepository ───────────────┘ └─ HaSocket ── /api/websocket: auth → subscribe_events(state_changed)
```

1. `connect(ids)` opens the socket: `auth_required` → `auth` → `auth_ok`,
   then `subscribe_events` for `state_changed`. Status `connected`.
2. On `connected`, `RoomController.refresh()` does a REST read of the
   selected ids (initial state, and reconciliation after every reconnect).
3. Events are filtered to selected ids; `new_state: null` = removed.
4. The socket pings every 30 s. Drop → `reconnecting` with backoff
   1, 2, 4 … 30 s. `auth_invalid` → `authFailed`, no retry.
5. App to background → disconnect (unsubscribe, close); foreground →
   connect + fresh read.

## Command lifecycle (`RoomController`)

```
          setPower ──► Pending ──┬─ event/response/fresh read == target ──► confirmed (idle)
 (rejected if offline,           ├─ request throws (401/403/HTTP/demo) ──► Failed (value unchanged)
  unavailable, unknown,          ├─ 8 s, one fresh read still differs ───► Unconfirmed(timeout)
  removed or already pending)    ├─ connection lost ─────────────────────► Unconfirmed(connectionLost)
                                 └─ entity removed ──────────────────────► Failed(NotFound)
```

- Already satisfied: if the confirmed value equals the target once the
  request is accepted, it confirms immediately.
- Nothing is queued while offline; nothing is replayed after reconnect.
- Offline: every value is flagged stale and keeps `lastConfirmedAt`.

## Mode switching

`SessionCubit` → `GetItSessionScope.open(mode)` pushes a GetIt scope with
the backend, `RoomController` and `LeaveRoom`. Switching pops the old
scope first; its dispose callbacks cancel subscriptions and close sockets
(`test/di/get_it_session_scope_test.dart`). Screens are keyed by a session
epoch so they never hold a disposed controller.

## Where a commercial backend could fit later

Today the phone talks straight to Home Assistant with a user's long-lived
token. A product would add a backend (e.g. Laravel) between them:

- **Auth**: per-user accounts and, toward HA, the OAuth2 authorization
  code flow from HA's auth API instead of pasted long-lived tokens.
- **Relay**: backend ↔ HA over a persistent connection; phone ↔ backend
  over REST + WebSocket (or push). Permissions per user and per room.
- **Audit/history**: persistent activity log, command outcomes, alerts.

In the app this is one new `RoomBackend` implementation (say
`CloudRoomRepository`) registered in `di/`. It must pass the same contract
tests; domain and UI stay unchanged.
