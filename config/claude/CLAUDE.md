# Global Agent Guidelines

## Dotfiles Path Rules

When working inside `~/.dotfiles`, treat home config paths as symlinked targets.

- Never edit files under `~/.config/`, `~/.claude/`, or other symlink destinations directly.
- Always edit the source file in this repo under `~/.dotfiles/config/`.
- If a user references `~/.config/<tool>/...`, translate it to `~/.dotfiles/config/<tool>/...`.
- If a user references `~/.claude/...`, translate it to `~/.dotfiles/config/claude/...`.
- Prefer repo-relative paths in tool calls to avoid unnecessary permission prompts.

## Shared Playbooks

Canonical methodology for all agents lives in `config/ai/playbooks/`. Agent
files in `config/claude/agents/` inline this content with a comment pointing
back to the source. When agent behavior needs updating, edit the playbook at
`config/ai/playbooks/<name>.md` first, then sync `config/claude/agents/<name>.md`.

| Playbook | Corresponding agent |
|----------|---------------------|
| `config/ai/playbooks/code-review.md` | `config/claude/agents/code-reviewer.md` |
| `config/ai/playbooks/docs-research.md` | `config/claude/agents/docs.md` |
| `config/ai/playbooks/browser-testing.md` | `config/claude/agents/browser.md` |
| `config/ai/playbooks/ui-dev.md` | `config/claude/agents/ui-dev.md` |
| `config/ai/playbooks/gds-deployment.md` | `config/claude/agents/deployment.md` |
| `config/ai/playbooks/employee-lookup.md` | `config/claude/agents/whois.md` |

## Available Subagents

- **code-reviewer**: Reviews recent code changes for bugs, edge cases, and quality issues
- **docs**: Documentation specialist for fetching library docs using Context7
- **browser**: Browser automation and web testing specialist using Playwright
- **ui-dev**: Frontend UI development specialist for React and Material-UI with Figma integration
- **deployment**: GLG Deployment System (GDS) specialist for infrastructure queries
- **whois**: Employee directory specialist for finding and looking up GLG employees

## GitHub Issues

- **Do not assign issues** to the user unless explicitly asked. Create issues unassigned by default.

## Git Workflow

- **Branch names must not contain `/`** — slashes break the deployment pipeline when promoting branches
  to the testing environment. Use hyphens as separators instead (e.g., `feature-my-thing`, not
  `feature/my-thing`).

## GLG Repositories

When working in any repository under `~/github/glg/`:

- **SQL Templates & DB Queries**: If the project references SQL files, epiquery templates, or database
  queries, always search `~/github/glg/epiquery-templates/` for the relevant templates. This central
  repository is the source of truth for database queries across all GLG projects.
- **Issue-First Workflow**: Require an associated GitHub issue for all implementation work. Accept
  either (1) a user-provided issue at session start, or (2) creating a new issue after planning but
  before the first code edit, commit, or PR. If no valid open issue is found, pause and prompt the
  user to create one before proceeding.
- **Project Tagging**: When creating the issue, add it to `glg` project `92` (`Enterprise
  Integration`).

## Code Style

- Use TypeScript with proper types when applicable
- Prefer const over let, modern ES syntax
- Include error handling, descriptive variable names
- Comments for complex logic only
- Format with language-specific tools (prettierd, stylua, etc.)

## Daily Notes Policy

The `daily-notes` skill is the source of truth for the shared daily-note capture model: section
structure, task-note conventions, status values, backlinking, and quick inline operations.

Longer workflows (morning planning, carryover, end-of-day review, meeting transcripts, weekly
summaries, and larger cleanup passes) are defined in the notes vault's `CLAUDE.md` at
`~/github/mhuggins7278/notes/CLAUDE.md`. Open a session there for those workflows.

Global rules that apply everywhere:

- **Do not** carry forward tasks whose task file has `status: done` or `status: cancelled`
- **Do not** auto-copy yesterday's Notes section into today's file
- Prefer structured edits — place items under the correct section heading rather than appending to
  the end of the file

## Notes Vault (`~/github/mhuggins7278/notes`)

Rules that apply when working in the notes vault:

### Daily Note Location

Daily notes are flat files at `dailies/YYYY-MM-DD.md`. The Obsidian Daily Notes plugin is configured
with `folder=dailies` and `format=YYYY-MM-DD`.

### Task Notes

Standalone task records live at `work/tasks/<slug>.md`. Daily note task sections (Tasks, Waiting On,
I Owe, After Hours) contain wikilinks to task files — not raw checkboxes. The task file's `status`
field is canonical.

Create task notes with: `obsidian create path=work/tasks/<slug> template=task`

### Meeting Files

- **One-off meetings**: `meetings/YYYY-MM-DD-Meeting Title.md`
  — create with `obsidian create path=meetings/YYYY-MM-DD-Title template=meeting-one-off`
- **Recurring occurrences**: `meetings/YYYY-MM-DD-Series Title.md`
  — create with `obsidian create path=meetings/YYYY-MM-DD-Title template=meeting-occurrence`
- **Series files** (metadata only): `work/meetings/<Series Name>.md`
- Backlink from the daily note as `[[meetings/YYYY-MM-DD-Title|Title]]`

### Recurring Meeting Series

| File | Description |
| --- | --- |
| `work/meetings/JB 1x1.md` | Bi-weekly 1x1 with manager |
| `work/meetings/Service Leads.md` | Service Dev Leads sync |
| `work/meetings/Eng Managers.md` | Engineering Managers sync |
| `work/meetings/CSX Team Sync.md` | CSX team standup |
| `work/meetings/Priya 1x1.md` | 1x1 with Priya |

For recurring meetings, create an occurrence file (going forward; no backfill). Do not add session
notes directly to the series file.
