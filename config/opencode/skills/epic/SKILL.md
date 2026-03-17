---
name: epic
description: Multi-repo epic orchestration with dependency tracking and parallel worktree sessions. Always use this skill when the user invokes `/epic`, references a GitHub epic issue (a parent issue with linked sub-issues spanning multiple repos), asks what to work on next within an epic, wants a cross-repo status board of sub-issue progress, or needs to create worktrees to start on an epic ticket. Handles dependency graphs, blocked/ready classification, and sesh session management. Do NOT trigger for generic issue listing, PR creation, or single-issue work that lacks an explicit epic context.
---

# Epic Orchestration Skill

Coordinate work across multiple repositories for a GitHub epic with linked sub-issues. Tracks dependencies, displays cross-repo status, and creates worktrees for parallel work sessions.

## GLG Workflow Rules

Read `~/.dotfiles/config/opencode/references/glg-workflow.md` before executing. It covers:
- **Branch naming** (no slashes — hyphens only — and the `<issue-number>-<slug>` format)
- **Issue-first workflow** for commits and PRs
- **Project 85 tagging** and `Fixes` PR reference format
- **Team member logins**

## When to Use

- User runs `/epic <issue-reference>` to see status or pick up work
- User asks "what should I work on next?" in the context of a multi-repo epic
- User wants to see progress across repos for a linked set of issues

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth status`)
- `wt` (worktrunk) CLI installed for worktree management (`brew install worktrunk`)
- `sesh` installed for session management (`brew install joshmedeski/sesh/sesh`)
- `tmux` running (sesh requires an active tmux server)
- `jq` installed

If `wt` is not found, warn the user and suggest `brew install worktrunk`. The status board still works without `wt` — only worktree creation requires it.
If `sesh` is not found, warn the user and skip cross-repo session spawning — note which repos need manual sessions.

## Workflow

### 1. Parse the Epic Reference

Accept any of these formats and extract owner, repo, and issue number:

- Full URL: `https://github.com/glg/streamliner/issues/500`
- Short ref: `glg/streamliner#500`
- Number only (uses current repo context): `#500` or `500`

If no reference is provided ($ARGUMENTS is empty), ask the user for it.

### 2. Fetch Epic and Sub-issues

Use a single GraphQL query to get the epic and all its sub-issues:

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $number) {
        title
        state
        url
        body
        subIssues(first: 50) {
          nodes {
            number
            title
            state
            url
            body
            repository {
              nameWithOwner
              name
              owner { login }
            }
          }
        }
      }
    }
  }
' -f owner="<owner>" -f repo="<repo>" -F number=<number>
```

If the query fails with a scope error, instruct the user to run `gh auth refresh -s project`.

### 3. Check PR Status for Open Sub-issues (run in parallel)

For each sub-issue that is still `OPEN`, run both checks in parallel to find linked PRs:

```bash
# Search by issue number reference in PR body/title
gh pr list -R <owner>/<repo> --search "#<issue-number>" --state all --limit 100 \
  --json number,state,url,headRefName

# Search by branch naming convention
gh pr list -R <owner>/<repo> --limit 100 --json number,state,url,headRefName \
  --jq '[.[] | select(.headRefName | test("^(fix-issue-)?<number>(-|$)"))]'
```

A sub-issue has an active PR if either search returns a result with state `OPEN` or `DRAFT`. A `MERGED` PR means the ticket is effectively done even if the issue itself is still open. A `CLOSED` PR is ignored.

### 4. Parse Dependencies from Issue Bodies

Scan each sub-issue's body for dependency declarations. Match these patterns (case-insensitive):

```
(?i)(?:depends on|blocked by|after):?\s+(?:https?://github\.com/)?([\w.-]+/[\w.-]+)?(?:#|/issues/)(\d+)
```

Examples that must match:
- `depends on #123`
- `depends on: #123` (with colon)
- `blocked by glg/streamliner#456`
- `Blocked by: glg/streamliner#456`
- `after https://github.com/glg/consultations-api/issues/789`

When a reference uses `#N` without a repo qualifier, resolve it relative to the same repo as the sub-issue it appears in — **not** the epic's repo.

If no dependency hints are found in any sub-issue body, treat all tickets as independent (all READY). This is correct behavior, not an error.

**Cycle detection:** If the dependency graph contains cycles, warn the user with the affected issue numbers. Continue by treating cycle participants as READY so work is not completely blocked.

### 5. Classify Each Sub-issue

| Status | Condition |
|---|---|
| `done` | Issue state is `CLOSED`, or issue has a MERGED PR |
| `in_progress` | Issue is `OPEN` and has an OPEN or DRAFT PR |
| `ready` | Issue is `OPEN`, no active PR, all dependency issues are `done` |
| `blocked` | Issue is `OPEN`, no active PR, one or more dependencies are not `done` |

### 6. Display the Status Board

Present a formatted cross-repo overview grouped by status. Omit groups with no tickets.

```
Epic: <title> (<owner/repo>#<number>)
Progress: <done-count>/<total> complete

DONE:
  [x] <owner/repo>#<N> - <title>

IN PROGRESS:
  [/] <owner/repo>#<N> - <title> (PR #<pr> open)

READY:
  [ ] <owner/repo>#<N> - <title>

BLOCKED:
  [ ] <owner/repo>#<N> - <title>
      blocked by: <owner/repo>#<dep>, <owner/repo>#<dep>
```

### 7. Recommend Action and Present Execution Plan

Detect the current session's repo:

```bash
CURRENT_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
```

Determine the situation:

- **READY tickets exist for this repo:** Pick the highest-priority one (fewest remaining dependents = most unblocking). If multiple READY tickets exist in this repo, pick one to lead with — do not ask.
- **This repo's tickets are all blocked:** Name what must finish first; identify which other repo has READY tickets.
- **This repo has no tickets:** Identify the repo with the most READY tickets as the primary target.
- **All tickets are done or in progress:** Show remaining open items.

**Present a single, concrete execution plan** — not a menu. State exactly what will happen:

```
Recommended action:
  Primary (this session): <owner/repo>#<N> — <title>
    → branch: <branch-name>

  Parallel (new sesh session): <owner/repo>#<M> — <title>
    → branch: <branch-name-2>, repo: ~/github/glg/<repo-name>

Proceed? (yes/no)
```

Only list parallel tickets if they are READY and in a different repo. If there is only one READY ticket total, say so clearly and omit the parallel section.

Wait for the user to confirm with "yes" (or equivalent). If they say no or ask to change the target, update the plan accordingly and re-confirm.

### 8. Execute Plan Automatically

Once the user confirms, execute everything without additional prompts.

**Generate branch names:**
- Format: `<issue-number>-<slug>`
- Slugify the title: lowercase, replace non-alphanumeric with hyphens, collapse consecutive hyphens, strip trailing hyphens, truncate to 50 chars
- **Never use a slash** — hyphens only, always

**For the primary ticket (current repo) — create worktree:**

```bash
wt switch --create -y --no-cd <branch-name>
```

`--no-cd` suppresses the "Cannot change directory — shell requires restart" warning that appears when `wt` is called from a non-interactive subprocess (like opencode's bash tool). The worktree is still created successfully; opencode doesn't need the shell cd behavior.

After creation, derive the worktree path from the convention:

```
~/github/glg/<repo-name>.<branch-name>
```

Use this path explicitly for all subsequent file operations (read, edit, glob, grep). Pass it as `workdir` to bash commands that need to run inside the worktree (e.g., `git status`, test commands).

**For each parallel ticket (different repo) — open a sesh session:**

Before embedding the title in the command string, strip or escape any double-quote characters from `<title>`. Replace `"` with `'` or remove them entirely.

Check whether the local repo path exists first:

```bash
ls -d "$HOME/github/glg/<repo-name>" 2>/dev/null || echo "not found"
```

**Repo not found** — clone it first:

```bash
sesh clone git@github.com:<owner>/<repo-name>.git --cmdDir ~/github/glg
```

`sesh clone` clones into `~/github/glg/<repo-name>` and connects to a new session. After cloning, continue with the steps below.

**Create the worktree in the parallel repo** (always run after confirming the repo exists):

```bash
wt -C ~/github/glg/<repo-name> switch --create -y <branch-name>
```

The `-C` flag tells `wt` to treat `~/github/glg/<repo-name>` as its working directory, so the worktree is created in that repo's context. The worktree lands at `~/github/glg/<repo-name>.<branch-name>`.

**Then create a sesh session at the worktree path:**

```bash
sesh connect --switch \
  --command "opencode --prompt \"Work on <owner/repo>#<number>: <safe-title>. Run /epic <epic-ref> for full context.\"" \
  ~/github/glg/<repo-name>.<branch-name>
```

`--switch` is used because the command is triggered from within opencode rather than a direct terminal action. By pointing sesh at the worktree path (not the base repo), the session is always new and `--command` is never silently ignored due to an existing session for the same path.

Spawn all parallel sesh sessions before proceeding.

Report a brief summary of what was launched (branch names, sessions opened, any repos cloned), then move immediately to step 9.

### 9. Begin Implementation Immediately

After the worktree is created for the primary ticket, **start implementing without waiting for further input**. The user already confirmed — no more prompting.

1. Read the full sub-issue body and extract: acceptance criteria, technical notes, dependencies, any referenced files or endpoints.
2. Explore the codebase to understand the relevant code paths.
3. Form an implementation plan, write it to the TodoWrite tool, and begin executing it.
4. Follow the normal GLG implementation workflow: make edits, run tests if available, prepare for commit.

The user should come back to find meaningful progress already made, not a prompt asking them what to do next.

### 10. Re-check (Subsequent Invocations)

When `/epic` is invoked again from any session, repeat the full fetch-classify-display cycle from step 2. GitHub is the source of truth — no local state exists.

After re-fetching, call out what changed:
- Tickets newly closed (completed by other sessions)
- Tickets newly unblocked (blockers just merged)
- New PRs opened against epic tickets

## Integration with Other Skills

This skill coordinates but does not replace the existing workflow:

| Task | Use |
|---|---|
| Implement the ticket | This skill proceeds directly after worktree creation |
| Commit changes | `/commit` skill — issue-first enforcement still applies |
| Create a PR | `/pr` skill — associate with the sub-issue number, not the epic |
| Review a PR | `review` agent or `/counselors` |
| Wrap up a session | `/done` skill — captures which epic ticket was worked |

## Common Pitfalls

- **No slashes in branch names** — the deployment pipeline breaks. See GLG Workflow Rules above.
- **Always verify repo paths** before running `wt` or `sesh connect`. Never assume `~/github/glg/<name>` exists.
- **Always re-fetch from GitHub** — do not cache or remember status between invocations. Other sessions may have merged PRs or closed issues.
- **Cross-repo `#N` references** resolve to the same repo as the issue they appear in, not the epic's repo.
- **A MERGED PR means done** even if the GitHub issue is still open — check PR state, not just issue state.
- **Do not re-prompt after user confirms** — once the user says yes to the execution plan, proceed through steps 8 and 9 without stopping. Do not ask "shall I start implementing?" or "which file should I look at first?"
- **Pick one primary ticket, not a menu** — if multiple READY tickets exist in this repo, choose the best one and state your choice. Do not present a numbered list and ask the user to select.
