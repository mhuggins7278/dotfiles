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

- **No slashes in branch names** — use hyphens (`feature-foo`, not `feature/foo`). If current branch has a `/`, warn and stop.
- **Issue-first**: Every PR needs an open GitHub issue. Check branch name, commits, or user input for an issue number. Validate with `gh issue view <n>`. If missing, stop and prompt the user to create one (add it to project 85: `gh issue create --project "Client Solutions Experience" ...`).
- **Link the PR to its issue** with `Fixes <owner>/<repo>#<n>` in the PR body.

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

Glob for `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/PULL_REQUEST_TEMPLATE/*.md`. If found, read and use its structure verbatim (write "N/A" for inapplicable sections). If not found, use the default body in step 5.

### 4. Compile evidence

1. If the repo has `package.json`, `pnpm-lock.yaml`, `yarn.lock`, or `package-lock.json`: run `eval "$(fnm env --shell bash)" && fnm use --install-if-missing`, then install deps with the appropriate lockfile command (`pnpm install` / `yarn install` / `npm ci`).
2. Run `~/.dotfiles/config/opencode/scripts/check-principles.sh`
3. Note testing performed (unit tests, Playwright, manual) from session context
4. Note whether the `review` subagent returned `APPROVED`

### 5. Push and create PR

```bash
git push -u origin <branch>   # if not yet pushed

gh pr create --draft --reviewer @copilot --base <base> --title "<title>" --body "$(cat <<'EOF'
## Summary

- <bullet>

## Details

<prose>

## Evidence

- [x] **Golden Principles**: Passed
- [x] **Testing**: <how tested>
- [x] **Code Review**: <APPROVED by OpenCode review agent | N/A>

## Related Issue

Fixes <owner>/<repo>#<n>
EOF
)"
```

Always return the PR URL to the user.
