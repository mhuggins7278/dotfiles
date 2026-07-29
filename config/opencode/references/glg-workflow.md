# GLG Workflow Rules

These rules apply when working in any repository under `~/github/glg/`.

## Branch Naming

**Never use a slash (`/`) in a branch name.** Slashes break the deployment pipeline when promoting branches to the testing environment. This is a hard stop, not a preference.

- WRONG: `feature/foo`, `fix/bar`, `chore/anything`
- RIGHT: `feature-foo`, `fix-bar`, `chore-anything`

If the current branch contains a `/`, warn the user and stop until it is renamed.

**Format for issue branches:** `issue_<number>`.

For a `/workon` repository lane, use the parent epic number when the parent
repository has multiple linked tickets. In another repository, use the first
local ticket number in deterministic dependency order. A one-ticket lane always
uses that ticket's number. Never use slashes.

## Issue-First Workflow

All implementation work in GLG repos requires an associated GitHub issue **before** making any code edits, commits, or PRs.

1. Check for an existing issue reference in branch context, commit messages, or user-provided input
2. Validate candidate issue numbers with `gh issue view <number>` — if closed or unrelated, treat as missing
3. If no valid open issue is found, **pause and prompt the user to create one** before proceeding
4. If the user agrees, create the issue and add it to `glg` project `92`

## Project Tagging

Default GitHub Project: **`glg` project `92` (`Enterprise Integration`)**

- When using `gh issue create --project`, use the name `"Enterprise Integration"` (not the numeric ID)
- When using `gh project item-add`, use `92` and `--owner glg`

```bash
# Add issue to project after creation
gh project item-add 92 --owner glg --url "$(gh issue view <number> --repo "$REPO" --json url -q .url)"
```

## Pull Requests

The `/pr` skill owns pull-request issue links and closing-keyword syntax. When
a GLG workflow creates or updates a PR, invoke `/pr` and follow its `Issue
Links That Close on Merge` section rather than duplicating those mechanics here.

## SQL Templates & DB Queries

If the project references SQL files, epiquery templates, or database queries, always search `~/github/glg/epiquery-templates/` for the relevant templates. This is the central repository and source of truth for database queries across all GLG projects.

## Team Members

| Name | GitHub Login |
|------|-------------|
| Mark Huggins | `mhuggins7278` |
| David Hayes | `drhayes` |
| Ronan O'Malley | `Ronanj7` |
| Eva LeBreux | `LeBeva` |
| Matt Keeble | `beldougie` |
| Raul Reynoso | `rulio` |
| Vamsi Krishna Budati | `vbudati-glg` |

To request a Copilot code review, pass `--reviewer @copilot` directly to `gh pr create`, or use `gh pr edit --add-reviewer @copilot` to add it to an existing PR. Requires gh v2.88.0 or later.

## Repo Setup

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
```
