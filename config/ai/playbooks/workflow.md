# Planning And Execution Workflow

This is the canonical workflow for planning and executing engineering work.
Each state has one owner, one artifact, and one reason to stop. Skills and
agents must not add a second gate owned by another state.

| Transition | Owner | Artifact | Stop only when |
| --- | --- | --- | --- |
| Unclear idea to aligned | `grill-with-docs` | Updated `CONTEXT.md` and ADRs | A decision needs the user |
| Aligned to specified | `to-spec` | GitHub spec issue | A material decision is still unknown |
| Specified to ticketed | `to-tickets` | GitHub issue or epic with sub-issues | Waiting for one publication approval |
| Ticketed to implemented | `implement` | Commit and verification evidence | A material ambiguity or unrecoverable failure occurs |
| Executable epic to parallel work | `workon` | Lane branches and draft PRs | A lane reports blocked or complete |

## Rules

- Use `grill-with-docs` only when decisions are unresolved. It owns the
  interactive interview and must not publish specs or tickets.
- `to-spec` synthesizes the resolved conversation and codebase context. It
  does not restart a broad grilling session. It may ask about a material,
  unresolved product or architecture decision.
- `to-tickets` decomposes an approved spec mechanically. It must not restart
  grilling. Present the full ticket set once and wait for one approval before
  publishing it.
- An explicit `implement` or `workon` request authorizes routine execution.
  Select ordinary test seams autonomously and record them in the implementation
  summary. Ask only when a choice materially changes product behavior,
  architecture, or safety.
- `workon` workers must finish with an explicit `LANE_RESULT: COMPLETE` or
  `LANE_RESULT: BLOCKED` marker. A blocked result names the ticket and the
  exact decision or failure that requires attention.

## Supporting Skills

`grilling`, `domain-modeling`, `tdd`, `research`, `prototype`, `review`,
`commit`, and `pr` support a state owner. They do not create additional user
approval gates unless the workflow above explicitly calls for one.
