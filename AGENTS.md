# Agent Guidelines for Dotfiles Repository

## Key Commands

- Update system: `update` (homebrew, git pull dotfiles)
- Apply dotfiles: `dotfiles` (ansible-playbook with all tasks)
- Sync packages: `brewsync` (ansible-playbook packages only)
- Edit with: `nvim` (aliased from vim/vi)

## Repository Structure

This is an Ansible-managed dotfiles repository supporting macOS and Linux. Main playbook: `ansible/dotfiles.yml`

All global config files live in this repository (primarily under `config/`) and are symlinked to their correct system locations via Ansible. **Always read and edit files under `~/.dotfiles/config/` directly — never under `~/.config/`, which contains only symlinks.** When adding or modifying a config file:

1. Place the file under `~/.dotfiles/config/<tool>/` (or the repo root for dotfiles like `zshrc`)
2. Add a symlink entry to `ansible/tasks/link_files.yml` following the existing pattern:
   ```yaml
   - { src: "~/.dotfiles/config/<tool>", dest: "~/.config/<tool>", force: true }
   ```
3. If the destination directory is new, add it to the `Create folder` task in `ansible/dotfiles.yml`
4. Apply with `dotfiles` (or `ansible-playbook --check --diff ansible/dotfiles.yml` to preview)

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
