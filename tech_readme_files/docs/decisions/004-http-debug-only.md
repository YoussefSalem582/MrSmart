# 004 — Plain HTTP only in debug builds

## Context
Most home HA installs are `http://<lan-ip>:8123`. HTTP sends the token in
clear text. Dart's `dart:io` networking does not go through iOS ATS, so
platform switches alone don't enforce anything on iOS.

## Decision
App-level rule in `ConnectHomeAssistant`: `allowInsecureHttp = !kReleaseMode`.
Release builds refuse `http://` before sending anything. Android gets a
cleartext network config in `src/debug` only. HTTP shows a warning.
TLS validation is never disabled.

## Consequences
Learning on a LAN works in debug; a release build needs HTTPS with a
trusted certificate.
