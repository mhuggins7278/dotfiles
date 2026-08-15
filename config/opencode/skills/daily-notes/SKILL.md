---
name: daily-notes
description: Daily-note capture, task updates, or lightweight review. Use when the user says "track this", "note this", "I owe", "I'm waiting on", "what's open", "mark that done", or "what did I get done". Use exec-assistant for prioritization or recommendations, and the notes-vault workflow for morning planning, end-of-day review, meetings, or cleanup passes.
---

# Daily Notes

Own quick, factual updates to today's daily note. The task-file status is the
source of truth; daily-note sections are its planning view.

## Route the request

- **Capture or status change**: load [task-model.md](references/task-model.md),
  then classify the user's natural language and update the task file and daily
  note together.
- **Lightweight review**: load
  [lightweight-review.md](references/lightweight-review.md) and inspect only
  today's linked tasks unless the user asks for a vault-wide result.
- **Prioritization or recommendation**: use `exec-assistant`; do not mutate
  notes from that skill without loading this one first.
- **Morning startup, end-of-day review, meeting transcripts, weekly summaries,
  or broad cleanup**: tell the user to open a session in
  `~/github/mhuggins7278/notes`; its `CLAUDE.md` owns that orchestration.

## Capture workflow

1. Resolve today's path with `obsidian daily:path` and read it before editing.
2. Load the task model for any task, waiting, owed, completion, or section
   mutation. Use the lightweight-review reference for a review request.
3. Classify the update without forcing the user into a form. Ask only when
   ambiguity changes ownership, section, or whether a new linked note is needed.
4. Make surgical edits to the resolved note and task file. Preserve frontmatter,
   existing sections, and unrelated content.
5. Re-read the changed files and confirm the requested entry, status, and
   backlink are present. Reply with a brief factual confirmation.

## Canonical locations

- Daily notes: `dailies/YYYY-MM-DD.md`, resolved through `obsidian daily:path`
- Task notes: `work/tasks/<slug>.md`
- Meeting notes: `meetings/YYYY-MM-DD-Title.md`

Use `date` for current dates. Never infer a date from conversation context.

## Shared ownership

This skill owns the daily-note structure, task status semantics, natural capture
classification, backlinks, and one-off Obsidian operations. The notes vault owns
long-form orchestration. Keep those responsibilities separate.
