### Discovery Investigation

Use this workflow when the user gives no specific issue (just a service name, "check on X", "is X healthy?").

#### D1. Query errors from app logs

```bash
SERVICE="<service_name>"
START="-1h"

observe-glg -S "$SERVICE" -s "$START" --log_level ERROR -l 200 -O /tmp/obs_app.json
```

#### D2. Query 5xx responses from access logs

```bash
observe-glg -S "$SERVICE" -s "$START" -i access --status_code 5 -l 200 -O /tmp/obs_access.json
```

#### D3. Check result counts

```bash
APP_COUNT=$(wc -l < /tmp/obs_app.json 2>/dev/null | tr -d ' ')
ACCESS_COUNT=$(wc -l < /tmp/obs_access.json 2>/dev/null | tr -d ' ')
echo "App errors: $APP_COUNT | Access 5xx: $ACCESS_COUNT"
```

#### D4. Expand time window if both are empty

If **both** queries return 0 results, expand and re-run D1 + D2:

1. `-s -1h` (already done)
2. `-s -24h`
3. `-s -3d`
4. `-s -7d`

Stop as soon as either returns results. If all windows return 0: tell the user the service appears healthy — no errors or 5xx in the last 7 days.

#### D5. Summarize recurring issues

If results exist, analyze and present a **numbered list of top issues**:

```bash
jq -r 'select(.log_level == "ERROR") | .message_json | if .__text then .__text else (. | tostring) end' /tmp/obs_app.json | sort | uniq -c | sort -rn | head -10
```

```bash
jq -r '"\(.status_code) \(.http_method) \(.request_uri)"' /tmp/obs_access.json | sort | uniq -c | sort -rn | head -10
```

Present as:
```
Top issues for <service> (last <window>):
1. [42 occurrences] ERROR: NullPointerException in UserService.getProfile — first seen 12:03, last seen 12:58
2. [18 occurrences] 503: POST /api/checkout — first seen 12:15, last seen 12:45
3. ...
```

#### D6. Ask user which issue to investigate

Present the numbered list and ask which one to dig into. Then switch to **Targeted Investigation** (load `workflow-targeted.md`) using that issue's keywords.
