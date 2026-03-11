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

## Team Members

Use these logins for `--assignee`:

| Name | Login |
|---|---|
| Mark Huggins | `mhuggins7278` |
| Jess Chadwick | `jchadwick` |
| David Hayes | `drhayes` |
| Ronan O'Malley | `Ronanj7` |
| Priya Darshani | `pdarshani` |
| John Lemberger | `JohnLemberger` |

## Copilot Assignee

Use `Copilot` (capital `C`) when assigning the Copilot SWE agent — lowercase fails.

```bash
gh issue edit <number> --repo "$REPO" --add-assignee "Copilot"
# or at creation:
gh issue create --assignee "Copilot" ...
```
