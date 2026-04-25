# Documentation Research Methodology

Canonical, tool-agnostic playbook for library documentation research. Referenced by
`config/opencode/agent/docs.md` and `config/claude/agents/docs.md`.

---

## Process

### 1. Resolve the Library ID
Before fetching documentation, always resolve the library name to the tool's internal identifier.

- Analyze the query to identify what library or framework is needed
- Select the most relevant match based on name, description, and trust score
- Prefer libraries with trust scores of 7–10 (authoritative, well-maintained sources)
- For common names with multiple matches (e.g., "react"), use context clues to pick the right one
- For version-specific queries, include the version in the identifier

### 2. Fetch Focused Documentation
Once the library ID is resolved, retrieve documentation with a targeted scope:

- Use a topic/focus parameter when the user asks about a specific feature
  (e.g., `hooks`, `routing`, `authentication`, `migrations`)
- Request more tokens/content for complex architectural queries; fewer for simple lookups
- If the first fetch is too broad, refetch with a narrower topic

### 3. Extract and Present
Transform raw documentation into actionable output:

- Start with the resolved library ID and version
- Present the most relevant sections — not everything
- Extract code examples when they illustrate the point
- Highlight key APIs, methods, and patterns
- Summarize complex documentation into actionable insights
- Suggest follow-up queries if the documentation is incomplete or tangentially related

---

## Search Strategies

- **Exact match**: Prioritize exact name matches in resolution
- **Partial match**: Use description relevance for fuzzy queries
- **Framework-specific**: Look for official packages (e.g., `@angular`, `@react`)
- **Topic focus**: Always use topic parameter for specific features or APIs
- **Token optimization**: Calibrate token count to query complexity

---

## Common Patterns

| User says... | Action |
|---|---|
| "How do I use React hooks?" | Resolve `react`, fetch with topic `hooks` |
| "Next.js routing docs" | Resolve `next.js`, fetch with topic `routing` |
| "Express middleware examples" | Resolve `express`, fetch with topic `middleware` |
| "TypeORM migrations" | Resolve `typeorm`, fetch with topic `migrations` |
| "Latest Tailwind utilities" | Resolve `tailwindcss` with latest version |

---

## Communication Style

- Be concise — developers want the answer, not everything the docs contain
- Format code examples with proper syntax highlighting
- Explain what the API does, not just what it is
- Note version-specific behavior when relevant
- Suggest related topics if the initial result is insufficient
