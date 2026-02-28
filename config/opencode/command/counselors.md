---
description: Fan out a prompt to multiple AI coding agents in parallel for independent review and synthesis
---
Load and execute the `counselors` skill.

Arguments: $ARGUMENTS

When arguments are provided, dispatch immediately using `--group fast` by default (no prompting).
Override with `--group <name>` or `--tools <ids>` in the arguments.

Examples:
- `/counselors review my opencode config` → runs with fast group, no prompts
- `/counselors --group smart is this approach thread-safe?` → runs with smart group
- `/counselors` (no args) → interactive: lists agents, asks which to use

Follow the counselors skill workflow exactly (all phases: context gathering, dispatch mode selection, agent selection, prompt assembly, dispatch, read results, synthesize, action).
