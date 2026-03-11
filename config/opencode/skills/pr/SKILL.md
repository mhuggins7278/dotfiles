---
name: pr
description: Use this skill when the user asks you to create a pull request, open a PR, or push and create a PR. Provides the full PR creation workflow including branch push and gh CLI usage.
---

# Pull Request Skill

Create a pull request using the `gh` CLI.

## CRITICAL: Branch Naming — Read Before Anything Else

**NEVER use a slash (`/`) in a branch name. This is a hard stop, not a preference.**

Slashes break the deployment pipeline. There are no exceptions.

- WRONG: `feature/foo`, `fix/bar`, `chore/anything`
- RIGHT: `feature-foo`, `fix-bar`, `chore-anything`

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

For repos under `~/github/glg/`, confirm there is a GitHub issue to associate before creating the PR:

- Check for an existing issue reference in branch context (commit messages, branch name, user-provided issue number)
- Validate candidate issue numbers with `gh issue view <number>` — if the issue is closed or unrelated, treat it as missing
- If no valid open issue is found, prompt the user to create one before continuing
- If the user agrees, create the issue in the active repo and add it to `glg` project `85`, then use that new issue number
- Include the issue in the PR body using `Fixes <owner>/<repo>#<number>` (for example, `Fixes glg/streamliner#5232`)

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

## Common Pitfalls

- **Always check for a PR template before writing the PR body** — never skip this step even if you think there is no template
- **In GLG repos, do not create a PR without an associated open issue** — if none exists, prompt to create one first
- Creating a PR requires pushing the branch — do not push unless the user has asked for a PR
- Do not use `--force` push unless the user explicitly requests it
- Do not use interactive git flags (`-i`) — they require TTY input
- Review ALL commits in the PR range, not just `HEAD`
- Always pass `--base` explicitly to avoid targeting the wrong branch
