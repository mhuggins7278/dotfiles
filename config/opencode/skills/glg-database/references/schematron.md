# SchemaTron Changes

Use this branch for database schema, code-object, permission, one-time data, or
server-level changes in `~/github/glg/SchemaTron/`. SchemaTron is PR-based
change control; DRE reviews and executes deployable changes.

## Classify And Place The Change

Read the current `CLAUDE.md`, `README.md`, PR template, relevant platform and
database tree, and nearby accepted changes before creating a file. Platform
layouts vary, so resolve the concrete destination from the repository rather
than extrapolating from `SqlServer/GLGLIVE`.

| Change | Placement |
| --- | --- |
| Existing procedure, function, view, or other code object | Modify its existing file under `code/` |
| New code object | Appropriate `code/<object-type>/` directory |
| One-time DDL | Target database's `schema_changes/` directory |
| One-time DML | Target database's `data_changes/` directory |
| Roles, users, or grants | Existing `roles/`, `users/`, or `permissions/` structure |
| Server-level operation outside those categories | `change-control/` record |

Do not duplicate an existing code object in a dated change file when the
repository expects the canonical object file to be edited in place.

## Names And Ordering

Run `date` when creating a date-sensitive file; never infer the date from the
conversation. Data and schema changes use:

```text
YYYYMMDD_short_descriptive_text.sql
```

When multiple files have a required execution order, use the repository's
documented step form:

```text
YYYYMMDD_Step1_description.sql
YYYYMMDD_Step2_description.sql
```

Preserve the existing name for a canonical code object. Change-control records
are Markdown and use `YYYY_MM_DD_very_short_description.md`; follow
`change-control/README.md` exactly.

## SQL Safety

For SQL Server data and schema changes, start from the repository's documented
testable shape rather than an arbitrary production script:

```sql
USE <database>;

SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- Show the relevant state before the change.
SELECT ...;

-- Apply the bounded change.
UPDATE ...;
SELECT @@ROWCOUNT;

-- Prove the intended state after the change.
SELECT ...;

ROLLBACK TRANSACTION;
SELECT @@TRANCOUNT;
```

Leave the safe test rollback in the submitted script when current repository
guidance says DRE will change it during deployment. Make predicates narrow and
auditable, expose the affected-row count, show before/after evidence, and make
rerun or partial-failure behavior explicit. Never execute a write or DDL change
without explicit authorization, and never execute the deployment on DRE's
behalf unless the user specifically authorizes that external mutation and the
normal deployment process permits it.

The template above is T-SQL-specific. For PostgreSQL, Snowflake, MySQL, or
Azure variants, use syntax and transaction behavior verified from current
repository guidance and nearby accepted changes. Do not paste SQL Server
transaction or row-count syntax into another engine.

## Validation And Handoff

1. Verify the platform, database, object ownership, dependencies, and
   applications or Epiquery templates affected.
2. Test on the correct development database. Capture the command or tool used,
   before/after evidence, expected versus actual row counts, and rollback
   behavior without exposing sensitive values.
3. Inspect for locks, table scans, long transactions, non-idempotent retry
   behavior, irreversible data loss, and deployment ordering.
4. Ensure the final file is deployable without DRE needing to infer intent or
   contact the author.

The PR must explain what and why, link the originating ticket or documentation,
describe development testing, link relevant Epiquery templates, identify
affected audiences and notifications, and provide a rollback plan when a Git
revert is insufficient. Use a draft PR if the change is not deployment-ready;
a ready PR enters DRE's work queue. The submitter remains responsible for
post-deployment verification and closure evidence.
