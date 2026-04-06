---
name: daily-notes
description: >
  Inline daily notes capture and lightweight review — quickly track what the
  user needs to do, what they did, what they're waiting on, what they owe, and
  what they want to remember in today's note without switching context. Use
  this skill whenever the user says things like "track this," "note this,"
  "I just shipped...," "I'm waiting on...," "I owe...," "what's open?,"
  "what did I get done?," or otherwise wants daily-note updates to happen in
  the flow of work. For full morning planning, end-of-day review, meeting
  transcript processing, weekly summaries, or larger cleanup passes, direct the
  user to the `daily-notes` agent instead.
---

# Daily Notes — Inline Capture

Handles low-friction daily-note updates from any session. Default to capturing
the user's natural-language updates directly into today's note with minimal
ceremony. For full conversational workflows (morning startup, end-of-day
review, meeting transcripts, weekly summaries, broad cleanup), tell the user to
switch to the `daily-notes` agent via `ctrl+p` → Agents.

## Note Location

```
/Users/MHuggins/github/mhuggins7278/notes/dailies/YYYY-MM-DD.md
```

Use `obsidian daily:path` to get today's path. Use `obsidian daily:read` to
read the current note. Never hardcode the date — always resolve it via CLI or
`date`.

## Default Behavior

- Capture first, clean up second.
- Classify the user's update into the right section without making them speak in
  a rigid format.
- Make the write, then reply with a brief confirmation.
- Ask a follow-up only when ambiguity materially changes where the item belongs
  or whether a new linked note should be created.

## CLI Quick Operations

Prefer these for single-item changes:

| Goal | Command |
|------|---------|
| List open tasks with line numbers | `obsidian tasks daily todo verbose` |
| Mark a task done | `obsidian task daily line=<n> done` |
| Toggle a task | `obsidian task daily line=<n> toggle` |
| Set in-progress | `obsidian task daily line=<n> "status=/"` |
| Append a new task | `obsidian daily:append content="- [ ] Task description"` |
| Get today's path | `obsidian daily:path` |
| Read today's full note | `obsidian daily:read` |
| Search vault | `obsidian search query="<text>"` |
| Search with line context | `obsidian search:context query="<text>" path=dailies` |

**Use `tasks daily todo verbose` as the default starting point for any task
review or update.** It returns `path:line: task text` output — you get line
numbers directly and can mark items done without loading the full note into
context. Only use `daily:read` when you need the full note contents (freeform
sections like `Activity` or `Notes`).

For anything that needs insertion under a specific heading such as `Activity`,
`Waiting On`, or `Notes`, read the note and make a targeted edit.

## File Edits

When a CLI command isn't sufficient (inserting under a specific heading,
updating multiple sections, reordering items), use the Edit tool on the
resolved daily note path directly. Read the file first, then make a targeted
edit. Prefer surgical edits over full rewrites.

## Note Structure

```markdown
## Tasks
- [ ] Things you own and need to do

## Activity
- Shipped thing, met with person, made decision, sent update

## After Hours
- [ ] Lower-priority items to revisit

## Meetings
### Meeting Title
Notes or link to meeting file

## Waiting On
- [ ] [[Person Name]] — what you're waiting for

## I Owe
- [ ] [[Person Name]] — what you owe them

## Notes
Freeform thoughts, context, observations, rationale, and reminders
```

Use `Activity` for what happened during the day. Use `Notes` for context worth
remembering. Keep tasks in checkbox sections. Do not add checkboxes to
`Notes` or `Activity`.

## Natural Capture Model

Translate natural language into note updates using this mental model:

- `I need to...` -> `Tasks`
- `later / not urgent / revisit...` -> `After Hours`
- `I did / shipped / met / decided / sent...` -> `Activity`
- `waiting on...` -> `Waiting On`
- `I owe / need to send them / promised...` -> `I Owe`
- `remember / context / observation / rationale...` -> `Notes`

One user message can create multiple entries when that matches reality.

Example:

- User: `I sent Priya the draft and now I'm waiting on feedback`
- Result:
  - `Activity`: sent draft to `[[Priya]]`
  - `Waiting On`: `[[Priya]]` — feedback on draft

## Checkbox States

| Syntax | Meaning | Carries over? |
|--------|---------|---------------|
| `- [ ]` | To do | Yes |
| `- [/]` | In progress | Yes |
| `- [x]` | Done | No |
| `- [-]` | Cancelled | No |
| `- [>]` | Deferred | Yes |

## Backlinks

Use Obsidian wikilinks for people, projects, and ideas:

- **People**: `[[Person Name]]` → file lives at `work/people/Person Name.md`
- **Projects**: `[[Project Name]]` → file lives at `work/projects/ProjectName.md`
- **Waiting On / I Owe**: always backlink the person name at the start

Prefer best-effort backlinking for obvious matches. Do not block capture on
name uncertainty.

- If an exact or clearly intended person file already exists, link it.
- If multiple plausible matches exist, ask.
- If no existing file is obvious, keep the plain-text name for now unless the
  user specifically wants a people note created.
- Before creating a new person note, check existing people files with
  `obsidian files folder=work/people`.

## Lightweight Review

This skill can also handle quick review prompts such as:

- `what's still open?`
- `what did I get done today?`
- `what am I waiting on?`
- `mark that done`
- `move that to after hours`

**Prefer targeted CLI commands over reading the full note:**

- `what's still open?` → `obsidian tasks daily todo verbose` (returns tasks +
  line numbers; no full note load)
- `what did I get done today?` → `obsidian tasks daily done`
- `what am I waiting on?` → `obsidian tasks daily todo verbose`, then filter
  lines that start with `[[`
- `mark that done` → `obsidian tasks daily todo verbose` to identify the line,
  then `obsidian task daily line=<n> done`
- `move that to after hours` → line number from `verbose` output, then edit the
  note at that line

Only use `obsidian daily:read` when freeform content (`Activity`, `Notes`,
`Meetings`) is needed.

## Escalation Boundary

Tell the user to switch to the `daily-notes` agent for:
- Morning startup and carry-over review across days
- End-of-day closeout and reflection
- Meeting transcript processing
- Weekly summary generation
- Large cleanup or restructuring passes across the note

For Obsidian-specific syntax (wikilinks, callouts, frontmatter), refer to `~/.dotfiles/config/opencode/references/obsidian-markdown.md`.
