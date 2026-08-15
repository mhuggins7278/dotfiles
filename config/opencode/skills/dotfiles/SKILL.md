---
name: dotfiles
description: Manage configuration sourced from the Ansible dotfiles repository. Use when changing `~/.config` files, root dotfiles, Ansible links, brew packages, or applying the dotfiles playbook.
---

# Dotfiles Operations

This repository is the source of truth for configuration deployed by Ansible.
Edit `/Users/mhuggins/.dotfiles`, never a symlink destination under
`~/.config/`.

## Resolve the source

For an existing destination, inspect
`ansible/tasks/link_files.yml` before editing. Typical mappings are:

- `~/.config/<tool>/...` → `config/<tool>/...`
- `~/.<file>` → the corresponding root-level `<file>` in the repository
- `~/Library/Application Support/<tool>/...` → the mapped `config/<tool>/...`

If the destination is not linked, inspect the playbook and repository layout
instead of guessing. Preserve unrelated user changes.

## Add a configuration

1. Put the source under `config/<tool>/` or at the repository root for a
   root-level dotfile.
2. Add the source-to-destination entry to `ansible/tasks/link_files.yml`.
3. If the destination directory is new, add it to the existing folder loop in
   `ansible/dotfiles.yml`.
4. Preview the exact link changes before applying them.

```bash
ansible-playbook --check --diff ansible/dotfiles.yml --tags links
```

## Manage packages

Inspect `ansible/vars/formula.yml`, `casks.yml`, or `taps.yml` and preserve the
existing YAML shape. Use `brewsync` or:

```bash
ansible-playbook ansible/dotfiles.yml --tags packages
```

## Apply and verify

Use `dotfiles` only when the user asks to apply the configuration. For focused
work, use the relevant Ansible tag. After applying, verify the destination is a
symlink to the intended repository source and report the playbook result.

Useful commands:

```bash
dotfiles
brewsync
ansible-playbook --check --diff ansible/dotfiles.yml
ansible-playbook ansible/dotfiles.yml --tags macos_defaults
```

Completion means the repository source, Ansible mapping, preview result, and
application result are all clear. Do not claim a system change from editing a
source file alone.
