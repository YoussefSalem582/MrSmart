# Add a backend (another source for the room)

1. Implement `RoomBackend` in `lib/features/<source>/data/`.
2. Run the shared contract: in a test, call
   `roomBackendContract(create: ..., lightId: ..., lightInitiallyOn: ...)`.
3. Register a factory for a new `AppMode` in `lib/di/injection_container.dart`.
4. Domain and UI must not change. If they need to, the contract is wrong —
   fix the contract first and write an ADR.
