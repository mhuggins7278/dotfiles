---
description: Publish the resolved plan as a concise GitHub spec issue
agent: build
---

Synthesize the current conversation, repository context, and $ARGUMENTS into
one concise GitHub spec issue. Invoking `/spec` authorizes creation of that one
issue. Ask only if a material product, architecture, or safety decision remains
unresolved.

Explore enough of the repository to align terminology and existing behavior.
Use these sections when relevant: Problem, Proposed behavior, Acceptance
criteria, Implementation decisions, Testing approach, and Out of scope. Avoid
exhaustive user-story inventories, brittle file paths, and speculative details.
Identify high-value test seams at existing public behavior when they are known;
do not invent a seam merely to complete the template.

Create the issue with `gh`. For a GLG repository, follow
`~/.dotfiles/config/opencode/references/glg-workflow.md` for project tagging.
Return the issue URL.
