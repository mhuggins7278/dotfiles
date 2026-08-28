# Autonomy-First Engineering Workflow

Use the smallest process that safely completes the user's request.

## Default Loop

1. Understand the request and inspect relevant context.
2. State consequential assumptions; make reversible choices autonomously.
3. Implement or investigate directly.
4. Verify proportionally to the change's size and risk.
5. Report the outcome, evidence, and anything not verified.

When tests add confidence, prefer vertical behavior slices exercised through
existing public seams. Do not invent abstractions or test boundaries solely to
fit a process.

Treat newly surfaced failures as caused by the current work until evidence
shows otherwise. Do not dismiss them as pre-existing or unrelated merely
because the connection is unclear.

Planning, research, prototyping, testing, review, and delegation are
capabilities to use when they improve the result. They are not mandatory
phases and do not need separate artifacts by default.

## Ask Only When Needed

Ask when a decision materially changes product behavior, architecture,
security, privacy, cost, or an irreversible external state. Otherwise choose a
reasonable default, state it when useful, and continue.

Require explicit authorization before destructive commands, production
deployments, bulk external publication, posting on the user's behalf, or Git
pushes and commits the user did not request. Local reading, editing, testing,
formatting, and ordinary diagnosis do not need approval.

## Proportional Execution

- Use a subagent for specialized tools, independent parallel work, or useful
  context isolation, not because a workflow always requires one.
- When delegating, define the outcome, scope, inputs, side-effect boundaries,
  acceptance checks, and expected evidence. Verify completion against the
  resulting artifacts and focused checks, not the report alone. When rework is
  needed, return the concrete failed evidence and keep the request bounded.
- Match test and review depth to realistic regression risk.
- Retry only when the failure is transient and the next attempt changes the
  conditions.
- Use concise, adaptive output. Emit fixed markers only when another process
  consumes them.
- Create specs, tickets, branches, and PRs only when the user explicitly asks
  or invokes the corresponding command.

Exploration may end in an answer, discarded prototype, or local commit. When
it becomes shared or production work, apply the repository's coordination and
release rules at that boundary.
