# GDS Deployment Investigation Methodology

Canonical playbook for querying and interpreting GLG Deployment System (GDS) infrastructure.
Referenced by `config/opencode/agent/deployment.md` and `config/claude/agents/deployment.md`.

---

## GDS Cluster Naming Conventions

| Prefix | Type | Internet exposure |
|---|---|---|
| `s` | Secure | Internal only, requires auth |
| `i` | Internal | Internal only |
| `j` | Job / batch | Background processing |
| `p` | Public | Exposed to public internet |

Common clusters: `s01`, `i15`, `j01`, `p01`. Always confirm the cluster with the user if not
specified — running a query against the wrong cluster wastes time and can be misleading.

---

## Investigation Workflow

1. **Clarify scope** — confirm cluster ID and service name (or search pattern) before querying
2. **Search if uncertain** — when the exact deployment name is unknown, search first
3. **Retrieve deployment details** — get orders file, configuration, and metadata
4. **Check service status** — ECS service state, task count, recent events
5. **Check job status** — if the service has background jobs, check their lock and execution state
6. **Correlate** — connect deployment config with service behavior and any reported symptoms
7. **Surface findings** — present clearly, flag issues, suggest next investigative steps

---

## Key Concepts

### Orders File
The orders file is the source of truth for a deployment's intended configuration. Discrepancies
between the orders file and actual service state indicate a deployment drift.

### ECS Service Status
Check: desired count vs running count, task health, recent events (restarts, failures), and
deployment status (stable vs updating).

### Job Locks
GDS jobs use locks to prevent concurrent execution. A stuck lock means the job won't run until it
is released or expires. Always check lock status when a job appears to be not running.

---

## Communication Style

- Lead with the most important finding (service unhealthy > config change > informational)
- Use tables for comparing multiple deployments or clusters
- Highlight warnings or anomalies in bold
- Always indicate which cluster and service you queried
- Suggest related data that might be useful (e.g., "would you like me to check the job status too?")
- Flag any information that seems inconsistent or unexpected

---

## Common Investigations

| User asks... | Start with... |
|---|---|
| "Is X deployed?" | Search for X, check service status |
| "What version is running?" | Get deployment details / orders file |
| "Why isn't the job running?" | Check job status and lock state |
| "What changed in the last deploy?" | Get deployment history / orders diff |
| "Is X healthy?" | Get ECS service status, check task count and events |
