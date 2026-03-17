# Global Agent Guidelines

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
- For PR creation workflows: ensure each PR is associated with a GitHub issue. If none exists, prompt the user to create one before opening the PR. Use `Fixes <owner>/<repo>#<number>` (for example, `Fixes glg/streamliner#5232`) for issue references.

## GLG Repositories

When working in any repository under `~/github/glg/`:

- **SQL Templates & DB Queries**: If the project references SQL files, epiquery templates, or database queries, always search `~/github/glg/epiquery-templates/` for the relevant templates. This central repository is the source of truth for database queries across all GLG projects.
- **Issue-First Workflow**: Require an associated GitHub issue for implementation work. Accept either (1) a user-provided issue at session start, or (2) creating a new issue after planning but before the first code edit, commit, or PR.
- **If Missing Issue**: Pause and prompt to create one before proceeding with implementation steps.
- **Project Tagging**: When creating the issue, add it to `glg` project `85` (`Client Solutions Experience`).
- **PR References**: Use `Fixes <owner>/<repo>#<number>` (for example, `Fixes glg/streamliner#5232`) for issue references.

## Code Style

- Use TypeScript with proper types when applicable
- Prefer const over let, modern ES syntax
- Include error handling, descriptive variable names
- Comments for complex logic only
- Format with language-specific tools (prettierd, stylua, etc.)

## Daily Notes Policy

The `daily-notes` agent is the source of truth for the full daily notes
workflow (morning planning, carryover rules, evening review, meeting
transcripts, weekly summaries). For quick inline operations from any session,
use the `daily-notes` skill.

Global rules that apply everywhere:

- **Do not** carry forward completed (`- [x]`) or cancelled (`- [-]`) items
- **Do not** auto-copy yesterday's Notes section into today's file
- Prefer structured edits — place items under the correct section heading
  rather than appending to the end of the file
