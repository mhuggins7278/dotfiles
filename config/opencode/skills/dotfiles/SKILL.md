---
name: dotfiles
description: >
  Use when adding, modifying, or managing dotfile configurations in this Ansible-managed dotfiles repo.
  Trigger for adding a new tool config, creating symlinks, updating Ansible tasks, managing brew packages,
  running the dotfiles playbook, or any request involving ~/.config paths, brew packages, or Ansible
  playbooks in ~/.dotfiles. Also trigger when the user asks to "install" a new tool config or "set up"
  a new CLI tool in their environment.
---

# Dotfiles Operations Skill

Handles configuration management for the Ansible-managed dotfiles repo at `~/.dotfiles`.

## Path Rules (Critical)

**NEVER edit files under `~/.config/` — they are symlinks.**  
**ALWAYS edit under `~/.dotfiles/config/` instead.**

If the user references a path like `~/.config/<tool>/...`, translate it to `~/.dotfiles/config/<tool>/...` before reading or editing.

## Add a New Config File

1. **Place the file** under `~/.dotfiles/config/<tool>/`

2. **Add a symlink entry** to `ansible/tasks/link_files.yml`:
   ```yaml
   - { src: "~/.dotfiles/config/<tool>", dest: "~/.config/<tool>", force: true }
   ```
   Follow the existing pattern in the file exactly.

3. **If the destination directory is new**, add it to the `Create folder` task in `ansible/dotfiles.yml`:
   ```yaml
   - name: Create folder
     file:
       path: "~/.config/<tool>"
       state: directory
   ```

4. **Preview changes** before applying:
   ```bash
   ansible-playbook --check --diff ansible/dotfiles.yml
   ```

5. **Apply**:
   ```bash
   dotfiles
   ```

## Key Commands

| Goal | Command |
|------|---------|
| Apply all dotfile changes | `dotfiles` |
| Sync brew packages only | `brewsync` |
| Update system (brew + git pull) | `update` |
| Preview Ansible changes | `ansible-playbook --check --diff ansible/dotfiles.yml` |
| Apply Ansible changes | `ansible-playbook ansible/dotfiles.yml` |

## Repository Structure

```
~/.dotfiles/
├── ansible/
│   ├── dotfiles.yml          # Main playbook
│   └── tasks/
│       └── link_files.yml    # Symlink definitions
├── config/                   # All tool configs (source of truth)
│   ├── opencode/
│   ├── nvim/
│   └── <tool>/
├── zshrc                     # Shell config (root-level dotfiles)
└── aliases                   # Custom shell aliases
```

## Code Style

- Shell scripts: 2-space indentation, descriptive variable names
- Config files: follow existing patterns for the technology
- Ansible YAML: proper indentation, descriptive task names
- No trailing whitespace; 80-char line length preferred

## Common Pitfalls

- Do not edit `~/.config/<tool>` directly — changes will be overwritten by the next `dotfiles` run
- Always verify the `link_files.yml` entry uses the correct `src` and `dest` before running
- Check if the destination parent directory exists before adding the symlink — missing dirs cause Ansible failures
- Run `--check --diff` before applying to catch mistakes early
