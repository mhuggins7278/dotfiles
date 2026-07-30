---
name: pr
description: >
  Use this skill when the user asks you to create a pull request, open a PR, or push and create a PR.
  Trigger on "create a PR", "open a pull request", "push this up", "submit for review", "ready to merge",
  "share this with the team", or any request to submit work for review. Provides the full PR creation
  workflow including branch push, PR template detection, issue-first enforcement, and gh CLI usage.
---

# Pull Request Skill

## GLG Rules (repos under `~/github/glg/` only)

For repos under `~/github/glg/`, read
`~/.dotfiles/config/opencode/references/glg-workflow.md` before creating or
updating the PR. It owns branch naming, issue-first, and project rules.

## Issue Links That Close on Merge

When a PR addresses one or more issues, put one closing reference per issue in
the PR **description**. Use the syntax that matches where the issue lives:

```text
## Linked issues

Fixes #<same-repository-issue-number>
Fixes <owner>/<repository>#<different-repository-issue-number>
```

The `Fixes` lines must be plain text in the description, outside code fences.
Do not put them only in the title, a PR/review comment, a checklist entry, or a
markdown link. Keep commit SHAs and other bookkeeping on separate lines. A
comment or a plain `#123` reference can make an issue look related without
causing it to close.

GitHub only applies closing keywords when the PR targets the repository's
default branch. Verify that before creating or updating the PR. Afterward,
verify the body and GitHub's parsed links. If the PR intentionally targets a
non-default branch, an empty `closingIssuesReferences` result is expected:

```bash
gh pr view <pr-number> --json baseRefName,closingIssuesReferences
```

## Workflow

### 1. Detect base branch

```bash
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

Use the result as `<base>` everywhere. Fallback: `git remote show origin | grep 'HEAD branch' | awk '{print $NF}'`

### 2. Gather context (run all in parallel)

```bash
git status -sb
git log origin/<base>...HEAD --oneline
git diff origin/<base>...HEAD --stat
```

Use `origin/<base>` (remote ref) to avoid "unknown revision" errors. If missing, fetch first: `git fetch origin <base>`

### 3. Check for PR template

Glob for `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/PULL_REQUEST_TEMPLATE/*.md`. If found, read and preserve its structure (write "N/A" for inapplicable sections). If not found, use the default body in step 5. In either case, ensure the final body contains an evidence section, the dedicated `## Linked issues` section, and one exact closing line for every associated issue.

### 4. Compile evidence

1. If the repo has `package.json`, `pnpm-lock.yaml`, `yarn.lock`, or `package-lock.json`: run `eval "$(fnm env --shell bash)" && fnm use --install-if-missing`, then install deps with the appropriate lockfile command (`pnpm install` / `yarn install` / `npm ci`).
2. Run `~/.dotfiles/config/opencode/scripts/check-principles.sh "origin/<base>...HEAD"`
3. Run the repository's documented lint, format-check, and typecheck commands
   when available. Do not invent commands; record exact commands and results.
4. Note testing performed (unit tests, Playwright, manual) from session context
5. Note whether the `review` subagent returned `APPROVED`

### 5. Push, create, or update the PR

For a `/workon` repository lane, first search for an existing open PR on the
current branch. Update it rather than creating another PR. Its body must retain
the parent epic reference, one checked commit-SHA-qualified `Included issues`
entry, and one matching plain-text `Fixes` line for every completed local
ticket. Do not use `Fixes` for the parent epic.

```bash
EXISTING_PR=$(gh pr list --head "$(git branch --show-current)" --state open \
  --json number,url --jq '.[0].number // empty')
```

If `EXISTING_PR` is present, first fetch its body so the existing included
issues, linked-issue lines, and parent epic reference are retained. Add any
missing closing lines to the description; do not add them only as a comment:

```bash
gh pr view "$EXISTING_PR" --json body --jq .body
```

Then use `gh pr edit "$EXISTING_PR" --title "<title>" --body "$BODY"` with the
updated title and body.
Otherwise create the draft PR below.

```bash
git push -u origin <branch>   # if not yet pushed

gh pr create --draft --reviewer @copilot --base <base> --title "<title>" --body "$(cat <<'EOF'
## Summary

- <bullet>

## Details

<prose>

## Evidence

- [x] **Automated checks**: Passed
- [x] **Linting/formatting/typecheck**: <commands and results | N/A>
- [x] **Testing**: <how tested>
- [x] **Code Review**: <APPROVED by OpenCode review agent | N/A>

## Linked issues

Fixes <issue-closing-reference>

## Included issues

- [x] <owner>/<repository>#<n> (<commit-sha>)

## Parent epic

Part of <parent-owner>/<parent-repo>#<parent-number>
EOF
)"
```

Always return the PR URL to the user.
