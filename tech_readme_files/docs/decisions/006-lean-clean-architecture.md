# 006 — Lean Clean Architecture

## Context
The reference apps use `dartz` `Either`, one use case per operation and
datasource classes. For a learning MVP most of those would be
pass-through boilerplate.

## Decision
- Keep the layers and the dependency rule (enforced by a test).
- Use cases only where there is logic (`LeaveRoom`, `ConnectHomeAssistant`,
  `EraseHomeAssistant`); cubits call `RoomController` directly.
- Errors are a sealed `Failure` hierarchy thrown by data, caught in
  domain/presentation. No `Either`.
- Cubits, not Blocs: every screen has few, simple inputs.

## Consequences
Fewer files; same testability. If a flow grows, add the use case then.
