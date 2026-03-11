/**
 * Returns pagination metadata for a paginated list query result.
 * Used by API endpoints to compute next/prev page links.
 */
export function getPaginationMeta(
  total: number,
  pageSize: number,
  currentPage: number
) {
  const totalPages = Math.floor(total / pageSize);
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
