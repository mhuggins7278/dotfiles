---
description: Break a spec into a minimal set of executable GitHub issues
agent: build
---

Resolve the spec or epic in $ARGUMENTS, using conversation context when the
reference is omitted. Propose the smallest set of independently verifiable
vertical slices. Each ticket should state delivered behavior, acceptance
criteria, exclusions, and real blocking dependencies.

Separate executable work from unresolved fog. A sharp question may be tracked
as a decision blocker, but do not disguise a product or architecture decision
as an implementation ticket. The ready frontier is the set whose blockers are
resolved and whose behavior is clear enough to build.

For a wide mechanical migration that cannot land as vertical slices, use
expand, migrate, contract: introduce the new form beside the old, migrate
callers in green batches, then remove the old form after every migration.

Present the complete set once and ask before publishing because this command
may create multiple shared artifacts. After approval, create the issues without
another gate, add native sub-issue relationships when an epic is useful, and
apply GLG project tagging from
`~/.dotfiles/config/opencode/references/glg-workflow.md` when relevant.

Return each issue URL and identify which tickets are immediately executable.
