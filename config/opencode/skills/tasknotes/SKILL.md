---
name: tasknotes
description: Create, update, delete, and list TaskNotes tasks via HTTP API. USE for any task CRUD or status changes; never edit TaskNotes files directly.
aliases: []
id: SKILL
tags: []
---

# TaskNotes Skill

CRUD operations on tasks via TaskNotes plugin HTTP API.

## When to Use
- Any time you create, update, complete, or delete a task
- When you need current task status, priority, or metadata
- Never edit `TaskNotes/Tasks/` files directly

## API Endpoint

```
http://127.0.0.1:8080/api
```

## List Tasks

```bash
curl -s "http://127.0.0.1:8080/api/tasks"
curl -s "http://127.0.0.1:8080/api/tasks?status=in-progress"
```

## Create Task

```bash
curl -X POST "http://127.0.0.1:8080/api/tasks" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Task title",
    "status": "open",
    "priority": "high",
    "projects": ["[[Project Name]]"],
    "due": "2026-01-15",
    "scheduled": "2026-01-10"
  }'
```

**Fields:**

| Field     | Values                                      |
| --------- | ------------------------------------------- |
| title     | Task name (required)                        |
| status    | `open`, `in-progress`, `done`               |
| priority  | `none`, `low`, `normal`, `high`             |
| projects  | `["[[Project Name]]"]` - array of wikilinks |
| due       | `YYYY-MM-DD`                                |
| scheduled | `YYYY-MM-DD` or `YYYY-MM-DDTHH:MM:SS`       |

## Update Task

```bash
curl -X PUT "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2Fmy-task.md" \
  -H "Content-Type: application/json" \
  -d '{"status": "done"}'
```

**Note:** Path must be URL-encoded (`/` → `%2F`, space → `%20`). Include the full task path (e.g., `TaskNotes/Tasks/...`).

## Delete Task

```bash
curl -X DELETE "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2Fmy-task.md"
```

## Get Options

```bash
curl -s "http://127.0.0.1:8080/api/options"
```

Returns available statuses, priorities, and projects.

## Common Pitfalls
- Path is missing the `TaskNotes/Tasks/` prefix
- Path is not URL-encoded (spaces and slashes)
- Editing files directly instead of using the API

## Example Workflow

```bash
# Create
curl -X POST "http://127.0.0.1:8080/api/tasks" \
  -H "Content-Type: application/json" \
  -d '{"title": "Review proposal", "status": "open", "projects": ["[[Website Redesign]]"]}'

# Start working
curl -X PUT "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2FReview%20proposal.md" \
  -H "Content-Type: application/json" \
  -d '{"status": "in-progress"}'

# Complete
curl -X PUT "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2FReview%20proposal.md" \
  -H "Content-Type: application/json" \
  -d '{"status": "done"}'
```

## Find Task by Title

```bash
curl -s "http://127.0.0.1:8080/api/tasks" | rg -n "Review proposal"
```
