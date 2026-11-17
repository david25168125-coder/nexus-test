# Nexus — Phase 1 dashboard iteration

This is a local source update, not a production release. Prepared for the user-authorized nexus-test repository after local dashboard checks.

Changes:
- Refreshed dark theme, typography, spacing and accessible header controls.
- Time-based greeting and a scrollable dashboard that keeps controls available during connection failures.
- Existing animated energy map and Riverpod/API integrations retained.
- Daily energy totals use the existing data model, with no invented forecasts or claims of whole-home health.
- Existing security, EV, water and settings routes retained.
- Energy-node taps now open reading sheets instead of unregistered routes.
- Missing system screens are labelled Not configured in the existing systems menu.
- Bundled licensed Roboto fonts and configured a local CanvasKit renderer for web startup without public CDN dependencies.
- Fixed the MG asset declaration and the dashboard entry point's missing daily_energy_panel import.
- Replaced the obsolete counter test with offline and narrow-screen dashboard tests.
- The energy API URL can be configured with --dart-define=NEXUS_API_URL=http://YOUR_CORE:8000; the existing localhost default remains.

Verification:
- Flutter dependencies resolved; the lockfile reflects the installed SDK's pinned dependencies.
- Eight widget tests pass, including responsive branding, existing navigation and all five energy-node reading sheets.
- The active application builds successfully for web.
- Scoped static analysis of home UI, theme, energy provider and tests has no errors. Existing warnings and SDK deprecation/style notices remain.
- Full-project static analysis reports pre-existing errors: obsolete NexusData constructor arguments in nexus_repository.dart; incorrect security overview import in navigation.dart; absent base_repository.dart used by SecurityRepository; missing TapAnimation arguments in tap_test_page.dart. These were outside this dashboard iteration and have not been silently replaced.

Limitations:
- Physical devices, Home Assistant, alarm hardware and NSPanel Pro have not been tested here.
- SecurityService in the supplied app simulates alarm state; its UI must not be treated as proof that a real alarm is armed.
- Existing backend energy state currently supplies zero placeholders for solar/battery values and does not establish full telemetry health. This update does not fix that backend behaviour.
- History, forecasting, battery optimisation, automation building and the full new navigation structure are subsequent work.
- NEXUS_API_URL currently configures the energy provider only; other supplied services retain their existing URLs.

Run from Nexus_App using a compatible Flutter SDK:

    flutter pub get
    flutter test
    flutter run -d chrome --dart-define=NEXUS_API_URL=http://YOUR_CORE:8000

Browser builds require the backend to allow the app's origin. Use the existing native platforms for target-device verification.

Browser screenshots use simulated readings, not telemetry from a real property. Browser checks block HTTPS requests to verify that the local renderer/font setup works without public CDNs.

## Branding feedback update

- Replaced default NEXUS header text with the supplied logo asset and an accessible Nexus label.
- Left-aligned the logo for Android/iOS and compact viewports; spacious desktops can centre it. Added an explicit alignment override for kiosks.
- Removed the Digitize Nexus footer from the animated energy display; the existing footer component remains available elsewhere.
- Preserved the large central House node, telemetry and animation behaviour.
- Matched landscape tap targets to the painter's existing node positions.
- Web build and eight widget tests pass. Scoped static analysis reports no errors, with pre-existing warning/deprecation/style notices retained.
