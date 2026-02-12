---
name: git-commit
description: Stage and commit changes with conventional commit messages. Fully automated with safety checks.
---

# Git Commit Skill

Fully automated git commit workflow that stages changes and creates well-formatted conventional commits with safety checks.

## When to Use

- When you need to commit changes to the repository
- After completing a feature, fix, or other atomic change
- User explicitly requests a commit with phrases like "commit this", "create a commit", "commit these changes"

## Safety Checks

- NEVER update git config
- NEVER run destructive/irreversible git commands (like push --force, hard reset)
- NEVER skip hooks (--no-verify, --no-gpg-sign) unless user explicitly requests
- NEVER use git commit --amend unless ALL conditions are met:
  - User explicitly requested amend, OR commit succeeded but pre-commit hook auto-modified files
  - HEAD commit was created by you in this conversation (verify: `git log -1 --format='%an %ae'`)
  - Commit has NOT been pushed to remote (verify: `git status` shows "Your branch is ahead")
- CRITICAL: If commit FAILED or was REJECTED by hook, NEVER amend - fix the issue and create a NEW commit
- Do not commit files that likely contain secrets (.env, credentials.json, etc.) - warn user if detected
- NEVER push commits - user will push manually when ready
- NEVER create pull requests - user will create PRs when ready

## Workflow

### 1. Gather Context (Run in Parallel)

```bash
# Check working tree status
git status

# See all staged and unstaged changes
git diff HEAD

# Review recent commit messages for style consistency
git log --oneline -10
```

### 2. Analyze Changes

- Determine the primary change type: feat, fix, docs, style, refactor, perf, test, chore
- Identify the main scope and purpose
- Check for secret files that should not be committed

### 3. Stage Changes (If Needed)

```bash
# Only if no files are currently staged
git add .
```

### 4. Draft Commit Message

Follow conventional commit format:
- Format: `<type>[optional scope]: <description>`
- Keep under 72 characters
- Use imperative mood (e.g., "add feature" not "added feature")
- Types: feat, fix, docs, style, refactor, perf, test, chore

### 5. Execute Commit

```bash
# Simple commit (single line)
git commit -m "<generated message>"

# Multi-line commit (e.g., breaking changes)
git commit -m "<title>" -m "<body>"

# Verify success
git status
```

### 6. Report Results

- Display commit hash from output
- Provide brief summary of what was committed
- Confirm success

## Conventional Commit Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, whitespace)
- `refactor`: Code changes that neither fix bugs nor add features
- `perf`: Performance improvements
- `test`: Adding or fixing tests
- `chore`: Changes to build process, tools, dependencies

## Examples

### Simple feature commit
```
feat: add user authentication
```

### Bug fix with scope
```
fix(api): handle null response in user endpoint
```

### Breaking change
```
feat!: redesign authentication system

BREAKING CHANGE: old JWT tokens are no longer valid
```

## Error Handling

- If no changes to commit, inform user (don't create empty commit)
- If pre-commit hook fails, fix issues and create NEW commit (never amend unless explicitly requested)
- If secrets detected, warn user before committing
- If validation fails, provide clear error message and next steps

## Output Format

After successful commit, provide:
```
✓ Committed: <commit hash>
<commit message>

Summary: <brief description of changes>
```
