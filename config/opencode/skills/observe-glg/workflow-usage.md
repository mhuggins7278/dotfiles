### URL Usage Stats

Use this workflow when the user wants to know how often an endpoint is called, who the callers are, or general traffic patterns for a URL path. The user may describe the endpoint using route-style placeholders (e.g. `consultations/:id`, `member/:memberId/profile`) — these must be converted to regex patterns for querying.

#### U1. Parse the endpoint pattern

Extract the URL path from the user's prompt. Convert route-style placeholders to regex wildcards:

| User says | Regex pattern |
|-----------|---------------|
| `consultations/:id` | `consultations/[^/?]+` |
| `member/:id/profile` | `member/[^/?]+/profile` |
| `/nm-api/user` | `/nm-api/user` (exact, no placeholders) |
| `survey/:surveyId/responses` | `survey/[^/?]+/responses` |

Rules:
- Replace `:paramName` segments with `[^/?]+` (matches one path segment, stops at `/` or `?`)
- Replace `*` wildcards with `[^?]*` (matches anything up to query string)
- If the user gives a path without a leading service prefix and you know the service name, prepend `/<service>/` (e.g. for service `nm-api` and path `member/:id`, use `/nm-api/member/[^/?]+`)
- Preserve the rest of the path literally

Store the resulting regex:
```bash
URI_PATTERN="<computed_regex>"
```

#### U2. Query access logs

Use the `-f` flag with a raw OPAL regex filter to match the URI pattern. Use a high limit — usage stats need volume.

```bash
SERVICE="<service_name>"
START="<time_range>"  # e.g. -30d, -7d, -24h
```

> **Why `-f` instead of `--request_uri`?** The `--request_uri` flag with `%` prefix does a contains match, but for route patterns with wildcards in the middle (e.g. `member/[^/?]+/profile`), a proper regex via `-f` is needed.

For simple patterns without mid-path wildcards (e.g. just a prefix), `--request_uri %<prefix>` is acceptable too.

#### U3. Check result count

```bash
ACCESS_COUNT=$(wc -l < /tmp/obs_access.json 2>/dev/null | tr -d ' ')
echo "Matching requests: $ACCESS_COUNT"
```

If 0 results:
1. Double-check the regex pattern — common mistakes include forgetting the service prefix in the path
2. Try a broader match (e.g. contains match on just a key segment)
3. Expand the time window

If results are capped at the limit, note this in the summary ("at least N requests — actual count may be higher").

#### U4. Analyze usage stats

Run the following jq analyses on `/tmp/obs_access.json`:

**Total request count:**
```bash
wc -l < /tmp/obs_access.json | tr -d ' '
```

**Breakdown by HTTP method:**
```bash
jq -r '.http_method' /tmp/obs_access.json | sort | uniq -c | sort -rn
```

**Status code distribution:**
```bash
jq -r '.status_code' /tmp/obs_access.json | sort | uniq -c | sort -rn
```

**Top callers by `src` query parameter:**
```bash
jq -r '(.request_uri | split("?") | if length > 1 then .[1] | split("&") | map(select(startswith("src="))) | first // "src=unknown" | ltrimstr("src=") else "no-src" end)' /tmp/obs_access.json | sort | uniq -c | sort -rn
```

**Top callers by http_referrer (path only):**
```bash
jq -r '(.http_referrer // "") | if . == "" or . == "null" or . == null then "no-referrer" else capture("https?://[^/]+(?<path>/.*)") | .path // "no-path" end' /tmp/obs_access.json | sort | uniq -c | sort -rn | head -20
```

**Top callers by user_agent (to distinguish browser vs service-to-service):**
```bash
jq -r '.user_agent // "unknown"' /tmp/obs_access.json | sort | uniq -c | sort -rn | head -10
```

**Traffic by cluster:**
```bash
jq -r '.cluster // "unknown"' /tmp/obs_access.json | sort | uniq -c | sort -rn
```

#### U5. Present findings

Present a structured summary. Do NOT dump raw logs. Format:

```
## Endpoint Usage: <pattern> (<service>)
**Time window:** <start> to <end>
**Total requests:** <count> (note if capped at limit)

### By HTTP Method
  GET:  1,234
  POST:    56

### By Status Code
  200: 1,180
  404:    82
  500:    28

### Top Callers (src param)
  1. prism      — 842 requests (68%)
  2. mosaic     — 203 requests (16%)
  3. no-src     — 189 requests (15%)

### Top Referrers
  1. /prism/member/.../overview  — 612
  2. /mosaic/consultation/...    — 198
  3. no-referrer                 — 480

### Top User Agents
  1. Mozilla/5.0 ...Chrome...   — 923 (browser traffic)
  2. axios/1.6.8                — 367 (service-to-service)
```

Guidelines:
- Calculate percentages for the top callers
- Group referrer paths by their app prefix (e.g. `/prism/...`, `/mosaic/...`) when there are many unique paths with IDs in them
- Distinguish browser traffic (Mozilla/Chrome/Safari user agents) from service-to-service traffic (axios, node-fetch, got, etc.)
- If the result set hit the limit, explicitly note that actual traffic is likely higher
