# Add a device kind (e.g. `fan`)

1. `lib/features/room/domain/entities/entity_snapshot.dart`: add a
   `DeviceKind` value with its HA domain (`fan('fan')`).
2. `lib/features/home_assistant/data/ha_state_mapper.dart`: map the
   domain and its states.
3. `room_formatters.dart`: `kindText` + `kindIcon` cases.
4. `tool/gen_arb.py`: add `kindFan` in EN + AR, then regenerate.
5. Tests: a mapper case + a repository test that the right service path is called.
6. Safety: is it a non-critical load? If not, don't add it.
