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
  transcript processing, weekly summaries, or larger cleanup passes, open a
  session in the notes vault where the full workflow is defined.
---

# Daily Notes — Inline Capture

Handles low-friction daily-note updates from any session and serves as the
canonical shared contract for daily-note structure, task-note conventions,
status values, backlinking, and one-off Obsidian CLI operations.

Default to capturing the user's natural-language updates directly into today's
note with minimal ceremony. For full conversational workflows (morning
startup, end-of-day review, meeting transcripts, weekly summaries, broad
cleanup), tell the user to open a session in the notes vault
(`~/github/mhuggins7278/notes`) where `CLAUDE.md` at
`~/github/mhuggins7278/notes/CLAUDE.md` defines those workflows.

## Ownership

- This skill owns the shared note model used across daily-note workflows.
- Long-form orchestration (morning planning, evening review, weekly summaries,
  meeting transcripts, cleanup passes) is defined in the notes vault's
  `CLAUDE.md` at `~/github/mhuggins7278/notes/CLAUDE.md`.
- When a shared rule changes, update this skill first and keep the vault's
  `CLAUDE.md` aligned to it.

## Note Location

```
~/github/mhuggins7278/notes/dailies/YYYY-MM-DD.md
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

---

## Tiered Task Model

Not every action item deserves its own file. Use this decision tree before
creating a task note:

**Create a task note** (`work/tasks/<slug>.md`) when the task:
- Involves investigation, research, or findings you'll need to reference later
- Has meaningful context that won't fit in a single line (background,
  depends-on, open questions, findings)
- Is a top-level commitment — something that shows up in your planning view
  on its own merits

**Use an inline checkbox** (`- [ ] action item`) when the task:
- Is a discrete sub-step of an existing task note
- Has no context beyond what the parent note already contains
- Would only ever be looked at through the parent note anyway

**Where inline sub-tasks live**: inside the parent task note under a
`## Sub-tasks` section:

```markdown
## Sub-tasks

- [ ] **Short label** — detail (scheduled YYYY-MM-DD)
- [ ] **Another step** — detail
```

The daily note links only to the parent task note. Sub-tasks are checked off
inside the parent note itself.

**Simple standalone tasks** that need carry-over but have no context: still
create a task note. The tiered model targets sub-tasks, not lightweight
top-level items.

---

## Bases — Review View

Obsidian Bases provides a live table/kanban view over your task notes without
plugins. Set it up once; use it as your primary review surface.

### Setup

1. In Obsidian, run **"Create new base"** from the command palette (or
   right-click `work/tasks/` in the file explorer → New Base).
2. Name it `Open Tasks` and save it at `work/tasks/Open Tasks.base`.
3. Configure via the Base UI:
   - Source: `work/tasks` folder
   - Filters: `status` is not `done` **and** `status` is not `cancelled`
   - Sort: `scheduled` ascending
   - Group by: `status` (separates `todo` / `in-progress` / `waiting`)
   - Columns: `status`, `priority`, `scheduled`, `tags`

The Base file lives in your vault at `work/tasks/Open Tasks.base` and
refreshes automatically as frontmatter changes. Obsidian must be running.

### Daily use

- **Morning review**: open `Open Tasks.base` — all active task notes in one
  view, no wikilink hopping
- **Mark done**: click the `status` cell and change it directly in the Base,
  or open the task note
- **Snooze**: update `scheduled` in the Base cell to push a task out of view
- **Sub-tasks**: Bases reads frontmatter only, not note body — open the
  parent task note directly to check off inline sub-tasks

### Promoting a sub-task

If a sub-task grows large enough to need its own context, promote it: create a
task note and replace the checkbox line in the parent with a wikilink.

---

## CLI Quick Operations

Prefer these for single-item changes:

| Goal | Command |
|------|---------|
| List all open tasks | `rg "^status: (todo\|in-progress\|waiting)" work/tasks/ -l` |
| List today's focus tasks | `rg "^scheduled: YYYY-MM-DD" work/tasks/ -l` |
| Mark a task done | Edit task file: set `status: done` + `completed: YYYY-MM-DD` |
| Mark a task waiting | Edit task file: set `status: waiting` + `waiting_for: [[Person]]` |
| Snooze a task | Edit task file: update `scheduled: YYYY-MM-DD` |
| Check sub-tasks on a parent | Read the task file; check `## Sub-tasks` section |
| Create a task (structured) | `obsidian create path=work/tasks/<slug> template=task`, then **immediately set `status`** (template default is `done`), fill fields + add link to daily note |
| Create a meeting note | `obsidian create path=meetings/YYYY-MM-DD-Title template=meeting-one-off` |
| Create a recurring occurrence | `obsidian create path=meetings/YYYY-MM-DD-Title template=meeting-occurrence` |
| Create a person note | `obsidian create path=work/people/Name template=person` |
| Create a project note | `obsidian create path=work/projects/Name template=project` |
| Get today's path | `obsidian daily:path` |
| Read today's full note | `obsidian daily:read` |
| Search vault | `obsidian search query="<text>"` |
| Search with line context | `obsidian search:context query="<text>" path=dailies` |

**After `obsidian create ... template=<name>`**: the note is created with the
template structure. Use an Edit to fill in specific frontmatter fields the
template leaves blank (e.g., `scheduled`, `source`, `project`, `role`).

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

## Meeting Prep Context

When setting up the day's note from calendar events, enrich each meeting with
brief prep context when sources are available. The goal is to help the user walk
into the meeting oriented, not to dump all related history into the daily note.

- Create or update the meeting note as the source of truth for prep details,
  discussion notes, decisions, and follow-ups.
- For each calendar meeting, derive search terms from the meeting title,
  organizer, required attendees, recurring series name, projects, and obvious
  acronyms.
- Search recent daily notes, prior meeting notes, recurring meeting metadata,
  linked project notes, and linked person notes for relevant context.
- If Teams, email, SharePoint, calendar, or other O365 connectors are available,
  also check recent messages and threads involving the meeting title, attendees,
  project names, and active follow-ups.
- Prefer context since the last occurrence for recurring meetings; otherwise use
  the last 7-14 days unless the meeting clearly references older work.
- Add 1-3 concise prep bullets or questions to the meeting note, with source
  hints such as `Daily note`, `Teams`, `Email`, or `Prior meeting` when useful.
- In the daily note's `Meetings` section, keep the summary compact: the meeting
  backlink plus one short prep cue when there is useful context.
- Do not invent context. If nothing useful is found, leave the meeting summary
  plain or note `no obvious prep context found` only when that is helpful.

## Natural Capture Model

Translate natural language into note updates using this mental model:

- `I need to...` → **First ask**: is this a sub-step of an existing task note?
  If yes → add `- [ ] **label** — detail` to that task note's `## Sub-tasks`
  section. If no → create task file + add link to `Tasks`.
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

0. **Decide tier first**: is this a sub-task of an existing task note? If so,
   add `- [ ] **Short label** — detail (scheduled YYYY-MM-DD)` to that note's
   `## Sub-tasks` section and stop — do not create a new file.
1. `obsidian create path=work/tasks/<slug> template=task`
2. **Immediately** edit the task file to set `status` to the correct value
   (`todo`, `in-progress`, or `waiting`). The template default is `status: done`
   — never leave it as-is. A task with `status: done` will not carry forward and
   will be invisible in the planning view.
3. Fill in remaining fields: `scheduled`, `priority`, `source` (if from a
   meeting), `project` (if applicable), `waiting_for` or `delegated_to` if
   relevant, `completed` must be blank unless actually done.
4. Add the wikilink to the correct daily note section.

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

- **People**: `[[Person Name]]` — resolves to `work/people/Person Name.md`.
  Bare wikilinks are preferred when the name is unambiguous. Use the full path
  form `[[work/people/Person Name|Person Name]]` only when disambiguation is
  needed (e.g. two people with similar names).
- **Projects**: `[[Project Name]]` → file lives at `work/projects/ProjectName.md`
- **Task notes**: `[[work/tasks/slug|Display text]]` — always use the path-qualified
  form in task sections so links are unambiguous regardless of note title.
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

- `what's still open?` → Read today's daily note, collect all wikilinks from
  `Tasks`, `After Hours`, `Waiting On`, and `I Owe` sections, read each linked
  task file, and filter to those with `status: todo`, `in-progress`, or
  `waiting`. Also check `## Sub-tasks` sections in each task file for unchecked
  boxes. This gives today's open items — not a vault-wide list.
  Use `rg "^status: (todo|in-progress|waiting)" work/tasks/ -l` only when the
  user explicitly asks for all open tasks vault-wide (not just today's).
- `what did I get done today?` → `obsidian daily:read`, then filter for tasks in today's sections whose files have `status: done`
- `what am I waiting on?` → Read today's note, collect links from `Waiting On`,
  read each task file. For vault-wide waiting tasks: `rg "^status: waiting" work/tasks/ -l`
- `mark that done` → identify the task file from context, edit it: `status: done` + `completed: YYYY-MM-DD`
- `move that to after hours` → read the daily note, move the task link from `Tasks` to `After Hours`

Only use `obsidian daily:read` when freeform content (`Activity`, `Notes`,
`Meetings`) is needed.

## Escalation Boundary

Tell the user to open a session in the notes vault
(`~/github/mhuggins7278/notes`) for:
- Morning startup and carry-over review across days
- End-of-day closeout and reflection
- Meeting transcript processing
- Weekly summary generation
- Large cleanup or restructuring passes across the note

For Obsidian-specific syntax (wikilinks, callouts, frontmatter), refer to `~/.dotfiles/config/opencode/references/obsidian-markdown.md`.
