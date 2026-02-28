---

## Review: OpenCode TUI Config

### tui.json

#### Theme: `tokyonight` — Valid and Fine
`tokyonight` is a confirmed built-in theme. Good choice — solid contrast, well-maintained upstream. No issues.

---

#### Keybinds: Three Problems

**1. `session_child_cycle_reverse = alt+l` is wrong**

This is the biggest issue. You set `session_child_cycle = alt+j`, which follows Vim's `j` = down/next convention. The natural reverse in Vim-style bindings is `alt+k` (up/prev) — not `alt+l` (right). Using `alt+l` here is both asymmetric and non-idiomatic. It would make more sense as a cursor-movement key, not a reverse-cycle key.

Fix:
```json
"session_child_cycle_reverse": "alt+k"
```

**2. Only 3 keybinds defined — large gaps**

You're relying entirely on defaults for session management, model switching, and message scrolling. The defaults are functional, but several are worth explicitly setting to avoid surprises if defaults change. The ones worth knowing you're implicitly accepting:

| Action | Default |
|---|---|
| `session_new` | `<leader>n` |
| `session_list` | `<leader>l` |
| `session_timeline` | `<leader>g` |
| `messages_page_up/down` | `ctrl+alt+b` / `ctrl+alt+f` |
| `model_list` | `<leader>m` |
| `agent_cycle` | `tab` |

The scroll bindings (`ctrl+alt+b/f`) are particularly awkward on a Mac. Worth overriding.

**3. Default conflict you've inherited: `<leader>h` is double-mapped**

The opencode defaults map both `messages_toggle_conceal` and `tips_toggle` to `<leader>h`. This is a bug in the defaults you're inheriting. Since you haven't overridden either, one will silently shadow the other. You should explicitly resolve this in your config.

---

### config.json

#### MCP: Missing `-y` flag on Playwright

```json
"playwright": {
  "command": ["npx", "@playwright/mcp@latest"]
}
```

Every other `npx` command uses `-y` to skip confirmation prompts. `playwright` doesn't. If the package isn't cached, it may hang waiting for user input. Fix:

```json
"command": ["npx", "-y", "@playwright/mcp@latest"]
```

#### Dangling tool disable: `zenhub_*`

```json
"zenhub_*": false
```

There is no `zenhub` MCP server in your `mcp` section. This is a dead entry — harmless, but suggests stale config from a server you removed. Clean it up.

#### All MCP servers enabled + all tools disabled — intentional but worth naming

You start all 5 MCP servers on every OpenCode launch (startup overhead), but disable all their tools by default. This only makes sense if your skills explicitly re-enable tools as needed. If that's how your skills work, the pattern is fine. But if you're not using all 5 servers regularly, consider setting `enabled: false` on the ones you use rarely (e.g., `figma` or `gdsData`) and only enabling them when needed.

#### `reasoningEffort: "high"` on both agents

This will be consistently slower and more token-intensive. Not wrong, but be intentional — `plan` with high reasoning makes sense; `build` with high reasoning may be over-engineered for straightforward tasks. Consider whether `"medium"` on `build` gives acceptable results at lower cost.

---

### Summary of Required Fixes

| Priority | Issue | Action |
|---|---|---|
| High | `session_child_cycle_reverse = alt+l` | Change to `alt+k` |
| High | Missing `-y` on playwright npx | Add `-y` flag |
| Medium | `<leader>h` double-mapped in defaults | Explicitly override one of them |
| Low | `zenhub_*: false` with no zenhub server | Remove the entry |
| Low | All MCP servers always enabled | Disable rarely-used servers |
