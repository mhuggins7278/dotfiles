---
name: done
description: >
  End-of-session skill. Synthesizes the full conversation into a structured Obsidian note capturing
  decisions, changes, questions, and follow-ups. Trigger on "/done", "wrap up", "we're done", "save
  this session", "end of day", "I'm logging off", "capture this session", or any indication the user
  is finishing a coding session and wants a record of what happened.
---

# Done Skill — Session Wrap-Up

Synthesizes everything from the current OpenCode session into a note in the Obsidian vault.

## When to Use

- User runs `/done` at the end of a coding session
- User says "wrap up this session", "we're done", "save this session"

## Workflow

### 1. Gather Context (Run in Parallel)

Run all of the following at once:

```bash
date "+%Y-%m-%d %H:%M"
git rev-parse --show-toplevel 2>/dev/null || echo "not a git repo"
git remote get-url origin 2>/dev/null || echo "no remote"
git branch --show-current 2>/dev/null || echo "unknown"
git log --oneline -5 2>/dev/null || echo "no commits"
```

Run git commands from the repo root identified by `git rev-parse --show-toplevel`. If the shell's working directory differs, use the `workdir` parameter of the Bash tool.

Capture:
- `date`: `YYYY-MM-DD`
- `time`: `HH:MM`
- `repo`: short name derived from remote URL (e.g., `glg/myglg` or `mhuggins7278/dotfiles`)
- `branch`: current git branch
- `working_dir`: absolute path of repo root (or `$PWD` if not a git repo)
- `project`: repo short name, or directory basename if not a git repo
- `model`: the model name from the current session context (visible in the system prompt)

**Multi-repo sessions**: If the session touched multiple repos, use the repo where the most significant work happened for the frontmatter. List all repos touched in the `## Context` section.

### 2. Synthesize the Session

Review the entire conversation and extract:

**Summary** — 2-4 sentences describing what the session accomplished overall.

**Changes Made** — concrete file-level or system-level changes. For each:
- What file/thing was changed (verify the exact path using the Glob or Read tool — do not guess)
- What was done (created, edited, deleted, configured)
- One-line reason

**Key Decisions** — architectural, design, or direction choices made during the session. Focus on *why*, not just *what*.

**Questions Raised** — questions that came up during the session (answered or unanswered). Include the resolution if there was one.

**Follow-ups** — unresolved items, next steps, things to revisit. These become actionable todos.

**Context** — technical context useful for picking up where this left off.

### 3. Determine Output Path

The session notes vault base is:

```
NOTES_BASE=~/github/mhuggins7278/notes
SESSION_DIR=$NOTES_BASE/ai-sessions
```

Output path: `$SESSION_DIR/YYYY/MM/YYYY-MM-DD-HHmm.md`

Example: `ai-sessions/2026/02/2026-02-18-1430.md`

Create parent directories if they don't exist:

```bash
mkdir -p "$SESSION_DIR/YYYY/MM"
```

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
model: <model-name-from-session-context>
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

- **Repos touched**: <list if multi-repo session>
- **Key paths**: <config dirs, notable file locations>
- **Commands to know**: <any non-obvious commands used or needed>
- **Constraints / gotchas**: <anything that would trip you up picking this up later>
```

### 5. Update Today's Daily Note

Uses the same note structure and CLI conventions as the `daily-notes` skill.
Do not hardcode the path — always resolve it via the CLI.

```bash
obsidian daily:path   # get today's note path
obsidian daily:read   # read the current note
```

If the daily note **does not exist yet**, skip this step silently — do not
create it (that's the daily-notes agent's job).

If the daily note **exists**:

1. **Insert follow-up items under `## Tasks`** — use the Edit tool to insert
   each actionable follow-up as an unchecked checkbox immediately after the
   last existing item in the `## Tasks` section:
   ```markdown
   - [ ] <follow-up item>
   ```
   Only add items that are clearly actionable by the user. Skip vague or
   reference-only items. Use `- [ ]` state for all new items (see `daily-notes`
   skill for the full checkbox type table).

2. **Add a backlink in the Notes section** — use the Edit tool to insert this
   line after the last existing item under `## Notes`:
   ```markdown
   - [[ai-sessions/YYYY/MM/YYYY-MM-DD-HHmm|OpenCode session — <project> (<branch>)]]
   ```
   If no `## Notes` section exists, add one at the end of the file.

When making these edits, read the resolved daily note path first, then apply
targeted edits — do not rewrite the full file.

### 6. Backlink the Project

Use the Glob tool to check if a project file exists at:
```
$NOTES_BASE/work/projects/*.md
```

If a file matching the project name exists, use an Obsidian backlink in the heading:
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
- Do not guess file paths in Changes Made — verify with Glob or Read before writing
- Do not truncate the Changes Made list — include every file touched
- Follow-ups should be specific and actionable, not vague ("look into X" is bad; "investigate why X fails when Y is null" is good)
- Keep Key Decisions focused on non-obvious choices — don't list things that had only one option
- Do not hardcode the model name — read it from the session context
- For Obsidian-specific syntax (wikilinks, callouts, frontmatter), refer to `~/.dotfiles/config/opencode/references/obsidian-markdown.md`
