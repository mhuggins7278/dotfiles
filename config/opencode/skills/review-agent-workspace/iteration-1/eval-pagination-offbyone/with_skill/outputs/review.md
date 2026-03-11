# Code Review: pagination.ts

## Summary

The pagination utility has a critical logic error in how it calculates the total number of pages, leading to an off-by-one bug where the last page of results is cut off. There are also several missing boundary checks that could cause edge cases if invalid query parameters are passed.

## Issues Found

### [Critical] Incorrect total pages calculation
**Line:** 10
**Problem:** `totalPages` is calculated using `Math.floor(total / pageSize)` instead of `Math.ceil(total / pageSize)`.
**Risk:** If the total number of items is not perfectly divisible by the page size, the last page of results will be completely ignored and unreachable. For example, if `total = 11` and `pageSize = 10`, `totalPages` will be evaluated as `1`, making the 11th item inaccessible since `hasNextPage` will return false on page 1.
**Fix:** Change `Math.floor` to `Math.ceil(total / pageSize)`.

### [Warning] Division by zero vulnerability
**Line:** 10
**Problem:** There is no check to ensure `pageSize` is greater than 0 before performing the division `total / pageSize`.
**Risk:** If `pageSize` is passed as 0 (e.g., from an unvalidated API query parameter), the calculation will result in `Infinity`, corrupting the pagination metadata and potentially crashing consumers relying on this data.
**Fix:** Validate that `pageSize` is greater than 0 (e.g., `const safePageSize = Math.max(1, pageSize);`), or throw an explicit `Error` if `pageSize <= 0`.

### [Warning] Missing validation for negative or zero page numbers
**Line:** 8
**Problem:** There are no boundary checks on `currentPage`.
**Risk:** If a user requests `currentPage = 0` or negative numbers, the API will likely return invalid bounds, but `hasPrevPage` and `hasNextPage` logic will break. E.g., `currentPage = -5` could result in `hasNextPage = true` and `hasPrevPage = false`, which is mathematically accurate based on the code but semantically meaningless.
**Fix:** Clamp the `currentPage` between 1 and `totalPages` (e.g., `const safeCurrentPage = Math.max(1, currentPage)`) or throw an error for invalid page numbers.
