# Second Opinion Request

## Question
# Review Request

## Question
Review my opencode TUI config. Is it well-configured? Are there any issues, improvements, or missing keybinds worth considering? Are the keybind choices idiomatic?

## Context

### Files to Review
@~/.dotfiles/config/opencode/tui.json
@~/.dotfiles/config/opencode/config.json

### Notes
- `tui.json` is the TUI-specific config (theme, keybinds)
- `config.json` is the main opencode config (models, MCP servers, permissions, tool toggles)
- `~/.config/opencode` is symlinked to `~/.dotfiles/config/opencode` (dotfiles-managed)
- The keybinds currently set: `session_child_cycle = alt+j`, `session_child_cycle_reverse = alt+l`, `sidebar_toggle = <leader>b`
- Theme: tokyonight

## Instructions
You are providing an independent review. Be critical and thorough.
- Read the referenced files to understand the full context
- Consult the opencode docs (https://opencode.ai/docs) if needed to understand valid keybind names, available themes, and TUI options
- Identify any: misconfigured keys, non-standard/unexpected choices, missing useful keybinds, or improvements
- Note whether `session_child_cycle_reverse` uses `alt+l` (instead of something more symmetric like `alt+k`)
- Comment on theme choice and whether it's a valid built-in theme
- Be direct and opinionated — don't hedge
- Structure your response with clear headings

## Instructions
You are providing an independent second opinion. Be critical and thorough.
- Analyze the question in the context provided
- Identify risks, tradeoffs, and blind spots
- Suggest alternatives if you see better approaches
- Be direct and opinionated — don't hedge
- Structure your response with clear headings
- Keep your response focused and actionable
