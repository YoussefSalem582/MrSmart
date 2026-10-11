# 002 — Commands are confirmed by reported state, never by HTTP success

## Context
`POST /api/services/light/turn_on` returning 200 means "accepted". The
device may be offline, slow, or never report back. Showing success on
the response would lie.

## Decision
`RoomController` tracks per device: confirmed value + time, stale flag,
and a command state `Pending → (confirmed) | Failed | Unconfirmed(timeout |
connectionLost)`. Confirmation comes from a `state_changed` event, a
returned changed state, or a fresh read. Already-satisfied targets confirm
at once. After 8 s one fresh read is made, then *not confirmed*.
Offline: no queue, no replay.

## Consequences
- The UI always tells the truth about what HA reported.
- Still HA's view: a device that can't report back can still be wrong.
- Covered by `test/features/room/domain/room_controller_test.dart`.
