# Agent Guidelines for Dotfiles Repository

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
