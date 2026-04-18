### Targeted Investigation

Use this workflow when the user gives a specific issue (error message, endpoint, symptom).

#### T1. Extract keywords from the user's issue description

Identify: error messages, HTTP paths, status codes, method names, log levels, time ranges.

#### T2. Query app logs

Build the `observe-glg` command using extracted keywords. Always write to a temp file.

```bash
SERVICE="<service_name>"
START="-1h"

observe-glg -S "$SERVICE" -s "$START" --log_level ERROR --message "%<keyword>" -l 200 -O /tmp/obs_app.json
```

#### T3. Query access logs (if relevant)

If the issue involves HTTP endpoints, status codes, or latency:

```bash
observe-glg -S "$SERVICE" -s "$START" -i access --status_code <code> --request_uri "%<path>" -l 200 -O /tmp/obs_access.json
```

#### T4. Check results and expand time window if empty

```bash
APP_COUNT=$(wc -l < /tmp/obs_app.json 2>/dev/null | tr -d ' ')
ACCESS_COUNT=$(wc -l < /tmp/obs_access.json 2>/dev/null | tr -d ' ')
echo "App results: $APP_COUNT | Access results: $ACCESS_COUNT"
```

If **0 results**, expand the time window and re-run T2/T3:

1. `-s -1h` (initial)
2. `-s -24h`
3. `-s -3d`
4. `-s -7d`

Stop expanding once you get results or exhaust all windows.

#### T5. Correlate app + access logs

If you have both log types, merge by timestamp and look for patterns within a **±5 second window**:
- An error log at T → check access logs at T±5s for the triggering request
- A 5xx response at T → check app logs at T±5s for the root cause

Use the merged timeline jq pattern from Section 3. For each 5xx access entry, look for app log entries within ±5 seconds at ERROR or WARN level. Explain what the app was doing when the request failed.

#### T6. Present findings as narrative

Do NOT dump raw logs. Present:

1. **Summary**: Time window examined, total counts (errors, 5xx responses)
2. **Correlated incidents**: "At [time], POST /checkout returned 503. The app logged: 'DB connection timeout'. This occurred 12 times."
3. **Patterns**: Clustering by time, endpoint, cluster, error type
4. **Recommendations**: Suggested next steps or root cause hypothesis

Quote 2-3 representative log lines — not the full output.
