# 003 — REST for reads and commands, WebSocket for events

## Context
HA offers both. WebSocket `call_service` returns no changed states; REST
does, and REST is simpler to test with a Dio adapter.

## Decision
REST: connection test, initial and fresh reads, service calls.
WebSocket: auth + `subscribe_events(state_changed)` only, filtered to
selected ids on the phone. Ping every 30 s; backoff 1 → 30 s; stop on
`auth_invalid`.

## Consequences
- Two transports to keep healthy; REST works even while the socket reconnects (but control is disabled while offline by design).
- Every state change in the house reaches the phone. Upgrade path:
  server-side filtering (`subscribe_trigger`), TODO Phase 6.
