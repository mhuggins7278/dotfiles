---
name: pr
description: Create or update a GitHub pull request. Use when the user explicitly asks to open, push, submit, or share a PR for review.
---

# Pull Requests

The request to create or update a PR authorizes the push and GitHub mutation
needed for that PR. It does not authorize merging, releasing, or deploying. If
the user asks only for preparation, keep the work local.

## Context

Resolve the repository's default branch with:

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

Inspect status, commits, and the diff against that branch. Read a PR template
when present. Run documented checks relevant to the change, but do not install
dependencies or run unrelated suites by default. Record exact commands and
results, including meaningful checks that were unavailable.

For a repository under `~/github/glg/`, read
`~/.dotfiles/config/opencode/references/glg-workflow.md` before creating or
updating the PR. It owns branch naming, production tracking, and project rules.

## Issue links

Put one closing reference per associated issue in the PR description, outside
code fences:

```text
## Linked issues

Fixes #<same-repository-number>
Fixes <owner>/<repository>#<number>
```

Use `No linked issue: exploratory work` when appropriate. Verify the PR targets
the default branch because GitHub only applies closing keywords there. After
creation or update, fetch the PR with:

```bash
gh pr view <number> --json baseRefName,body,closingIssuesReferences,isDraft,url
```

## Workon lanes

For a `/workon` lane, search for an existing open PR on the current branch and
update it rather than creating a duplicate. Preserve the parent epic reference,
commit-qualified included-issue entries, and matching plain-text closing lines
for completed local tickets. Do not use `Fixes` for the parent epic.

## Completion

Push and create or update the PR only after compiling the title, summary,
evidence, linked issues, and any repository-required sections. Return the PR
URL. Fetch it afterward and verify the title, base branch, body, issue-closing
references, and draft state; a successful push alone is not completion.
