# 001 — Talk to Home Assistant directly, no backend

## Context
The goal is learning smart-home control with one room. A backend would
add accounts, hosting and a relay before anything works.

## Decision
The app talks straight to the user's Home Assistant on the LAN with a
long-lived access token. Demo mode needs nothing at all.

## Consequences
- Works on day one; nothing to deploy.
- Token = full user permissions; mitigated by a dedicated test user,
  secure storage and an erase flow ([security.md](../security.md)).
- A product would add a backend; the seam is a new `RoomBackend`
  ([architecture.md](../architecture.md)).
