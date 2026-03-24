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

## GLG Workflow Rules

These rules apply to any repo under `~/github/glg/`. Skip all GLG sections for non-GLG repos.

### Branch Naming

**Never use a slash (`/`) in a branch name** — slashes break the deployment pipeline when promoting to the testing environment. Use hyphens instead:

- WRONG: `feature/foo`, `fix/bar`, `chore/anything`
- RIGHT: `feature-foo`, `fix-bar`, `chore-anything`

If the current branch contains a `/`, warn the user immediately and **do not push or create the PR until the branch is renamed.**

Issue branch format: `issue_<number>` — use the parent issue number for same-repo epics; the sub-issue number for cross-repo branches.

### Issue-First Workflow

All PRs in GLG repos require an associated open GitHub issue before creation.

1. Check for an existing issue reference in the branch name, commit messages, or user-provided input
2. Validate with `gh issue view <number>` — if closed or unrelated, treat as missing
3. If no valid open issue is found, **stop and prompt the user to create one**
4. If the user agrees, create the issue and add it to project 85 (see Project Tagging below)

### Project Tagging

When creating a new issue, add it to **project `85`** (`Client Solutions Experience`). Use the project name directly on `gh issue create`:

```bash
gh issue create --project "Client Solutions Experience" ...
```

Or add it after creation:

```bash
gh project item-add 85 --owner glg --url "<issue_url>"
```

### PR Issue References

Always link the PR to its issue using the `Fixes` keyword so the issue auto-closes on merge. Place this in the **PR body**, not the title:

```
Fixes <owner>/<repo>#<number>
```

Example: `Fixes glg/streamliner#5232`

## When to Use

- User says "create a PR", "open a pull request", "push and make a PR"
- User asks you to submit work for review

## Workflow

### 1. Detect Base Branch (run first, before anything else)

**Never assume `main` exists.** Determine the actual default branch before running any diff or log commands:

```bash
# Preferred: ask GitHub directly
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'

# Fallback: inspect remote HEAD
git remote show origin | grep 'HEAD branch' | awk '{print $NF}'
```

Use the result as `<base-branch>` in all subsequent commands. If both commands fail (e.g., no remote), check which of `main` or `master` exists locally:

```bash
git branch --list main master
```

### 2. Gather Context (run in parallel)

```bash
git status -sb                              # shows branch tracking and file status
git diff HEAD                               # all changes vs last commit
git log --oneline -10
git branch --show-current
git remote get-url origin
git diff origin/<base-branch>...HEAD --stat   # files changed vs base
git log origin/<base-branch>...HEAD --oneline # commits diverged from base
```

**Always use `origin/<base-branch>` (the remote ref) instead of the bare branch name** — this avoids "unknown revision" errors when the base branch hasn't been checked out locally. If the remote ref is missing, fetch it first:

```bash
git fetch origin <base-branch>
```

### 3. Check for a Pull Request Template

**This step is mandatory — do not skip it.**

Use the Glob tool to search for a PR template at these paths:

```
.github/pull_request_template.md
.github/PULL_REQUEST_TEMPLATE.md
.github/PULL_REQUEST_TEMPLATE/*.md
```

If a template exists, read it in full and use it as the structure for the PR body. Fill in every section — do not delete or collapse sections, and do not substitute your own structure. If a section genuinely does not apply, write "N/A" rather than omitting it.

If no template exists, fall back to the default body format in step 5.

### 4. Analyze Changes

Review ALL commits that will be in the PR — not just the latest. Use the template sections (or the default structure below) to capture:

- What changed and why (the "what" in bullets, the "why" in prose)
- Any notable decisions or tradeoffs

### 5. Ensure an Associated Issue Exists (GLG repos only)

For repos under `~/github/glg/`, confirm there is a GitHub issue before creating the PR. See GLG Workflow Rules above for the full issue-first workflow and `Fixes` reference format.

### 6. Compile Evidence Markers

Gather proof that the code is ready to ship to embed in the PR description:
1. Run `~/.dotfiles/config/opencode/scripts/check-principles.sh` to get a clean run of the Golden Principles.
2. Check the session context or ask the user what testing was performed (e.g., "All unit tests passed", or a Playwright run, or manual browser testing).
3. Check the session context to see if the `review` subagent was run and returned `APPROVED`.

Compile this into an `## Evidence` section to inject at the bottom of the PR template.

### 7. Push and Create PR (run sequentially)

Use the `<base-branch>` detected in step 1. For stacked PRs or a user-specified base, pass `--base <branch>` explicitly to avoid targeting the wrong branch.

If not yet pushed:

```bash
git push -u origin <branch>
```

Always create PRs as drafts using `--draft` and always request a Copilot review using `--reviewer @copilot`. Both flags go directly on `gh pr create` — no separate edit step needed.

Then create the PR. If a template was found, populate its sections as the body and include an issue reference in the `Fixes <owner>/<repo>#<number>` format. If no template was found, use this default:

```bash
gh pr create --draft --reviewer @copilot --title "<title>" --base <base-branch> --body "$(cat <<'EOF'
## Summary

- <bullet 1>
- <bullet 2>

## Details

<optional prose>

## Evidence

- [x] **Golden Principles**: Passed
- [x] **Testing**: <describe how it was tested>
- [x] **Code Review**: <"APPROVED by OpenCode review agent" or "N/A">

## Related Issue

Fixes <owner>/<repo>#<number>
EOF
)"
```

### 8. Return the PR URL

Always return the PR URL to the user after creation.

## GLG-Specific Defaults

- Default base branch: detected dynamically (step 1) — do not hardcode `main`
- Default repo: `glg/client-solutions-experience` (unless user specifies otherwise)
- Do NOT force-push to `main` or `master` — warn the user if they request it
- For team member GitHub logins, see `~/.dotfiles/config/opencode/references/glg-workflow.md`

## Common Pitfalls

- **Never hardcode `main` as the base branch** — always detect it first with `gh repo view` or `git remote show origin`
- **Use `origin/<base-branch>` in diff/log commands** — bare branch names fail if not checked out locally
- **Always check for a PR template before writing the PR body** — never skip this step even if you think there is no template
- **In GLG repos, do not create a PR without an associated open issue** — if none exists, prompt to create one first
- Creating a PR requires pushing the branch — do not push unless the user has asked for a PR
- Do not use `--force` push unless the user explicitly requests it
- Do not use interactive git flags (`-i`) — they require TTY input
- Review ALL commits in the PR range, not just `HEAD`
- Always pass `--base` explicitly to avoid targeting the wrong branch
