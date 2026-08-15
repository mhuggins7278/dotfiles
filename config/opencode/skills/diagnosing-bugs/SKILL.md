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

## Investigate

Form falsifiable hypotheses grounded in the evidence. Rank and share them when
the problem is ambiguous or user context could change the order; do not require
a fixed count or checkpoint for obvious failures.

Prefer targeted inspection and instrumentation that distinguishes hypotheses.
Change one relevant variable at a time. For performance regressions, establish
a baseline and measure rather than relying on broad logging.

## Fix And Verify

Add a regression test first when a meaningful seam exists. Do not add a shallow
or implementation-coupled test solely to satisfy process. Apply the smallest
root-cause fix, rerun the original reproduction, and run proportionate related
checks.

Remove temporary instrumentation and artifacts before reporting completion.
Summarize the cause, evidence, fix, verification, and any residual uncertainty.
Recommend `/architecture-review` afterward only when the investigation exposed
a concrete structural weakness worth addressing separately.
