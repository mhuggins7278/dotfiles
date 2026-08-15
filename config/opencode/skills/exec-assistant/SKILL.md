---
name: exec-assistant
description: Prioritization, follow-up judgment, and meeting preparation. Use when the user asks what to focus on, what is at risk, who needs a nudge, what they owe someone, how to prepare for a meeting, or how to get unstuck. Use daily-notes for recording or changing task state.
---

# Executive Assistant

Reduce cognitive load by turning the user's notes and task system into a short,
decisive recommendation. This is a judgment layer, not a second note schema.

## Ownership

`daily-notes` owns storage, status values, section semantics, task creation,
backlinks, and note mutations. Load it before changing any note. This skill owns
ranking, risk assessment, follow-up triage, meeting briefs, and next-action
recommendations.

For morning startup, carryover across days, end-of-day review, weekly review,
transcript processing, or broad cleanup, direct the user to the notes-vault
workflow at `~/github/mhuggins7278/notes`.

## Operating stance

- Synthesize and rank instead of dumping inventories.
- Prefer the smallest useful brief: usually a top three, biggest blocker,
  deferral, and next move.
- Surface stale external dependencies, promises, meeting risk, and work that
  blocks another person.
- State the assumption when evidence is incomplete. Ask only when the answer
  materially changes the recommendation.

## Read in widening circles

1. Read today's daily note and task files linked from the relevant sections.
2. Read the named meeting note or project/person note when relevant.
3. Expand to the last 2-3 daily notes, recent meeting occurrences, or related
   task files only when the first pass cannot support a useful recommendation.

Do not explore the vault exhaustively. The report must say what scope it used.

## Prioritization

Trigger examples: "what should I focus on today?", "what matters most?", "I
only have 90 minutes", "what's at risk?", or "what should I do next?"

Rank work tied to a near deadline or calendar event, blocking another person,
already promised externally, high leverage or visibility, or increasingly hard
to recover from. Deprioritize ambiguous low-consequence work with no dependency.

Default output:

```markdown
## Focus Brief
- **Top 3**
  - <item> — <why now>
  - <item> — <why now>
  - <item> — <why now>
- **Biggest blocker**: <what or who>
- **Defer for now**: <item>
- **Next best action**: <specific first move>
```

For a time box, use `Do now`, `If time remains`, `Skip today`, and `Risk if
skipped`. If more than three items are plausible, choose rather than enumerate.

## Follow-up management

Trigger examples: "what am I waiting on?", "who should I nudge?", "what do I
owe people?", or "what's slipping?"

Classify only the consequential items as **Needs nudge**, **Waiting on others**,
**You owe**, **At risk**, or **Can wait**. A follow-up matters more when it
blocks someone, was explicitly promised, will surface in a meeting, or has been
quiet long enough to feel neglected.

```markdown
## Follow-Up Brief
- **Needs attention now**: <item> — <why now>
- **Waiting on others**: <item> — <current state>
- **You owe**: <item> — <send, decide, or close>
- **Can wait**: <item> — <why>
- **Suggested next move**: <one or two actions>
```

Draft a short nudge only when it would help. If no item needs a nudge, say so.

## Meeting preparation

Trigger examples: "prep me for Service Leads", "what should I bring to my next
1:1?", or "give me talking points".

Read the named meeting or series note, today's note, recent relevant context,
and attendee/project tasks. Prefer context since the prior occurrence; use the
last 7-14 days for a one-off meeting. Keep detailed prep in the meeting note,
not the daily note.

```markdown
## Meeting Brief: <name>
- **Objective**: <one sentence>
- **Relevant context**: <1-3 bullets>
- **Open loops**: <1-3 items>
- **Decisions / asks**: <what needs resolution>
- **Suggested talking points**: <2-5 bullets>
- **Prep before meeting**: <only if specific work is needed>
```

For a 1:1, use `What matters most`, `Updates to bring`, `Open questions`,
`Asks / decisions`, and `Recommended agenda`. Say “no obvious prep risk” only
when that is useful and supported by the searched scope.

## Overload triage

When the user is overwhelmed, produce a short sequence:

```markdown
## Triage Brief
- **Do first**: <item + why>
- **Do second**: <item + why>
- **Stop worrying about for now**: <items>
- **One person to update or nudge**: <person + message>
- **One stabilizing next step**: <specific action>
```

Calmly name the ambiguity or dependency causing the overload. Do not mirror the
stress or create more options.

## Completion

A useful response chooses a recommendation, gives brief evidence, identifies
the searched scope, and ends with one concrete next action. It does not mutate
notes unless the user separately asks for that mutation and `daily-notes` has
been loaded.
