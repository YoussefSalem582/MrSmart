# Testing

```bash
flutter test                                   # everything (~4 s)
flutter test test/features/room/domain         # command semantics
flutter test test/features/home_assistant      # HA client vs fake server
```

- `test/helpers/fake_room_backend.dart`: scriptable backend with sync streams.
- `test/helpers/fake_home_assistant.dart`: in-memory HA (REST adapter + WS transport) following the documented shapes. Not a real server.
- Time-based logic: `fake_async`. Exception: code that awaits
  `StreamSubscription.cancel()` or GetIt `popScope` — use real async there
  (fake_async can't drain those root-zone futures).
- Test behaviour that matters (confirmation, offline, removal, leaks). No coverage-padding tests.
