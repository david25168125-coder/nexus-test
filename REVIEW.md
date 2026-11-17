# Nexus UI review implementation

This increment evolves the existing Flutter application. It retains Home Assistant/Core integration paths, Riverpod state, the repository API, animated energy map and existing water controls. No backend migration or state-management rewrite was made.

## Desktop and branding

- The logo from Settings (`assets/digitize_nexus_logo.png`) is shared through NexusBrand.
- Large desktops show that logo at the top of a persistent sidebar; the header omits it to avoid duplicate branding. Phones and tablets retain the logo in the header and the compact systems menu.
- The energy map keeps House as the larger central node. Desktop node radii, icon sizes, labels and values grow proportionally. Android/iOS and compact touchscreen node sizes retain their prior scale.
- Painter positions and tap targets use shared geometry so enlarged desktop nodes still open the right reading sheets.
- Your Home, Connected, daily readings and home controls remain in the dashboard hierarchy.

## Overview pages

- Solar: Core generation, daily/month/year totals where supplied, the existing energy-flow visualisation and a forecast placeholder.
- Battery: Core state of charge, charge/discharge state, power and daily usage where supplied; a weather-aware optimisation placeholder. Positive battery power follows the existing charging convention.
- Heating: unavailable house and zone readings, unassigned zone examples, energy summary and placeholders for schedules and optimisation. No fabricated temperatures or active schedules.
- Security: the existing simulated SecurityController/Service provides preview arm/disarm and zone data. The preview is labelled explicitly and does not operate a physical alarm. Existing alarm naming now appears in the overview. Cameras, events and outputs remain unconnected placeholders.
- EV: supplied vehicle image is labelled as an illustration, not a detected vehicle. Core values replace the earlier hard-coded battery/range/session display. Missing values are shown as unavailable. Range and comfort features remain placeholders.
- EV charging controls call the existing repository methods for pause, fast/eco charging and schedule start/stop. Schedule entry validates a future start time and supports an overnight window. Requests have a ten-second UI timeout and show failure without clearing readings. These endpoints are not verified against physical hardware, and the supplied Python API may need their implementation. Schedules cannot yet be read back in this interface.

## Settings

Every existing Settings menu item has a destination. Account, appearance, units, tariffs, equipment, alerts and system pages explain their intended purpose and unconnected state; they do not pretend to save configuration. Vehicle Overview opens the EV page. Alarm Settings retains its existing session-local name edit/save behaviour and now uses the shared page theme.

## Missing data and integration limits

The energy model retains its legacy numeric defaults so the existing map is not rewritten. It also records which non-null JSON fields Core actually returned. New summary panels use that presence information to distinguish unavailable values from genuine zero readings. Explicit zeros returned by the backend may still be backend placeholders: this UI cannot infer device health from them.

The existing supplied backend uses zero placeholders for some equipment. Most device communication flags in the supplied model are also defaults rather than verified device health. No whole-building health or physical alarm protection is inferred.

The energy repository URL can be supplied with `--dart-define=NEXUS_API_URL=...`; other existing service URLs are unchanged. Forecasting, automatic battery optimisation, camera streaming, heating integrations and persistent settings are not implemented by this UI increment.

## Verification

- Active web application builds successfully.
- 18 widget tests cover four viewport/platform combinations, all Settings destinations, alarm preview arm/disarm, retained alarm-name editing, EV failure feedback, desktop-only map scaling, navigation, all five node taps, and missing versus zero readings.
- Changed app paths have zero static-analysis errors. Existing unused-helper and style/SDK-deprecation notices remain; see `docs/overview-analysis.txt`.
- Full-project analysis still identifies inherited errors in the older NexusData repository constructor, missing BaseRepository used by the old SecurityRepository, an outdated security navigation import, and the TapAnimation sample page. These inactive paths are documented rather than silently removed.
- Browser previews use simulated energy readings, with external HTTPS requests blocked to check local fonts/renderer startup. No physical Home Assistant, alarm, charger or NSPanel Pro was tested.
