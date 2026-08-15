---
name: observe-glg
description: Query production app or access logs for a GDS-deployed service. Use when investigating a deployed-service symptom, checking production errors or 5xx responses, or measuring endpoint traffic.
---

Query Observe app and access logs via the installed `observe-glg` CLI. This is
the production-log branch of diagnosis: use it when the evidence lives in GDS
logs, then correlate the result with source code or deployment state as needed.

Start with `observe-glg --help` when syntax is uncertain. Keep the CLI's output
in a unique temporary directory and remove it after the investigation. Redact
tokens, credentials, customer data, request bodies, and unnecessary personal
information before quoting logs.

## Query setup

The installed binary's help is authoritative for flags, datasets, fields, and
output format. A typical query looks like:

```bash
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/observe-glg.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT
SERVICE="<service>"
START="-1h"
observe-glg -S "$SERVICE" -s "$START" -l 200 -O "$TMP_DIR/results.json"
```

The wrapper emits newline-delimited JSON by default. Count records with
`jq -s length`, not line counts. Treat a result limit as a cap, not a total.

## Workflow

### Service Name

When run in the context of a GLG Git repository, Service name should be the repository name,
plus the '%' wildcard prefix:

`observe-glg -S "%$(basename "$(git rev-parse --show-toplevel)")"`

### Determine investigation mode and read the workflow file

- **Specific issue** (error message, endpoint, symptom) → read `workflow-targeted.md`
- **No specific issue** ("check on X", "is X healthy?") → read `workflow-discovery.md`
- **Endpoint usage/traffic** ("how often is X called?", "who calls X?") → read `workflow-usage.md`

Read **only** the selected file for the determined workflow, then follow its steps.

## Source Code Correlation

Identify specific error messages, class names, or file references from logs, then match them to source code.

## Authentication and failures

Run the CLI normally and report authentication or VPN failures without
repeated retries. Never print the contents of its auth configuration. Empty
results mean only that no matching observations were returned for that query;
they are not proof that a service is healthy.

## Common Pitfalls

- **Wrong dataset**: App-only filters belong with `-i app`; access-only filters belong with `-i access`. Confirm with `observe-glg --help`.
- **Recent events**: Allow for ingestion delay before treating an empty result as meaningful; widen the window when appropriate.
- **Capped results**: Increase `-l` or state that the result is a lower bound.
- **Authentication**: If the CLI reports a VPN or authentication failure, stop and report the prerequisite.
