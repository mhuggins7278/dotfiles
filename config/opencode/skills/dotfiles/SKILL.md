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

Path translation guide:

| User references... | Edit instead at... |
|---|---|
| `~/.config/<tool>/...` | `~/.dotfiles/config/<tool>/...` |
| `~/.zshrc`, `~/.zprofile`, `~/.curlrc`, etc. | `~/.dotfiles/zshrc`, `~/.dotfiles/zprofile`, etc. |
| `~/Library/Application Support/<tool>/...` | `~/.dotfiles/config/<tool>/...` (check `link_files.yml` for the exact mapping) |

When in doubt, grep `ansible/tasks/link_files.yml` for the `dest` path to find the corresponding `src`.

---

## Workflows

### Edit an existing config

Just edit the source file in the repo — no Ansible changes needed. The symlink is already in place.

```bash
nvim ~/.dotfiles/config/<tool>/...    # for config/ files
nvim ~/.dotfiles/zshrc                # for root-level dotfiles
```

### Add a new config file

There are three symlink patterns in use — pick the one that matches your case.

**Pattern A — tool config under `~/.config/`** (most common):

1. Place the file at `~/.dotfiles/config/<tool>/`

2. If `~/.config/<tool>/` doesn't exist yet, add it to the `loop` in the `Create folder` task in `ansible/dotfiles.yml`:
   ```yaml
   loop:
     - "~/.config/<tool>"   # add this line to the existing loop
   ```

3. Add to `ansible/tasks/link_files.yml`:
   ```yaml
   - { src: "~/.dotfiles/config/<tool>", dest: "~/.config/<tool>", force: true }
   ```

**Pattern B — root-level dotfile** (e.g., zshrc, curlrc):

1. Place the file at `~/.dotfiles/<file>` (repo root, no leading dot in the filename)

2. Add to `ansible/tasks/link_files.yml`:
   ```yaml
   - { src: "~/.dotfiles/<file>", dest: "~/.<file>" }
   ```

**Pattern C — non-standard destination** (e.g., `~/Library/...`):

1. Place the file at `~/.dotfiles/config/<tool>/`

2. Add the destination directory to the `Create folder` loop in `ansible/dotfiles.yml` if it doesn't exist yet.

3. Add to `ansible/tasks/link_files.yml` with the explicit destination:
   ```yaml
   - {
       src: "~/.dotfiles/config/<tool>/config.yml",
       dest: "~/Library/Application Support/<tool>/config.yml",
       force: true,
     }
   ```

**After any pattern — preview then apply:**

```bash
ansible-playbook --check --diff ansible/dotfiles.yml --tags links
dotfiles
```

### Add or remove a brew package

Packages are managed in `ansible/vars/`:

| File | Purpose |
|---|---|
| `ansible/vars/formula.yml` | CLI tools (formulas) |
| `ansible/vars/casks.yml` | GUI apps (casks) |
| `ansible/vars/taps.yml` | Homebrew taps |

**To add** — append the package name as a key under the relevant dict (null value = latest):

```yaml
# ansible/vars/formula.yml
formula:
  ripgrep:       # add this
  existing-tool:
```

**To remove** — delete the line, or set `state: absent` to be explicit:

```yaml
formula:
  old-tool:
    state: absent
```

**Apply packages only:**

```bash
brewsync
# or explicitly:
ansible-playbook ansible/dotfiles.yml --tags packages
```

---

## Key Commands

| Goal | Command |
|---|---|
| Apply all dotfile changes | `dotfiles` |
| Sync brew packages only | `brewsync` |
| Apply symlinks only | `ansible-playbook ansible/dotfiles.yml --tags links` |
| Apply macOS defaults only | `ansible-playbook ansible/dotfiles.yml --tags macos_defaults` |
| Update system (brew + git pull) | `update` |
| Preview Ansible changes | `ansible-playbook --check --diff ansible/dotfiles.yml` |

---

## Repository Structure

```
~/.dotfiles/
├── ansible/
│   ├── dotfiles.yml          # Main playbook (Create folder loop lives here)
│   ├── vars.yml              # Top-level vars
│   ├── vars/
│   │   ├── formula.yml       # Homebrew CLI formulas
│   │   ├── casks.yml         # Homebrew GUI casks
│   │   └── taps.yml          # Homebrew taps
│   └── tasks/
│       ├── link_files.yml    # Symlink definitions (source of truth)
│       ├── packages.yml      # Brew/apt/pacman package tasks
│       ├── shells.yml        # Default shell setup
│       └── macos_defaults.yml
├── config/                   # Tool configs under ~/.config/ (source of truth)
│   ├── nvim/
│   ├── tmux/
│   ├── opencode/
│   └── <tool>/
├── zshrc                     # ~/.zshrc (root-level dotfiles have no leading dot here)
├── zprofile                  # ~/.zprofile
├── aliases                   # sourced by zshrc, not directly symlinked
└── shellrc, curlrc, wgetrc, etc.
```

---

## Code Style

- Shell scripts: 2-space indentation, descriptive variable names
- Config files: follow existing patterns for the technology
- Ansible YAML: proper indentation, descriptive task names
- No trailing whitespace; 80-char line length preferred

---

## Common Pitfalls

- Do not edit `~/.config/<tool>` directly — changes will be overwritten by the next `dotfiles` run
- The `Create folder` task in `dotfiles.yml` has a single `loop` list — add new dirs to that list, don't create a new task
- Use `--tags links` to re-apply only symlinks after editing `link_files.yml` (faster than running the full playbook)
- Always run `--check --diff` before applying to catch path mistakes early
- For non-`~/.config/` destinations, verify the parent dir exists or add it to the `Create folder` loop
