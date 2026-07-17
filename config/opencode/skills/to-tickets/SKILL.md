---
name: to-tickets
description: Break a task, PR, or spec into GitHub issues — tracer-bullet vertical slices, each declaring the tickets that block it. Use when asked to "plan this out", "create tickets for", "break this into issues", or "make a plan for". Produces a single issue for self-contained work, or a parent epic with linked sub-issues for larger features. Runs a grilling challenge phase before drafting.
disable-model-invocation: true
---

# To Tickets

Break a task description, PR, or spec into well-scoped GitHub issues — **tracer-bullet** tickets, each declaring the tickets that **block** it. A single self-contained task produces one issue; multi-phase or multi-concern work produces a parent epic with sub-issues linked via GitHub's native sub-issue relationship.

The output is always GitHub issues — not a markdown document. Use `to-spec` first if you want a spec/PRD published instead of, or ahead of, tickets.

This skill includes a mandatory challenge phase before drafting issues, run via the `grilling` skill. It will push back on the plan, ask uncomfortable questions, and force you to defend your choices. That pressure is the point — it surfaces gaps before they become bugs or scope creep.

---

## Step 1: Detect Repo Context

```bash
gh repo view --json owner,nameWithOwner -q '{owner: .owner.login, repo: .nameWithOwner}'
```

Record `OWNER` and `REPO`. If `OWNER == "glg"`, GLG mode is active:
- Issues will be added to project `92` (`Enterprise Integration`)
- Branch naming uses hyphens only (no slashes)
- Read `~/.dotfiles/config/opencode/references/glg-workflow.md` for full rules

---

## Step 2: Intake

If `$ARGUMENTS` was provided (a task description, spec issue, or PR reference), use it as the starting context and proceed to Step 3.

If the input references a pull request (a PR URL, a `#number`, or the phrase "this PR"), fetch its details before doing anything else:

```bash
gh pr view <number-or-url>
gh pr diff <number-or-url>
```

Use `gh pr view` output to understand intent and `gh pr diff` output as the authoritative source of what has changed. Treat the diff the same as codebase research — extract file paths, patterns, and scope from it directly.

If the input references an existing spec issue (from `to-spec`), fetch its full body:

```bash
gh issue view <number> --repo "<REPO>"
```

If nothing was provided, ask:

> "What needs to be planned? Provide a description of the task, feature, or problem — or a spec/PR reference."

Wait for the user's response before continuing.

---

## Step 3: Research

Before engaging with the user, investigate the codebase thoroughly. Use the `explore` subagent (via the Task tool):

```
Research this task in the codebase: [TASK DESCRIPTION]

Find:
- Files and components directly relevant to this change
- Existing patterns to follow (similar features, naming conventions)
- Integration points, dependencies, and potential side effects
- Any TODOs, feature flags, or known gaps related to this area
- Alternative approaches that exist in the codebase or were previously attempted
- Anything in-flight (recent commits, open PRs) that could conflict with this change

Return: a summary of findings with file:line references, flag anything that
would affect scope or approach, and note any places where the proposed approach
might conflict with existing patterns.
```

If a PR diff or spec body was retrieved in Step 2, include it as additional context in the research prompt so the subagent can cross-reference it against the codebase.

Read the research output fully before proceeding — the challenge phase and the ticket breakdown both depend on it. Ticket titles and descriptions should use the project's domain glossary vocabulary (`CONTEXT.md`, if it exists) and respect ADRs in the area you're touching. Look for opportunities to prefactor the code to make the implementation easier — "make the change easy, then make the easy change" — and reflect any prefactoring as its own, first ticket.

---

## Step 4: Challenge & Refine

Run a `grilling` session as the challenge phase. Follow its instructions exactly — interview the user relentlessly, one question at a time, resolving each branch of the decision tree before moving on.

Ground every question in the codebase research from Step 3. When a question can be answered by exploring the codebase, explore it instead of asking. Calibrate depth to complexity:

- **Tiny change**: 1-2 targeted probes.
- **Single feature**: Full interview covering technical feasibility, scope, and assumptions.
- **Multi-service or architectural change**: Full interview across all dimensions — feasibility, scope, architecture, assumptions, and business value.

When the interview is complete, give a brief confidence summary before proceeding:

```
Based on our discussion:
- Strong: [what's well-reasoned — 1-2 things]
- Resolved: [what we worked out during the challenge]
- Remaining risk: [what's still uncertain or unresolved — be honest]

Ready to scope the tickets?
```

Carry any unresolved risks forward into the ticket bodies as open questions.

---

## Step 5: Draft Vertical Slices

Break the work into **tracer bullet** tickets:

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh agent session — one `implement` run per ticket
- Any prefactoring identified in Step 3 is its own ticket, first in the sequence

Give each ticket its **blocking edges** — the other tickets that must complete before it can start, written as `depends on <REPO>#<N>` in its body (this is the convention `workon` parses for its dependency graph). A ticket with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**:

1. **Expand** — add the new form beside the old so nothing breaks.
2. **Migrate** — move call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists.
3. **Contract** — delete the old form once no caller remains, in a ticket blocked by every migrate batch.

When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket — green is promised only there.

---

## Step 6: Determine Scope — Single Issue or Epic

**Single issue** when:
- The work can be reviewed in one PR
- There are no natural seams that would make separate PRs safer
- The full change is understandable as one unit of work

**Epic + sub-issues** when:
- The work spans multiple logical concerns or multiple repos
- Phases have clear dependencies (phase 2 can't start until phase 1 merges)
- Independent parts could be worked in parallel by different people
- The total change would be too large to review in a single PR

Present the proposed structure for approval before drafting bodies:

```
I'm proposing [1 issue / an epic with N sub-issues]:

  Epic: [title] ← parent, no code changes, tracks overall progress
    └─ #1: [title] — [one-line description]
    └─ #2: [title] — [one-line description, depends on #1]
    └─ #3: [title] — [one-line description]

Does this structure make sense, or would you like to adjust the breakdown?
```

Wait for approval before writing issue bodies.

---

## Step 7: Draft Issue Bodies

Write a draft body for each ticket and present them to the user for review. Show all issues before creating any of them. Avoid specific file paths or code snippets in the bodies — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype.

### Sub-issue / single-issue body template

```markdown
## What to build

[The end-to-end behaviour this ticket makes work, from the user's perspective — not a
layer-by-layer implementation list. Link to the parent epic if this is a sub-issue.]

## Out of scope

[Explicit list of related things this issue does NOT cover, to prevent scope creep.]

## Risks & open questions

[Populate this from the challenge phase. For each unresolved concern or assumption
that wasn't fully addressed, write one bullet. Omit this section if nothing of
substance remains — don't manufacture fake risks to fill it.]

## Acceptance criteria

- [ ] [Specific, verifiable condition]
- [ ] [Another verifiable condition]
- [ ] Tests pass
- [ ] No regressions in [related area]

## Blocked by

[`depends on <REPO>#<N>` for each blocking ticket, or "None — can start immediately".]
```

### Epic body template

```markdown
## Overview

[2–3 sentences describing the full feature and why it's being built.]

## Sub-issues

- [ ] #N — [title]
- [ ] #N — [title]
- [ ] #N — [title]

## Risks & open questions

[Carry forward any unresolved concerns from the challenge phase that apply to the
epic as a whole rather than a specific sub-issue.]

## Done when

[The overall acceptance criteria for the epic as a whole — what does "complete"
look like from a user or system perspective?]
```

Present the drafts and iterate until the user approves. Do not create any issues until explicitly told to proceed.

---

## Step 8: Create Issues on GitHub

Once the user approves, create all issues in this order:
1. Sub-issues first (so their numbers are known)
2. Epic last (so its body can reference the real issue numbers)

```bash
gh issue create \
  --repo "<REPO>" \
  --title "<title>" \
  --body "$(cat <<'EOF'
<body>
EOF
)"
```

Capture the issue number from each `gh issue create` call. Hard-code the real numbers into the epic body and into any ticket's `Blocked by` section before creating it.

**GLG repos — add each issue to project 92:**

```bash
gh project item-add 92 --owner glg \
  --url "$(gh issue view <number> --repo "<REPO>" --json url -q .url)"
```

**Link sub-issues to the epic** (only when an epic was created), using GitHub's native sub-issue relationship:

Run one `gh api graphql` command per sub-issue. Supply each issue's GraphQL
node ID directly, which avoids shell variable assignments that plan mode does
not need permission to execute:

```bash
gh api graphql -f query='
  mutation($parentId: ID!, $childId: ID!) {
    addSubIssue(input: {issueId: $parentId, subIssueId: $childId}) {
      issue { number }
      subIssue { number title }
    }
  }
' -f parentId="<epic-node-id>" -f childId="<sub-issue-node-id>" \
  --jq '.data.addSubIssue.subIssue | "#\(.number) \(.title)"'
```

Get an issue's node ID from `gh issue view <number> --repo "<REPO>" --json id
--jq .id` before making the GraphQL call.

Do NOT close or modify any parent issue.

---

## Step 9: Report

```
Created:
  Epic:  <REPO>#<N> — <title>  <url>
  Sub-issues:
    <REPO>#<N> — <title>  <url>
    <REPO>#<N> — <title>  <url>  [depends on #N]

Use /workon <epic-url> to start working through these, or /implement <issue> to
build a single ticket directly.
```

---

## Guidelines

- **Never create issues without user approval of the draft bodies**
- **Never assign issues** to the user unless explicitly asked
- **Keep issue titles short** — a verb phrase, ≤ 60 chars (e.g. "Add pagination to /consultations endpoint")
- **`Blocked by` uses `depends on <REPO>#<N>` syntax** — this is what the `workon` skill parses for ordering
- **Scope each ticket to one PR and one agent session** — if a body describes two distinct reviewable changes, or is too large for one fresh context window, split it
- **"Out of scope" sections are mandatory** for any issue touching a shared boundary (shared DB table, shared API, shared component)
- **Challenge quality matters more than challenge quantity** — three sharp, specific challenges beat ten generic ones
