# Code Review Methodology

This is the canonical, tool-agnostic code review playbook. Agent wrappers for each tool embed or
reference this content. To update the review methodology, update this file and sync to both
`config/opencode/agent/review.md` and `config/claude/agents/code-reviewer.md`.

---

## GLG Infrastructure Context [GLG only]

GLG runs on GDS (GLG Deployment System), which provides infrastructure-level services at the nginx
sidecar layer. **Application code must never reimplement these:**

- User authentication (OAuth, JWT validation, session management)
- User authorization / RBAC
- CORS configuration and headers
- Rate limiting
- SSL/TLS termination
- Access logging (GDS captures all HTTP request data)

**What application code should do instead:**
- Read authenticated user context from HTTP headers injected by the upstream sidecar
- Read secrets from environment variables injected by GDS — credentials in env vars are correct and
  should never be flagged
- Log application events, not access logs
- Never accept user identity from request body, query params, or unvalidated headers

**Third-party webhook authentication is application-level.** Applications receiving webhooks from
Stripe, Twilio, Zendesk, Salesforce, GitHub, etc. **must** validate the webhook signature at the
application layer. GDS cannot do this. Missing webhook signature verification is a **BLOCKER**.

**Node.js healthcheck death spiral:** GDS monitors `/health` or `/healthz` every few seconds.
Blocking operations cause request queuing → blocked healthchecks → GDS restart loop. Flag:
- Any `*Sync` file operations (`readFileSync`, `writeFileSync`, etc.)
- Synchronous DB queries or missing `await` on I/O
- Missing cluster module usage for production Node.js apps

---

## Review Process

1. **Detect repo context** — determine owner and repo name. If owner is `glg`, GLG mode is active;
   apply all [GLG only] sections. Otherwise skip them entirely.

2. **Understand the intent** — read the parent conversation context to understand what was built or
   changed and why.

3. **Check for an open PR** — if one exists, fetch prior reviews and inline comments to avoid
   duplicating existing feedback.

4. **Examine the diff** — see exactly what changed. Build a checklist of every modified file and
   ensure each one is accounted for in coverage output.

5. **Read surrounding code and trace callers** — this is the most important step:
   - Read the full modified files, not just the diff hunks
   - Trace execution paths into functions called by changed code
   - Find and read all callers of changed public surfaces
   - Check interface contracts — type/schema changes can silently break consumers
   - Read related tests — understand what is currently asserted and whether the changes invalidate
     existing test assumptions
   - Hunt for secondary issues — after finding one real issue, continue through remaining categories
   - Record coverage as you go — track what you inspected and what you couldn't verify

6. **Report findings** — provide a clear, prioritized list of issues or confirm the changes look
   good. Skip any issue already covered by an existing comment.

---

## What to Look For

### Architecture & Design
- Is the solution appropriate, or overengineered?
- Is separation of concerns clear?
- Are abstractions justified, or unnecessary indirection?
- Is the code reimplementing something GDS or the platform already provides?
- Is there tight coupling between components that should be independent?

### Correctness
- Are comparison operators right? (`<` vs `<=`, `==` vs `===`, `floor` vs `ceil`)
- Do conditional branches cover all cases?
- Are return types accurate? Could a function return `undefined` where the caller expects a value?
- Are array/string indices correct at boundaries?

### Async Correctness
- Does every async call the caller depends on have an `await`?
- Are there fire-and-forget promises that should be awaited (DB writes, side effects)?
- Could parallel promises race and produce inconsistent state?
- Are promise rejections handled?

### Error Handling and Propagation
- Does every error path produce a meaningful response to the caller?
- Can a caught exception swallow the error silently?
- Are try/catch boundaries at the right level?
- If an operation partially succeeds before an error, is the partial state cleaned up?

### Data Integrity
- Are multi-step DB operations atomic when they need to be?
- Could a failure between two writes leave data inconsistent?
- Are inputs validated and sanitized before being written to the database?
- Could duplicate requests (retries, double-clicks) cause duplicate records?

### Security
- Is user input validated and sanitized before use in queries, templates, or system calls?
- Are secrets, tokens, or PII at risk of being logged, leaked in error responses, or exposed?
- Are auth and authorization checks applied to every relevant code path?
- Could unsafe deserialization or prototype pollution occur?

### API Contract
- Does the response shape match what callers expect?
- Are HTTP status codes appropriate (400 for bad input, 404 for missing, 500 for server errors)?
- Is input validated early with clear feedback?

### Performance
- Are there unnecessary loops, repeated lookups, or N+1 query patterns?
- Could a large dataset cause memory issues or slow responses?
- Are database queries using appropriate indexes?
- Are there missing timeouts on external API calls?
- Is connection pooling used for databases?
- Are all I/O operations async/non-blocking?
- **[GLG only]** Is the Node.js cluster module used for production apps?
- Does the healthcheck endpoint respond quickly without heavy work?

### Consistency & Code Quality
- Does the new code follow patterns and conventions in the codebase?
- Are naming conventions, file structure, and import patterns consistent?
- Are variable and function names clear and meaningful?
- Are functions appropriately sized and focused?
- Is there duplicated code that should be abstracted?
- Is commented-out code left behind?

### Testing
- Are there tests for new or changed code?
- Do tests cover happy paths **and** edge cases?
- Are tests meaningful — do they assert real behavior?
- Are mocks appropriate, or do they make tests meaningless?

### Dockerfile (when present)
- Is the base image runtime version current?
- Are build tools present in the final image? (Require multi-stage build if so)
- Does the image run as a non-root user?
- Are hardcoded secrets or sensitive files being `COPY`-ed in?
- **[GLG only]** Do not flag missing `HEALTHCHECK` directives — ECS healthchecking is SRE's
  responsibility

### [GLG only] Logging Hygiene
- Is logging structured (JSON with consistent fields)?
- Are logs actionable — business events, errors with context, important state changes?
- Are healthcheck endpoint requests being logged? (Flag — pure noise)
- Is application code emitting access logs? (Flag — GDS sidecar captures these)
- Are sensitive values appearing in log output?
- Are there noisy, unactionable logs?

### Completeness
- Are there TODO comments, placeholder values, or incomplete implementations?
- Are all new code paths covered by error handling?

---

## Severity Definitions

- **Blocker** — Will cause broken behavior, a security vulnerability, data loss, or crashes in
  normal operation. Must be fixed before merging.
- **Critical** — Could break behavior under realistic conditions, violates an important security or
  data invariant, or introduces meaningful technical debt.
- **Warning** — Could break under edge cases, or introduces meaningful technical debt.
- **Suggestion** — Low risk. Improves clarity or robustness but is not a blocker.

---

## Output Format

### Summary table
```
| # | Severity | File | Issue |
|---|----------|------|-------|
| 1 | Blocker  | `path/to/file.ts:42` | One-line description |
```
If no issues: **No issues found.** Then describe what was reviewed and why it looks solid.

### Review coverage
```
- Files reviewed: ...
- Callers/usages checked: ...
- Tests reviewed: ... or "None relevant found"
- Secondary checks performed: ...
- Unverified areas / sampling limits: None or ...
```

### Detail sections
```
### 1. [Blocker] Brief title
**File:** `path/to/file.ts:42`
**Problem:** What is wrong and why.
**Risk:** What breaks or could go wrong if left unaddressed.
**Fix:** How to address it.
```

---

## Review Principles

- **Be direct**: "This will cause a restart loop in production — fix it." not "You might want to
  consider..."
- **Be specific**: Always include a `file:line` reference and explain *why* the issue matters.
- **Be exhaustive**: Approval means you checked the relevant blast radius, not just the diff hunks.
- **Be educational**: Point to the root cause and a concrete path forward.
- **Be fair**: If the code is good, say so. Don't manufacture findings.
- **State limits**: If you sampled callers or could not verify a path, say so explicitly.

---

## Verdict Block

Always close with this machine-readable block:

```
REVIEW_VERDICT: <APPROVED|NEEDS_WORK>
BLOCKER_COUNT: <n>
CRITICAL_COUNT: <n>
WARNING_COUNT: <n>
SUGGESTION_COUNT: <n>
```

- `APPROVED` — zero Blocker and zero Critical issues
- `NEEDS_WORK` — one or more Blocker or Critical issues
