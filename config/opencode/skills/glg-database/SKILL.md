---
name: glg-database
description: Author and review GLG Epiquery SQL templates and SchemaTron database changes. Use when searching or changing epiquery-templates, choosing execution masks or query targets, preparing SchemaTron DDL, DML, code objects, or permissions, or troubleshooting Epiquery template behavior.
---

# GLG Database Work

Route database work through the repository that owns the change:

- Epiquery query discovery, application data access, and template changes:
  read [the Epiquery workflow](references/epiquery.md).
- Schema, one-time data, stored procedure, view, function, permission, and
  server-level changes: read
  [the SchemaTron workflow](references/schematron.md).
- Local Epiquery mounts, containers, diagnostics, and template execution: load
  `glg-localdev` and use its harness. Do not recreate that lifecycle here.

Search `~/github/glg/epiquery-templates/` before changing a GLG SQL template,
database query, or caller. Treat current repository instructions, nearby files,
callers, CI, and `CODEOWNERS` as authoritative; this skill supplies the route
and invariants, not a substitute copy of those sources.

## Establish The Target

Before editing or executing SQL, resolve from tracked evidence:

- the owning application and operation;
- the exact template path or SchemaTron platform/database directory;
- the database engine, connection name, and development environment;
- whether the operation reads data, writes data, or changes database objects;
- the expected cardinality, affected-row count, and sensitive-data exposure.

Do not guess a connection, database, execution mask, or deployment target.
Default validation to a development database. A request to author or review SQL
does not authorize database writes, DDL execution, merging, or deployment; get
explicit authorization before any such mutation. Never print credentials or
unnecessary customer or personal data, and bound exploratory reads.

## Shared Workflow

1. Inspect the owning repository's `AGENTS.md` or `CLAUDE.md`, `README.md`,
   nearby accepted files, CI, and caller before choosing syntax or placement.
2. Prefer modifying the existing template or code object over creating a
   parallel implementation.
3. Keep parameters bound rather than interpolated, minimize transaction scope,
   and make verification observable.
4. Validate against a development database and through the actual integration
   path required by the owning repository. Use `glg-localdev` for local
   Epiquery execution.
5. Inspect the final diff for target, access, performance, rollback, and data
   exposure risks. State any validation gap rather than implying the SQL ran.

When the user asks to open a pull request, load `pr`; its GLG issue and
publication rules remain authoritative. Creating a PR does not authorize merge
or deployment.

Completion requires the change to follow the correct repository branch,
placement, and safety rules, plus concrete development validation evidence. If
database access or the integration environment is unavailable, report exactly
what remains unverified.
