# Epiquery Templates

Use this branch for finding, authoring, reviewing, or troubleshooting templates
in `~/github/glg/epiquery-templates/` and for application code that calls them.

## Inspect First

Read the repository's current `CLAUDE.md`, relevant `README.md` sections,
nearby templates, caller, `CODEOWNERS`, and applicable workflows under
`.github/workflows/`. Resolve the template path and connection from source or
configuration rather than inventing them. When low-level transport, result
shape, or error behavior matters, inspect the current Epiquery client or
`epiquery2` implementation instead of relying on a remembered URL format.

Use an existing template when it already represents the operation. For a new
template, follow the owning service directory's naming and result-shape
conventions. Prefer `.sql`; never create a new `.mustache` template. Snowflake
may use `.snowflake`, but target-specific binding rules must come from current
nearby examples and implementation evidence.

## Required Header

Every template needs both transition-era execution masks. Begin with least
privilege and widen a mask only when the verified caller requires it:

```sql
/*
executionMasks:
  jwt-role-glg: 0
  session-role-glg: 0
glgjwtComment: 'Flag [0] includes = DENY_ALL'
*/
```

Masks are additive:

| Value | Role |
| ---: | --- |
| 0 | `DENY_ALL` |
| 1 | `USER` |
| 2 | `CLIENT` |
| 4 | `COUNCILMEMBER` |
| 8 | `SURVEYRESPONDENT` |
| 16 | `APP` |
| 32 | `EXTERNAL_WORKER` |
| 2147483647 | `ALLOW_ALL` |

Bits `2`, `4`, or `8` in either mask make the template external-facing and
trigger the DRE external ACL review gate. Do not copy a broad mask from a
nearby file without proving that the same caller population needs it. Keep the
comment consistent with the chosen value.

For a non-default backend, place the current repository-supported query target
after the mask, for example:

```sql
-- query-target: postgres
-- query-target: azure client-media
-- query-target: snowflake
-- query-target: salesforce
```

Some targets include a database name and alternate extensions may infer the
target. Copy the exact form from current guidance and a matching connection;
never bypass Epi-Screamer to hide a target mismatch.

## Parameters

SQL templates declare bound parameters immediately after the header and query
target:

```sql
--parameters:
--@clientId INT
--@startDate DATETIME request.startDate
```

The optional third token maps a differently named request-context key to the
SQL variable. Use caller evidence for names and types. Declare `VARCHAR` and
`NVARCHAR` without a length in the parameter block. Never interpolate values
into SQL. Do not apply SQL Server declarations to another backend without
checking that target's current binding convention.

Include runnable, non-sensitive test parameters in template comments when the
repository's PR guidance calls for them. Avoid real customer identifiers when
representative development data can be used.

## Query Shape And Safety

For read-only SQL Server templates, the standard preamble is:

```sql
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
```

Do not wrap a `SELECT` in a transaction. For atomic writes, prepare read logic
before the transaction and wrap only the statements that must succeed or fail
together. Do not use read-uncommitted isolation for writes.

Do not add `USE GLGLIVE`; the connection supplies the default database. Use an
explicit `USE <database>` when the query must target that database, including a
single non-default database, and current repository or caller evidence supports
it. Prefer bound, sargable predicates; constrain result sets; preserve
intentional multi-result-set shapes; and assess query frequency, target primary
versus replica, locking, and index use.

## Validation And Review

1. Run the SQL in isolation against a development database and verify values,
   nulls, empty results, cardinality, and expected affected rows.
2. Load `glg-localdev`, mount the selected templates worktree, and execute the
   template through its harness. The harness owns embedded-error detection and
   write authorization.
3. Review Epi-Screamer output and fix critical findings. Explain any warning
   intentionally retained.
4. Exercise the actual application caller when its mapping or result contract
   changed.

For a PR, document the use case, caller and frequency, target connection and
primary/replica expectation, test parameters, isolated SQL test, local
Epiquery test, performance implications, and retained warnings. All template
changes require a PR and normal approval from the directory Code Owner, or DRE
when no Code Owner exists. Templates with external mask bits `2`, `4`, or `8`
additionally require the DRE external ACL review gate. If explicitly asked to
merge, do so only when the user can monitor the deployment and verify the
change after the documented deployment window.

Troubleshoot from evidence: harness status and mounts, the Epiquery diagnostic,
the exact connection and template path, embedded response errors, and caller
mapping. Report VPN, authentication, or unavailable-development-data blockers
without exposing configuration secrets.
