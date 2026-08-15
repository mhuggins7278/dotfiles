---
name: resolving-merge-conflicts
description: "Use when you need to resolve an in-progress git merge/rebase conflict."
---

Resolve an in-progress merge or rebase by intent, not by choosing lines. Keep
conflict resolution, operation continuation, and committing as separate actions.

1. **See the current state.** Check `git status`, the merge/rebase state, the
   conflicting files, and the unmerged diff. Identify whether this is a merge,
   rebase, or cherry-pick.

2. **Trace intent for each conflict.** Read the relevant commit messages and
   nearby code. Check the PR or issue only when it resolves a real ambiguity.
   Record incompatible choices and their trade-off instead of inventing new
   behavior.

3. **Resolve each hunk.** Preserve both compatible intents, edit only the
   conflicted files, and inspect the resulting diff. If the intended result
   cannot be established safely, stop and report the exact conflict. Aborting
   is valid when the user requests it or the operation is unsafe to continue.

4. **Verify the resolution.** Confirm there are no unmerged paths or conflict
   markers, then discover and run proportionate project checks. Report any
   failure as part of the unresolved result.

5. **Stop at the requested boundary.** By default, leave resolved files
   unstaged and report that the conflict is resolved. Stage files only when the
   user explicitly asks. Continue a merge/rebase only when explicitly asked to
   finish that operation; continuing may create a commit. Never create a
   standalone commit unless the user explicitly requests a commit.

Completion means every conflict is either resolved and verified, or reported
with its exact blocker. The final report states the operation state and whether
files were staged or the merge/rebase was continued.
