# Daily Notes Task Model

Load this reference before creating, changing, completing, waiting on, or
moving a task. Task-file status is canonical; daily-note sections contain links
to task files, never raw task checkboxes.

## Classification

| User says | Daily-note section | Task file |
|---|---|---|
| `I need to...` | `Tasks` | Yes, unless it is a sub-task |
| `later`, `not urgent`, `revisit` | `After Hours` | Yes |
| `I did`, `shipped`, `met`, `decided`, `sent` | `Activity` | No, unless it closes a tracked task |
| `waiting on <person>` | `Waiting On` | Yes, with `status: waiting` |
| `I owe`, `promised`, `need to send` | `I Owe` | Yes |
| `remember`, `context`, `rationale` | `Notes` | No |

One message may produce several entries when that matches reality. If a
completion matches a task linked from today's note, set that task to `done` and
set `completed: YYYY-MM-DD`, even when the completion happened through email or
Teams.

## Task tiers

Create `work/tasks/<slug>.md` when the item is a top-level commitment, needs
carry-over, or has context worth preserving. Put a discrete sub-step inside its
parent task's `## Sub-tasks` section when it has no independent context.

```markdown
## Sub-tasks

- [ ] **Short label** — detail
```

The daily note links only to the parent task. A simple standalone task still
gets a task file; the tier distinction applies to sub-tasks.

## Required creation sequence

1. Create the file with:
   `obsidian create path=work/tasks/<slug> template=task`
2. Immediately set `status` to `todo`, `in-progress`, or `waiting`. The
   template default is `done`, which is wrong for a new task.
3. Fill `scheduled`, `priority`, `source`, `project`, `waiting_for`, or
   `delegated_to` when relevant. Leave `completed` blank until completion.
4. Add `[[work/tasks/<slug>|Display text]]` to the correct daily-note section.

When marking a task done, set `status: done` and
`completed: YYYY-MM-DD` in the same edit. A done task does not carry forward.
Cancelled tasks also do not carry forward.

## Daily-note structure

```markdown
## Tasks

- [[work/tasks/slug|Display text]]

## Activity

- Completed work, decisions, meetings, or updates sent

## After Hours

- [[work/tasks/slug|Display text]]

## Meetings

## Waiting On

- [[work/tasks/slug|Person — what you're waiting for]]

## I Owe

- [[work/tasks/slug|Person — what you owe them]]

## Notes
```

Use plain bullets for `Activity` and `Notes`. Use path-qualified task wikilinks
for task sections. Link an existing person or project note when unambiguous;
keep plain text when no existing note is obvious, and ask when multiple matches
are plausible.

## One-off operations

- Resolve today's note: `obsidian daily:path`
- Read today's note: `obsidian daily:read`
- Search the vault: `obsidian search query="<text>"`
- List open tasks: `rg "^status: (todo|in-progress|waiting)" work/tasks/ -l`

Read the target file before a surgical edit. Do not rewrite the entire daily
note to insert one item.
