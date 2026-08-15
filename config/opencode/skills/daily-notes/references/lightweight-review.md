# Lightweight Daily-Note Review

Use targeted reads. Start with today's note, collect task links from `Tasks`,
`After Hours`, `Waiting On`, and `I Owe`, then read only those task files.

## Requests

- **What's still open?** Return linked tasks whose status is `todo`,
  `in-progress`, or `waiting`. Inspect unchecked `## Sub-tasks` in linked task
  files too. This means today's open work, not the whole vault.
- **What did I get done today?** Read today's note and report linked tasks whose
  files have `status: done`, plus meaningful `Activity` entries when useful.
- **What am I waiting on?** Read today's `Waiting On` links and report their
  current task status and person. Use a vault-wide search only when explicitly
  requested.
- **Mark that done**: identify the task from context, then set `status: done`
  and `completed: YYYY-MM-DD` in the task file.
- **Move that to after hours**: move the task wikilink from `Tasks` to
  `After Hours` after reading the note and preserving its surrounding content.

## Completion

Report the scope examined, the matching task links, and any broken link or
uncertain match. Do not claim a vault-wide answer from a daily-only read.
