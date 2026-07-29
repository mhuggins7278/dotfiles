# GDS Deployment Investigation & Operations Methodology

Canonical playbook for querying, deploying, and troubleshooting GLG Deployment System (GDS)
infrastructure via the `gds` MCP server. Referenced by
`config/opencode/agent/deployment.md`.

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

## Tool Categories

The `gds` MCP server exposes three kinds of tools. Prefer a playbook tool over manual guesswork
whenever one exists — they encode current, authoritative GDS process instead of relying on
possibly-stale knowledge.

**Live lookups** — query real inventory/config:

| Tool | Purpose |
|---|---|
| Find deployment | Search the deploy inventory by app, service, repo, route, or hostname |
| List clusters | List all GDS clusters and their metadata |
| Get service config | Inspect a service's deployed config, files, orders, auth mode, image, and env (secrets redacted) |

**Playbooks** — step-by-step guided workflows:

| Tool | Purpose |
|---|---|
| Deploy app playbook | End-to-end workflow to deploy, release, or install an app on GDS |
| Watch deploy playbook | Monitor GH Actions → CC Watcher/CodeBuild → ECS rollout → route health after a push or commit |
| Edit config playbook | Workflow to add, change, or remove GDS app configuration |
| Orders audit checklist | Pre-commit checklist for clusterconfig changes (orders, secrets.json, policy.json, templates.json, service dirs) |
| Clusterconfig discovery playbook | Find which clusterconfig repo owns a given service, route, FQDN, or hostname |
| Auth setup playbook | Fix local `gh`, AWS CLI, Granted, SSO, or assumed-role blockers |

**Reference lookups** — documentation, not live state:

| Tool | Purpose |
|---|---|
| Architecture reference | Authoritative facts on clusters, orders, CC Watcher, reverse proxy, routing, session auth, build-and-push, Terraform, ECR, logs (by section 1–28 or topic) |
| Build reference | GitHub Actions, `glg/build-and-push`, ECR OIDC, image tags, healthcheck inputs, private dependency creds |
| Service guidelines | Runtime requirements: health checks, PORT binding, SIGTERM, logging, secrets, Dockerfile, 12-factor behavior |
| Verified session helper | Debug 401/403/302/307-to-bounce-host/connect failures that need `verifiedSession` |
| Whoami | Decode `session-*` headers the GDS reverse proxy injects, to debug identity/OAuth |

> **Known gap:** the `gds` server has no live "is this service healthy right now" or "is this job
> lock stuck" query. `get_service_config` returns static config, not task counts or events; the
> watch-deploy playbook only monitors a rollout right after a push. If a user needs current ECS task
> health or job lock state, say so plainly rather than inferring it from static config.

---

## Workflows

### Investigating a deployment
1. **Clarify scope** — confirm cluster ID and service name (or a search term) before querying
2. **Search if uncertain** — use find-deployment when the exact service/cluster isn't known
3. **Retrieve config** — get the service's deployed config, orders file, and environment
4. **Correlate** — connect the config with whatever symptom or question prompted the investigation
5. **Surface findings** — present clearly, flag anything unexpected, suggest next steps

### Deploying or releasing an app
1. Run the deploy-app playbook (with an app/FQDN hint if known) to get the current workflow
2. Execute the returned steps yourself — build/push, clusterconfig commit, etc. — using bash/git/gh
3. Run the watch-deploy playbook to confirm the rollout reaches ECS and the route is healthy
4. Report success only after the watch confirms a healthy rollout, not immediately after pushing

### Editing GDS configuration
1. Run the edit-config playbook to get the guided workflow — don't hand-edit clusterconfig from memory
2. If the owning repo isn't known, run the clusterconfig-discovery playbook first
3. Make the change, then run the orders-audit checklist **before committing** — mandatory for
   orders, `secrets.json`, `policy.json`, `templates.json`, or service directory changes
4. Commit, then run the watch-deploy playbook to confirm the change rolled out cleanly

### Troubleshooting auth / session issues

| Symptom | Use |
|---|---|
| Local `gh`/AWS CLI/Granted/SSO setup is blocking work | Auth setup playbook |
| A GLG/GDS URL 401s, 403s, or redirects to a session bounce host | Verified session helper |
| Need to confirm what identity/session headers a service actually sees | Whoami |

### General reference lookups

| Question type | Use |
|---|---|
| How does routing/auth/build/logging work? | Architecture reference (by section or topic) |
| CI/build questions (Actions, ECR, image tags, healthchecks) | Build reference |
| Runtime requirements for a service | Service guidelines |

---

## Key Concepts

### Orders File
The orders file is the source of truth for a deployment's intended configuration. Discrepancies
between the orders file and actual behavior indicate deployment drift — get the config before
speculating about why something isn't working as expected.

### Clusterconfig Repos
Each cluster's configuration lives in a clusterconfig repo. Don't assume which repo owns a service —
use the clusterconfig-discovery playbook rather than guessing from naming patterns.

### Deploy Lifecycle
A deploy is: app image push (build-and-push/ECR) → clusterconfig commit → CC Watcher/CodeBuild →
ECS rollout → route health. The watch-deploy playbook covers this whole chain, so use it instead of
manually polling individual stages.

---

## Communication Style

- Lead with the most important finding (broken/blocked > config detail > informational)
- Use tables for comparing multiple deployments or clusters
- Highlight warnings, drift, or anomalies in bold
- Always indicate which cluster and service you queried or acted on
- When a playbook tool returns a multi-step workflow, present the steps clearly before executing
  them, especially for deploys and config edits — these touch production infrastructure
- If a request needs live health/status info the `gds` server can't provide, say so directly
  instead of inferring it from static config
