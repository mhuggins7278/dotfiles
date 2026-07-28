---
name: ask-matt
description: Ask which skill or flow fits your situation. A router over every skill in this setup.
disable-model-invocation: true
---

# Ask Matt

You don't remember every skill, so ask.

A **flow** is a path through the skills. Most engineering work runs along one **main flow**, with a few **on-ramps** merging onto it. Everything else is standalone, GLG/personal tooling, or a vocabulary layer that runs underneath.

## The main flow: idea → ship

1. **`grill-with-docs`** — sharpen the idea by interview. Use this when you **have a codebase**: it's stateful, retaining what it learns in `CONTEXT.md` and ADRs. No codebase? Use `grill-me` instead — same `grilling` primitive underneath, but stateless.
2. **Branch — can you settle every question in conversation?** If a question needs a runnable answer (state, business logic, a UI you have to see), detour through a prototype, bridged by **`handoff`** in both directions:
   - `handoff` out, then open a fresh session against that file,
   - `prototype` to answer the question with throwaway code,
   - `handoff` back what you learned, referencing it from the original thread.
3. **Branch — is this a multi-session build?**
   - **Yes** → `to-spec` (turn the thread into a spec issue), then `to-tickets` to split it into tracer-bullet GitHub issues, each declaring its **blocking edges** (`depends on <REPO>#N`). Use `workon` to launch the executable frontier as concurrent repository lanes; each lane processes its same-repo chain in one worktree and session.
   - **No** → `implement` right here, in the same context window.

   Either way, `implement` builds by driving `tdd` internally — one red-green slice at a time, at seams you agree on first — then closes out by running the `review` subagent (two-axis Standards + Spec check) before committing via `commit`.

## On-ramps

- **Bugs and requests piling up** → `triage`. Moves issues through triage roles and produces agent-ready issues that `implement` later picks up. Only for issues you didn't create — don't triage tickets `to-tickets` already made.
- **Something's broken** → `diagnosing-bugs`. For the hard ones — refuses to theorize until it has a tight feedback loop that already goes red on *this* bug, then fixes with a regression test.
- **Working an existing GitHub epic** → `workon`. Fetches sub-issue status, builds a dependency graph, and launches the current executable wave as detached repository-lane sessions.

## Codebase health

- **`improve-codebase-architecture`** — run whenever you have a spare moment. Surfaces **deepening opportunities** as a visual HTML report; picking one generates an idea you take into `grill-with-docs`.

## Vocabulary underneath

- **`domain-modeling`** — sharpen the project's domain language: challenge a fuzzy term, resolve an overloaded word, record a hard-to-reverse decision as an ADR. The active discipline `grill-with-docs` drives to keep `CONTEXT.md` a clean glossary.
- **`codebase-design`** — the deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality) for designing a module's shape. `tdd` and `improve-codebase-architecture` both speak it.

## Crossing sessions

- **`handoff`** — compact the current conversation into a markdown file so a fresh session can continue from it. Use when a thread is full or you're branching into a `prototype` session.
- **`/compact`** (built-in) — stay in the same conversation, summarizing earlier turns. Use at intentional breaks between phases; don't compact mid-phase.

## Standalone

- **`prototype`** — a small, throwaway program that answers one design question. Keep the answer, delete the code.
- **`research`** — delegate reading legwork to a background agent against primary sources; leaves a cited markdown file to feed into `grill-with-docs`.
- **`teach`** — learn a concept over multiple sessions using the current directory as a stateful workspace.
- **`resolving-merge-conflicts`** — resolve an in-progress git merge/rebase conflict.
- **`writing-great-skills`** — reference for writing and editing skills well; `skill-creator` points here for style guidance.
- **`skill-creator`** — the full create/eval/iterate loop for a skill, with real benchmark scripts. Reach for this over `writing-great-skills` when you need to actually build and test a new skill, not just polish prose.

## GLG & personal (not part of Matt's flow)

- **`commit`** / **`pr`** — the actual git mechanics: secret scanning, hook awareness, GLG issue-first enforcement, PR template detection. `implement` and `workon` call these rather than running raw git.
- **`gh-issues`** — general GitHub issue operations outside the ticket flow above.
- **`daily-notes`** / **`exec-assistant`** — daily capture and chief-of-staff prioritization in the notes vault.
- **`dotfiles`** — managing this Ansible-based dotfiles repo itself.
- **`git-context`** — get oriented in an unfamiliar repo before reading code.
- **`observe-glg`** — query production logs for GDS-deployed services.
- **`playwright-cli`** — browser automation for web testing.
- **`retro`** — post-session retrospective; updates this repo's `AGENTS.md`/`CLAUDE.md` with new gotchas.
- **`done`** — end-of-session wrap-up note.
- **`date`** — get the current date without guessing.

## Precondition

None — GLG-specific config (issue tracker = GitHub, project 92 tagging, branch naming) lives centrally in `~/.dotfiles/config/opencode/references/glg-workflow.md`, read by whichever skill needs it, rather than per-repo setup files.
