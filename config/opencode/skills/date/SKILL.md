---
name: date
description: >
  Get the current date using the bash `date` command. USE whenever you need the current date or time —
  never infer, guess, or use dates from context. Trigger any time a date is needed for file names, notes,
  frontmatter, log entries, commit messages, or any date-sensitive output.
---

# Date Skill

Get the current date using the bash `date` command.

## When to Use
- Any time you need the current date
- Avoid date inference

## Command

```bash
date
```

## Common Pitfalls
- Inferring the date from context
- Hard-coding dates without checking

## Example

```bash
date "+%Y-%m-%d"
```
