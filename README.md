# Nexus

Flutter interface for the local-first Nexus building control platform.

This repository contains the first dashboard UI iteration, preserving the supplied animated energy map, Riverpod data flow, and existing security, EV, water and settings screens. It does not contain the separate Python backend.

## Verification

- Web build passes.
- Both dashboard widget tests pass, covering offline navigation, narrow-screen layout and the energy reading panel.
- Scoped dashboard analysis has no errors; warning and style/deprecation notices remain.
- Full-project analysis still reports errors in older files outside this dashboard iteration. See [review notes](REVIEW.md) and [analysis output](docs/full-project-analysis.txt).
- Physical devices, Home Assistant and NSPanel Pro have not been verified. Some existing security logic simulates alarm state.

## Run

```sh
flutter pub get
flutter test
flutter run -d chrome --dart-define=NEXUS_API_URL=http://YOUR_CORE:8000
```

`NEXUS_API_URL` configures the energy provider; other supplied services retain their existing endpoints. Replace `YOUR_CORE` with your local Nexus Core address. The Python API must run separately. Licensed Roboto fonts and the CanvasKit renderer load locally in web builds.

## Preview

These screenshots use **simulated energy readings**, not real home telemetry.

![Desktop dashboard](docs/dashboard-desktop.png)

[Phone-sized preview](docs/dashboard-mobile.png)

This is development source, not a commercial release. See [REVIEW.md](REVIEW.md) for scope and limitations.
