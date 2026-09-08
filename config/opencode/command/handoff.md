---
description: Write a compact handoff for a fresh agent session
agent: reporter
---

Write a handoff document for the current conversation, tailored to $ARGUMENTS
when supplied. Save it under the OS temporary directory rather than the current
repository.

Capture the goal, current state, decisions, relevant files and URLs, validation
already performed, unresolved questions, and concrete next actions. Reference
existing specs, issues, ADRs, commits, and diffs instead of duplicating them.
Suggest only capabilities that would materially help the next session, and
redact secrets or sensitive personal data. Return the absolute path.
