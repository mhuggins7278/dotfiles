---
name: teach
description: Run a structured, multi-session learning workspace. Use only when the user explicitly asks to start or continue a teaching curriculum.
---

# Teaching Workspace

Use this skill only for an explicitly requested, stateful curriculum. Treat the
current directory as the workspace and ground lessons in the user's mission.

## Workspace

- `MISSION.md` captures why the user is learning. Confirm before changing it.
- `lessons/` contains numbered, self-contained lesson HTML files.
- `reference/` contains concise reusable reference documents.
- `learning-records/` captures durable lessons and non-obvious insights.
- `RESOURCES.md` tracks trusted sources; `NOTES.md` stores teaching preferences.
- `assets/` contains reusable lesson components. Reuse existing components
  before adding one.

Load the applicable format before changing a workspace artifact:
`MISSION-FORMAT.md`, `RESOURCES-FORMAT.md`, `LEARNING-RECORD-FORMAT.md`, and
the existing files in the workspace.

## Lesson design

Make each lesson short, mission-relevant, and focused on one tangible skill.
Use high-trust sources and cite claims. Add retrieval practice or a feedback
loop when it serves the topic; do not force interactivity where it does not.
Create reference material when it will be reused across lessons.

Read learning records to choose an appropriate challenge, widening context only
as needed. Ask a focused question when the mission is genuinely unclear.

## Completion

Leave the requested lesson or learning artifact in the workspace, preserve its
existing structure and terminology, and report what was created plus the next
learning action. Open the lesson for the user only when the environment makes
that useful.
