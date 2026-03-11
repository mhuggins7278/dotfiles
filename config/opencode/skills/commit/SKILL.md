---
name: commit
description: Use this skill when the user asks you to commit changes, stage files, or create a git commit. Provides the safe commit workflow with pre-commit hook awareness.
---

# Commit Skill

Commit staged and unstaged changes safely.

## When to Use

- User says "commit this", "commit the changes", "make a commit"
- User asks you to save work to git

## CRITICAL: Branch Naming — Read Before Anything Else

**NEVER use a slash (`/`) in a branch name. This is a hard stop, not a preference.**

Slashes break the deployment pipeline. There are no exceptions.

- WRONG: `feature/foo`, `fix/bar`, `chore/anything`
- RIGHT: `feature-foo`, `fix-bar`, `chore-anything`

If you need to create a branch before committing, use hyphens only. If the current branch contains a `/`, warn the user and stop until it is renamed.

## Safety Rules

- NEVER update git config
- NEVER run destructive git commands (force push, hard reset) unless explicitly asked
- NEVER skip hooks (`--no-verify`) unless explicitly asked
- NEVER commit files that may contain secrets (`.env`, credentials, tokens) — warn the user
- Amend is allowed ONLY when ALL three conditions are met: (1) user explicitly requested it OR the commit succeeded but a pre-commit hook auto-modified files that need including, AND (2) HEAD commit was created by you in this conversation, AND (3) commit has NOT been pushed to remote
- If a commit FAILED or was REJECTED by a hook, NEVER amend — fix the issue and create a NEW commit
- In repos under `~/github/glg/`, require an associated GitHub issue before committing. If missing, prompt to create one first and tag it to `glg` project `85`.

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

### 4. Stage and Commit (run sequentially)

If there is nothing to commit (clean working tree), report that to the user and stop.

```bash
git add <relevant files>
git commit -m "<message>"
git status
```

Run `git status` after the commit to verify success.

### 5. If Pre-commit Hook Modifies Files

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
