---
name: daily-notes
description: >
  Inline daily notes operations — add tasks, mark items done, check open items,
  read or update the daily note, and make targeted edits to any section. Use
  this skill whenever the user wants to add a task, update status, check what's
  open, add something to Waiting On or I Owe, insert a note, or make any quick
  change to their daily note — even mid-session, without switching context.
  Trigger on phrases like "add a task," "mark that done," "what's still open,"
  "add to waiting on," "log a note," or any request to read or modify today's
  note. For full morning planning, evening review, meeting transcript processing,
  or weekly summaries, direct the user to the `daily-notes` agent instead.
---

# Daily Notes — Inline Operations

Handles quick reads and targeted writes to the Obsidian daily note from any
session. For full conversational workflows (morning planning, evening review,
meeting transcripts, weekly summaries), tell the user to switch to the
`daily-notes` agent via `ctrl+p` → Agents.

## Note Location

```
/Users/MHuggins/github/mhuggins7278/notes/dailies/YYYY-MM-DD.md
```

Use `obsidian daily:path` to get today's path. Use `obsidian daily:read` to
read the current note. Never hardcode the date — always resolve it via CLI or
`date`.

## CLI Quick Operations

Prefer these for single-item changes:

| Goal | Command |
|------|---------|
| Read today's note | `obsidian daily:read` |
| Get today's path | `obsidian daily:path` |
| Append a new task | `obsidian daily:append content="- [ ] Task description"` |
| List open tasks | `obsidian tasks daily todo` |
| Mark a task done | `obsidian task daily line=<n> done` |
| Toggle a task | `obsidian task daily line=<n> toggle` |
| Set in-progress | `obsidian task daily line=<n> "status=/"` |
| Search vault | `obsidian search query="<text>"` |

## File Edits

When a CLI command isn't sufficient (inserting under a specific heading,
updating multiple sections, reordering items), use the Edit tool on the
resolved daily note path directly. Read the file first, then make a targeted
edit. Prefer surgical edits over full rewrites.

## Note Structure

```markdown
## Tasks
- [ ] Things you own and need to do

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
Freeform thoughts, context, observations — never task restatements
```

**Rule**: Something is either a task (checkbox) or a note (prose) — never both.
Never add checkboxes to the Notes section.

## Checkbox States

| Syntax | Meaning | Carries over? |
|--------|---------|---------------|
| `- [ ]` | To do | Yes |
| `- [/]` | In progress | Yes |
| `- [x]` | Done | No |
| `- [-]` | Cancelled | No |
| `- [>]` | Deferred | No |

## Backlinks

Use Obsidian wikilinks for people, projects, and ideas:

- **People**: `[[Person Name]]` → file lives at `work/people/Person Name.md`
- **Projects**: `[[Project Name]]` → file lives at `work/projects/ProjectName.md`
- **Waiting On / I Owe**: always backlink the person name at the start

Before creating a new person backlink, check for existing people files:
`obsidian files folder=work/people`

## Escalation Boundary

Tell the user to switch to the `daily-notes` agent for:
- Morning planning (carry-over, state changes, new tasks via conversation)
- Evening exit interview (review, reflections, weekly summaries)
- Meeting transcript processing
- Weekly summary generation
- Any workflow requiring extended back-and-forth conversation

For Obsidian-specific syntax (wikilinks, callouts, frontmatter), refer to `~/.dotfiles/config/opencode/references/obsidian-markdown.md`.
