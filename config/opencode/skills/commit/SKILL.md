---
name: commit
description: Use this skill when the user asks you to commit changes, stage files, or create a git commit. Provides the safe commit workflow with pre-commit hook awareness.
---

# Commit Skill

Commit staged and unstaged changes safely.

## When to Use

- User says "commit this", "commit the changes", "make a commit"
- User asks you to save work to git

## Safety Rules

- NEVER update git config
- NEVER run destructive git commands (force push, hard reset) unless explicitly asked
- NEVER skip hooks (`--no-verify`) unless explicitly asked
- NEVER commit files that may contain secrets (`.env`, credentials, tokens) — warn the user
- Avoid `--amend` unless: (1) user explicitly requested it OR the commit succeeded but a pre-commit hook auto-modified files, AND (2) HEAD commit was created by you in this conversation, AND (3) commit has NOT been pushed to remote
- If a commit FAILED or was REJECTED by a hook, NEVER amend — fix the issue and create a NEW commit

## Workflow

### 1. Gather Context (run in parallel)

```bash
git status
git diff HEAD
git log --oneline -5
```

### 2. Draft the Commit Message

- Summarize the nature of the change: new feature, enhancement, bug fix, refactor, test, docs, chore
- Use accurate verbs: "add" = wholly new, "update" = enhancement, "fix" = bug fix
- Focus on the *why* over the *what*
- Keep it concise: 1-2 sentences max

### 3. Stage and Commit (run sequentially)

```bash
git add <relevant files>
git commit -m "<message>"
git status
```

Run `git status` after the commit to verify success.

### 4. If Pre-commit Hook Fails

Fix the underlying issue, then create a **new** commit — do NOT amend.

## Common Pitfalls

- Do not push unless the user explicitly asks
- Do not use `git commit -a` blindly — review what's being staged
- Do not use interactive flags (`-i`, `-p`) — they require TTY input
