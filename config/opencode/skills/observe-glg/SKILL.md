---
name: observe-glg
description: Queries production logs to troubleshoot GDS-deployed services. Use when the user asks to investigate, debug, or diagnose issues with a deployed GDS service, wants to see app/access logs for a service, or wants usage stats for an endpoint/URL path.
---

Query Observe app and access logs via the `observe-glg` CLI to diagnose issues with GDS-deployed services and analyze endpoint usage.

## CLI Reference

| Flag             | Dataset | Description                                                                                |
| :--------------- | :------ | :----------------------------------------------------------------------------------------- |
| `-S <service>`   | both    | Service name. Prefix with `%` for contains match                                           |
| `-s <start>`     | both    | Start time: `-1h`, `-30m`, `-3d`, `-1d12h`, `04:00`, `2026-03-05T04:00` (default: `-15m`)  |
| `-e <end>`       | both    | End time. Same formats + offset from start: `+1h`, `+1d` (default: now)                    |
| `-i app\|access` | —       | Dataset selection (default: `app`)                                                         |
| `-l <N>`         | both    | Result limit (default: 50)                                                                 |
| `-O <file>`      | both    | Write output to file (NDJSON)                                                              |
| `-f '<opal>'`    | both    | Free-form OPAL filter (repeatable)                                                         |
| `--log_level`    | app     | `ERROR`, `WARN`, `INFO`, `DEBUG` (repeatable, exact match)                                 |
| `--message`      | app     | Message content filter (always contains/regex match). `%` prefix accepted but not required |
| `--status_code`  | access  | Contains match: `5` matches all 5xx (repeatable)                                           |
| `--http_method`  | access  | Exact match: `GET`, `POST`, etc. (repeatable)                                              |
| `--request_uri`  | access  | URI filter. `%` prefix for contains match                                                  |
| `--cluster`      | both    | Cluster name (repeatable, exact match)                                                     |

**Key dataset fields:**

- **app**: `timestamp`, `message`, `log_level`, `service_name`, `cluster`
- **access**: `timestamp`, `http_method`, `request_uri`, `status_code`, `response_bytes`, `request_time`, `http_referrer`, `user_agent`, `starphleet_user`, `service_name`, `cluster`

> **`message_json` field:** JSON output includes a `message_json` field on each result. If `.message` is valid JSON (e.g. structured pino/fastify logs), `message_json` is the parsed object. If `.message` is raw text, `message_json` is `{"__text": "..."}`. The original `message` string is always preserved. Use `.message_json` for programmatic access and `.message` for the original log line.

> **Note:** `--message` always uses contains/regex match — no `%` prefix needed. The filter uses `string(message)` internally, so it matches both structured JSON and raw text message content.

> **Note:** `request_uri` includes the query string (e.g. `/my-api/items/123?src=prism`). The `src` query parameter is a convention used to identify the calling application. `http_referrer` contains the full Referer header URL.

**Service name quoting**: The `-S` flag is a plain CLI argument — the CLI handles OPAL quoting internally. Always quote shell variables when they may contain spaces or special characters:

```bash
observe-glg -S "$SERVICE" -s -1h
observe-glg -S "%my-prefix" -s -1h   # contains match
```

## Workflow

### Service Name

When run in the context of a GLG Git repository, Service name should be the repository name,
plus the '%' wildcard prefix:

`observe-glg -S %$(basename "$(git rev-parse --show-toplevel)")`

### Determine investigation mode and read the workflow file

- **Specific issue** (error message, endpoint, symptom) → read `workflow-targeted.md`
- **No specific issue** ("check on X", "is X healthy?") → read `workflow-discovery.md`
- **Endpoint usage/traffic** ("how often is X called?", "who calls X?") → read `workflow-usage.md`

Read **only** the selected file for the determined workflow, then follow its steps.

## Source Code Correlation

Identify specific error messages, class names, or file references from logs, then match them to source code.

## Cleanup

Always clean up temp files when the investigation is complete:

## Authentication

The CLI handles authentication automatically. No manual auth steps are needed before running queries.

**How it works:**

1. **Pre-flight check**: On startup, the CLI checks `~/.config/observe.yaml` (or `$OBSERVE_CONFIG`) for required fields (`customerid`, `site`, `authtoken`). If missing or incomplete, it runs `glgroup observe login` automatically.
2. **Query-time retry**: If a query fails with an auth error (expired token, 401, etc.), the CLI runs `glgroup observe login` and retries the query once.
3. **GLG session expiry**: If `glgroup observe login` triggers a browser-based GLG re-login ("Session: Saved"), the CLI retries credential provisioning automatically.
4. **No VPN**: If the GLG auth service is unreachable (ECONNRESET/ECONNREFUSED), the CLI stops with: "Connect to VPN and try again."

**For agents:** Auth is transparent. Just run `observe-glg` commands normally. If you see "Connect to VPN and try again", report this to the user as an unrecoverable error requiring VPN access. Do not retry further.

## Common Pitfalls

- **`observe-glg` CLI missing**: Run `gh api repos/glg/observe-glg/contents/install.sh --jq .content | base64 -d | sh`
- **Wrong dataset**: `--log_level` and `--message` require `-i app`; `--status_code`, `--http_method`, `--request_uri` require `-i access`. Mixing them causes a CLI error.
- **% prefix**: Use `%` for contains/regex matching on `-S` and `--request_uri`. Do NOT use `%` on `--log_level`, `--http_method`, or `--cluster` (these are exact match only). `--status_code` is always a contains match — no `%` needed. `--message` is always a contains match — `%` is accepted but not required.
- **Time format**: Relative times are negative from now (`-1h`). Positive offsets (`+1h`) only work with `-e` and are relative to the start time.
- **Result limit**: Default is 50. Use `-l 200` or higher for investigation to avoid missing patterns.
- **Log propagation delay**: Logs are NOT instantly available. Expect at least a **30-second** delay and possibly up to **2 minutes** between when an event occurs and when it appears in query results. If querying for very recent events (e.g. a request you just made), wait before querying or use a wider time window and re-query if results are empty.
- **Empty results**: Always check counts before analysis. Expand the time window before concluding there are no issues. If you are looking for a specific recent event, account for propagation delay before assuming it is missing.
- **Quoting**: Always double-quote shell variables (`"$SERVICE"`, `"$START"`). The CLI handles OPAL quoting for service names internally, but shell argument quoting still applies for variables containing spaces or special characters.
- **Auth errors**: The CLI handles auth automatically. If you see "Connect to VPN and try again", stop and inform the user — this is not retryable without VPN.
