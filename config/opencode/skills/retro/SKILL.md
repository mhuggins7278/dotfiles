---
name: retro
description: >
  Run a post-session retrospective to analyze friction, mistakes, and learnings.
  Use this skill to update the repo's CLAUDE.md with new gotchas, or to propose
  new playbooks and golden principles. Trigger on "/retro", "run a retro",
  "let's do a retrospective", or "what did we learn".
---

# Retrospective Skill

Analyze the current coding session to capture learnings, prevent future mistakes,
and improve the AI harness.

## Workflow

### 1. Analyze the Session
Review the entire conversation history of the current session. Look for:
- Things that required multiple attempts to get right.
- Tool failures, test failures, or linter errors.
- Missing context (e.g., "I didn't know I had to use X").
- Architectural patterns specific to this repo that we had to figure out.

### 2. Identify Actionable Improvements
Categorize the learnings into three buckets:

**A. Repo-Specific Gotchas (CLAUDE.md)**
Quirks, preferred libraries, test setup commands, or architectural rules specific to this repository.

**B. Missing Playbooks**
Workflows we did today that are likely to be repeated (e.g., "Adding a new database migration"). These should be documented as step-by-step playbooks.

**C. Golden Principles**
Systemic invariants that should be checked mechanically across all repos (e.g., "Never commit `console.log`").

### 3. Propose `CLAUDE.md` Updates
If there are repo-specific learnings, check if a `CLAUDE.md` file exists in the repository root (`git rev-parse --show-toplevel`).
If it doesn't exist, propose creating it.
Draft the exact markdown additions (using the "stable content first, volatile details last" pattern) and present them to the user for approval.

### 4. Apply Updates
Wait for the user to approve. Once approved:
- Use the Edit/Write tools to update `CLAUDE.md` in the repo root.
- If new Playbooks or Golden Principles were identified, instruct the user how they should be captured in `~/.dotfiles/config/opencode/`.

## Common Pitfalls
- Don't pollute `CLAUDE.md` with generic programming advice; keep it strictly repo-specific.
- Do not apply changes automatically without user approval.
- Always read the existing `CLAUDE.md` before appending so you don't duplicate rules.