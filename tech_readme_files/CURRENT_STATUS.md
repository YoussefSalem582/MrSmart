# Current status

> Snapshot derived from [TODO.md](TODO.md) and [../CHANGELOG.md](../CHANGELOG.md).
> Those are the source of truth; update them first.

**Version**: `0.1.0+1`, tag `v0.1.0` on `main` (2026-10-11). 60 tests.

| Phase | What | Status |
| --- | --- | --- |
| 1 | Scaffold and demo | Done |
| 2 | Reliable controls | Done |
| 3 | Home Assistant integration | Done (code + fake-server tests) |
| 4 | Validation and handover | Done |
| 5 | Real-world verification | **Next** |

## Verification

| What | Where | Result |
| --- | --- | --- |
| Demo mode, all demo controls, Leave room partial failure | iOS 26.5 simulator, iPhone 17 Pro | Works |
| Arabic RTL + dark mode | same | Works (numeric bidi fixed) |
| HA REST + WebSocket | In-memory fake HA (unit tests) | Pass |
| HA against a real instance | — | **Not done** |
| Physical device (lamp/plug) | — | **Not done** |
| Android | `flutter build apk --debug` | Builds; not run |

## Known limits

All `state_changed` events reach the phone (client-side filter) · activity
in memory only · Leave room needs the app open · long-lived tokens are a
dev convenience.
