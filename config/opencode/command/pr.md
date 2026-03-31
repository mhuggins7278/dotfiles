---
description: Create a pull request from the current branch with safety checks
agent: build
---

# Git PR

Fully automated GitHub pull request creation workflow that analyzes changes, generates PR content, and creates the PR with safety checks.

## Safety Checks

- NEVER create PR from main/master branch - error and abort
- NEVER auto-commit changes - user must commit explicitly first
- NEVER push with --force unless user explicitly requests
- Do not proceed if there are uncommitted changes - inform user to commit first
- Always verify branch has upstream tracking or auto-push with -u flag
- Always specify --base flag with user's chosen target branch
- In repos under `~/github/glg/`, require an associated issue before creating a PR; if none exists, prompt to create one and add it to `glg` project `85`.

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

### 6. Prepare Node Environment (If Needed)

If the repo is Node-based and you need to install JavaScript dependencies for
validation or testing, switch to the project's configured Node version with
`fnm` before running any package manager install command.

```bash
eval "$(fnm env --shell bash)"
fnm use --install-if-missing

if [ -f pnpm-lock.yaml ]; then
  pnpm install
elif [ -f yarn.lock ]; then
  yarn install
elif [ -f package-lock.json ]; then
  npm ci
elif [ -f package.json ]; then
  npm install
fi
```

Use this only when Node dependencies are actually needed. Do not guess a Node
version or rely on a random global install.

### 7. Generate PR Content

**Title**:
- Concise, action-oriented summary
- Imperative mood (e.g., "Add feature" not "Added feature")
- Under 72 characters

**Body**:

Before finalizing the body, ensure there is an associated GitHub issue:

- Look for an issue number in branch name, commit messages, or user context
- Validate with `gh issue view <number>`
- If none exists, ask the user whether to create one now
- If created, include it in PR body with `Fixes <owner>/<repo>#<number>`

If template exists:
- Read template structure
- Fill in each section based on changes
- Preserve template formatting
- Note "N/A" for non-applicable sections
- Add a related issue line in the most relevant section (for example, `Fixes glg/streamliner#5232`)

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
Fixes <owner>/<repo>#<number>
```

### 8. Create PR

```bash
# Create PR with specified base branch
gh pr create --base <target-branch> --title "<title>" --body "$(cat <<'EOF'
<body content>
EOF
)"

# Or create as draft
gh pr create --base <target-branch> --title "<title>" --body "<body>" --draft

# With reviewers
gh pr create --base <target-branch> --title "<title>" --body "<body>" --reviewer user1,user2
```

Ask the user if they want:
- Draft PR vs. ready for review
- Specific reviewers to assign

If $ARGUMENTS is provided, use it to inform PR options (e.g. `/pr --draft` or `/pr staging` to set target branch directly).

### 9. Report Results

- Display PR URL
- Encourage user to review online
- Confirm successful creation

## Error Handling

- If on main/master: Error and abort
- If uncommitted changes: Inform user to commit first, do not proceed
- If `gh` CLI not available: Provide installation instructions
- If `fnm use --install-if-missing` fails: Surface the error and stop before package installation
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
