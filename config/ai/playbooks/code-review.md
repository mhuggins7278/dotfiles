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

## Two Axes: Standards and Spec

Every finding in this review belongs to one of two axes — tag it in the summary table (see Output
Format) so neither axis can mask the other:

- **Standards** — does the code conform to this repo's documented coding standards (`CODING_STANDARDS.md`,
  `CONTRIBUTING.md`, or equivalent, if present), plus the smell baseline below? **[GLG only]**: also
  treat `~/.dotfiles/config/opencode/references/glg-workflow.md` and the `[GLG only]` sections of this
  playbook as standards sources.
- **Spec** — does the code faithfully implement the originating issue/ticket/PRD? Identify the spec
  source, in order: issue references in commit messages or the PR body (`#123`, `Closes #45`), a path
  the user passed as an argument, or a spec produced by `to-spec`. If no spec can be found, skip this
  axis and note "no spec available" — do not fail the review over it.

A change can pass one axis and fail the other — code that follows every standard but implements the
wrong thing is a Standards pass / Spec fail, and vice versa. Report both; don't let one rerank the other.

### Code Smell Baseline (Standards axis)

On top of whatever the repo documents, the Standards axis always carries this fixed set of Fowler code
smells (*Refactoring*, ch. 3) — even when a repo documents nothing. Two rules bind it: **the repo
overrides** (a documented repo standard always wins; where it endorses something the baseline would
flag, suppress the smell), and it's **always a judgement call** (a labelled heuristic, never a hard
violation) — skip anything tooling already enforces.

- **Mysterious Name** — a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code** — the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy** — a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same few fields or params keep travelling together. → bundle them into one type, pass that.
- **Primitive Obsession** — a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches** — the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery** — one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change** — one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality** — abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains** — long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man** — a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest** — a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### Spec Fidelity Checklist (Spec axis)

When a spec source is available, check for:

- Requirements the spec asked for that are missing or partial
- Behaviour in the diff that wasn't asked for (scope creep)
- Requirements that look implemented but where the implementation looks wrong

Quote the spec line for each finding.

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

6. **Report findings** — provide a clear, prioritized list of issues, each tagged with its axis
   (Standards or Spec — see Two Axes above), or confirm the changes look good. Skip any issue already
   covered by an existing comment.

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
- Run the **Code Smell Baseline** (see Two Axes above) against every changed hunk.

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

### Spec Fidelity
- Run the **Spec Fidelity Checklist** (see Two Axes above) whenever a spec source was found.

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
| # | Axis | Severity | File | Issue |
|---|------|----------|------|-------|
| 1 | Standards | Blocker  | `path/to/file.ts:42` | One-line description |
| 2 | Spec      | Warning  | `path/to/file.ts:67` | One-line description |
```
If no issues: **No issues found.** Then describe what was reviewed and why it looks solid. If no spec
source was found, note "Spec: no spec available" once instead of leaving the axis silently unchecked.

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
### 1. [Standards / Blocker] Brief title
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

## Post-Review Actions

### No open PR (pre-commit / implementation review)

Do **not** attempt to post anything to GitHub. Present the findings and stop.

### Open PR exists (PR review)

**Never post a review to GitHub without explicit user confirmation.**

After presenting findings, ask: *"Shall I post this review to the pull request on GitHub?"* and
**wait for an explicit yes before doing anything**. Do not post automatically, do not offer to post
inline unless asked, do not interpret silence or "looks good" as confirmation.

Only after the user explicitly confirms: post all inline comments in a single API call using
`REQUEST_CHANGES` for any Blocker, Critical, or Warning. If there are only suggestions or no issues found, use `APPROVE`.
Write inline comments as direct technical observations — state what's wrong, why it matters, and
how to fix it. Use GitHub suggestion syntax (` ```suggestion `) for mechanical fixes so the author
can apply them with one click.

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
