---
name: git-pr
description: Create a pull request from the current branch. Fully automated with safety checks.
---

# Git PR Skill

Fully automated GitHub pull request creation workflow that analyzes changes, generates PR content, and creates the PR with safety checks.

## When to Use

- When you need to create a pull request for the current branch
- After completing and committing a feature or fix
- User explicitly requests a PR with phrases like "create a PR", "open a pull request", "make a PR"

## Safety Checks

- NEVER create PR from main/master branch - error and abort
- NEVER auto-commit changes - user must commit explicitly first
- NEVER push with --force unless user explicitly requests
- Do not proceed if there are uncommitted changes - inform user to commit first
- Always verify branch has upstream tracking or auto-push with -u flag
- Always specify --base flag with user's chosen target branch

## Workflow

### 1. Verify Git State (Run Sequentially)

```bash
# Check current branch
git status

# Verify not on main/master
current_branch=$(git branch --show-current)
if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
  echo "Error: Cannot create PR from main/master branch"
  exit 1
fi

# Check for uncommitted changes
git status --porcelain

# Check upstream tracking
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
```

**If uncommitted changes exist**: Stop and inform user to commit first. Do not proceed.

### 2. Prompt for Target Branch

```bash
# Get default branch
gh repo view --json defaultBranchRef -q .defaultBranchRef.name

# List remote branches
git branch -r
```

Ask user which branch to target:
- Present default branch (main/master) as first option
- Common targets: main, master, develop, staging, production
- Allow custom branch name

### 3. Push Changes (If Needed)

```bash
# If no upstream tracking
git push -u origin <branch-name>

# If upstream exists but unpushed commits
git push
```

Inform user when pushing.

### 4. Check for PR Template

```bash
# Look for template
if [ -f .github/pull_request_template.md ]; then
  cat .github/pull_request_template.md
fi
```

If template exists, use its structure. Otherwise use default format.

### 5. Analyze Changes for PR (Run in Parallel)

```bash
# See commit list since branching from target
git log --oneline origin/<target-branch>..HEAD

# See full diff from target branch
git diff origin/<target-branch>...HEAD --stat

# Get detailed changes
git diff origin/<target-branch>...HEAD
```

### 6. Generate PR Content

**Title**:
- Concise, action-oriented summary
- Imperative mood (e.g., "Add feature" not "Added feature")
- Under 72 characters

**Body**:

If template exists:
- Read template structure
- Fill in each section based on changes
- Preserve template formatting
- Note "N/A" for non-applicable sections

If no template:
```markdown
## Summary
<Brief overview of changes and motivation>

## Changes
- <Key change 1>
- <Key change 2>
- <Key change 3>

## Testing
<How changes were tested>

## Related Issues
<Link issues/tickets if applicable>
```

### 7. Create PR

```bash
# Create PR with specified base branch
gh pr create --base <target-branch> --title "<title>" --body "<body>"

# Or create as draft
gh pr create --base <target-branch> --title "<title>" --body "<body>" --draft

# With reviewers
gh pr create --base <target-branch> --title "<title>" --body "<body>" --reviewer user1,user2
```

Use heredoc for body to preserve formatting:
```bash
gh pr create --base <target-branch> --title "<title>" --body "$(cat <<'EOF'
<body content>
EOF
)"
```

Ask the user if they want:
- Draft PR vs. ready for review
- Specific reviewers to assign

### 8. Report Results

- Display PR URL
- Encourage user to review online
- Confirm successful creation

## PR Template Handling

Common template sections:
- Description/Summary
- Type of change (feature, bugfix, etc.)
- How has this been tested?
- Checklist (breaking changes, tests added, docs updated)
- Related issues/tickets
- Screenshots (for UI changes)
- Breaking changes

Fill each section thoughtfully based on the actual changes.

## Error Handling

- If on main/master: Error and abort
- If uncommitted changes: Inform user to commit first, do not proceed
- If `gh` CLI not available: Provide installation instructions
- If branch behind remote: Inform user to pull first
- If push fails: Display error and suggest resolution

## Output Format

After successful PR creation:
```
✓ Pull request created: <PR URL>

Title: <PR title>
Base: <target-branch> ← <current-branch>

Review your PR online at the link above.
```

## Examples

### PR with template

If `.github/pull_request_template.md` contains:
```markdown
## Description

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change

## Testing
```

Fill it out:
```markdown
## Description
Add user authentication system with JWT tokens

## Type of Change
- [ ] Bug fix
- [x] New feature
- [ ] Breaking change

## Testing
- Unit tests for JWT utilities
- Integration tests for login/logout
- Manual testing with Postman
```

### PR without template

```markdown
## Summary
Refactor database connection pooling to improve performance under high load

## Changes
- Increase connection pool size from 10 to 50
- Add connection timeout configuration
- Implement retry logic with exponential backoff
- Add pool utilization monitoring

## Testing
Load tested with 1000 concurrent users showing 40% improvement in response time
```
