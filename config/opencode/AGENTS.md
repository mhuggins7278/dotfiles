# Global Agent Guidelines

## Dual-Tool AI Setup

This dotfiles repo manages config for both OpenCode and Claude Code. They share
canonical workflow methodology via shared playbooks.

| Component | Source path |
|-----------|-------------|
| OpenCode global instructions | `config/opencode/AGENTS.md` (this file) |
| OpenCode agents | `config/opencode/agent/*.md` |
| Claude Code global instructions | `config/claude/CLAUDE.md` |
| Claude Code agents | `config/claude/agents/*.md` |
| Shared skills | `config/opencode/skills/` (symlinked into both tools) |
| Shared playbooks | `config/ai/playbooks/` |

Agents in both tools reference their canonical methodology in `config/ai/playbooks/`.
When updating agent behavior, update the playbook first, then sync both agent files.

## Dotfiles Path Rules

When working inside `~/.dotfiles`, treat home config paths as symlinked targets.

- Never edit files under `~/.config/` directly.
- Always edit the source file in this repo under `~/.dotfiles/config/`.
- If a user references `~/.config/<tool>/...`, translate it to `~/.dotfiles/config/<tool>/...`.
- Prefer repo-relative paths in tool calls (for example, `config/opencode/...`) to avoid unnecessary permission prompts.

## Available Subagents

- **docs**: Documentation specialist for fetching library docs using Context7
- **browser**: Browser automation and web testing using Chrome DevTools
- **whois**: GLG employee directory lookup specialist
- **deployment**: GLG Deployment System (GDS) infrastructure specialist
- **ui-dev**: Frontend UI development with React/Material-UI and Figma
- **review**: Code reviewer for catching bugs and issues before committing

## GitHub Issues

- **Do not assign issues** to the user unless explicitly asked. Create issues unassigned by default.

## Git Workflow

- **Branch names must not contain `/`** — slashes break the deployment pipeline when promoting branches to the testing environment. Use hyphens as separators instead (e.g., `feature-my-thing`, not `feature/my-thing`).

## GLG Repositories

When working in any repository under `~/github/glg/`:

- **SQL Templates & DB Queries**: If the project references SQL files, epiquery templates, or database queries, always search `~/github/glg/epiquery-templates/` for the relevant templates. This central repository is the source of truth for database queries across all GLG projects.
- **Issue-First Workflow**: Require an associated GitHub issue for all implementation work. Accept either (1) a user-provided issue at session start, or (2) creating a new issue after planning but before the first code edit, commit, or PR. If no valid open issue is found, pause and prompt the user to create one before proceeding.
- **Project Tagging**: When creating the issue, add it to `glg` project `92` (`Enterprise Integration`).

## Code Style

- Use TypeScript with proper types when applicable
- Prefer const over let, modern ES syntax
- Include error handling, descriptive variable names
- Comments for complex logic only
- Format with language-specific tools (prettierd, stylua, etc.)

## Notes Skills Policy

The `daily-notes` skill is the source of truth for the shared daily-note
capture model: section structure, task-note conventions, status values,
backlinking, and quick inline operations.

The `exec-assistant` skill is the chief-of-staff layer on top of that system.
Use it for prioritization, follow-up triage, and meeting preparation — whenever
the user asks what to focus on, what they're waiting on, what they owe, who
needs a nudge, or wants a meeting brief. Do NOT use `daily-notes` for these
judgment-and-recommendation tasks; that is `exec-assistant`'s job.

Longer workflows (morning planning, carryover, end-of-day review, meeting
transcripts, weekly summaries, and larger cleanup passes) are defined in the
notes vault's `CLAUDE.md` at `~/github/mhuggins7278/notes/CLAUDE.md`. Open a
session there for those workflows.

Global rules that apply everywhere:

- **Do not** carry forward tasks whose task file has `status: done` or `status: cancelled`
- **Do not** auto-copy yesterday's Notes section into today's file
- Prefer structured edits — place items under the correct section heading
  rather than appending to the end of the file

## Notes Vault (`~/github/mhuggins7278/notes`)

Rules that apply when working in the notes vault:

### Daily Note Location

Daily notes are flat files at `dailies/YYYY-MM-DD.md`. The Obsidian Daily
Notes plugin is configured with `folder=dailies` and `format=YYYY-MM-DD`.

### Task Notes

Standalone task records live at `work/tasks/<slug>.md`. Daily note task
sections (Tasks, Waiting On, I Owe, After Hours) contain wikilinks to task
files — not raw checkboxes. The task file's `status` field is canonical.

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

For recurring meetings, create an occurrence file (going forward; no backfill).
Do not add session notes directly to the series file.
