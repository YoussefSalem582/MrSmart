# Connecting Home Assistant

You need an existing Home Assistant (HA) instance on your local network.
MrSmart does not install, expose or configure Home Assistant.

## 1. Create a token

1. In Home Assistant, open your user profile (bottom-left) → **Security**.
2. Under **Long-lived access tokens**, create one named `MrSmart`.
3. Copy it once; HA does not show it again.

A long-lived token can do **everything that user can do**. For learning,
create a separate non-admin HA user and make the token as that user.
Revoke it from the same screen when you are done.

## 2. Connect the app

- Address: `http://homeassistant.local:8123` or `http://<lan-ip>:8123`.
  - Debug builds accept `http://` (unencrypted) for local learning and show
    a warning.
  - Release builds require `https://` with a certificate the phone trusts.
    MrSmart never disables certificate validation.
- Paste the token → **Test and save**. The app calls `GET /api/` and
  `GET /api/config` and shows the location name and HA version.
- iOS asks for **Local Network** permission the first time; allow it.
- The phone must be on the same network as Home Assistant. Do **not**
  forward port 8123 on your router or expose HA to the internet for this.

## 3. Practise without hardware: virtual helpers

Helpers are entities that exist only inside Home Assistant. They are
perfect for learning the flow (select → toggle → event → confirmation),
but they are **not** physical devices: they change instantly, never time
out, and never fail the way a real radio link does. Don't read helper
behaviour as proof that a real device works.

In **Settings → Devices & services → Helpers → Create helper**:

| Create | Settings | Shows up in MrSmart as |
|---|---|---|
| **Toggle** | Name: `Learning lamp` | `input_boolean.learning_lamp` (Helper toggle) |
| **Toggle** | Name: `Learning plug` | `input_boolean.learning_plug` |
| **Number** | Name: `Learning temperature`, min 10, max 35, step 0.5, unit `°C` | (not shown; used by the next helper) |
| **Template → Template a sensor** | State: `{{ states('input_number.learning_temperature') }}`, unit `°C`, device class *Temperature*, state class *Measurement* | `sensor.<name>` (Temperature) |

Then in MrSmart → Settings → **Choose room devices**, tick the two
toggles and the template sensor.

Try:

- Flip `Learning lamp` in the HA web UI → MrSmart updates within a second
  and logs *changed outside the app*.
- Move the Number helper → new temperature reading with HA's unit.
- Delete a selected helper in HA → the card shows *Removed from the source*.
- Stop HA or turn off Wi-Fi on the phone → *Offline*, stale values, controls
  disabled; reconnect → fresh read.

### Optional: a virtual *light*

A `light` entity needs the Template integration. YAML syntax changes
between HA releases, so check the current
[Template integration docs](https://www.home-assistant.io/integrations/template/)
for your version before copying anything. The idea is a template light
whose `turn_on`/`turn_off` call `input_boolean.turn_on/turn_off` on a
helper and whose state follows that helper.

## 4. Replace one helper with a real lamp or plug

No purchase is required to learn with MrSmart. If you already own a device,
or decide to get one later:

1. **Check compatibility first.** Look it up in the
   [Home Assistant integrations list](https://www.home-assistant.io/integrations/)
   and prefer **local** integrations (Zigbee via ZHA or Zigbee2MQTT with a
   coordinator you already have, Matter, Shelly, or other local-API
   devices). Avoid devices that need a vendor cloud.
2. Plug a **lamp** (or similar non-critical load) into it. Not heaters,
   pumps, medical or security equipment.
3. Add it in HA (*Settings → Devices & services → Add integration*) and
   check that flipping it in HA's own UI works and that HA shows the
   state changing back when you press its physical button.
4. In MrSmart: **Settings → Choose room devices**, untick the helper,
   tick the new `light.*` or `switch.*`. No code changes.
5. Compare with the helper: real latency, the *waiting for confirmation*
   line, what happens when you unplug it (*Unavailable*), and what happens
   when its radio is out of range (*Not confirmed*).
