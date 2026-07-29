---
name: workon
description: GitHub epic wave launcher with sub-issue dependency tracking, repository lanes, worktrees, detached tmux workers, and combined draft PRs. Always use this skill when the user invokes `/workon`, references an issue with linked sub-issues, asks what can be worked in parallel in an epic, or wants to launch worktrees for an epic. Handles same-repo chains, cross-repo dependency waves, and a one-ticket workon run. Do NOT trigger for generic issue listing or standalone PR creation.
---

# Workon Skill

`/workon` launches the current executable wave of a GitHub epic. It finds
which sub-issues can progress, groups them into repository lanes, and starts
one detached tmux worker per lane. It does not monitor workers or recursively
launch later waves. Rerun `/workon <epic>` after workers finish to launch work
unblocked by their completed draft PRs.

The invocation authorizes all routine setup, implementation, commits, pushes,
and draft PR work in the launched lanes. Do not ask for an initial or
between-ticket confirmation. A worker asks only when ambiguity materially
affects product behavior or architecture, an unsafe action is needed, or it
cannot recover from a failure.

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth status`)
- `wt` (worktrunk) CLI for worktree management (`brew install worktrunk`)
- `tmux` running
- `jq` installed

If `wt` or `tmux` is missing, report the missing prerequisite and show the
status board without launching workers.

---

## Workflow

### 1. Parse the Epic Reference

Accept a full issue URL, `owner/repo#number`, `#number`, or `number` in the
current repository. Resolve the parent owner, repository, and issue number.
If no reference is supplied, ask the user for one.

When the parent repository belongs to `glg`, read
`~/.dotfiles/config/opencode/references/glg-workflow.md` before continuing.

### 2. Fetch the Epic Graph

Fetch the parent and up to 50 linked sub-issues using GitHub's native
`subIssues` GraphQL field. For every sub-issue retain its number, title, state,
body, URL, and repository name-with-owner.

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $number) {
        title
        state
        url
        subIssues(first: 50) {
          nodes {
            number
            title
            state
            url
            body
            repository { nameWithOwner name owner { login } }
          }
        }
      }
    }
  }
' -f owner="<owner>" -f repo="<repo>" -F number=<number>
```

If the query needs the project scope, instruct the user to run
`gh auth refresh -s project`. An issue without sub-issues is a one-ticket lane
in its own repository.

### 3. Build the Dependency Graph

Read each issue body for dependency declarations, case-insensitively:

```
(?i)(?:depends on|blocked by|after):?\s+(?:https?://github\.com/)?([\w.-]+/[\w.-]+)?(?:#|/issues/)(\d+)
```

Bare `#N` references resolve in that sub-issue's repository. A dependency edge
points from the prerequisite to the dependent ticket.

For each issue, fetch candidate PRs in parallel. Use the issue's own repository
and include merged PRs and their bodies:

```bash
gh pr list -R <issue-owner>/<issue-repo> --search "#<issue-number>" \
  --state all --limit 100 --json number,state,url,headRefName,body
```

A dependency is satisfied when its issue is closed, has a merged PR, or is
marked as completed in a prior lane PR's **Included issues** section:

```
- [x] <owner>/<repo>#<number> (<commit-sha>)
```

An open or draft PR alone does not satisfy a dependency. It must contain the
checked entry and commit SHA, which records that the ticket was individually
reviewed and committed. When reading older lane PRs, also accept the previous
ledger format where `Fixes` was prefixed to the fully qualified issue
reference; new and updated PR bodies keep the closing reference separate.

If the graph has a cycle, report the cycle as blocked. Do not launch it because
there is no valid first ticket.

### 4. Form the Executable Wave

Group all sub-issues by repository. A repository lane is executable when it
contains at least one open ticket whose external dependencies are satisfied.

For each executable lane, include its **local chain**: every same-repository
dependent that becomes executable by completing tickets already in that lane.
Order the lane topologically, then by issue number. Do not include a ticket
whose unresolved dependency is in another repository.

This means independent repositories launch concurrently, while same-repository
work runs sequentially in one branch and one worker. A later `/workon` run
creates the next wave after an upstream lane PR records its completed tickets.

### 5. Display the Wave Board

Always show the complete graph, followed by the launch plan:

```
Epic: <title> (<owner/repo>#<number>)

READY NOW:
  [ ] <owner/repo>#<N> - <title>

LOCAL CHAINS:
  <owner/repo>: #12 -> #19

WAITING ON OTHER REPOS:
  [!] <owner/repo>#<N> - <title>
      waiting on: <owner/repo>#<dependency>

IN PROGRESS / DONE:
  [~|x] <owner/repo>#<N> - <title>

LAUNCHING:
  <owner/repo>  issue_<branch-number>  #12, #19
```

Omit empty groups. Continue immediately; the board is informational, not an
approval prompt.

### 6. Choose a Stable Lane Branch

Use all linked sub-issues, not only the current wave, to choose a lane branch:

| Lane | Branch |
|---|---|
| One ticket in the repository | `issue_<ticket-number>` |
| Multiple tickets in the parent repository | `issue_<parent-epic-number>` |
| Multiple tickets in another repository | `issue_<first-local-ticket-number>` |

`first-local-ticket-number` is the first ticket in the lane's deterministic
topological order, with issue number breaking ties. Before creating a branch,
search for an open draft PR whose body identifies `Part of <parent-repo>#<parent-number>`.
Reuse that PR's head branch when it exists; this preserves the branch across
later waves.

### 7. Create or Reuse Each Worktree

Launch every executable lane. Worktrees and workers must be independent, so a
problem in one lane never prevents another lane from starting.

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_PARENT=$(dirname "$REPO_ROOT")
CURRENT_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
LANE_REPO="<lane-owner>/<lane-repo>"

if [ "$LANE_REPO" = "$CURRENT_REPO" ]; then
  LANE_REPO_PATH="$REPO_ROOT"
else
  LANE_REPO_PATH="$REPO_PARENT/<lane-repo>"
fi

WORKTREE_PATH="$REPO_PARENT/<lane-repo>.<branch-name>"

if [ ! -e "$LANE_REPO_PATH/.git" ]; then
  git clone git@github.com:<lane-owner>/<lane-repo>.git "$LANE_REPO_PATH"
fi

LANE_AVAILABLE=true

if [ -d "$WORKTREE_PATH" ]; then
  if [ -n "$(git -C "$WORKTREE_PATH" status --porcelain)" ]; then
    # Report the lane as unavailable; never mix work into a dirty worktree.
    LANE_AVAILABLE=false
  else
    git -C "$WORKTREE_PATH" pull --ff-only
  fi
elif git -C "$LANE_REPO_PATH" show-ref --verify --quiet \
  "refs/heads/<branch-name>" \
  || git -C "$LANE_REPO_PATH" show-ref --verify --quiet \
  "refs/remotes/origin/<branch-name>"; then
  wt -C "$LANE_REPO_PATH" switch -y --no-cd <branch-name>
else
  wt -C "$LANE_REPO_PATH" switch --create -y --no-cd <branch-name>
fi
```

For the parent repository, `LANE_REPO_PATH` may equal `REPO_ROOT`. Do not pull
when the worktree has uncommitted changes; report that lane as unavailable
instead of overwriting or mixing work.

### 8. Launch Detached Lane Workers

Detect the lane's package manager using this order: `pnpm-lock.yaml`,
`yarn.lock`, `package-lock.json`, `package.json`, `Gemfile.lock`,
`requirements.txt`, `pyproject.toml`, `go.mod`, then `Cargo.toml`.

Build a worker prompt containing:

- the parent epic reference;
- the lane branch and existing lane PR, if any;
- the ordered local chain of issue references and titles;
- cross-repository dependencies already satisfied, including branch and commit
  information where available; and
- the worker contract below.

The worker contract is:

1. Process the listed tickets in order. Run `/implement` for each ticket.
2. Let `/implement` own test-seam selection, review, and the separate commit for
   each ticket. Confirm it completed before advancing.
3. Pause only for a consequential ambiguity or unrecoverable failure.
4. Do not invoke `/workon`, switch branches, or start work outside this lane.
5. After the final listed ticket, run `/pr` to create or update one combined
   draft PR for the lane. Include the required lane PR body from this prompt.
6. End with exactly one result marker: `LANE_RESULT: COMPLETE` after the lane
   PR is updated, or `LANE_RESULT: BLOCKED` followed by the ticket and exact
   decision or unrecoverable failure that needs attention. Never stop on a bare
   question.

Run each worker detached. Keep the initiating OpenCode session and active tmux
client unchanged.

```bash
SESSION_NAME=$(basename "$WORKTREE_PATH" | tr '.' '_')
WORKER_PROMPT='<lane worker contract and lane manifest>'

if [ -n "$INSTALL_CMD" ]; then
  STARTUP="$INSTALL_CMD && opencode --prompt $(printf '%q' "$WORKER_PROMPT")"
else
  STARTUP="opencode --prompt $(printf '%q' "$WORKER_PROMPT")"
fi

if [ "$LANE_AVAILABLE" = false ]; then
  # This lane was reported as unavailable during worktree setup.
  :
elif tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  # An existing worker owns this lane. Report it; do not duplicate it.
  :
else
  tmux new-session -d -s "$SESSION_NAME" -c "$WORKTREE_PATH" "$STARTUP"
fi
```

For Node lanes, prefix `$INSTALL_CMD` with
`eval "$(fnm env --shell bash)" && fnm use --install-if-missing &&`.
`$STARTUP` installs dependencies when needed and then starts `opencode` with
the worker prompt. Do not use `sesh connect`, `tmux switch-client`, or any
command that closes or replaces the initiating session.

### 9. Create or Update the Lane Draft PR

At the end of its local chain, the worker pushes the lane branch and creates or
updates one draft PR. The PR must use the repository's template when present.
Regardless of the template, invoke `/pr` with every completed local ticket;
`/pr` owns the `## Linked issues` section and closing-keyword syntax. Keep the
commit ledger in `## Included issues`. Without a template, use:

```markdown
## Summary

<combined lane summary>

## Included issues

- [x] <owner>/<repo>#<number> (<commit-sha>)

## Parent epic

Part of <parent-owner>/<parent-repo>#<parent-number>

## Evidence

- [x] Testing: <summary>
- [x] Code review: approved per included ticket
```

Include every ticket completed in this and prior waves on the lane branch and
pass them all to `/pr`, which adds the closing references to the PR description.
Do not include the parent epic among those tickets; it is a `Part of` reference
only.

### 10. Report and Leave Control Intact

Report each launched, reused, skipped, and blocked lane with its repository,
issues, branch, worktree, tmux session, and existing PR if present. Workers
must provide their `LANE_RESULT` marker in the detached session. Keep this
OpenCode session open for follow-up prompts. It does not poll workers or launch
later waves automatically.

---

## Integration with Other Skills

| Task | Use |
|---|---|
| Build each lane ticket | `/implement` |
| Test-first work | `/tdd` |
| Commit each ticket | `/commit` |
| Create or update lane PR | `/pr` |
| Start a later wave | `/workon <epic>` |
