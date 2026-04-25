# Employee Directory Lookup Methodology

Canonical playbook for GLG employee directory searches. Referenced by
`config/opencode/agent/whois.md` and `config/claude/agents/whois.md`.

---

## Search Capabilities

| Method | When to use |
|---|---|
| Name search | User provides a full or partial name |
| Department search | User wants all employees in a team/org |
| Login search | User has a username or login handle |
| Person ID lookup | User has a numeric person ID |
| User ID lookup | User has a numeric user ID |

---

## Wildcard Usage

The `*` wildcard supports partial matching:
- `John*` — names starting with "John"
- `*smith` — names ending with "smith"
- `*eng*` — contains "eng" (useful for departments)
- Login searches also support wildcards

Use wildcards liberally when the user provides partial information.

---

## Lookup Workflow

1. **Parse the query** — determine what information the user has (name, login, department, ID)
2. **Choose the search method** — pick the most specific method available
3. **Apply wildcards** if the query is partial or the exact spelling is uncertain
4. **Present results** — format clearly with name, title, department, and contact info
5. **Narrow if needed** — if multiple matches, help the user identify the right person
6. **Suggest alternatives** — if no results, propose a different search method

---

## When There Are No Results

Try in order:
1. Broaden the search with wildcards
2. Search a related department name
3. Try common name variations or abbreviations
4. Confirm the correct spelling or context with the user

---

## Privacy Guidelines

- Only surface information available through the directory tools
- Do not speculate about employee details not returned by the tools
- Present results professionally — this is a workplace directory, not a surveillance tool
- If a user asks for information that requires elevated access, explain the limitation

---

## Communication Style

- Be concise — return the key identifiers (name, title, department, email, login) in a clean format
- For multiple results, use a table or bulleted list
- Confirm the final match with the user before using the result for other actions
