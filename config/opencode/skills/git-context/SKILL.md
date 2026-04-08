---
name: git-context
description: >
  Understand an unfamiliar git repository before reading code. Use this
  skill whenever the user asks where to start in a new codebase, wants a
  quick repo audit, references the "git commands before reading code"
  workflow, or wants hotspots, ownership risk, bug clusters, activity
  trends, or firefighting patterns from commit history. Run a small set of
  git history commands, interpret the signals, then recommend what code to
  inspect first.
---

# Git Context Skill

Build a quick diagnostic picture of a repository from git history before
opening source files.

## When to Use

- User asks where to start in an unfamiliar repo
- User wants a quick codebase audit before deeper reading
- User wants hotspots, ownership risk, bug clusters, or deploy stability
  signals
- User references the "git commands before reading code" idea

## Workflow

### 1. Establish the frame

- Start with `git status -sb` so you know the current branch and whether the
  worktree is dirty.
- Default to a `1 year` window for churn, bug, and firefighting checks unless
  the user asks for a different span.
- Compare overall authorship with a `6 months` view to spot ownership drift.
- Do not open code yet unless the user already asked about a specific file,
  bug, or feature.

### 2. Gather repo signals

Run the independent commands in parallel when possible.

```bash
git status -sb
git log --format=format: --name-only --since="1 year ago" | rg . | sort | uniq -c | sort -nr
git shortlog -sn --no-merges
git shortlog -sn --no-merges --since="6 months ago"
git log -i -E --grep="fix|bug|broken" --name-only --format='' --since="1 year ago" | rg . | sort | uniq -c | sort -nr
git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c
git log --oneline --since="1 year ago" | rg -i 'revert|hotfix|emergency|rollback'
```

Because tool output is already captured in full, summarize the top results in
your response instead of adding `head` or other truncation commands.

### 3. Interpret the signals

#### Churn hotspots

- The most frequently changed files are where the codebase has the most
  ongoing pressure.
- High churn is not automatically bad. Discount obvious noise like lockfiles,
  generated files, vendored code, or mass-renamed paths.
- Files that are both high-churn and high-bug should be treated as the
  highest-risk code in the repo.

#### Ownership and bus factor

- Use overall `git shortlog` to see who built the system.
- Compare that with the `--since="6 months ago"` output to see who is still
  active.
- If one person dominates authorship and is no longer active, call out the bus
  factor risk directly.
- Note that squash-merge workflows may reflect who merged work rather than who
  wrote it.

#### Bug clusters

- Treat the bug-keyword command as a rough defect-density map.
- Commit message quality matters; weak messages reduce the signal.
- Cross-reference this list with churn hotspots before choosing where to read.

#### Activity shape

- A steady monthly rhythm usually means stable delivery.
- Large drop-offs can indicate staffing loss or a stalled project.
- Repeating spikes followed by quiet periods often mean batch releases instead
  of continuous delivery.

#### Firefighting patterns

- Repeated `revert`, `hotfix`, `emergency`, or `rollback` commits suggest low
  deploy confidence.
- Zero matches can mean stability, or simply weak commit-message discipline.

### 4. Recommend what to read first

After summarizing the git signals, identify the `3-5` files or directories
most worth reading next.

Prioritize:

1. Files that appear in both the churn and bug lists
2. Core areas heavily shaped by a now-inactive contributor
3. Paths repeatedly involved in firefighting or rollback commits

If the output points to a directory rather than a single file, say that and
explain why.

## Response Structure

Use a concise report like this:

```markdown
## Git Readout
- Branch / worktree status: ...
- Churn hotspots: ...
- Ownership risk: ...
- Bug hotspots: ...
- Activity trend: ...
- Firefighting signals: ...
- Read these first: ...
```

Keep the emphasis on what the history implies, not on pasting raw command
output.

## Common Pitfalls

- Treating high churn alone as proof of bad code
- Ignoring generated files or lockfiles that dominate change counts
- Over-trusting `shortlog` in squash-merge repos
- Assuming no bug or firefighting matches means the repo is healthy
- Opening random files before the history points you to the likely hotspots
