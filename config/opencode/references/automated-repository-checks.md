# Automated Repository Checks

`check-principles.sh` runs a small cross-repository hygiene check before
commits and pull requests. It is not a substitute for tests, linters, or
proportional review, and it should not be presented as a quality verdict in a
PR.

## Checks

1. Changed diffs must not introduce merge-conflict markers beginning with
   `<<<<<<<`.
2. Changed JavaScript and TypeScript source files must not contain
   `console.log`. Paths containing `test`, `spec`, or `story` are treated as
   test or demonstration code and excluded.

The second check is intentionally narrow and heuristic. It is a candidate for
replacement with repository-specific lint rules if a project has legitimate
`console.log` use cases or a structured logging convention.

## Scope

- With no argument, the checker examines staged changes. The commit workflow
  stages intended files before running it.
- With a Git diff range, such as `origin/main...HEAD`, it examines that range.
  The PR workflow uses this form because the index is normally empty after the
  ticket has been committed.
- The checks cover changed paths and the current working-tree contents of those
  paths. They do not inspect unrelated files.
