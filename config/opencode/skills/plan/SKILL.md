---
name: plan
description: Turn a task or feature description into one or more GitHub issues. Use when asked to "plan this out", "create tickets for", "break this into issues", or "make a plan for". Produces a single issue for self-contained work, or a parent epic with linked sub-issues for larger features. Researches the codebase, then uses the grill-me skill to stress-test the plan before drafting issue bodies for review and creating them on GitHub.
---

# Plan Skill

Turn a task description into one or more well-scoped GitHub issues. Single
tasks produce one issue. Multi-phase or multi-concern work produces a parent
epic with sub-issues linked via the native GitHub sub-issue relationship.

The output is always GitHub issues — not a markdown document.

This skill includes a mandatory challenge phase before drafting issues. It
will push back on your plan, ask uncomfortable questions, and force you to
defend your choices. That pressure is the point — it surfaces gaps before
they become bugs or scope creep.

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

If `$ARGUMENTS` was provided (a task description or issue/ticket reference),
use it as the starting context and proceed to Step 3.

If the input references a pull request (a PR URL, a `#number`, or the phrase
"this PR"), fetch the PR details before doing anything else:

```bash
# Get PR metadata (title, body, author, base branch, status)
gh pr view <number-or-url>

# Get the full diff of the PR
gh pr diff <number-or-url>
```

Use `gh pr view` output to understand intent and `gh pr diff` output as the
authoritative source of what has changed. Treat the diff the same as codebase
research — extract file paths, patterns, and scope from it directly.

If nothing was provided, ask:

> "What needs to be planned? Provide a description of the task, feature, or
> problem. Include any ticket numbers, PR links, or relevant context."

Wait for the user's response before continuing.

---

## Step 3: Research

Before engaging with the user, investigate the codebase thoroughly. Use the
`explore` subagent (via the Task tool):

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

If a PR diff was retrieved in Step 2, include it as additional context in the
research prompt so the subagent can cross-reference it against the codebase.

Read the research output fully before proceeding. The challenge phase depends
on this — ground your challenges in concrete evidence from the codebase.

---

## Step 4: Challenge & Refine

Use the `grill-me` skill to run the challenge phase. Follow its instructions
exactly — interview the user relentlessly, one question at a time, resolving
each branch of the decision tree before moving on.

Ground every question in the codebase research from Step 3. When a question
can be answered by exploring the codebase, explore it instead of asking.
Calibrate depth to complexity:

- **Tiny change**: 1-2 targeted probes.
- **Single feature**: Full interview covering technical feasibility, scope,
  and assumptions.
- **Multi-service or architectural change**: Full interview across all
  dimensions — feasibility, scope, architecture, assumptions, and business
  value.

When the interview is complete, give a brief confidence summary before
proceeding:

```
Based on our discussion:
- Strong: [what's well-reasoned — 1-2 things]
- Resolved: [what we worked out during the challenge]
- Remaining risk: [what's still uncertain or unresolved — be honest]

Ready to scope the issues?
```

Carry any unresolved risks forward into the issue bodies as open questions.

---

## Step 5: Determine Scope — Single Issue or Epic

Based on the task, research, and what survived the challenge phase, decide:

**Single issue** when:
- The work can be reviewed in one PR
- There are no natural seams that would make separate PRs safer
- The full change is understandable as one unit of work

**Epic + sub-issues** when:
- The work spans multiple logical concerns or multiple repos
- Phases have clear dependencies (phase 2 can't start until phase 1 merges)
- Independent parts could be worked in parallel by different people
- The total change would be too large to review in a single PR

If the challenge phase resulted in scope changes (the user agreed to cut
something or add something), reflect that here. The structure should match
the plan that emerged from the challenge, not the plan the user started with.

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

## Step 6: Draft Issue Bodies

Write a draft body for each issue and present them to the user for review.
Show all issues before creating any of them.

### Sub-issue / single-issue body template

```markdown
## Context

[Why this work is needed. One short paragraph. Link to the parent epic if this
is a sub-issue.]

## What needs to change

[Bulleted list of the concrete changes required. Be specific enough that
someone can start work without reading the full thread, but don't write
implementation code here.]

## Out of scope

[Explicit list of related things this issue does NOT cover, to prevent scope
creep.]

## Risks & open questions

[Populate this from the challenge phase. For each unresolved concern or
assumption that wasn't fully addressed, write one bullet.]

- [Risk: what could go wrong and why — include mitigation if one was discussed]
- [Assumption: what needs to be validated during implementation]
- [Dependency risk: external factor that could change the plan]

[Omit this section if nothing of substance remains from the challenge phase.
Don't manufacture fake risks to fill the section.]

## Success criteria

- [ ] [Specific, verifiable condition]
- [ ] [Another verifiable condition]
- [ ] Tests pass
- [ ] No regressions in [related area]

## Dependencies

[If this issue must come after another, write:]
depends on <owner>/<repo>#<number>

[Omit this section entirely if there are no dependencies.]
```

### Epic body template

```markdown
## Overview

[2–3 sentences describing the full feature and why it's being built.]

## Sub-issues

[List will be linked via GitHub sub-issue relationship — this section is for
human readability and quick status checking.]

- [ ] #N — [title]
- [ ] #N — [title]
- [ ] #N — [title]

## Risks & open questions

[Carry forward any unresolved concerns from the challenge phase that apply
to the epic as a whole rather than a specific sub-issue.]

- [Epic-level risk or open question]

## Done when

[The overall acceptance criteria for the epic as a whole — what does
"complete" look like from a user or system perspective?]
```

Present the drafts and iterate until the user approves. Do not create any
issues until explicitly told to proceed.

---

## Step 7: Create Issues on GitHub

Once the user approves, create all issues in this order:
1. Sub-issues first (so their numbers are known)
2. Epic last (so its body can reference the real issue numbers)

For each issue:

```bash
gh issue create \
  --repo "<REPO>" \
  --title "<title>" \
  --body "$(cat <<'EOF'
<body>
EOF
)"
```

Capture the issue number from the output of each `gh issue create` call.
Hard-code the real numbers into the epic body before creating it.

**GLG repos — add each issue to project 92:**

```bash
gh project item-add 92 --owner glg \
  --url "$(gh issue view <number> --repo "<REPO>" --json url -q .url)"
```

**Link sub-issues to the epic** (only when an epic was created):

```bash
EPIC_ID=$(gh api repos/<REPO>/issues/<epic-number> --jq .node_id)

for SPEC in "<REPO>/<sub-number>" "<REPO>/<sub-number>"; do
  CHILD_ID=$(gh api repos/${SPEC%/*}/issues/${SPEC##*/} --jq .node_id)
  gh api graphql -f query='
    mutation($parentId: ID!, $childId: ID!) {
      addSubIssue(input: {issueId: $parentId, subIssueId: $childId}) {
        issue { number }
        subIssue { number title }
      }
    }
  ' -f parentId="$EPIC_ID" -f childId="$CHILD_ID" \
    --jq '.data.addSubIssue.subIssue | "#\(.number) \(.title)"'
done
```

---

## Step 8: Report

When all issues are created and linked, summarise:

```
Created:
  Epic:  <REPO>#<N> — <title>  <url>
  Sub-issues:
    <REPO>#<N> — <title>  <url>
    <REPO>#<N> — <title>  <url>  [depends on #N]

Use /workon <epic-url> to start working through these.
```

---

## Guidelines

- **Never create issues without user approval of the draft bodies**
- **Never assign issues** to the user unless explicitly asked
- **Keep issue titles short** — a verb phrase, ≤ 60 chars
  (e.g. "Add pagination to /consultations endpoint")
- **Dependencies in bodies use `depends on` syntax** — this is what the
  `workon` skill parses for ordering
- **Scope each issue to one PR** — if a body describes two distinct
  reviewable changes, split it
- **"Out of scope" sections are mandatory** for any issue touching a shared
  boundary (shared DB table, shared API, shared component)
- **Challenge quality matters more than challenge quantity** — three sharp,
  specific challenges beat ten generic ones
