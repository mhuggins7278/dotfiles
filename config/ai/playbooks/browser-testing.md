# Browser Testing & Automation Methodology

Canonical, tool-agnostic playbook for browser automation, debugging, and testing. Referenced by
`config/opencode/agent/browser.md` and `config/claude/agents/browser.md`.

---

## Core Principle: Snapshots Over Screenshots

Always prefer accessibility tree snapshots over screenshots:
- Snapshots are faster and more reliable
- They expose element refs (UIDs) needed for interactions
- Element UIDs change after DOM mutations — always take a fresh snapshot before interacting
- Screenshots are useful only when visual layout verification is the explicit goal

---

## Interaction Workflow

For any automation task:

1. **Navigate** to the target URL or page
2. **Snapshot** to understand current page structure
3. **Identify** the element ref/UID from the snapshot
4. **Interact** (click, fill, hover, press, drag, select, upload)
5. **Snapshot again** to verify the result after interaction
6. **Repeat** as needed

For multi-field forms, prefer batch fill operations over sequential fills.

---

## Debugging Workflow

1. **Navigate** to the page exhibiting the issue
2. **Monitor console messages** — capture logs, warnings, and errors
3. **Monitor network requests** — look for failed requests, unexpected payloads, timing issues
4. **Snapshot** to understand current DOM state
5. **Execute JavaScript** in page context to inspect runtime state if needed
6. **Correlate** console errors with network failures and DOM state

---

## Performance Analysis Workflow

1. **Navigate** to the page
2. **Start a performance trace** before the interaction you want to measure
3. **Perform the relevant actions**
4. **Stop the trace** and analyze results
5. **Report** Core Web Vitals (LCP, CLS, FID/INP), load metrics, bottlenecks

Key metrics to surface:
- LCP (Largest Contentful Paint) — target < 2.5s
- CLS (Cumulative Layout Shift) — target < 0.1
- Total blocking time
- Time to first byte
- Resource load breakdown

---

## Accessibility Testing Workflow

1. Navigate and snapshot
2. Verify semantic HTML structure (heading hierarchy, landmark roles)
3. Check ARIA labels and roles on interactive elements
4. Test keyboard navigation (Tab order, Enter/Space for buttons, Escape for modals)
5. Verify focus indicators are visible
6. Check color contrast (visual only — use screenshot if needed)

---

## Network Emulation

Use network throttling for realistic condition testing:
- Slow 3G: tests critical user journeys on poor connections
- Fast 4G: typical mobile experience
- Offline: tests PWA/offline behavior

Use CPU throttling to simulate slower devices.

---

## Multi-tab Handling

When testing flows that open new tabs:
1. List all open tabs to get their IDs
2. Select the relevant tab before interacting
3. Close tabs when done with them

---

## Communication Style

- Report test results with pass/fail status and relevant detail
- Format network request logs in a readable structure (method, URL, status, timing)
- Highlight errors, warnings, and performance regressions
- Provide specific, actionable recommendations when issues are found
- Suggest follow-up test scenarios if gaps are identified
