# Security notes

## Tokens

- The Home Assistant long-lived token is a secret with the full
  permissions of the HA user that created it. Use a dedicated test user.
- Stored only in platform secure storage (`flutter_secure_storage`):
  iOS Keychain with `first_unlock_this_device` (not synced to iCloud, not
  restored to another device); Android Keystore-backed storage.
- Never written to source, preferences, logs, analytics or crash reports.
  There are no analytics or crash reporters in this app.
- `AppLogger` passes every message through `redact()` (Bearer tokens,
  `*token`/`*secret`/`*password` JSON fields, JWT-shaped strings).
  The REST error log has only method, path and status. `HaCredentials.toString()`
  masks the token. The token field disables autocorrect, suggestions and
  IME learning.
- **Disconnect and erase credentials** (Settings) closes the session and
  deletes address, token and room selection. Also revoke the token in HA.

## Transport

- TLS certificate validation is never disabled or overridden.
- HTTPS is preferred. Plain HTTP:
  - App policy: accepted only in debug builds (`kReleaseMode` check in
    `ConnectHomeAssistant`); release builds reject `http://` before
    sending anything. HTTP shows an "unencrypted" warning.
  - Android: `android/app/src/debug/res/xml/network_security_config.xml`
    allows cleartext **in debug builds only**; release uses Android's
    default (no cleartext).
  - iOS: no App Transport Security exception was added. Dart's own
    networking (`dart:io`, used by Dio and the WebSocket) is not routed
    through ATS, so the app-level rule above is what blocks HTTP in
    release. `NSLocalNetworkUsageDescription` is set so iOS can ask for
    Local Network access.

## LAN assumptions

- The phone and Home Assistant share a trusted home network.
- MrSmart never configures remote access, port forwarding or cloud relays.
  Do not expose HA's port to the internet for this project.
- The app subscribes to **all** `state_changed` events and filters on the
  phone, so states of every entity in the house reach the phone's memory
  (not storage, not logs).

## Production gaps

- Long-lived tokens are not a multi-user authorization model: no scopes,
  no per-room permissions, no expiry handling, no refresh. A product
  should use HA's OAuth2 flow or a backend (see [architecture.md](architecture.md)).
- No certificate pinning; no root/jailbreak detection.
- Server-side event filtering (e.g. `subscribe_trigger`) is not used.
- Not verified against a real Home Assistant instance or real devices yet.
