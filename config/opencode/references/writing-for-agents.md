# Writing For Agents

Adapted for OpenCode from the principles in
[`mattpocock/skills`](https://github.com/mattpocock/skills), reviewed at commit
`8b78b531ab965735c5dc74f6f7a219e1e37326df` (MIT).

Write for predictable execution, not identical prose. Every instruction should
change behavior, route the agent to needed context, or define a meaningful
completion boundary.

## Context Pointers

A context pointer names material outside the current prompt and says when to
load it. Skill descriptions, `AGENTS.md` references, and links from commands
all serve this role.

- Front-load the capability or action the agent should recognize.
- Name each distinct trigger once; repeated synonyms add load without adding a
  branch.
- Make the loading condition explicit. A strong target behind a vague pointer
  is still unreliable.
- Keep pointers short because they are often loaded on every turn.

## Progressive Disclosure

Keep universal steps and safety constraints close to the entry point. Put
branch-specific procedures, examples, templates, and large reference sets
behind links that are loaded only when needed.

Co-locate a concept's definition, rules, and caveats. Split by a real branch or
sequence, not merely because a file became long. Too many tiny files replace
context load with navigation overhead.

## Completion Criteria

Use a completion criterion when premature completion would create a real risk.
Make it observable and proportionate, such as every changed caller checked or
the original reproduction passing. Do not turn ordinary engineering judgment
into a checklist merely to make the process deterministic.

## Sources Of Truth

- Keep each durable rule in one authoritative place and point to it elsewhere.
- Treat source code, configuration, local `--help`, and repository scripts as
  primary context. Do not cache facts the agent can cheaply inspect.
- Prune stale branches, duplicated meanings, and instructions the current model
  already follows without prompting.
- Prefer positive target behavior. Reserve prohibitions for hard guardrails.

## OpenCode Mechanics

- Skills are model-visible when discovered and require a useful `description`.
  OpenCode does not support `disable-model-invocation`.
- Use explicit commands for user-invoked workflows, especially when they
  publish, commit, push, or create multiple artifacts.
- Use `permission` to enforce tool boundaries; deprecated `tools` entries are
  additive and are not allowlists.
- Keep agent files authoritative and concise rather than duplicating a second
  canonical playbook.

## Local QA Before Publishing A Skill

Before adding or materially changing a skill, check:

- The description names the capability and each genuinely distinct trigger
  branch, using concrete local nouns where possible.
- The primary file contains universal steps and completion criteria; branch-only
  reference is disclosed behind a precise local pointer.
- Durable rules have one owner. Other skills point to that owner instead of
  restating the rule.
- Environment facts come from source files, local `--help`, repository scripts,
  or runtime inspection unless the fact is an unwritten convention or gotcha.
- Mutation boundaries are explicit and post-action state is verified.
- Every local markdown link resolves, the folder and frontmatter names match,
  and the skill inventory audit passes.

OpenCode does not support a portable `disable-model-invocation` frontmatter
switch. Preserve natural-language routing for useful skills; use commands for
explicit orchestration, publication, and multi-artifact workflows rather than
pretending a skill is user-only.
