# Water overview data

The Flutter UI retains the existing GET `/api/water/status`, POST `/api/water/valve` (`open` / `close`) and POST `/api/water/lock` (`lock` / `unlock`) endpoints. The supplied Python backend is unchanged by this UI increment.

Existing status fields are `flow_lpm`, `battery_percent`, `valve_open`, `valve_locked` and `last_update`. The Water page displays values reported by Core; a Core response is not independent hardware verification. Missing/invalid fields are labelled unavailable. Missing consumption is not converted into fabricated sample totals, and absent leak status is not treated as leak-free.

The UI also accepts these **optional future meter fields** on the same status response:

```json
{
  "daily_liters": 112.4,
  "month_liters": 540.2,
  "year_liters": 1200.0,
  "leak_detected": false,
  "alerts": [],
  "usage_history": [
    {"date": "2026-11-16", "liters": 94.0},
    {"date": "2026-11-17", "liters": 112.4}
  ]
}
```

These are illustrative values, not measurements. Consumption values must be finite, nonnegative numbers in litres. History entries are daily totals with ISO calendar dates; valid entries are sorted and the most recent seven are plotted. Invalid entries are ignored. An empty history displays an intentional no-data chart area, without sample bars. Current flow is litres per minute and is never used to invent a daily total.

`leak_detected` is a boolean from an actual detection source. When absent, leak monitoring is labelled unconnected. `alerts` is an optional list of readable strings: an absent list means the alert feed is unconnected; an explicitly empty list means Core reported no alerts in that response. Low meter battery, reported leaks and local communication failures are surfaced independently. Leak analytics and smart-meter setup are future work, not operating detection functions.

While open, Water refreshes on entry and every 15 seconds, with the existing service's five-second network timeout. Manual refresh remains available. Refresh failures retain old values only with a stale-data message and disabled valve commands. Requests are not duplicated while another command is pending. Successful command responses trigger a status refresh; failures are shown instead of silently changing valve state.

`--dart-define=NEXUS_API_URL=http://YOUR_CORE:8000` now configures Water as well as Energy. The default remains `http://127.0.0.1:8000`.
