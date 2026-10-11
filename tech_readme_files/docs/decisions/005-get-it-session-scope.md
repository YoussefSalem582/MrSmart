# 005 — One GetIt scope per app mode

## Context
Switching demo ↔ Home Assistant must not leak sockets, timers or stream
subscriptions, and screens must never hold a disposed controller.

## Decision
`GetItSessionScope.open(mode)` pushes a scope with the backend,
`RoomController` and `LeaveRoom`, each with a dispose callback.
Switching pops the old scope first. `SessionState.epoch` keys per-screen
`BlocProvider`s so they are recreated.

## Consequences
Leak-free switching, proven by `test/di/get_it_session_scope_test.dart`.
`RoomController.dispose` starts every cancel before awaiting any.
