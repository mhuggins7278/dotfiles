---
name: research
description: Research a multi-source question using high-trust primary sources. Use when the user explicitly asks for research or evidence beyond a focused library-doc lookup.
---

Investigate against primary sources such as official documentation, source
code, specifications, and first-party APIs. Trace important claims to the
source that owns them and distinguish verified facts from inference.

Work inline for focused questions. Delegate only when the reading is
independent, long-running, or usefully parallel. Use the `docs` agent for a
single library's API documentation.

Return a concise cited answer by default. Write a Markdown artifact only when
the user requests one or the findings need to persist across sessions; follow
the repository's existing documentation convention when doing so.
