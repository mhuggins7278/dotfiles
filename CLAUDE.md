# Dotfiles Repository Guidelines

## Repository Overview

Ansible-managed dotfiles for macOS and Linux. Config files live in this repo
under `config/` and are symlinked to their correct locations via Ansible.

**Never edit `~/.config/`, `~/.claude/`, or other symlink destinations directly.**
Always edit the source under `~/.dotfiles/config/`.

## Key Commands

- `update` — pull latest dotfiles + brew update
- `dotfiles` — apply full Ansible playbook (all tasks)
- `brewsync` — sync Homebrew packages only

## Ansible Workflow

- Preview changes: `ansible-playbook --check --diff ansible/dotfiles.yml`
- Apply changes: `dotfiles`
- Main playbook: `ansible/dotfiles.yml`
- Symlinks: `ansible/tasks/link_files.yml`

## Dual-Tool AI Setup

This repo manages config for two AI coding tools that share canonical methodology:

| Tool | User config source | Agents/skills source |
|------|--------------------|----------------------|
| OpenCode | `config/opencode/AGENTS.md` | `config/opencode/agent/*.md`, `config/opencode/skills/` |
| Claude Code | `config/claude/CLAUDE.md` | `config/claude/agents/*.md`, `config/opencode/skills/` (linked) |

Shared playbooks (canonical methodology for all agents) live in `config/ai/playbooks/`.
Skills are the source of truth at `config/opencode/skills/` — symlinked into both tools.

## Path Translation

| Reference | Actual source |
|-----------|---------------|
| `~/.config/<tool>/` | `~/.dotfiles/config/<tool>/` |
| `~/.claude/` | `~/.dotfiles/config/claude/` |
| `~/.config/opencode/` | `~/.dotfiles/config/opencode/` |

## Code Style

### Formatters

- JavaScript/TypeScript: prettierd
- HTML/CSS/Vue: prettierd
- JSON/JSONC: jq
- YAML: prettierd
- Markdown: prettierd
- Lua: stylua
- Go: goimports, gofumpt

### Conventions

- 2-space indentation, 80-char line length max
- No trailing whitespace
- TypeScript with proper types when applicable
- Prefer `const` over `let`, modern ES syntax
- Descriptive variable names, async/await over promises
- Comments for complex logic only
- Always include error handling
