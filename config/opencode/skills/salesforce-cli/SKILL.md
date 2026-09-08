---
name: salesforce-cli
description: Operate a Salesforce org or DX project with the `sf` CLI. Use for authentication, metadata, SOQL, Apex, tests, or project inspection.
---

# Salesforce CLI

Use the modern `sf` CLI. Start by checking the locally installed command help
when flags or command names are uncertain because installed plugins define the
available surface.

## Establish Context

1. Confirm the CLI is available with `sf --version`.
2. From a Salesforce project, inspect `sfdx-project.json` and use
   `sf org list --all` to identify available org aliases.
3. Pass `--target-org <alias>` on all org-changing commands unless the project
   explicitly defines the intended default org.
4. Before a consequential action, use `sf org display --target-org <alias>` to
   confirm the username, instance, and org type.

Do not expose access tokens, auth URLs, or the sensitive output of
`sf org display --verbose`.

## Authentication

For an interactive login, run:

```bash
sf org login web --alias <alias> --set-default
```

Use the repository's documented auth method for CI or noninteractive work.
Never write credentials, auth files, or access tokens into the repository.

## Metadata

Run deploy and retrieve operations from inside a Salesforce DX project.

Use an explicit, narrow target for routine work:

```bash
sf project deploy start --source-dir force-app/main/default/classes \
  --target-org <alias> --wait 10

sf project retrieve start --metadata ApexClass:ExampleClass \
  --target-org <alias>
```

Prefer `--dry-run` before a production deploy. Select the test level that the
target and deployment require; use `RunLocalTests` for a production deploy
containing Apex unless the repository's release process says otherwise.

`--ignore-conflicts`, `--ignore-warnings`, `--ignore-errors`, and destructive
change flags can mask data loss or partial deployments. Explain the effect and
ask for confirmation before using them.

## Data And Apex

Treat data mutations and anonymous Apex as consequential. Show the exact
command or script and get confirmation before executing inserts, updates,
deletes, or Apex that can change data or configuration.

Use SOQL for read-only inspection:

```bash
sf data query --query "SELECT Id, Name FROM Account LIMIT 10" \
  --target-org <alias>
```

For anonymous Apex, place the code in a temporary local `.apex` file and run:

```bash
sf apex run --file /path/to/script.apex --target-org <alias>
```

Run targeted Apex tests with `sf apex run test`; inspect `sf apex run test
--help` first to select suitable test and result flags.

## Output And Diagnostics

Use `--json` when command output will be parsed or compared. Otherwise retain
human-readable output. For failures, first re-run the relevant command with
its help or diagnostics, preserve the deploy/job ID, and use the corresponding
report or resume command instead of repeating a potentially destructive action.

Useful discovery commands:

```bash
sf search <terms>
sf <command> --help
sf plugins
sf doctor
```

## Completion

For a deploy, retrieve, query, or test run, report the exact target org,
command, result or job ID, and verification state. A submitted asynchronous
job is not a completed deployment: inspect its result with the CLI's report or
resume command. For mutations, include the confirmation boundary and any
warnings or partial-failure state.
