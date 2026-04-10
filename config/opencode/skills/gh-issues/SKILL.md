---
name: gh-issues
description: Always use this skill for ALL GitHub issue operations including listing, searching, viewing, creating, closing, and managing issues. Uses GitHub CLI only.
---

# GitHub Issues Skill

Use the native `gh` CLI for all issue operations. If you hit a project scope error, run `gh auth refresh -s project`.

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
```

## Commands

**List open issues assigned to me**
```bash
gh issue list --repo "$REPO" --assignee "$(gh api user --jq .login)" --state open
```

**View an issue**
```bash
gh issue view <number> --repo "$REPO"
```

**Search / filter**
```bash
gh issue list --repo "$REPO" --state <open|closed|all> [--assignee <login>] [--label <label>] [--limit <n>]
gh issue list --repo "$REPO" --search "<query>" --state open
```

**Create (and add to project)**
```bash
gh issue create --repo "$REPO" \
  --title "<title>" \
  --body "<body>" \
  --project "Enterprise Integration"
```

Use the project **name** (`"Enterprise Integration"`), never the numeric ID `92` — `gh issue create --project` will error with the ID. If `--project` fails, create without it then add separately:

```bash
gh project item-add 92 --owner glg --url "$(gh issue view <number> --repo "$REPO" --json url -q .url)"
```

**Comment / Close / Reopen**
```bash
gh issue comment <number> --repo "$REPO" --body "<text>"
gh issue close <number> --repo "$REPO"
gh issue reopen <number> --repo "$REPO"
```

**Assign / Unassign**
```bash
gh issue edit <number> --repo "$REPO" --add-assignee "<login>"
gh issue edit <number> --repo "$REPO" --remove-assignee "<login>"
```

Use `Copilot` (capital C) to assign the Copilot SWE agent.

## Sub-Issues (Linking to an Epic)

Always use the native GraphQL sub-issue relationship — never just reference the epic in the body.

```bash
EPIC_ID=$(gh api repos/<owner>/<repo>/issues/<epic-number> --jq .node_id)
CHILD_ID=$(gh api repos/<owner>/<repo>/issues/<child-number> --jq .node_id)

gh api graphql -f query='
  mutation($parentId: ID!, $childId: ID!) {
    addSubIssue(input: {issueId: $parentId, subIssueId: $childId}) {
      subIssue { number title }
    }
  }
' -f parentId="$EPIC_ID" -f childId="$CHILD_ID" \
  --jq '.data.addSubIssue.subIssue | "#\(.number) \(.title)"'
```

For multiple children, repeat the CHILD_ID fetch + mutation for each issue. Works across repos.

## Reference

- Team members and full GLG workflow rules: `~/.dotfiles/config/opencode/references/glg-workflow.md`
