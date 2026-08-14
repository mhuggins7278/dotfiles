---
name: commit
description: >
  Commit or stage Git changes safely. Use only when the user explicitly asks to
  commit, stage, or create a Git commit.
---

# Commit Skill

Commit staged and unstaged changes safely.

## When to Use

- User says "commit this", "commit the changes", "make a commit"
- User asks you to save work to git

## GLG Production Tracking

For repos under `~/github/glg/`, read
`~/.dotfiles/config/opencode/references/glg-workflow.md` before committing and
apply its branch and production tracking rules. Do not block an existing PR
solely because its branch contains `/`; branch-format guidance applies to
branches intended to publish GDS images or deployments. An issue is recommended
for substantive production work but is not required for local exploratory
commits. Never block a commit solely because no issue exists.

## Safety Rules

- NEVER update git config
- NEVER run destructive git commands (force push, hard reset) unless explicitly asked
- NEVER skip hooks (`--no-verify`) unless explicitly asked
- NEVER commit files that may contain secrets (`.env`, credentials, tokens) — warn the user
- Amend is allowed ONLY when ALL three conditions are met: (1) user explicitly requested it OR the commit succeeded but a pre-commit hook auto-modified files that need including, AND (2) HEAD commit was created by you in this conversation, AND (3) commit has NOT been pushed to remote
- If a commit FAILED or was REJECTED by a hook, NEVER amend — fix the issue and create a NEW commit
  - In repos under `~/github/glg/`, do not block a commit solely because no issue exists.

## Workflow

### 1. Gather Context (run in parallel)

```bash
git status
git diff --staged   # review what is already staged
git diff            # review unstaged changes
git log --oneline -5
```

### 2. Check for Secrets Before Staging

Scan `git status` output for sensitive files before running `git add`:

- Flag any `.env`, `*.pem`, `*.key`, `*credentials*`, `*token*`, or similar files
- Warn the user and do NOT stage those files unless they explicitly confirm it is safe

### 3. Draft the Commit Message

- Summarize the nature of the change: new feature, enhancement, bug fix, refactor, test, docs, chore
- Use accurate verbs: "add" = wholly new, "update" = enhancement, "fix" = bug fix
- Focus on the *why* over the *what*
- Keep it concise: 1-2 sentences max

### 4. Stage and Check

Stage only the relevant files with `git add <relevant files>`, then run
`~/.dotfiles/config/opencode/scripts/check-principles.sh` to enforce the
automated repository rules. If the check fails, fix the errors before
committing.

### 5. Commit (run sequentially)

If there is nothing to commit (clean working tree), report that to the user and stop.

```bash
git commit -m "<message>"
git status
```

Run `git status` after the commit to verify success.

### 6. If Pre-commit Hook Modifies Files

If the hook **succeeds** but auto-modifies files (e.g., a formatter), amend is allowed provided the three conditions in Safety Rules are met:

```bash
git add <hook-modified files>
git commit --amend --no-edit
```

If the hook **fails or rejects** the commit, fix the underlying issue and create a **new** commit — do NOT amend.

## Common Pitfalls

- Do not push unless the user explicitly asks
- Do not use `git commit -a` blindly — review what's being staged
- Do not use interactive flags (`-i`, `-p`) — they require TTY input
