# Agent Guidelines for Dotfiles Repository

## Repository Structure

This is an Ansible-managed dotfiles repository supporting macOS and Linux.
The main playbook is `ansible/dotfiles.yml`.

All global config files live in this repository and are symlinked to their
system locations through Ansible. Always edit repository sources, never a
symlink destination such as `~/.config/`.

- OpenCode sources live in `config/opencode/`.
- Shared AI policy and playbooks live in `config/ai/`.
- OpenCode skills live in `config/opencode/skills/`.

When adding a new config:

1. Place the file under `~/.dotfiles/config/<tool>/` (or the repo root for dotfiles like `zshrc`)
2. Add its source-to-destination link to `ansible/tasks/link_files.yml`.
3. If the destination directory is new, add it to the `Create folder` task in `ansible/dotfiles.yml`
4. Preview with `ansible-playbook --check --diff ansible/dotfiles.yml` before applying with `dotfiles`.

## Key Commands

- Update system: `update`
- Apply dotfiles: `dotfiles`
- Sync packages: `brewsync`

## Code Style

- Shell scripts use 2-space indentation and descriptive names.
- Follow each configuration format's existing style.
- Keep Ansible task names descriptive and YAML properly indented.
- Avoid trailing whitespace; prefer an 80-character line length where practical.
