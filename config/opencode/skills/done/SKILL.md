---
name: done
description: Save an end-of-session summary to the notes vault. Use when the user invokes `/done` or explicitly asks to wrap up, save, or archive the current session.
---

# Session Wrap-Up

Capture the current session as one searchable note, then add a compact backlink
and actionable follow-ups to today's daily note. This skill writes only inside
`~/github/mhuggins7278/notes`.

## 1. Gather context

Run these independent lookups in parallel, using the repository root returned
by the first command for the other Git commands:

```bash
date "+%Y-%m-%d %H:%M"
git rev-parse --show-toplevel 2>/dev/null || printf 'not a git repo\n'
git remote get-url origin 2>/dev/null || printf 'no remote\n'
git branch --show-current 2>/dev/null || printf 'unknown\n'
git log --oneline -5 2>/dev/null || printf 'no commits\n'
```

Classify the session as `coding` when files, configs, commands, commits, or
diffs materially changed. Otherwise classify it as `exploration`. If uncertain,
choose exploration and omit empty sections.

## 2. Synthesize

Review the full conversation. Capture every changed path, key decisions,
questions and resolutions, follow-ups, and context needed to resume. For an
exploration session, capture insights, ideas, decisions, open questions, and
follow-ups instead. Use the appropriate template in
[coding-template.md](references/coding-template.md) or
[exploration-template.md](references/exploration-template.md).

Also derive:

- a one-sentence TL;DR of 20 words or fewer for today's note;
- a specific `session_slug` of 3-6 lowercase ASCII words joined with hyphens;
- the exact changed paths, verified with repository tools rather than guessed.

## 3. Write the session note

Use the current date and time from `date`. Store the note at:

```text
~/github/mhuggins7278/notes/ai-sessions/YYYY/MM/YYYY-MM-DD-HHmm-<session_slug>.md
```

Create its parent directory if needed. Preserve the coding or exploration
frontmatter from the selected template. Link an existing project note in the
heading when one clearly matches; do not create a project note automatically.

## 4. Update today's daily note

Load `daily-notes` before any daily-note mutation. Resolve the path with:

```bash
obsidian daily:path
obsidian daily:read
```

If today's note does not exist, skip this step without creating it. Otherwise:

1. Use the daily-notes task model for each clearly actionable user-owned
   follow-up. Add the resulting task wikilink to the appropriate section with
   a backlink to this session note.
2. Add one backlink and the TL;DR under `## Notes`:
   `[[ai-sessions/YYYY/MM/YYYY-MM-DD-HHmm-<session_slug>|OpenCode session — <project or topic>]] — <tldr>`
3. Read first and make targeted edits. Preserve frontmatter and unrelated
   content; do not insert raw task checkboxes into task sections.

## 5. Verify and report

Re-read the session note and daily note after writing. Confirm the session note
exists, the backlink is present, and every captured task has the expected task
file/status. Report the full note path, one-line summary, and number of
follow-ups captured. Never expose secrets or sensitive personal data.
