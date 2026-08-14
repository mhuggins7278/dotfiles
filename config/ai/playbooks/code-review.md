# Code Review Methodology

This is the canonical, tool-agnostic code review playbook. The OpenCode agent
adapter mirrors this contract in `config/opencode/agent/review.md`.

## Purpose

Review the current diff and changed files for concrete, actionable defects.
The primary responsibility is caller safety, not a broad architecture, style,
or code-smell audit.

## Review Process

1. Inspect the local and staged diff as applicable, or the PR diff for an
   explicit PR review. List every changed file.
2. Read the relevant changed functions, module state, exports, types, and
   interfaces in those files.
3. For every changed function, exported symbol, changed type, or changed
   interface, find all repository callers and consumers.
4. Inspect caller assumptions about arguments, return values, errors, async
   behavior, and edge-case inputs.
5. Follow callees or adjacent paths only when needed to establish the changed
   contract or explain a concrete risk.
6. Read directly related tests and report missing coverage only when it exposes
   a realistic regression risk.
7. Check changed files for no merge-conflict markers and no `console.log` in
   changed production JavaScript or TypeScript files. Test, spec, and story
   paths are exempt. These are hygiene signals, not a complete quality verdict.
8. Report concrete findings or clearly approve the change.

Inspect every caller when feasible. If there are too many references, inspect
the highest-risk callers first and state the sampling boundary. Do not invent
findings to fill categories, and do not recursively inspect unrelated code.

## Context

Determine whether the repository owner is `glg`. Apply GLG checks only when the
owner is `glg` and the changed code makes them relevant. For an explicit PR
review, read prior reviews and inline comments to avoid duplicate findings. For
a local pre-commit review, skip GitHub lookups other than the owner check.

When an issue, PRD, or other specification is supplied, check the changed
behavior against it. Otherwise note `Spec: not supplied` and do not search
broadly for a specification.

Prefer local file tools. Use GitHub API content calls only for repositories or
files unavailable locally. Never modify local git state.

## GLG Checks

When relevant, verify that application code does not reimplement GDS services:
user authentication, authorization, CORS, rate limiting, TLS termination, or
access logging. GDS-injected environment variables are the correct place for
secrets and must not be flagged. Never accept user identity from request bodies,
query parameters, or unvalidated headers.

Third-party webhooks must validate provider signatures in application code.
Missing webhook signature validation is a Blocker.

For Node.js services, flag blocking file or database I/O, missing `await` on
required I/O, and healthcheck paths that can block or hang. Check clustering
only when the deployment architecture explicitly requires it.

When changed code touches logging, check for sensitive values, noisy health or
access logs, and logs without actionable context. When a Dockerfile changes,
check only relevant runtime, privilege, secret, and build-artifact concerns. For
GLG Dockerfiles, do not flag a missing `HEALTHCHECK`; ECS healthchecking is an
SRE responsibility.

## Findings

Order findings by severity. Each finding must include a `file:line` reference,
the broken assumption, the impact, and a concise fix direction.

- **Blocker**: broken normal-operation behavior, security vulnerability, data
  loss, or crash.
- **Critical**: realistic behavior or security/data-contract failure that
  should be fixed before merging.
- **Warning**: meaningful edge-case failure or regression risk.
- **Suggestion**: low-risk improvement that prevents a concrete problem.

Use a compact report:

```text
## Findings

### 1. [Critical] Short title
**File:** `path/to/file.ts:42`
**Problem:** What changed and which caller or runtime assumption it breaks.
**Impact:** What happens if it remains.
**Fix:** Concise correction or direction.

## Coverage

Files: `...`; callers: `...`; tests: `...`; unverified: `...`; Spec: supplied or not supplied.
```

If no issue exists, say `No issues found.` Keep coverage concise and omit empty
category reports.

For an explicit PR review, ask whether the user wants the review posted after
presenting the findings. Wait for an explicit yes and never post automatically.

Always end with:

```text
REVIEW_VERDICT: <APPROVED|NEEDS_WORK>
BLOCKER_COUNT: <n>
CRITICAL_COUNT: <n>
WARNING_COUNT: <n>
SUGGESTION_COUNT: <n>
```

`APPROVED` means zero Blocker and Critical issues. `NEEDS_WORK` means one or
more Blocker or Critical issues remain.
