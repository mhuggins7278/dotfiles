# Agent Guidelines for Dotfiles Repository

## Available Subagents

- **docs**: Documentation specialist for fetching library docs using Context7
- **browser**: Browser automation and web testing using Chrome DevTools
- **whois**: GLG employee directory lookup specialist
- **zenhub**: ZenHub project management specialist
- **deployment**: GLG Deployment System (GDS) infrastructure specialist
- **ui-dev**: Frontend UI development with React/Material-UI and Figma

## Key Commands

- Update system: `update` (homebrew, git pull dotfiles)
- Apply dotfiles: `dotfiles` (ansible-playbook with all tasks)
- Sync packages: `brewsync` (ansible-playbook packages only)
- Edit with: `nvim` (aliased from vim/vi)

## Repository Structure

This is an Ansible-managed dotfiles repository supporting macOS and Linux. Main playbook: `ansible/dotfiles.yml`

## Code Style

- Shell scripts: 2-space indentation, descriptive variable names
- Config files: Follow existing patterns in each technology
- Ansible: YAML with proper indentation and task naming
- No trailing whitespace, 80-char line length preferred

## Development Workflow

- Test Ansible changes: `ansible-playbook --check --diff ansible/dotfiles.yml`
- Main config files in `config/` directory
- Custom aliases defined in `aliases` file
- Shell configuration in `zshrc` with zinit plugin manager

## GLG Repository Guidelines

When working in any repository inside `~/github/glg/`:

- **SQL Templates & DB Queries**: Always search `~/github/glg/epiquery-templates/**` for SQL templates, database queries, and related code
- This central template repository is the source of truth for database queries across GLG projects

## Daily Notes Policy

When creating new daily notes:

- **Do not** carry forward completed TaskNotes items from previous days
- **Do not** auto-copy yesterday's Notes section into today's file
- Keep each day's Tasks and Notes focused on current/in-progress work only
- Leave summaries and completed items in their respective daily files

## Guidelines from CLAUDE.md

- Use TypeScript with proper types when applicable
- Prefer const over let, modern ES syntax
- Include error handling, descriptive variable names
- Comments for complex logic only
- Format with language-specific tools (prettierd, stylua, etc.)