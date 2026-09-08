---
name: git-context
description: Read repository history for hotspots, ownership, bug clusters, or delivery risk. Use when the user explicitly asks for history-based repository context.
---

# Git Context

Use git history to answer a repository-context question, then recommend where
to inspect next. This is optional context, not a prerequisite for ordinary
code changes.

## Workflow

1. Establish the frame with `git status -sb` and the time window relevant to the
   question. Use a year for broad trends and a shorter window when requested.
2. Run only the history queries needed to answer the question. Useful signals
   include changed-file frequency, `git shortlog`, bug-keyword commits, monthly
   activity, and revert or rollback commits.
3. Discount generated files, lockfiles, vendored code, and mass renames.
   High churn alone is not evidence of poor code.
4. Cross-reference signals before calling out risk. A file that is both
   frequently changed and involved in bug fixes is a stronger hotspot than
   either signal alone. Treat empty results as weak evidence.
5. Recommend the most useful files or directories to read next, with a reason.
   Do not open source first unless the user already named a file, bug, or
   feature.

## Interpretation

- Compare overall authorship with recent authorship to identify ownership drift,
  while noting that squash merges may reflect the merger rather than the author.
- A steady activity rhythm suggests regular delivery; spikes and drop-offs may
  reflect release batching, staffing changes, or a stalled project.
- Repeated `revert`, `hotfix`, `emergency`, or `rollback` commits suggest lower
  delivery confidence, but no matches may also reflect weak commit messages.

## Completion

Return a concise readout covering the requested signals, the scope searched,
the limits of the evidence, and the recommended next files. Do not turn the
report into a full repository audit unless the user asks for one.
