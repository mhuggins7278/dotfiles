# Shared AI Policy

This policy applies to OpenCode. Repository instructions add behavior specific
to the active project.

## Durable Rules

- Do not assign GitHub issues to the user unless they explicitly ask.
- Prefer specialized skills and agents when they provide needed tools,
  isolation, or meaningful parallelism. Do not delegate mechanically.
- Match the surrounding codebase's style, naming, comments, and formatter
  conventions. Handle relevant failure modes without adding speculative guards.
- Use Worktrunk (`wt`) for worktree creation, selection, listing, and removal.
  Do not call `git worktree` directly.

## Workflow Core

Follow the autonomy-first defaults in
`~/.dotfiles/config/ai/playbooks/workflow.md`. Treat named workflows as
optional capabilities, not mandatory phases. Ask only when uncertainty is
material or an irreversible external action needs authorization.

## Dotfiles Sources

When a request concerns configuration managed by `~/.dotfiles`, edit the
repository source rather than a symlink destination such as `~/.config/`.
Source files live under `~/.dotfiles/config/<tool>/` unless the configuration
is a root-level dotfile.

## GLG Repositories

For work under `~/github/glg/`:

- Use GitHub issues as the default coordination mechanism for production-bound
  work. An issue is required before merging, deploying, or releasing work that
  affects shared or production systems.
- Local experiments, POCs, spikes, temporary debugging, and throwaway
  prototypes do not require an issue. Keep exploratory work isolated and
  clearly named. When an experiment graduates into production work, create or
  associate an issue before opening the production PR, merging, or deploying.
- For branches intended to publish GDS images or deployments, use lowercase
  letters, numbers, and hyphens only. Do not block an existing PR solely
  because its branch contains `/`; this rule applies when creating branches.
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
