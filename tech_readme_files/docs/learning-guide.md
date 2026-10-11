# Learning guide

Short definitions, each tied to where it shows up in MrSmart.

| Term | What it is | In MrSmart |
|---|---|---|
| **Entity** | One controllable or readable thing, addressed as `<domain>.<object_id>`, e.g. `light.desk_lamp`. A physical device can expose several entities. | `EntitySnapshot.id`; the selection screen lists entities, not devices. |
| **State** | An entity's current value as text (`on`, `off`, `21.5`), plus attributes (`friendly_name`, `unit_of_measurement`) and timestamps. `unknown` and `unavailable` are special values. | `EntityValue` (`OnOffValue`, `NumericValue`, `UnknownValue`, `UnavailableValue`). |
| **Integration** | Home Assistant code that talks to a brand or protocol (Hue, Zigbee, Shelly, MQTT…) and creates entities. | Not in the app; MrSmart only talks to Home Assistant. |
| **Service / action** | A command, `domain.service`, e.g. `light.turn_on`. Home Assistant calls the integration, which talks to the device. Newer HA versions call these *actions*. | `HaRoomRepository.setPower` → `POST /api/services/light/turn_on`. |
| **Event** | Something happened. `state_changed` fires whenever an entity's state changes, from any cause. | WebSocket `subscribe_events` → live updates and confirmations. |
| **Automation** | Trigger → condition → action rules that run inside Home Assistant, even when no app is open. | *Leave room* is deliberately **not** an automation: it needs the app. |
| **Scene** | A saved set of target states applied together ("Evening": lamp 30%, fan off). | Not used; *Leave room* is the app-side cousin. |
| **Hub** | The always-on box that bridges radios/protocols and runs automations. Home Assistant is a hub. | The thing MrSmart connects to. |
| **Local control** | The hub talks to the device on your LAN, no vendor cloud. Faster, works offline, fewer accounts. | MrSmart → HA is local too (LAN address, no cloud). |
| **MQTT** | A lightweight publish/subscribe protocol. Devices publish to topics (`home/lamp/state`), others subscribe. HA has an MQTT integration. | Not used directly; similar idea to the WebSocket event stream. |

## The one idea to keep

**Accepted ≠ done.** `POST /api/services/light/turn_on` returning 200 means
Home Assistant accepted the request. The lamp is only *confirmed* on when a
`state_changed` event, a returned changed state or a fresh read says
`on`. Even then it is Home Assistant's view: a lamp whose integration
cannot report back may still be wrong. MrSmart shows *pending*,
*confirmed*, *failed* and *not confirmed* separately for this reason.

Also: `POST /api/states/<id>` only rewrites Home Assistant's record. It does
not operate the device. Never use it for control.
