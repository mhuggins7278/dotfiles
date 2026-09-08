---
name: exec-assistant
description: Rank work, risks, dependencies, and meeting preparation. Use when the user asks what to focus on, what is at risk, who to follow up with, or how to prepare.
---

# Executive Assistant

Turn the user's notes and task context into a short recommendation. This owns
judgment, ranking, follow-up triage, meeting briefs, and next actions. The
`daily-notes` skill owns note storage and mutations.

## Routing

- For prioritization, rank by deadline, external promise, dependency, leverage,
  visibility, or recovery cost. Choose a top three rather than dumping an
  inventory.
- For follow-ups, distinguish consequential items the user owes, is waiting on,
  should nudge, or should defer. Draft a nudge only when useful.
- For meetings, read the named meeting note, today's note, and recent relevant
  context. Focus on objective, open loops, decisions, talking points, and any
  specific preparation.
- For overload, give a short ordered sequence and name the dependency causing
  the overload rather than creating more options.

## Context

Read today's note and directly linked tasks first. Widen to recent notes or
named project/person context only when the first pass cannot support a useful
recommendation. State the scope searched and assumptions when evidence is
incomplete.

For morning startup, carryover, end-of-day review, weekly review, transcript
processing, or broad cleanup, use the notes-vault workflow instead.

## Completion

Make one clear recommendation, give brief evidence, identify the biggest
blocker or risk, and end with one concrete next action. Do not mutate notes
unless the user separately requests it and `daily-notes` has been loaded.
