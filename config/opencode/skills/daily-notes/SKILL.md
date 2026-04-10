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
| List all open tasks | `rg "^status: (todo\|in-progress\|waiting)" work/tasks/ -l` |
| List today's focus tasks | `rg "^scheduled: YYYY-MM-DD" work/tasks/ -l` |
| Mark a task done | Edit task file: set `status: done` + `completed: YYYY-MM-DD` |
| Mark a task waiting | Edit task file: set `status: waiting` + `waiting_for: [[Person]]` |
| Snooze a task | Edit task file: update `scheduled: YYYY-MM-DD` |
| Capture a task (NLP) | `obsidian tasknotes:capture vault=notes text="<description>"` |
| Create a task (structured) | `obsidian create path=work/tasks/<slug> template=task`, then edit fields + add link to daily note |
| Create a meeting note | `obsidian create path=meetings/YYYY-MM-DD-Title template=meeting-one-off` |
| Create a recurring occurrence | `obsidian create path=meetings/YYYY-MM-DD-Title template=meeting-occurrence` |
| Create a person note | `obsidian create path=work/people/Name template=person` |
| Create a project note | `obsidian create path=work/projects/Name template=project` |
| Get today's path | `obsidian daily:path` |
| Read today's full note | `obsidian daily:read` |
| Search vault | `obsidian search query="<text>"` |
| Search with line context | `obsidian search:context query="<text>" path=dailies` |
| Start time tracking | `obsidian tasknotes:start-time vault=notes query="<task>"` |
| Stop time tracking | `obsidian tasknotes:stop-time vault=notes` |
| Time tracking status | `obsidian tasknotes:time-status vault=notes` |

**After `obsidian create ... template=<name>`**: the note is created with the
template structure. Use an Edit to fill in specific frontmatter fields the
template leaves blank (e.g., `scheduled`, `source`, `project`, `role`).

## TaskNotes CLI

TaskNotes registers commands with the Obsidian desktop CLI (`obsidian
tasknotes:*`). Obsidian must be running. Vault name for this vault is `notes`
— verify with `obsidian help | rg 'tasknotes:'` after installation.

### Task Capture

Use `tasknotes:capture` for quick NLP-driven creation when custom fields
(`waiting_for`, `source`, `delegated_to`) are not needed. Use the structured
`obsidian create` + Edit flow when those fields matter.

```bash
# NLP — parses dates, priority, tags, contexts automatically
obsidian tasknotes:capture vault=notes text="Review Katie's PR tomorrow high priority #work"

# Explicit fields — bypass NLP parsing
obsidian tasknotes:capture vault=notes \
  text="Fix scheduling bug" \
  scheduled=YYYY-MM-DD \
  priority=high \
  status=in-progress

# Literal title — no NLP parsing at all
obsidian tasknotes:capture vault=notes text="Exact title as written" literal
```

**NLP trigger characters** (in `text=` value):
- `@` — context (e.g. `@desk`)
- `#` — tag (e.g. `#work`)
- `+` — project link (e.g. `+[[BCG Invite Templates]]`)
- `*` — status (e.g. `*in-progress`)

**Supported explicit flags**: `title`, `details`, `status`, `priority`, `due`,
`scheduled`, `tags`, `contexts`, `projects`, `recurrence`,
`recurrence-anchor`, `reminders`, `estimate`

**Note**: `tasknotes:capture` does not set `waiting_for`, `source`, or
`delegated_to`. For tasks requiring those fields, use `obsidian create
path=work/tasks/<slug> template=task` then Edit the file.

**After capture**: add the wikilink manually to today's daily note since
`tasknotes:capture` does not update daily notes.

### Time Tracking

```bash
# Start tracking — target by fuzzy query, exact title, or path
obsidian tasknotes:start-time vault=notes query="scheduling bug"
obsidian tasknotes:start-time vault=notes title="Fix scheduling bug"
obsidian tasknotes:start-time vault=notes path="work/tasks/fix-scheduling-bug.md"

# With a session description
obsidian tasknotes:start-time vault=notes query="scheduling bug" description="Investigating root cause"

# Stop tracking (stops unambiguous active session)
obsidian tasknotes:stop-time vault=notes

# Stop specific task
obsidian tasknotes:stop-time vault=notes query="scheduling bug"

# Show active sessions / time summary for a task
obsidian tasknotes:time-status vault=notes
obsidian tasknotes:time-status vault=notes query="scheduling bug"
```

### Pomodoro

```bash
# Start a 25-minute session (with or without a linked task)
obsidian tasknotes:pomodoro vault=notes action=start duration=25
obsidian tasknotes:pomodoro vault=notes action=start query="scheduling bug" duration=25

# Control session
obsidian tasknotes:pomodoro vault=notes action=pause
obsidian tasknotes:pomodoro vault=notes action=resume
obsidian tasknotes:pomodoro vault=notes action=stop

# Breaks
obsidian tasknotes:pomodoro vault=notes action=short-break
obsidian tasknotes:pomodoro vault=notes action=long-break

# Check state
obsidian tasknotes:pomodoro vault=notes action=status
```

## File Edits

When a CLI command isn't sufficient (inserting under a specific heading,
updating multiple sections, reordering items), use the Edit tool on the
resolved daily note path directly. Read the file first, then make a targeted
edit. Prefer surgical edits over full rewrites.

## Note Structure

```markdown
## Tasks
- [[work/tasks/slug|Display text]]

## Activity
- Shipped thing, met with person, made decision, sent update

## After Hours
- [[work/tasks/slug|Display text]]

## Meetings
### [[meetings/YYYY-MM-DD-Title|Meeting Title]]

## Waiting On
- [[work/tasks/waiting-person-thing|Person — what you're waiting for]]

## I Owe
- [[work/tasks/owe-person-thing|Person — what you owe them]]

## Notes
Freeform thoughts, context, observations, rationale, and reminders
```

Task sections (Tasks, After Hours, Waiting On, I Owe) hold **wikilinks to task
files** in `work/tasks/` — not raw checkboxes. The task file's `status` field
is canonical. The daily note is the planning view for the day.

Use `Activity` for what happened. Use `Notes` for context worth remembering.
Do not add checkboxes or task links to `Notes` or `Activity`.

## Natural Capture Model

Translate natural language into note updates using this mental model:

- `I need to...` → Create task file (`obsidian create path=work/tasks/<slug> template=task`) + add link to `Tasks`
- `later / not urgent / revisit...` → Create task file + add link to `After Hours`
- `I did / shipped / met / decided / sent...` → `Activity` (plain bullet, no task file needed)
- `waiting on...` → Create task file with `status: waiting` + `waiting_for:` + add link to `Waiting On`
- `I owe / need to send them / promised...` → Create task file + add link to `I Owe`
- `remember / context / observation / rationale...` → `Notes` (plain prose)

One user message can create multiple entries when that matches reality.

Example:

- User: `I sent Priya the draft and now I'm waiting on feedback`
- Result:
  - `Activity`: sent draft to `[[Priya]]`
  - Create `work/tasks/waiting-priya-draft-feedback.md` with `status: waiting`, `waiting_for: "[[Priya]]"`
  - `Waiting On`: `[[work/tasks/waiting-priya-draft-feedback|Priya — feedback on draft]]`

**Task creation steps**:
1. `obsidian create path=work/tasks/<slug> template=task`
2. Edit the task file to fill in: `scheduled`, `priority`, `source` (if from a meeting), `project` (if applicable), `waiting_for` or `delegated_to` if relevant
3. Add the wikilink to the correct daily note section

## Task Status Values

Task files use a `status` frontmatter field as the canonical state. This drives
carryover during morning planning — the daily note holds only wikilinks, never
raw checkboxes.

| Status        | Meaning                       | Carries over? |
|---------------|-------------------------------|---------------|
| `todo`        | Not started                   | Yes           |
| `in-progress` | Actively being worked on      | Yes           |
| `waiting`     | Blocked on another person     | Yes           |
| `done`        | Completed                     | No            |
| `cancelled`   | Dropped or no longer relevant | No            |

## Backlinks

Use Obsidian wikilinks for people, projects, and ideas:

- **People**: `[[Person Name]]` → file lives at `work/people/Person Name.md`
- **Projects**: `[[Project Name]]` → file lives at `work/projects/ProjectName.md`
- **Task notes**: `[[work/tasks/slug|Display text]]` — used in task sections
- **Meeting notes**: `[[meetings/YYYY-MM-DD-Title|Title]]` — used in Meetings section

Prefer best-effort backlinking for obvious matches. Do not block capture on
name uncertainty.

- If an exact or clearly intended person file already exists, link it.
- If multiple plausible matches exist, ask.
- If no existing file is obvious, keep plain-text name for now.
- Before creating a new person note, check existing people files with
  `obsidian files folder=work/people`.
- To create a person note: `obsidian create path=work/people/Name template=person`

## Lightweight Review

This skill can also handle quick review prompts such as:

- `what's still open?`
- `what did I get done today?`
- `what am I waiting on?`
- `mark that done`
- `move that to after hours`

**Prefer targeted operations over reading the full note:**

- `what's still open?` → `rg "^status: (todo|in-progress|waiting)" work/tasks/ -l` to find open task files; or `obsidian daily:read` and collect task links from the sections
- `what did I get done today?` → `obsidian daily:read`, then filter for tasks in today's sections whose files have `status: done`
- `what am I waiting on?` → `rg "^status: waiting" work/tasks/ -l`
- `mark that done` → identify the task file from context, edit it: `status: done` + `completed: YYYY-MM-DD`
- `move that to after hours` → read the daily note, move the task link from `Tasks` to `After Hours`

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
