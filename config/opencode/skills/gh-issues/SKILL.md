---
name: gh-issues
description: Always use this skill for ALL GitHub issue operations including listing, searching, viewing, closing, moving, and managing issues. Provides GitHub CLI and Zenhub GraphQL API integration.
---

# GitHub Issues + Zenhub Skill

Manage GitHub and Zenhub issues via `scripts/zh.sh`. Never hand-write curl commands — always use the script.

## Prerequisites

- `ZH_API_KEY` env var must be set (get from https://app.zenhub.com/settings/tokens)
- `gh` CLI installed and authenticated
- `jq` installed

## Running the Script

```
bash /Users/MHuggins/.config/opencode/skills/gh-issues/scripts/zh.sh <command> [args...]
```

## Commands

| Command | Description |
|---------|-------------|
| `list-mine` | My open issues (excludes epics) |
| `list-team` | All team open issues (excludes epics) |
| `list-epics [--mine]` | Team epics; `--mine` filters to current user only |
| `epic-issues <epic-number>` | Child issues of a given epic |
| `list-closed [--days N]` | Closed team issues (default: 14 days) |
| `board` | Pipeline overview with counts + points |
| `show <issue-number>` | Full issue details (requires repo context) |
| `search <pipeline> [--assignee X] [--label X]` | Filter issues in a pipeline |
| `viewer` | Current authenticated user info |
| `move <issue-number> <pipeline>` | Move issue to pipeline |
| `close <issue-number>` | Close issue |
| `reopen <issue-number> [pipeline]` | Reopen issue (default: todo) |
| `estimate <issue-number> <points>` | Set estimate |
| `create <title> [--body TEXT] [--zenhub]` | Create issue |
| `assign <issue-number> <login>` | Assign user |
| `unassign <issue-number> <login>` | Remove assignee |

**Pipeline names**: `inbox` | `todo` | `in-progress` | `on-hold` | `in-test`

## GitHub vs Zenhub Issues

Check the `type` field on any issue. Determines which API to use:

- `"GithubIssue"` — has a `htmlUrl`. Use `gh` CLI or `addAssigneesToIssues` for assignees. The script handles this automatically.
- `"ZenhubIssue"` — `htmlUrl` is empty. Use `addZenhubAssigneesToIssues`. The script auto-detects this; `assign` only works for the current viewer on ZH-only issues.

## Default Configuration

- **Workspace**: Client Solutions Experience (`5d7a5516d7fbc600019bc8ae`)
- **Zenhub Repo ID**: `Z2lkOi8vcmFwdG9yL1JlcG9zaXRvcnkvMTMzNzc3MjQw` (for Zenhub-only issue creation)

## Team Members

Mark Huggins, Jess Chadwick, David Hayes, Ronan O'Malley, Priya Darshani, John Lemberger

## Tips

- `workspace.issues` returns all issues (open + closed, no assignee filter) — client-side jq filtering is used for `list-mine` and `list-team`
- `search` uses `searchIssuesByPipeline` which supports server-side assignee/label filters — prefer it when you need filtered results per pipeline
- Max 100 issues per API query, 200 complexity points per query
- For GitHub-backed issues, `gh issue edit` also works for simple assign/label/close operations
