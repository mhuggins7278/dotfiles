---
description: Launch the executable work from a GitHub issue or epic
agent: build
---

When the current repository and branch already match a requested single-issue
lane (`owner/repo` on `issue-<number>`), treat the current process as a worker
prepared by a caller such as `agent-fix`. Work in this worktree and session. Do
not pull, switch or create another worktree, invoke `/workon` recursively, or
start another tmux or OpenCode process. This is an execution workflow: start
investigating and implementing the issue in this turn. Do not stop after
reporting the work context, a status board, or a plan, and do not ask the user
to confirm before beginning.

For any other request, resolve the GitHub issue or epic in $ARGUMENTS. Fetch
linked sub-issues and their repositories, inspect declared dependencies and
existing PRs, and show a compact status board of ready, active, complete, and
blocked work. Treat ready work as the current frontier and keep unresolved or
still-vague work visible without launching it.

Invoking `/workon` authorizes routine implementation, commits, pushes, and
draft PRs for clearly executable tickets. It does not authorize destructive Git
operations, production deployment, or work whose product behavior remains
materially ambiguous.

Use one isolated worktree per repository when parallel lanes are genuinely
useful. Keep same-repository dependency chains in one lane. Delegate lanes only
when isolation or parallelism improves the result; otherwise work in the
current session. Before launching, protect dirty worktrees and reuse existing
branches or draft PRs when they represent the same work.

Give each lane the full issue context and require proportional tests plus a
clear completion or blocker report. A prepared single-issue lane executes the
ticket end-to-end in the current process: implement it, run proportional
checks, address any blocking review findings, commit, push, and create or update
its draft PR. Use repository conventions and the GLG branch guidance when
applicable. Finish by reporting what completed, what remains blocked, and the
PR URLs created or updated.
