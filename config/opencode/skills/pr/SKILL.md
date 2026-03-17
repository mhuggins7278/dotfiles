---
name: pr
description: >
  Use this skill when the user asks you to create a pull request, open a PR, or push and create a PR.
  Trigger on "create a PR", "open a pull request", "push this up", "submit for review", "ready to merge",
  "share this with the team", or any request to submit work for review. Provides the full PR creation
  workflow including branch push, PR template detection, issue-first enforcement, and gh CLI usage.
---

# Pull Request Skill

Create a pull request using the `gh` CLI.

## CRITICAL: GLG Workflow Rules

For any repo under `~/github/glg/`, read `~/.dotfiles/config/opencode/references/glg-workflow.md` for:
- **Branch naming rules** (no slashes — hyphens only, always)
- **Issue-first workflow** (require an open issue before creating a PR)
- **PR issue references** (`Fixes <owner>/<repo>#<number>` format)
- **Project 85 tagging** when creating issues

If the current branch contains a `/`, warn the user immediately and do not push or create the PR until the branch is renamed.

## When to Use

- User says "create a PR", "open a pull request", "push and make a PR"
- User asks you to submit work for review

## Workflow

### 1. Gather Context (run in parallel)

```bash
git status -sb                 # shows branch tracking and file status
git diff HEAD                  # all changes vs last commit
git log --oneline -10
git branch --show-current
git remote get-url origin
git diff <base-branch>...HEAD  # all commits diverged from base (usually main)
```

### 2. Check for a Pull Request Template

**This step is mandatory — do not skip it.**

Use the Glob tool to search for a PR template at these paths:

```
.github/pull_request_template.md
.github/PULL_REQUEST_TEMPLATE.md
.github/PULL_REQUEST_TEMPLATE/*.md
```

If a template exists, read it in full and use it as the structure for the PR body. Fill in every section — do not delete or collapse sections, and do not substitute your own structure. If a section genuinely does not apply, write "N/A" rather than omitting it.

If no template exists, fall back to the default body format in step 5.

### 3. Analyze Changes

Review ALL commits that will be in the PR — not just the latest. Use the template sections (or the default structure below) to capture:

- What changed and why (the "what" in bullets, the "why" in prose)
- Any notable decisions or tradeoffs

### 4. Ensure an Associated Issue Exists (GLG repos only)

For repos under `~/github/glg/`, confirm there is a GitHub issue before creating the PR. See GLG Workflow Rules above for the full issue-first workflow and `Fixes` reference format.

### 5. Push and Create PR (run sequentially)

Determine the correct base branch (default: `main`). For stacked PRs or a user-specified base, pass `--base <branch>` explicitly to avoid targeting the wrong branch.

If not yet pushed:

```bash
git push -u origin <branch>
```

To create a draft PR, add `--draft` to the `gh pr create` command. Use draft when the user requests it or the work is not ready for review.

Then create the PR. If a template was found, populate its sections as the body and include an issue reference in the `Fixes <owner>/<repo>#<number>` format. If no template was found, use this default:

```bash
gh pr create --title "<title>" --base <base-branch> --body "$(cat <<'EOF'
## Summary

- <bullet 1>
- <bullet 2>

## Details

<optional prose>

## Related Issue

Fixes <owner>/<repo>#<number>
EOF
)"
```

### 6. Return the PR URL

Always return the PR URL to the user after creation.

## GLG-Specific Defaults

- Default base branch: `main`
- Default repo: `glg/client-solutions-experience` (unless user specifies otherwise)
- Do NOT force-push to `main` or `master` — warn the user if they request it
- See `~/.dotfiles/config/opencode/references/glg-workflow.md` for branch naming, issue-first workflow, and team member logins

## Common Pitfalls

- **Always check for a PR template before writing the PR body** — never skip this step even if you think there is no template
- **In GLG repos, do not create a PR without an associated open issue** — if none exists, prompt to create one first
- Creating a PR requires pushing the branch — do not push unless the user has asked for a PR
- Do not use `--force` push unless the user explicitly requests it
- Do not use interactive git flags (`-i`) — they require TTY input
- Review ALL commits in the PR range, not just `HEAD`
- Always pass `--base` explicitly to avoid targeting the wrong branch
