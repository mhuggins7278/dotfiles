---
name: done
description: End-of-session skill. Synthesizes the full conversation into a structured Obsidian note capturing decisions, changes, questions, and follow-ups.
---

# Done Skill — Session Wrap-Up

Synthesizes everything from the current OpenCode session into a note in the Obsidian vault.

## When to Use

- User runs `/done` at the end of a coding session
- User says "wrap up this session", "we're done", "save this session"

## Workflow

### 1. Gather Context (Run in Parallel)

```bash
# Current date and time
date "+%Y-%m-%d %H:%M"

# Git context from the working directory
git rev-parse --show-toplevel 2>/dev/null || echo "not a git repo"
git remote get-url origin 2>/dev/null || echo "no remote"
git branch --show-current 2>/dev/null || echo "unknown"
git log --oneline -5 2>/dev/null || echo "no commits"
```

Capture:
- `date`: `YYYY-MM-DD`
- `time`: `HH:MM`
- `repo`: short name derived from remote URL (e.g., `glg/myglg` or `mhuggins7278/dotfiles`)
- `branch`: current git branch
- `working_dir`: absolute path of repo root (or `$PWD` if not a git repo)
- `project`: repo short name, or directory basename if not a git repo
- `session_id`: `session-YYYY-MM-DD-HHmm` (e.g., `session-2026-02-18-1430`)

### 2. Synthesize the Session

Review the entire conversation and extract:

**Summary** — 2-4 sentences describing what the session accomplished overall.

**Changes Made** — concrete file-level or system-level changes. For each:
- What file/thing was changed
- What was done (created, edited, deleted, configured)
- One-line reason

**Key Decisions** — architectural, design, or direction choices made during the session. Focus on *why*, not just *what*.

**Questions Raised** — questions that came up during the session (answered or unanswered). Include the resolution if there was one.

**Follow-ups** — unresolved items, next steps, things to revisit. These become actionable todos.

**Context** — any technical context useful for picking up where this left off: relevant commands, config paths, APIs touched, constraints discovered.

### 3. Determine Output Path

```
/Users/MHuggins/github/mhuggins7278/notes/ai-sessions/YYYY/MM/YYYY-MM-DD-HHmm.md
```

Example: `ai-sessions/2026/02/2026-02-18-1430.md`

If there are multiple sessions on the same day, append a counter: `2026-02-18-1430-2.md`

Create parent directories if they don't exist.

### 4. Write the Note

Use this exact template:

```markdown
---
id: session-YYYY-MM-DD-HHmm
date: YYYY-MM-DD
time: "HH:MM"
tags:
  - ai-session
  - opencode
project: <repo-short-name>
repo: <owner/repo>
branch: <branch>
working_dir: <absolute-path>
model: claude-sonnet-4.6
---

# Session: [[work/projects/<ProjectName>|<project>]] — YYYY-MM-DD HH:MM

## Summary

<2-4 sentence overview of what the session accomplished>

## Changes Made

- `path/to/file.ext` — created/edited/deleted: <reason>
- ...

## Key Decisions

- **<decision title>**: <what was decided and why>
- ...

## Questions Raised

- **<question>**: <resolution or "unresolved">
- ...

## Follow-ups

- [ ] <actionable next step>
- [ ] ...

## Context

<Any technical context needed to pick up where this left off: commands, paths, constraints, gotchas>
```

### 5. Update Today's Daily Note

Append a backlink to the session note and any follow-up items into today's daily note at:
```
/Users/MHuggins/github/mhuggins7278/notes/dailies/YYYY/MM/DD/index.md
```

If the daily note exists:

1. **Add a backlink in the Notes section** — append this line under `## Notes`:
   ```markdown
   - [[ai-sessions/YYYY/MM/YYYY-MM-DD-HHmm|OpenCode session — <project> (<branch>)]]
   ```
   If no `## Notes` section exists, add one at the end of the file.

2. **Port follow-up items into Tasks** — for each item in the Follow-ups list, add it as an unchecked checkbox under `## Tasks`:
   ```markdown
   - [ ] <follow-up item>
   ```
   Only add items that are clearly actionable by the user. Skip vague or reference-only items.

If the daily note does **not** exist yet, skip this step silently — do not create it (that's the daily notes agent's job).

### 6. Backlink the Project

If `project` maps to an existing file in `/Users/MHuggins/github/mhuggins7278/notes/work/projects/`, use an Obsidian backlink in the heading:
```
[[work/projects/ProjectName|project]]
```

If no project file exists for this repo, use plain text in the heading and skip the backlink.

Do **not** create a new project file automatically — leave that to the daily notes workflow.

### 7. Confirm Output

After writing the file, report:
- The full path to the note
- A one-line session summary
- The number of follow-up items captured

## Common Pitfalls

- Do not infer the date — always run `date` first
- Do not truncate the Changes Made list — include every file touched
- Follow-ups should be specific and actionable, not vague ("look into X" is bad; "investigate why X fails when Y is null" is good)
- Keep Key Decisions focused on non-obvious choices — don't list things that had only one option
