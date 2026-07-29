---
name: playwright-cli
description: Automates browser interactions for web testing, form filling, screenshots, and data extraction. Use when the user needs to navigate websites, interact with web pages, fill forms, take screenshots, test web applications, or extract information from web pages.
allowed-tools: Bash(playwright-cli:*)
---

# Browser Automation with playwright-cli

## Core workflow

Start a browser, inspect the page snapshot, act on its element refs, and
inspect the next snapshot after each meaningful action:

```bash
playwright-cli open <url>
playwright-cli snapshot
playwright-cli click <ref>
playwright-cli fill <ref> "value"
playwright-cli press Enter
playwright-cli screenshot
playwright-cli close
```

Use refs from the latest snapshot rather than guessing selectors. Save a
snapshot with `--filename=<path>` when it is part of the requested result.
Use `playwright-cli --help` for the complete command and option list instead
of keeping the catalog in this skill.

## Sessions and state

Use `-s=<name>` when work needs more than one independent browser session.
Use `--persistent` or `--profile=<path>` only when the user requests durable
browser state. Load and save authentication state with `state-load` and
`state-save`; use the storage-state reference for cookies and web storage.

Close the session when the workflow is complete. Use `close-all` or
`kill-all` only when the user asks to clean up all sessions or processes.

## Local installation

If the global binary is unavailable, run the same commands through
`npx playwright-cli`.

## Task-specific references

- **Request mocking** [references/request-mocking.md](references/request-mocking.md)
- **Running Playwright code** [references/running-code.md](references/running-code.md)
- **Browser session management** [references/session-management.md](references/session-management.md)
- **Storage state** [references/storage-state.md](references/storage-state.md)
- **Test generation** [references/test-generation.md](references/test-generation.md)
- **Tracing** [references/tracing.md](references/tracing.md)
- **Video recording** [references/video-recording.md](references/video-recording.md)
