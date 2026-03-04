---
name: gh-issues
description: Always use this skill for ALL GitHub issue operations including listing, searching, viewing, creating, closing, and managing issues. Uses GitHub CLI only.
---

# GitHub Issues Skill

Use the native `gh` CLI directly for all issue operations.

## Prerequisites

- `gh` CLI installed and authenticated
- `jq` installed
- For project operations: `gh auth refresh -s project`

## Commands

- `viewer`: `gh api user | jq '{login, name, id, html_url}'`
- `active repo`: `gh repo view --json nameWithOwner -q .nameWithOwner`
- `list mine`: `gh issue list --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)" --assignee "$(gh api user --jq .login)" --state open`
- `show`: `gh issue view <issue-number> --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)"`
- `search`: `gh issue list --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)" --state <open|closed|all> [--assignee <login>] [--label <label>]`
- `create in project`: `gh issue create --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)" --title "<title>" [--body "<body>"] [--assignee "<login>"] --project "Client Solutions Experience"`
- `add to project`: `gh issue edit <issue-number> --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)" --add-project "Client Solutions Experience"`
- `close/reopen`: `gh issue close <issue-number> --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)"` / `gh issue reopen <issue-number> --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)"`
- `assign/unassign`: `gh issue edit <issue-number> --repo "$(gh repo view --json nameWithOwner -q .nameWithOwner)" --add-assignee "<login>"` / `--remove-assignee "<login>"`

## Default Configuration

- **Default GitHub Project**: `glg` project `85` (`Client Solutions Experience`)

## Team Members

Mark Huggins, Jess Chadwick, David Hayes, Ronan O'Malley, Priya Darshani, John Lemberger

## Tips

- `create` and `--add-project` require `project` scope in `gh` auth
- `active repo` is whatever `gh repo view` resolves in your current git context
- For simple edits, `gh issue edit` may still be the fastest direct command

## Copilot Assignee

Use GitHub login `Copilot` (capital `C`) when assigning the Copilot SWE agent.

- Correct: `gh issue edit <number> --repo <owner>/<repo> --add-assignee "Copilot"`
- Correct at creation: `gh issue create --assignee "Copilot" ...`
- Incorrect: lowercase `copilot` (this fails)

When assigning Copilot, use `Copilot` (capital `C`).
