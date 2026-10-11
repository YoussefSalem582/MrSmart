# MrSmart

A small Flutter app (Android + iOS) for learning smart-home control with
one room: start with a **simulated room**, then connect your own
**Home Assistant**. Arabic and English (RTL), light and dark themes.

> Learning project. No backend, no accounts, no cloud. Use a lamp or a
> similar non-critical load only.

## Quick start

Requirements: Flutter 3.44+ (Dart 3.12+), Xcode for iOS, Android SDK for Android.

```bash
flutter pub get
```

```bash
flutter run
```

Pick **Try demo** on the first screen. No hardware, credentials or network
needed.

### Checks

```bash
dart format --set-exit-if-changed lib test
```

```bash
flutter analyze
```

```bash
flutter test
```

```bash
flutter build ios --simulator --debug
```

```bash
flutter build apk --debug
```

Strings live in `tool/gen_arb.py` (one table, both languages). After editing
it, run `python3 tool/gen_arb.py && flutter gen-l10n`.

## Demo walkthrough (about 5 minutes)

1. **Try demo** → the room shows a Desk lamp, a Fan plug and a Room
   temperature sensor, each labelled *Simulated*.
2. Flip the lamp. The card shows *Turning off… waiting for confirmation*
   until the simulator reports the new state. That gap is the whole point:
   a request being accepted is not the same as the device changing.
3. Demo controls (purple card, clearly labelled):
   - **Fail next command**, then flip a device → red *failed* line; the
     value stays at the last confirmed state.
   - **Drop next confirmation**, then flip → after 8 s an amber *Not
     confirmed* line. Never shown as success.
   - **Flip … from outside** → the card updates and the activity list says
     it changed outside the app.
   - **Make … unavailable** → the value shows *Unavailable* and the switch
     is disabled.
   - **Disconnect** → banner turns *Offline*, values are marked *Last known
     value · confirmed HH:MM:SS*, switches are disabled. **Reconnect** does
     a fresh read. Nothing you tried while offline is replayed.
4. **Leave room** → turns off only this room's devices and lists each
   result (confirmed / already off / failed / not confirmed / skipped).
5. Settings → العربية and Dark to check RTL and dark mode.

## Home Assistant mode

See [tech_readme_files/docs/home-assistant-setup.md](tech_readme_files/docs/home-assistant-setup.md). Short version:

1. In Home Assistant: profile → Security → *Long-lived access tokens* →
   create one (prefer a dedicated test user).
2. In MrSmart: **Connect to Home Assistant**, enter
   `http://<your-ha-address>:8123` and the token, **Test and save**.
3. Tick the entities that belong to the room (lights, switches,
   input_booleans, temperature sensors). Nothing else is ever controlled.

Plain `http://` is accepted only in **debug** builds; release builds
require `https://`. See [tech_readme_files/docs/security.md](tech_readme_files/docs/security.md).

## Verification status (2026-10-11)

| Area | Status |
|---|---|
| Demo mode | Run on the iOS 26.5 simulator (iPhone 17 Pro): toggles, failures, unconfirmed, offline/stale, leave room, Arabic RTL, dark mode. |
| Home Assistant REST + WebSocket | Implemented against the official docs; unit-tested against an in-memory fake (auth, id correlation, events, reconnect/backoff, removal, malformed frames). **Not tested against a real Home Assistant instance or a physical device.** |
| Android | `flutter build apk --debug` succeeds. Not run on an Android device or emulator. |
| Automated checks | `dart format`, `flutter analyze` (0 issues), `flutter test` (all passing). |

## Limitations

- One room, four entity kinds (light, switch, input_boolean, temperature sensor).
- Subscribes to all `state_changed` events and filters on the phone; fine
  for a home, wasteful for very large installations.
- Activity history is in memory only.
- The app must be open for *Leave room*; use a Home Assistant automation
  for anything that should run on its own.
- Long-lived tokens are a development convenience, not a multi-user
  authorization model.

## Docs

Everything lives under `tech_readme_files/`; start at
[tech_readme_files/INDEX.md](tech_readme_files/INDEX.md). Conventions for
humans and AI agents: [AGENTS.md](AGENTS.md).

- [Learning guide](tech_readme_files/docs/learning-guide.md): the smart-home vocabulary, tied to this code
- [Home Assistant setup](tech_readme_files/docs/home-assistant-setup.md): virtual helpers, then one real lamp
- [Architecture](tech_readme_files/docs/architecture.md): layers, data flow, command lifecycle
- [Security](tech_readme_files/docs/security.md): tokens, LAN assumptions, production gaps
- [Changelog](CHANGELOG.md)

## License

**Source-available, all rights reserved.** You may read the code and send
suggestions or pull requests; you may not use, copy or redistribute it
without written permission. See [LICENSE](LICENSE) and
[CONTRIBUTING.md](CONTRIBUTING.md). Tajawal font: [SIL OFL 1.1](assets/fonts/OFL.txt).
