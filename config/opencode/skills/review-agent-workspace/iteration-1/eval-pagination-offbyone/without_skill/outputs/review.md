# Code Review: `pagination.ts`

## Summary

The function has two bugs and two quality concerns. The most critical is an off-by-one error in `totalPages` that causes the last page to be unreachable when the total record count is exactly divisible by `pageSize`. A second off-by-one error in `hasNextPage` flows directly from the first. There is also no input validation, which allows division by zero and negative inputs to produce nonsensical results silently.

---

## Issues

### Bug 1 — Off-by-one in `totalPages` (Line 10)

**Code:**
```ts
const totalPages = Math.floor(total / pageSize);
```

**Consequence:**
When `total` is exactly divisible by `pageSize`, the result is already a whole number, so `Math.floor` is a no-op — but the real problem is that `Math.floor` is the wrong operation here. The correct formula for the number of pages is `Math.ceil`, not `Math.floor`.

Example: `total = 30`, `pageSize = 10` → `Math.floor(30 / 10) = 3` (correct by accident).
Example: `total = 31`, `pageSize = 10` → `Math.floor(31 / 10) = 3` (wrong — there are 4 pages; items 31 is on page 4 and is unreachable).
Example: `total = 9`, `pageSize = 10` → `Math.floor(9 / 10) = 0` (wrong — there is 1 page).

**Fix:**
```ts
const totalPages = Math.ceil(total / pageSize);
```

---

### Bug 2 — `hasNextPage` is wrong when `total` is not divisible by `pageSize` (Line 11)

**Code:**
```ts
const hasNextPage = currentPage < totalPages;
```

**Consequence:**
This comparison is correct in intent, but because `totalPages` is computed with `Math.floor` (Bug 1), `hasNextPage` inherits the same off-by-one error. When the last page is the undercounted page (e.g., page 4 in the `total=31` example above), `hasNextPage` will return `true` on page 3 (correct) but `totalPages` itself is 3, so navigating to page 4 is considered out-of-range — a page that exists but can never be linked to.

Once Bug 1 is fixed with `Math.ceil`, this line is correct as-is and requires no further change.

---

### Bug 3 — No guard against `pageSize = 0` (Line 7 / 10)

**Code:**
```ts
const totalPages = Math.ceil(total / pageSize);
```

**Consequence:**
If `pageSize` is `0`, this produces `Infinity` (in JavaScript, `n / 0 === Infinity`). Every downstream consumer of `totalPages` or `hasNextPage` will receive `Infinity`, which is a silent data corruption — no exception is thrown, so callers won't know something went wrong. API responses will serialize `Infinity` as `null` in JSON, making the bug even harder to trace.

**Fix:**
Add an early guard:
```ts
if (pageSize <= 0) {
  throw new RangeError("pageSize must be a positive integer");
}
```

---

### Quality Issue — No validation for negative or zero inputs (Lines 6–8)

**Consequence:**
Negative values for `total` or `currentPage` produce mathematically valid but logically nonsensical results (e.g., negative `totalPages`, `hasPrevPage = true` when `currentPage = -5`). These won't crash but will corrupt API responses.

**Fix:**
```ts
if (total < 0) throw new RangeError("total must be >= 0");
if (currentPage < 1) throw new RangeError("currentPage must be >= 1");
```

---

### Quality Issue — Missing return type annotation (Line 5)

**Consequence:**
TypeScript will infer the return type, but without an explicit annotation the shape of the return value is not part of the public contract. Callers can't rely on a stable, named type, and refactors can silently change the inferred shape.

**Fix:**
Define and export an interface, then annotate the return type:
```ts
export interface PaginationMeta {
  total: number;
  pageSize: number;
  currentPage: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPrevPage: boolean;
}

export function getPaginationMeta(
  total: number,
  pageSize: number,
  currentPage: number
): PaginationMeta {
```

---

## Corrected Implementation

```ts
export interface PaginationMeta {
  total: number;
  pageSize: number;
  currentPage: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPrevPage: boolean;
}

/**
 * Returns pagination metadata for a paginated list query result.
 * Used by API endpoints to compute next/prev page links.
 */
export function getPaginationMeta(
  total: number,
  pageSize: number,
  currentPage: number
): PaginationMeta {
  if (total < 0) throw new RangeError("total must be >= 0");
  if (pageSize <= 0) throw new RangeError("pageSize must be a positive integer");
  if (currentPage < 1) throw new RangeError("currentPage must be >= 1");

  const totalPages = Math.ceil(total / pageSize);
  const hasNextPage = currentPage < totalPages;
  const hasPrevPage = currentPage > 1;

  return {
    total,
    pageSize,
    currentPage,
    totalPages,
    hasNextPage,
    hasPrevPage,
  };
}
```
