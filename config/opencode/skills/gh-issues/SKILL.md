---
name: gh-issues
description: Always use this skill for ALL GitHub issue operations including listing, searching, viewing, creating, closing, and managing issues. Uses GitHub CLI only.
---

# GitHub Issues Skill

Use the native `gh` CLI directly for all issue operations.

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth status`)
- `jq` installed
- Project operations require `project` scope — if you get a scope error, run `gh auth refresh -s project`

## Repo Variable

Many commands reference the active repo. Set it once and reuse:

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
```

The active repo is whatever `gh repo view` resolves in your current git context.

## Commands

**Current user**
```bash
gh api user | jq '{login, name, id, html_url}'
```

**List open issues assigned to me**
```bash
gh issue list --repo "$REPO" --assignee "$(gh api user --jq .login)" --state open
```

**View an issue**
```bash
gh issue view <issue-number> --repo "$REPO"
```

**Search / filter issues**
```bash
# Filter by state, assignee, label (combine freely)
gh issue list --repo "$REPO" --state <open|closed|all> [--assignee <login>] [--label <label>] [--limit <n>]

# Keyword / GitHub search syntax
gh issue list --repo "$REPO" --search "<query>" --state open
```

`gh issue list` defaults to 30 results — use `--limit 100` (or higher) when you need more.

**Create an issue (and add to project)**
```bash
gh issue create --repo "$REPO" \
  --title "<title>" \
  --body "<body>" \
  --assignee "<login>" \
  --project "Client Solutions Experience"
```

If `--project` fails (scope error or name mismatch), create without it and add to the project separately (see below).

**Add an existing issue to the project**
```bash
# Preferred — works reliably across gh versions
gh project item-add 85 --owner glg --url "$(gh issue view <issue-number> --repo "$REPO" --json url -q .url)"
```

**Comment on an issue**
```bash
gh issue comment <issue-number> --repo "$REPO" --body "<text>"
```

**Close / reopen**
```bash
gh issue close <issue-number> --repo "$REPO"
gh issue reopen <issue-number> --repo "$REPO"
```

**Assign / unassign**
```bash
gh issue edit <issue-number> --repo "$REPO" --add-assignee "<login>"
gh issue edit <issue-number> --repo "$REPO" --remove-assignee "<login>"
```

## Default Configuration

- **Default GitHub Project**: `glg` project `85` (`Client Solutions Experience`)
- **IMPORTANT**: Always use the project **name** (`"Client Solutions Experience"`) with `--project`/`--add-project`, never the numeric ID (`85`). The `gh` CLI will error with `'85' not found` if you use the ID.
- When using `gh project item-add`, use the numeric ID (`85`) and `--owner glg`.
- **Team members and full GLG workflow rules**: read `~/.dotfiles/config/opencode/references/glg-workflow.md`

## Linking Issues to an Epic (Sub-issues)

**Always use the native GitHub sub-issue relationship** — never just mention an epic in the issue body. Use the `addSubIssue` GraphQL mutation via `gh api graphql`.

```bash
# Get the epic's node ID first
EPIC_ID=$(gh api repos/<owner>/<repo>/issues/<epic-number> --jq .node_id)

# Link a single child issue
CHILD_ID=$(gh api repos/<owner>/<repo>/issues/<child-number> --jq .node_id)
gh api graphql -f query='
  mutation($parentId: ID!, $childId: ID!) {
    addSubIssue(input: {issueId: $parentId, subIssueId: $childId}) {
      issue { number }
      subIssue { number title }
    }
  }
' -f parentId="$EPIC_ID" -f childId="$CHILD_ID" \
  --jq '.data.addSubIssue.subIssue | "#\(.number) \(.title)"'
```

**Linking multiple child issues across repos in a loop:**

```bash
EPIC_ID="<epic-node-id>"
for SPEC in \
  "<owner>/<repo>/<issue-number>" \
  "<owner>/<repo>/<issue-number>"; do
  REPO=$(echo $SPEC | cut -d'/' -f1-2)
  NUM=$(echo $SPEC | cut -d'/' -f3)
  CHILD_ID=$(gh api repos/$REPO/issues/$NUM --jq .node_id)
  echo -n "Adding $REPO#$NUM ... "
  gh api graphql -f query='
    mutation($parentId: ID!, $childId: ID!) {
      addSubIssue(input: {issueId: $parentId, subIssueId: $childId}) {
        issue { number }
        subIssue { number title }
      }
    }
  ' -f parentId="$EPIC_ID" -f childId="$CHILD_ID" \
    --jq '.data.addSubIssue.subIssue | "#\(.number) \(.title)"'
done
```

> Note: `addSubIssue` works across repositories — the epic and child issues do not need to be in the same repo.

## Copilot Assignee

Use `Copilot` (capital `C`) when assigning the Copilot SWE agent — lowercase fails.

```bash
gh issue edit <number> --repo "$REPO" --add-assignee "Copilot"
# or at creation:
gh issue create --assignee "Copilot" ...
```
