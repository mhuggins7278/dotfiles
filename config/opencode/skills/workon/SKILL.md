---
name: workon
description: GitHub issue orchestration with sub-issue tracking, worktree sessions, dep installation, and review gates. Always use this skill when the user invokes `/workon`, references a GitHub issue that has sub-issues, asks what to work on next in a feature group, wants a status board of sub-issue progress, or needs to create a worktree to start on an issue. Handles same-repo and cross-repo layouts, auto dep installation, dependency graphs, blocked/ready classification, and review gates before PR. Do NOT trigger for generic issue listing, PR creation, or single-issue work that has no sub-issues.
---

# Workon Skill

Work through a GitHub issue that has sub-issues: fetch current state, show a
status board, recommend the next ticket to pick up, create a worktree,
install deps, and spawn a session. Provides a review gate before any PR.

Works for any GitHub repo — not just GLG. When in a GLG repo, additional
rules apply (see the GLG section below).

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth status`)
- `wt` (worktrunk) CLI for worktree management (`brew install worktrunk`)
- `sesh` for session management (`brew install joshmedeski/sesh/sesh`)
- `tmux` running
- `jq` installed

If `wt` is missing, warn the user — the status board still works but worktree
creation won't. If `sesh` is missing, warn and skip session spawning.

---

## Workflow

### 1. Parse the Issue Reference

Accept any of these formats:

- Full URL: `https://github.com/owner/repo/issues/500`
- Short ref: `owner/repo#500`
- Number only (current repo): `#500` or `500`

Resolve owner, repo, and issue number. If `$ARGUMENTS` is empty, ask the user.

---

### 2. Detect GLG Context

```bash
OWNER=$(gh repo view --json owner -q .owner.login 2>/dev/null || echo "")
```

If `$OWNER == "glg"`, read `~/.dotfiles/config/opencode/references/glg-workflow.md`
now. It governs branch naming (hyphens only, never slashes), issue-first
workflow, project 85 tagging, and PR reference format. Apply those rules for
the rest of this session.

For non-GLG repos, use the generic branch naming convention defined in step 7.

---

### 3. Fetch Issue and Sub-issues

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

If the query fails with a scope error, instruct the user:
`gh auth refresh -s project`

If the issue has **no sub-issues**, treat it as a single-ticket epic
(one item, always READY). The status board and worktree creation still apply.

---

### 4. Check PR Status for Open Sub-issues (run in parallel)

For each `OPEN` sub-issue, run both searches in parallel:

```bash
# Search by issue reference in PR body/title
gh pr list -R <owner>/<repo> --search "#<issue-number>" --state all --limit 100 \
  --json number,state,url,headRefName

# Search by branch naming convention
gh pr list -R <owner>/<repo> --limit 100 --json number,state,url,headRefName \
  --jq '[.[] | select(.headRefName | test("^issue_<number>(-|$)"))]'
```

A `MERGED` PR counts as done even if the GitHub issue is still open.
A `CLOSED` PR is ignored.

---

### 5. Parse Dependencies from Issue Bodies

Scan each sub-issue's body for dependency declarations (case-insensitive):

```
(?i)(?:depends on|blocked by|after):?\s+(?:https?://github\.com/)?([\w.-]+/[\w.-]+)?(?:#|/issues/)(\d+)
```

Matches: `depends on #123`, `blocked by owner/repo#456`,
`after https://github.com/owner/repo/issues/789`.

Bare `#N` resolves relative to the sub-issue's own repo, not the parent's.

If no dependencies are found, treat all tickets as independent (all READY).
If the dependency graph has cycles, warn and treat cycle participants as READY.

---

### 6. Classify Each Sub-issue

| Status | Condition |
|---|---|
| `done` | Issue is `CLOSED`, or has a MERGED PR |
| `in_progress` | Issue is `OPEN` and has an OPEN or DRAFT PR |
| `ready` | Issue is `OPEN`, no active PR, all dependencies are `done` |
| `blocked` | Issue is `OPEN`, no active PR, at least one dependency is not `done` |

---

### 7. Display the Status Board

```
Epic: <title> (<owner/repo>#<number>)
Progress: <done-count>/<total> complete

DONE:
  [x] <owner/repo>#<N> - <title>

IN PROGRESS:
  [~] <owner/repo>#<N> - <title>  (PR #<pr> open)

READY:
  [ ] <owner/repo>#<N> - <title>

BLOCKED:
  [!] <owner/repo>#<N> - <title>
      blocked by: <owner/repo>#<dep>
```

Omit groups with no tickets.

---

### 8. Detect Repo Layout

Inspect the repos of all OPEN sub-issues:

```bash
PARENT_REPO="<owner>/<repo>"  # the epic/parent issue's repo

UNIQUE_REPOS=(list of unique nameWithOwner values from open sub-issues)
```

**Same-repo layout** (all sub-issues share the parent's repo, or there are no
sub-issues):

- Create **one worktree** branched from the parent issue number.
- All sub-issues are worked in that single worktree.
- Branch: `issue_<parent-issue-number>`

**Cross-repo layout** (sub-issues span multiple repos):

- Create one worktree per unique repo among the READY tickets.
- Branch per repo: `issue_<issue-number>` (use the sub-issue number for that repo).
- Recommend the most valuable repo to tackle first (see step 9).

---

### 9. Recommend One Ticket

For **same-repo**: the recommendation is always "start / continue work on the
parent branch." Skip the menu if a worktree already exists.

For **cross-repo**: pick one READY sub-issue. Prefer the current session's
repo; otherwise pick the ticket that unblocks the most others. Don't present
a menu — pick one and explain why.

```
Recommended action:
  <owner/repo>#<N> — <title>
  branch: <branch-name>
  worktree: <worktree-path>

Proceed? (yes/no)
```

**Only show the `Proceed?` prompt when there are multiple READY tickets and a
real choice to confirm.** For single-ticket epics (no sub-issues, or only one
READY ticket), skip the prompt and proceed automatically.

If the user declines or wants a different ticket, update and re-confirm.

**Branch name format (generic):** `issue_<number>`
- Use the parent issue number for same-repo epics; use the sub-issue number for cross-repo branches.
- GLG repos: same format, hyphens only (never slashes) as per `glg-workflow.md`.

---

### 10. Create the Worktree

Once the user confirms, execute without further prompts.

**Pre-check — already in the target worktree:**

Before doing any setup, check whether you're already on the target branch:

```bash
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
```

If `$CURRENT_BRANCH` matches the target branch name (e.g. `issue_<number>`),
the session was launched by an external launcher (such as `agent-fix`) that
already created the worktree and installed deps. In that case:

1. Announce: *"Already in worktree for branch `<branch>` — skipping setup."*
2. Skip the rest of step 10 and all of step 11.
3. Proceed directly to working on the issue.

---

**Locate the base repo:**

```bash
# Current repo root and its parent directory
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_PARENT=$(dirname "$REPO_ROOT")
```

For the current repo:

```bash
WORKTREE_PATH="$REPO_PARENT/<repo-name>.<branch-name>"

if [ -d "$WORKTREE_PATH" ]; then
  # Worktree already exists — pull latest before continuing
  git -C "$WORKTREE_PATH" pull
else
  wt switch --create -y --no-cd <branch-name>
fi
```

`--no-cd` suppresses the "Cannot change directory" warning in a non-interactive
subprocess — the worktree is still created correctly.

For a different repo (cross-repo sub-issue):

```bash
# Derive sibling path convention: <same-parent-dir>/<repo-name>
OTHER_REPO_PATH="$REPO_PARENT/<repo-name>"

# Check if the local clone exists
if [ ! -d "$OTHER_REPO_PATH" ]; then
  git clone git@github.com:<owner>/<repo-name>.git "$OTHER_REPO_PATH"
fi

WORKTREE_PATH="$REPO_PARENT/<repo-name>.<branch-name>"

if [ -d "$WORKTREE_PATH" ]; then
  # Worktree already exists — pull latest before continuing
  git -C "$WORKTREE_PATH" pull
else
  wt -C "$OTHER_REPO_PATH" switch --create -y <branch-name>
fi
```

The worktree lands at `<REPO_PARENT>/<repo-name>.<branch-name>`.

---

### 11. Spawn Session

Detect the package manager for the worktree so the startup command can install
deps as its first step.

Detection order (first match wins):

| File present | Install command |
|---|---|
| `pnpm-lock.yaml` | `pnpm install` |
| `yarn.lock` | `yarn install` |
| `package-lock.json` | `npm ci` |
| `package.json` (no lock) | `npm install` |
| `Gemfile.lock` | `bundle install` |
| `requirements.txt` | `pip install -r requirements.txt` |
| `pyproject.toml` | `poetry install` (if `[tool.poetry]` present) or `pip install -e .` |
| `go.mod` | `go mod download` |
| `Cargo.toml` | `cargo fetch` |

If none of the above match, set `INSTALL_CMD=""` and skip the install step.

```bash
# Strip double-quotes from title to avoid shell escaping issues
SAFE_TITLE=$(echo "<title>" | tr -d '"')

# Derive session name the same way sesh does (basename of path)
SESSION_NAME=$(basename "$WORKTREE_PATH")

# Prepend dep install to the startup command so the new session owns its env
if [ -n "$INSTALL_CMD" ]; then
  STARTUP="$INSTALL_CMD && opencode --prompt 'Work on <owner/repo>#<number>: $SAFE_TITLE. Run /workon <issue-ref> for full context.'"
else
  STARTUP="opencode --prompt 'Work on <owner/repo>#<number>: $SAFE_TITLE. Run /workon <issue-ref> for full context.'"
fi

sesh connect --command "$STARTUP" "$WORKTREE_PATH"

# sesh connect creates the session but the switch may not propagate when
# called from a subprocess. Explicitly switch the active tmux client.
tmux switch-client -t "$SESSION_NAME"
```

Report: branch created, worktree path, session name (dep install runs in the new session).
The new session handles dep installation and implementation — this session's job is done.

---

### 12. Re-check (Subsequent Invocations)

When `/workon` is invoked again (from any session), repeat steps 3–7.
GitHub is the source of truth — no local state is cached.

After re-fetching, explicitly call out what changed since last check:
newly closed tickets, newly unblocked tickets, new PRs opened.

---

### 13. Review Gate (Before PR)

When the user signals that implementation is complete — or when you judge that
all planned work is done — trigger the review loop before opening a PR.

**Do not skip this step.** The review runs on uncommitted changes in the
working tree (`git diff` + `git diff --staged`). The loop runs until the
review agent returns `APPROVED` or the user intervenes.

#### Loop

1. Announce: *"Running code review on current changes before opening a PR."*
2. Invoke the `review` subagent via the Task tool. Pass it the issue context
   (owner/repo, issue number, title) so it understands what was being built.
3. Read the `REVIEW_VERDICT` block at the end of the subagent's output:
   - `APPROVED` → exit the loop and proceed to "After approval" below.
   - `NEEDS_WORK` → continue below.
4. Present the Blocker and Critical issues to the user in a brief summary.
5. Address each Blocker and Critical issue in the worktree. Warnings and
   Suggestions are noted but do not block the loop.
6. Commit the fixes using `/commit`.
7. Return to step 1.

**Loop guard:** If `NEEDS_WORK` is returned 3 times in a row, stop looping
and surface the remaining issues to the user:

> "The review has flagged issues across 3 iterations. Remaining blockers:
> [list]. How would you like to proceed — fix manually, skip, or abandon?"

Wait for explicit direction before continuing.

#### After approval

Proceed with `/pr`. Link the PR to the sub-issue (not the parent epic), using
`Fixes <owner>/<repo>#<number>` in the PR body.

---

## Integration with Other Skills

| Task | Use |
|---|---|
| Commit changes | `/commit` skill |
| Open a PR | `/pr` skill — after the review gate above |
| Wrap up a session | `/done` skill |
