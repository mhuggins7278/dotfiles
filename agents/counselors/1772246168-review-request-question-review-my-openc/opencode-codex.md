**Overall Verdict**
- Clean, minimal config that should work, but the keybind choices are not idiomatic and have a couple of practical risks.
- `tokyonight` is a valid built‑in theme, no issues there.

**TUI Config (`/Users/MHuggins/.dotfiles/config/opencode/tui.json`)**
- **Theme**: `tokyonight` is explicitly listed as a built‑in theme in the docs. Valid and safe.
- **Keybind names**: `session_child_cycle`, `session_child_cycle_reverse`, and `sidebar_toggle` are valid keys. No misconfiguration.
- **Leader**: You rely on the default `leader` (`ctrl+x`). That’s fine, but it makes your custom binds mixed style (one leader bind, two alt binds).

**Keybind Critique**
- **`session_child_cycle` / reverse**: Using `alt+j` and `alt+l` is not symmetric or idiomatic. If you’re mapping forward/back, use pairs that read as left/right or up/down:
  - Best options: `alt+h` / `alt+l` (left/right), or `alt+j` / `alt+k` (down/up).
- **Alt‑key risk**: `alt+<key>` is not consistently delivered across terminals and can conflict with readline/emacs shortcuts in some environments. Leader-based bindings are more reliable inside TUIs. If you want rock‑solid behavior, set these to `<leader>left` / `<leader>right` (the defaults) or `<leader>j` / `<leader>k`.

**Main Config Notes (`/Users/MHuggins/.dotfiles/config/opencode/config.json`)**
- **MCP servers enabled, tools disabled**: You have MCP servers enabled (`whoIs`, `gdsData`, `playwright`, `figma`, `context7`) but all related tools are disabled (`*_` set to `false`). That’s fine if you want hard safety, but it means those servers won’t actually be used. If that isn’t intentional, you’re effectively disabling the feature set.
- **Permissions**: External directory allowlist looks good. Skill policy is permissive with a single deny — reasonable.

**Recommendations**
- Change `session_child_cycle_reverse` to `alt+k` (or switch to `alt+h`/`alt+l`) for symmetry.
- Consider moving both session cycling binds to `<leader>` variants for reliability.
- If you want MCP tools to be usable, flip the relevant tool toggles to `true` (or allow specific tools rather than wildcard blocks).

**Net**
- Configuration is valid and will run.
- The keybind choices are the weakest part: not idiomatic, not symmetric, and slightly risky with terminal meta behavior.
