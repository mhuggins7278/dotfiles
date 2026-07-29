---
name: to-tickets
description: Break an approved spec into tracer-bullet GitHub issues with blocking edges. Use after `to-spec` when a build needs multiple implementation tickets.
disable-model-invocation: true
---

# To Tickets

Own the **specified to ticketed** transition from
`~/.dotfiles/config/ai/playbooks/workflow.md`.

Break an approved spec into tracer-bullet GitHub issues. This is a mechanical
decomposition phase, not a second planning or grilling session. The output is
always GitHub issues: one self-contained issue for small work, or an epic with
linked sub-issues for a multi-ticket build.

## 1. Load the spec and repository context

If the user supplied a spec issue or URL, fetch its full body. If the spec is
already in the conversation, use that context. For a referenced PR, read its
details and diff before decomposing it.

```bash
gh repo view --json owner,nameWithOwner -q '{owner: .owner.login, repo: .nameWithOwner}'
gh issue view <number> --repo "<REPO>"
gh pr view <number-or-url>
gh pr diff <number-or-url>
```

If the owner is `glg`, read
`~/.dotfiles/config/opencode/references/glg-workflow.md` for project tagging
and branch rules.

Explore only facts that the spec leaves uncertain: existing patterns,
integration points, dependencies, or in-flight work. Use the domain glossary
and relevant ADRs. Do not ask the user to repeat decisions already captured in
the spec. Ask one focused question only when a material gap prevents a safe
ticket boundary.

## 2. Draft vertical slices

Each ticket is a tracer bullet:

- Cuts a narrow but complete path through the needed layers.
- Is demoable or verifiable on its own.
- Fits one fresh implementation session and one reviewable PR.
- States every blocking edge. A ticket without blockers can start immediately.

Make prefactoring an earlier, separate ticket when it makes the implementation
easy. A wide mechanical refactor follows expand, migrate, contract: add the new
form beside the old, migrate callers in green batches, then remove the old form
only after every migration is complete.

## 3. Present one approval gate

Present the complete proposed ticket set once. For every ticket, include:

- Title
- What it delivers
- Acceptance criteria
- Blocked by

For multi-ticket work, show the epic and every sub-issue in dependency order.
Ask: "Publish this ticket set?"

Wait for explicit approval. This is the only approval gate in this skill.

## 4. Publish the approved tickets

After approval, write complete issue bodies and publish them without requesting
a second review. Create blockers first so dependency references use real issue
numbers. For multi-ticket work, create sub-issues first, then create the epic
and link each sub-issue with GitHub's native sub-issue relationship.

```bash
gh issue create --repo "<REPO>" --title "<title>" --body "<issue body>"
```

### Ticket body

```markdown
## What to build

The end-to-end behavior this ticket makes work, from the user's perspective.

## Out of scope

Related behavior deliberately excluded from this ticket.

## Acceptance criteria

- [ ] Specific, verifiable behavior
- [ ] Tests pass

## Blocked by

depends on <REPO>#<N>
```

Use `None - can start immediately` when there are no blockers. Avoid specific
file paths and code snippets unless a prototype captured a decision more
precisely than prose can.

### Epic body

```markdown
## Overview

What the complete feature delivers and why.

## Sub-issues

- [ ] #N - Title

## Done when

What completion means from the user's perspective.
```

For GLG repositories, add every created issue to project 92:

```bash
gh project item-add 92 --owner glg --url "$(gh issue view <number> --repo \"<REPO>\" --json url -q .url)"
```

Link each sub-issue to its epic using GitHub's native relationship:

```bash
gh api graphql -f query='
  mutation($parentId: ID!, $childId: ID!) {
    addSubIssue(input: {issueId: $parentId, subIssueId: $childId}) {
      subIssue { number title }
    }
  }
' -f parentId="<epic-node-id>" -f childId="<sub-issue-node-id>"
```

Get an issue's node ID before linking it:

```bash
gh issue view <number> --repo "<REPO>" --json id --jq .id
```

Never assign issues to the user or close or modify a parent issue unless they
explicitly request it.

## 5. Report

Report each created issue with its title, URL, blockers, and whether it is
ready now. Suggest `implement` for one ready ticket or `workon` for an epic.
