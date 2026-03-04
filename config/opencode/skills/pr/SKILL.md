---
name: pr
description: Use this skill when the user asks you to create a pull request, open a PR, or push and create a PR. Provides the full PR creation workflow including branch push and gh CLI usage.
---

# Pull Request Skill

Create a pull request using the `gh` CLI.

## When to Use

- User says "create a PR", "open a pull request", "push and make a PR"
- User asks you to submit work for review

## Branch Rules

- Branch names must NOT contain `/` — slashes break the deployment pipeline
- Use hyphens as separators: `feature-my-thing`, NOT `feature/my-thing`
- If the current branch has a `/` in the name, warn the user before proceeding

## Workflow

### 1. Gather Context (run in parallel)

```bash
git status
git diff HEAD
git log --oneline -10
git branch --show-current
git remote get-url origin
```

Also run: `git diff <base-branch>...HEAD` to see all commits diverged from the base branch (usually `main` or `master`).

Check whether the branch tracks a remote and is up to date:
```bash
git status -sb
```

### 2. Check for a Pull Request Template

**This step is mandatory — do not skip it.**

Look for a PR template in the repo root:

```bash
ls .github/pull_request_template.md 2>/dev/null \
  || ls .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null \
  || ls .github/PULL_REQUEST_TEMPLATE/*.md 2>/dev/null
```

If a template exists, read it in full and use it as the structure for the PR body. Fill in every section — do not delete or collapse sections, and do not substitute your own structure. If a section genuinely does not apply, write "N/A" rather than omitting it.

If no template exists, fall back to the default body format in step 3.

### 3. Analyze Changes

Review ALL commits that will be in the PR — not just the latest. Use the template sections (or the default structure below) to capture:

- What changed and why (the "what" in bullets, the "why" in prose)
- Any notable decisions or tradeoffs

### 4. Push and Create PR (run sequentially)

If not yet pushed:
```bash
git push -u origin <branch>
```

Then create the PR. If a template was found, populate its sections as the body. If no template was found, use this default:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary

- <bullet 1>
- <bullet 2>

## Details

<optional prose>
EOF
)"
```

### 5. Return the PR URL

Always return the PR URL to the user after creation.

## GLG-Specific Defaults

- Default base branch: `main`
- Default repo: `glg/client-solutions-experience` (unless user specifies otherwise)
- Do NOT force-push to `main` or `master` — warn the user if they request it

## Common Pitfalls

- **Always check for `.github/pull_request_template.md` before writing the PR body** — never skip this step even if you think there is no template
- Do not push unless the user explicitly asks for a PR (pushing implies push)
- Do not use `--force` push unless the user explicitly requests it
- Do not use interactive git flags (`-i`) — they require TTY input
- Review ALL commits in the PR range, not just `HEAD`
