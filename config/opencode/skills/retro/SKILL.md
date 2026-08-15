---
name: retro
description: Run a post-session retrospective to analyze friction, mistakes, and learnings. Use when the user explicitly asks for a retro or wants durable repository guidance proposed from the current session.
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

**A. Repo-Specific Gotchas (AGENTS.md)**
Quirks, preferred libraries, test setup commands, or architectural rules specific to this repository.

**B. Missing Durable Guidance**
Repository-specific workflows that repeatedly caused friction and belong in
`AGENTS.md` or a focused skill rather than a one-session transcript.

**C. Golden Principles**
Systemic invariants that should be checked mechanically across all repos (e.g., "Never commit `console.log`").

### 3. Propose `AGENTS.md` Updates
If there are repo-specific learnings, check if an `AGENTS.md` file exists in the repository root (`git rev-parse --show-toplevel`).
If it doesn't exist, propose creating it.
Draft the exact markdown additions (using the "stable content first, volatile details last" pattern) and present them to the user for approval.

### 4. Apply Updates
Wait for the user to approve. Once approved:
- Use the Edit/Write tools to update `AGENTS.md` in the repo root.
- Capture broader guidance only when the pattern has repeated and the rule is
  stable enough to justify permanent context.

Completion means the report separates repo-specific guidance, missing durable
guidance, and mechanical principles; it includes exact proposed edits; and no
file is changed without approval.

## Common Pitfalls
- Don't pollute `AGENTS.md` with generic programming advice; keep it strictly repo-specific.
- Do not apply changes automatically without user approval.
- Always read the existing `AGENTS.md` before appending so you don't duplicate rules.
