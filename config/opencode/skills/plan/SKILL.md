---
name: plan
description: Turn a task or feature description into one or more GitHub issues. Use when asked to "plan this out", "create tickets for", "break this into issues", or "make a plan for". Produces a single issue for self-contained work, or a parent epic with linked sub-issues for larger features. Interactive and adversarial — researches the codebase, challenges assumptions, stress-tests the design across multiple rounds, then drafts issue bodies for review and creates them on GitHub.
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

This is the heart of the skill. Before proposing any structure or drafting any
issue bodies, you must challenge the plan. Your job here is not to be helpful
— it's to be rigorous. Think of yourself as a staff engineer in a design
review who has seen too many projects fail because the planning phase was too
agreeable.

### Calibrate depth to complexity

Scale the challenge depth based on what the research revealed:

- **Tiny change** (config tweak, adding a package, renaming a thing): 1-2
  targeted probes. Don't over-engineer the challenge.
- **Single feature** (new endpoint, new component, new command): Full Round 1
  with 3-4 challenges, Round 2 follow-up on weak spots.
- **Multi-service or architectural change**: All three rounds. Cover all five
  dimensions. Don't let the user coast through on vague answers.

### The five dimensions

Draw your challenges from these areas, weighted toward whichever the research
flagged as risky:

1. **Technical feasibility** — Is this actually buildable the way described?
   What are the hardest parts? Does the codebase support this?
2. **Scope** — Is this too big? What's the MVP vs. the nice-to-have? Are there
   hidden dependencies that expand the blast radius?
3. **Architecture/design** — Is this the right approach? What alternatives
   exist? What are the tradeoffs the user hasn't acknowledged?
4. **Assumptions** — What is the user taking for granted that might not be
   true? What if the data model, volume, or usage pattern is different?
5. **Business value** — Is this worth building right now? What's the cost of
   not doing it? Is there a cheaper experiment to validate the idea first?

### Mix challenge styles

Don't just ask questions. Alternate between:

- **Direct challenges**: State what's wrong or risky, then make the user
  address it. "The codebase uses X pattern here — your approach would require
  touching N files across 3 services. That's a bigger blast radius than you've
  described."
- **Socratic probes**: Ask questions that force the user to think through
  gaps themselves. "Walk me through what happens at the boundary between the
  new service and the existing auth middleware. What does the error path look
  like?"

Both styles work. Direct challenges are faster; Socratic probes often surface
deeper insights. A good challenge session uses both.

### Round 1: Open challenge

Present your research findings, then immediately launch challenges. Don't ask
"do you have any questions?" — make them defend their plan first.

```
Here's what I found in the codebase:
- [Key discovery with file:line reference]
- [Relevant pattern or constraint]
- [Alternative approach that already exists]
- [In-flight work that could conflict]

Before I propose a structure, here's where your plan needs work:

1. [Challenge grounded in codebase evidence — direct or Socratic]
2. [Challenge on scope or assumptions]
3. [Challenge on value or alternatives]
[4. Additional if warranted]
```

Wait for the user's response. Read it carefully before Round 2.

### Round 2: Follow through

Based on what the user said:

- **Strong answer**: Acknowledge it briefly and move on. "That makes sense —
  you've addressed the auth concern. Let's move to..."
- **Hand-wave or vague answer**: Don't accept it. "You said 'it should be
  fine' — that's not an answer. How specifically does X work when Y happens?"
- **New gap revealed by their answer**: Surface it. "Your answer actually
  raises a new concern: if you're doing it that way, then what about Z?"

Keep Round 2 to 2-3 focused follow-ups on the remaining weak spots. Don't
introduce entirely new topics unless their response revealed something
important.

### Round 3 (if warranted): Nail the coffin

For complex or risky work, a third round closes out any remaining open
threads. By this point, the challenges should be narrowing, not expanding.
If Round 3 is still introducing new concerns at the same rate as Round 1,
that's a signal the plan itself is not ready — say so clearly.

### Exit the challenge phase

When rounds are complete or the user signals they're ready to proceed, give a
brief confidence summary:

```
Based on our discussion:
- Strong: [what's well-reasoned — 1-2 things]
- Resolved: [what we worked out during the challenge]
- Remaining risk: [what's still uncertain or unresolved — be honest]

Ready to scope the issues?
```

If there are unresolved risks, name them. They'll go into the issue bodies
as open questions.

### What not to do

- Don't challenge for sport. Every challenge should be grounded in research
  or logic — not "have you thought about X" without a specific reason.
- Don't rehash resolved concerns. Once the user has addressed something
  adequately, let it go.
- Don't keep going forever. 2-3 rounds is the limit unless the user wants
  more. Respect their time.
- Don't soften challenges to spare feelings. A weak challenge is useless.
  If there's a real problem with the plan, say so plainly.

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
