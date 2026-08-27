---
name: diagnosing-bugs
description: Diagnose hard, ambiguous, intermittent, or performance-related bugs. Use when a symptom resists ordinary reproduction, needs a tight feedback loop, or requires root-cause investigation. Use observe-glg when the evidence is production GDS logs, and prototype when the question is design or state uncertainty.
---

# Diagnosing Bugs

Build the smallest reliable feedback loop available, then use evidence to find
and fix the root cause. Match the process to the bug rather than forcing every
case through the same phases.

## Establish the Signal

Reproduce the reported symptom with the fastest meaningful signal: an existing
test, focused command, request, browser interaction, trace, log query, or small
harness. Confirm that it exercises the user's actual failure.

Use a direct compiler error, failing test, or deterministic reproduction as-is
when it is already sufficient. Tighten or minimize the reproduction only when
doing so reduces ambiguity or iteration time.

If the environment cannot reproduce the issue, inspect available code and
evidence, state the uncertainty, and identify the highest-value missing
artifact. Ask for access, logs, traces, or temporary instrumentation only when
that missing evidence genuinely blocks progress.

Redact credentials, tokens, customer data, and unnecessary personal
information from captured requests, logs, fixtures, and reports.

## Build A Tight Loop

For hard or ambiguous bugs, treat the feedback loop as the primary work. The
loop should go red on the user's exact symptom and green after the fix. Use the
cheapest meaningful form available:

- A failing test at a seam that reaches the bug
- A focused CLI invocation, HTTP request, or browser interaction
- A replay of a captured trace, event, or fixture
- A small throwaway harness or property loop when the existing system is too
  large or nondeterministic

The loop is ready when it drives the actual bug path, asserts the specific
symptom, has gone red at least once, and is fast enough to run repeatedly. A
direct compiler error, failing test, or deterministic reproduction already
meets this bar; do not build a second harness just to satisfy the process.

For intermittent bugs, increase the reproduction rate with repetition, stress,
or controlled timing until the failure is practical to investigate. The goal is
not perfect determinism, but a signal strong enough to distinguish hypotheses.

## Minimize

Once the loop is red, remove one input, caller, configuration value, data item,
or step at a time. Rerun after each removal and keep only what is load-bearing
for the failure. Stop when removing any remaining element makes the loop green.

## Investigate

Form falsifiable hypotheses grounded in the evidence. Rank and share them when
the problem is ambiguous or user context could change the order; do not require
a fixed count or checkpoint for obvious failures.

For ambiguous cases, prefer three to five ranked hypotheses. State the
prediction for each one, such as what change would make the failure disappear or
worsen. Discard explanations that cannot make a falsifiable prediction.

Prefer targeted inspection and instrumentation that distinguishes hypotheses.
Change one relevant variable at a time. For performance regressions, establish
a baseline and measure rather than relying on broad logging.

Tag temporary debug output with a unique prefix so it can be found and removed
reliably. Keep each probe tied to a hypothesis rather than logging broadly.

## Fix And Verify

Add a regression test first when a meaningful seam exists. Do not add a shallow
or implementation-coupled test solely to satisfy process. Apply the smallest
root-cause fix, rerun the original reproduction, and run proportionate related
checks.

Remove temporary instrumentation and artifacts before reporting completion.
Rerun the original feedback loop and confirm that it no longer reproduces the
symptom. Summarize the cause, evidence, fix, verification, and any residual
uncertainty.
Recommend `/architecture-review` afterward only when the investigation exposed
a concrete structural weakness worth addressing separately.
