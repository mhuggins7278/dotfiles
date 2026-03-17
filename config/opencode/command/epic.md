---
description: Show epic status and pick up work across multiple repos
agent: plan
---

Load and execute the `epic` skill.

Arguments: $ARGUMENTS

Treat $ARGUMENTS as the epic issue reference. Accept any of these formats:
- Full URL: `https://github.com/glg/streamliner/issues/500`
- Short ref: `glg/streamliner#500`
- Number only (resolved against current repo): `500`

If $ARGUMENTS is empty, ask the user for the epic reference before proceeding.

Follow the epic skill workflow exactly (all phases: parse reference, fetch sub-issues, check PR status, parse dependencies, classify, display status board, recommend action, create worktree).

Examples:
- `/epic glg/streamliner#500` → fetches epic, shows board, recommends next ticket
- `/epic https://github.com/glg/streamliner/issues/500` → same, full URL form
- `/epic` (no args) → asks for the epic reference interactively
