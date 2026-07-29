---
name: to-spec
description: Turn the current conversation into a spec and publish it as a GitHub issue — no interview, just synthesis of what you've already discussed. Use when the user says "turn this into a spec", "write this up", or "create an issue from this conversation".
disable-model-invocation: true
---

# To Spec

Own the **aligned to specified** transition from
`~/.dotfiles/config/ai/playbooks/workflow.md`.

Take the current conversation context and codebase understanding and produce a
spec (also known as a PRD). Do **not** interview the user or restart a broad
grilling session. If a material product or architecture decision still blocks
the spec, ask only about that decision.

## Process

### 1. Detect repo context

```bash
gh repo view --json owner,nameWithOwner -q '{owner: .owner.login, repo: .nameWithOwner}'
```

If `owner == "glg"`, GLG mode is active — read `~/.dotfiles/config/opencode/references/glg-workflow.md` for project tagging and branch rules.

### 2. Explore

Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec (`CONTEXT.md`, if it exists — see the `domain-modeling` skill), and respect any ADRs in the area you're touching.

### 3. Write and publish the spec

Derive candidate test seams from the resolved context. Prefer existing public
seams and record the rationale in the Testing Decisions section. Do not pause
for routine seam confirmation.

Write the spec using the template below, then publish it:

```bash
gh issue create --repo "<OWNER/REPO>" --title "<title>" --body "$(cat <<'EOF'
<spec body>
EOF
)"
```

**GLG repos** — add the issue to project 92:

```bash
gh project item-add 92 --owner glg --url "$(gh issue view <number> --repo "<REPO>" --json url -q .url)"
```

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each in the format:

1. As an \<actor\>, I want a \<feature\>, so that \<benefit\>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets — they go stale fast.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>

### 4. Report

Report the issue URL. Suggest `to-tickets` next if the spec needs breaking into implementation-sized pieces, or `implement` directly if it's small enough for one session.
