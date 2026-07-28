---
name: implement
description: Implement a piece of work described by a spec, ticket, or issue — test-first at agreed seams, then reviewed and committed. Use when asked to "implement", "build", or "work on" a ticket/issue/spec.
disable-model-invocation: true
---

# Implement

Build the work described by the user, a spec, or a GitHub issue/ticket.

## Process

### 1. Load context

If given an issue/ticket reference, fetch its full body (and the parent epic's, if it has one):

```bash
gh issue view <number> --repo "<REPO>"
```

Read `CONTEXT.md` and relevant ADRs (`docs/adr/`) if they exist, so naming and interfaces match the project's domain language (see the `domain-modeling` skill).

### 2. Build test-first at agreed seams

Use the `tdd` skill wherever the work has a clear seam to test at. Confirm the
seams with the user before writing any test, unless the prompt explicitly says
this is a `/workon` lane worker. A lane worker selects and records routine
seams autonomously so each ticket does not pause the lane.

Not every change has a meaningful seam (a pure config tweak, a one-line typo fix) — use judgment; `tdd` is for building or changing behavior, not every edit.

### 3. Check as you go

Run typechecking regularly and single test files regularly during the loop. Run the full test suite once at the end.

### 4. Review

Once the implementation is done, invoke the `review` subagent via the Task tool against the uncommitted diff. Pass it the issue/ticket context (repo, issue number, title) so it understands what was being built.

Read the `REVIEW_VERDICT` block at the end of its output:
- `APPROVED` → proceed to commit.
- `NEEDS_WORK` → fix every Blocker and Critical issue, then return to this step. Warnings and suggestions don't block, but note them.

If `NEEDS_WORK` comes back three times in a row, stop looping and surface the remaining issues to the user — ask how they'd like to proceed (fix manually, skip, or abandon) rather than looping forever.

### 5. Commit

Use the `commit` skill to commit the work to the current branch — it carries the safety rules (secret scanning, GLG issue-first check, hook awareness) that a raw `git commit` here would skip.

### 6. Report

Summarize what was built, the review outcome, and the commit. If the user wants
a PR, hand off to the `pr` skill. A `/workon` lane worker continues to its next
listed local ticket; after its final ticket, it updates the lane's combined
draft PR.
