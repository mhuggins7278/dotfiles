---
name: herdr
description: "Control Herdr, a terminal multiplexer for coding agents. Use only when the user explicitly mentions Herdr or asks to use Herdr to inspect or control panes, tabs, workspaces, commands, or another agent. Do not use merely because a task could benefit from a background terminal, delegation, or parallel work. Requires HERDR_ENV=1."
---

# Herdr

Herdr organizes terminals into workspaces, tabs, and panes, recognizes coding
agents running inside panes, and exposes the current session through the
`herdr` CLI.

Before issuing any control command, verify that this agent is running inside a
Herdr-managed pane:

```bash
test "${HERDR_ENV:-}" = 1
```

If the check fails, say that you are not running inside Herdr and stop. Do not
inspect or control the focused Herdr session from outside Herdr.

## Learn the current CLI

The installed binary is the authority for command syntax. Start with:

```bash
herdr --help
```

Then print the relevant command group by running the group without a
subcommand:

```bash
herdr agent
herdr pane
herdr workspace
herdr tab
herdr worktree
herdr terminal
herdr notification
herdr integration
herdr session
```

Do not run bare `herdr` for discovery; it launches or attaches to the TUI. Do
not probe a mutating nested command by omitting arguments. Most commands print
JSON; read identifiers from those responses instead of predicting them.

## Understand layout, panes, and agents

Choose the primitive that matches the job:

- Workspace, tab, and pane topology organize terminal locations.
- Pane commands control raw terminals, shells, tests, servers, input, and output.
- Agent commands control the recognized coding agent occupying a pane.

Use pane commands for ordinary processes. Use agent commands when Herdr must
interpret `idle`, `working`, `blocked`, `done`, or `unknown` lifecycle states.
Agent targets are unique live agent names or the pane ID hosting the agent;
they are not terminal IDs or bare agent-kind labels.

`idle` means ready for input after the tab has been seen in the focused Herdr
UI. `done` is unseen completed work. `blocked` means Herdr recognized an
approval or question UI. `unknown` means an agent is present but cannot be
classified confidently.

## Use IDs and caller context

Public IDs look like:

```text
workspace: w1
tab:       w1:t1
pane:      w1:p1
```

Herdr injects the caller's context into each managed pane:

```bash
printf '%s\n' "$HERDR_WORKSPACE_ID" "$HERDR_TAB_ID" "$HERDR_PANE_ID"
```

Prefer `--current` when a command should target the calling pane. Do not rely
on another client's focused pane.

Discover live state with:

```bash
herdr workspace list
herdr tab list --workspace "$HERDR_WORKSPACE_ID"
herdr pane current --current
herdr pane list --workspace "$HERDR_WORKSPACE_ID"
herdr agent list
```

## Start and coordinate an agent

Default to a sibling pane in the current tab and current working directory.
Keep the user's focus in the calling pane:

```bash
herdr pane split --current --direction right --cwd "$PWD" --no-focus
```

Read the returned pane ID, then start a supported agent in an available shell:

```bash
herdr agent start reviewer --kind codex --pane <returned-pane-id>
```

Submit work through the agent surface:

```bash
herdr agent prompt reviewer "Review the current diff and report actionable findings." --wait --timeout 120000
```

If a wait returns `blocked`, inspect the agent before sending input:

```bash
herdr agent get reviewer
herdr agent read reviewer --source recent-unwrapped --lines 120
```

Use logical keys for interactive controls:

```bash
herdr agent send-keys reviewer esc
herdr agent send-keys reviewer ctrl+c
```

## Run ordinary commands

Create a background sibling pane, run a command, and inspect it:

```bash
herdr pane split --current --direction right --cwd "$PWD" --no-focus
herdr pane run <returned-pane-id> "just test"
herdr pane wait-output <returned-pane-id> --match "test result" --timeout 120000
herdr pane read <returned-pane-id> --source recent-unwrapped --lines 120
```

Use `visible` for the current screen, `recent-unwrapped` for logs, and
`detection` for the bottom-buffer snapshot used by agent detection.

## Safety and coordination

- Use `--no-focus` for background work unless focus was requested.
- Use `--current`, an explicit pane ID, or a unique agent name.
- Parse IDs from JSON responses.
- Do not close workspaces, tabs, panes, or sessions you did not create unless explicitly asked.
- Never run `herdr server stop` from an active session unless explicitly intended; it stops pane processes.
- Never kill the main Herdr process.
