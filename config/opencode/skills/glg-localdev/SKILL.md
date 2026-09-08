---
name: glg-localdev
description: Run GLG local development through glgroup and Docker. Use for local.dev.glgresearch.com, host-app registration, Epiquery execution, or harness lifecycle.
---

# GLG Local Development

Use the machine-oriented harness rather than reproducing `glgroup`, Docker
Compose, process, or Epiquery lifecycle logic in the prompt:

```bash
HARNESS="$HOME/.config/opencode/skills/glg-localdev/scripts/localdev-harness.mjs"
node "$HARNESS" --help
```

The harness uses `~/github/glg/gds.clusterconfig.dev` as the central localdev
configuration by default. Override it with `--config-root` or
`GLG_LOCALDEV_CONFIG_ROOT`. It writes harness state and an ignored generated
Epiquery override under `~/.cache/glg-localdev`; it does not edit application
repositories, switch branches, pull repositories, or alter Streamliner's
existing bootstrap files.

## Current Project

From a GLG application worktree:

```bash
node "$HARNESS" project ensure --root "$(git rev-parse --show-toplevel)" --pretty
```

This resolves project metadata, generates the central Compose file when
missing, registers the project through native `glgroup localdev host-app`,
starts the localdev stack, reuses a matching process or starts the configured
project command, and verifies the generated service and route.

Known project metadata lives in the [project registry](references/projects.json).
An optional project-local `.glg-localdev.json` overrides the registry. Explicit
flags override both:

```bash
node "$HARNESS" project ensure \
  --root "$PWD" \
  --service example-api \
  --port 3000 \
  --security-mode verifiedSession \
  --command-json '["npm","run","dev"]'
```

When metadata is missing, inspect tracked project scripts, environment loading,
and matching GDS orders. Do not guess a port, service variant, UI/API target, or
security mode. Pass resolved values explicitly; ask only when tracked evidence
does not settle the choice.

`--no-start` registers an already-running project but fails when no matching
process owns the configured port. The harness never kills a process it did not
start and fails on an unrelated port owner.

## Epiquery Worktrees

Mount a selected `glg/epiquery-templates` checkout into both configured local
Epiquery services:

```bash
node "$HARNESS" epiquery ensure --templates-dir "$TEMPLATES_WORKTREE" --pretty
```

The harness writes an untracked override in its cache, starts localdev with the
base, repository, and generated overrides, verifies both Docker bind mounts,
and waits for the internal Epiquery diagnostic. The localdev stack is shared
state. Run `status` first; use `--replace` only when the current task is meant
to replace the worktree recorded by another harness invocation.

Execute a template with a JSON POST body:

```bash
node "$HARNESS" epiquery query \
  --connection GLGLIVE \
  --template path/to/getThing.sql \
  --params-json '{"id":123}'
```

The helper treats errors embedded in HTTP 200 responses as failures. It blocks
templates containing write or DDL statements and fails closed for legacy
`.mustache` templates unless `--allow-write` is passed; only pass that flag
after explicit authorization. Use `--summary-only` when rows are unnecessary,
and do not quote customer or personal data in reports.

To test an application against template changes, ensure Epiquery first and the
project second. Project startup automatically includes the active harness
Epiquery override.

## State And Cleanup

```bash
node "$HARNESS" status --pretty
node "$HARNESS" project stop --root "$PROJECT_ROOT" --pretty
node "$HARNESS" epiquery stop --pretty
```

Project cleanup stops only a harness-owned process and its host-app sidecar.
Epiquery cleanup stops the two harness-configured Epiquery services and removes
the generated override and state. Neither cleanup path removes Docker volumes,
prunes images, changes Git state, or runs the existing Streamliner bootstrap.

Use `--dry-run` before a new or uncertain setup. Dry runs emit planned commands
as JSON and do not create state. Local container/process changes are permitted
when they are necessary to fulfill the user's local testing request; commits,
pushes, deployments, database writes, and other external mutations retain their
normal authorization boundaries.

Completion requires observable evidence: the project route responds and the
reported process matches the worktree, or both Epiquery mounts match the
selected worktree and the requested template completes without embedded errors.
