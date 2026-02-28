**Scope Reviewed**
- Looked at `config/opencode/config.json`, `config/opencode/tui.json`, and `config/opencode/AGENTS.md`

**Key Risks**
- MCP tools are enabled but all `tools` are disabled (`figma*`, `gdsData_*`, `whoIs_*`, `playwright_*`, `context7_*`). This is a footgun: the model thinks integrations exist but will never be able to call them. You’ll see silent capability gaps and wasted turns.
- `permission.external_directory` allows two external paths but there’s no explicit deny for everything else. If default is permissive in opencode, you’re exposed to reading outside expected scopes; if default is restrictive, these allows are fine but the intent isn’t explicit.
- `context7` depends on `CONTEXT7_API_KEY` env. If the key is unset, the docs agent will fail hard and you’ll burn time debugging. No fallback or clarity.
- Models: `plan` uses Opus with high reasoning effort while `build` uses Sonnet with high reasoning effort. That’s expensive and still can bottleneck throughput for simple tasks. You’re paying for “high” even when it doesn’t matter.

**Tradeoffs You’re Making**
- Maximum reasoning vs speed: Both agents at `reasoningEffort: high` biases toward cost/latency over throughput. This is great for ambiguous tasks but bad for routine chores.
- Safety vs productivity: You deny only `obsidian-markdown` but allow every other skill. That’s a very permissive stance for custom skills without a policy boundary.
- UI efficiency: Custom keybinds are minimal. You’re not optimizing for high-frequency actions (search, save transcript, toggle tools). The TUI config is safe but underutilized.

**Blind Spots**
- No environment-based profiles (work/personal). If you move between contexts, you will either over‑enable tools or block yourself.
- No explicit policy on external directory access besides two allows; you don’t codify a “deny by default” intent.
- The `tools` block disables everything, which is likely contrary to your intent (you enabled MCP servers). This mismatch is the most likely source of “why didn’t it do X?” issues.

**Direct Fixes (Recommended)**
- Align MCP availability with tool permissions: either remove the `tools` disables or scope them. Example: allow `context7_*` and `whoIs_*` if you actually want those agents to work.
- Introduce profiles (if supported) or a simple manual switch: a “work” config with GLG tools enabled and a “personal” config with all MCP disabled.
- Downgrade reasoning effort for build tasks to `medium` or use a cheaper model for build; keep plan high only when needed.
- Make external permissions explicit: add a catch‑all deny if the config supports it, then allow only what you need.

**Alternative Approaches**
- Split config: `config/opencode/config.work.json` and `config/opencode/config.personal.json`, symlink the active one. This prevents accidental tool access.
- Add an “execution” agent with low‑cost model for running commands and formatting, reserving Opus for planning only.
- If you frequently use docs/figma/browser, enable only those tool namespaces and keep the rest disabled, not vice versa.

**Actionable Next Steps**
1. Decide which MCP tools you actually want enabled and update `tools` to match.
2. Set `reasoningEffort` to `medium` for `build` unless you routinely need deep reasoning there.
3. Confirm `CONTEXT7_API_KEY` is set; if not, either set it or disable `context7` entirely to avoid wasted attempts.
4. Consider a strict external directory policy with explicit denies.
