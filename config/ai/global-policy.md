# Shared AI Policy

This policy applies to OpenCode. Tool-specific adapters and repository
instructions add only behavior that cannot be shared here.

## Durable Rules

- Do not assign GitHub issues to the user unless they explicitly ask.
- Prefer specialized skills and agents when the task matches their scope.
- Shared specialist methodology lives in `config/ai/playbooks/`; tool adapters
  must not become independent copies of that methodology.
- Match the surrounding codebase's style, naming, comments, and formatter
  conventions. Handle relevant failure modes without adding speculative guards.

## Workflow Core

For planning and execution, follow
`~/.dotfiles/config/ai/playbooks/workflow.md`. Do not introduce additional
approval gates or restart a prior workflow phase unless that playbook requires
it.

## Dotfiles Sources

When a request concerns configuration managed by `~/.dotfiles`, edit the
repository source rather than a symlink destination such as `~/.config/`.
Source files live under `~/.dotfiles/config/<tool>/` unless the configuration
is a root-level dotfile.

## GLG Repositories

For work under `~/github/glg/`:

- Require an associated GitHub issue before implementation, commits, or pull
  requests. If no valid open issue exists, pause for the issue workflow.
- Branch names must use hyphens, not `/`.
- Search `~/github/glg/epiquery-templates/` before changing SQL templates or
  database queries.
- Load `~/.dotfiles/config/opencode/references/glg-workflow.md` for project
  tagging and other procedural details.

## Notes Routing

- Use `daily-notes` to capture, update, or complete notes and task records.
- Use `exec-assistant` for prioritization, follow-up triage, and meeting
  preparation. Do not use `daily-notes` for judgment or recommendations.
- For larger notes-vault workflows, use the vault guidance at
  `~/github/mhuggins7278/notes/CLAUDE.md`.
- When working with notes, do not carry forward `done` or `cancelled` tasks,
  do not copy yesterday's Notes section automatically, and make structured
  edits under the appropriate heading.
