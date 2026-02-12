---
name: tasknotes
description: Create, update, delete, query, and manage tasks via the TaskNotes Obsidian plugin HTTP API. USE for any task CRUD, status changes, or task queries; never edit TaskNotes files directly.
---

# TaskNotes Skill

Manage tasks via the TaskNotes Obsidian plugin HTTP API. Never edit `TaskNotes/Tasks/` files directly.

## When to Use

- Create, update, complete, or delete a task
- Query tasks by status, priority, project, date, or any field
- Get task statistics or filter options
- Create tasks from natural language
- User says "add a task", "list my tasks", "mark done", "what's open", etc.

## API Endpoint

```
http://127.0.0.1:8080/api
```

No authentication required. All responses use envelope: `{"success": bool, "data": {...}}`.

## Configuration

**Statuses**: `none`, `open`, `in-progress`, `done`
**Priorities**: `none`, `low`, `normal`, `high`
**Task folder**: `TaskNotes/Tasks`
**Vault**: `~/github/mhuggins7278/notes`

## Safety Checks

- Always use the API, never edit task files directly
- Verify API is running: `curl -s http://127.0.0.1:8080/api/health | jq .`
- Task IDs are file paths (e.g., `TaskNotes/Tasks/my-task.md`) — always URL-encode them
- GET `/api/tasks` does NOT support query param filters — use POST `/api/tasks/query` instead

## Quick Reference

### Health Check

```bash
curl -s "http://127.0.0.1:8080/api/health" | jq .
```

### Stats Overview

```bash
curl -s "http://127.0.0.1:8080/api/stats" | jq .
# Returns: {total, completed, active, overdue, archived, withTimeTracking}
```

### List All Tasks

```bash
curl -s "http://127.0.0.1:8080/api/tasks" | jq '.data.tasks[] | {title, status, priority, scheduled}'
```

Supports pagination: `?offset=0&limit=50` (max 200).

### Get Single Task

```bash
TASK_PATH="TaskNotes/Tasks/my-task.md"
curl -s "http://127.0.0.1:8080/api/tasks/$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TASK_PATH', safe=''))")" | jq '.data'
```

### Create Task

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Task title",
    "status": "open",
    "priority": "normal",
    "projects": ["[[Project Name]]"],
    "scheduled": "2026-02-15"
  }' | jq '.data'
```

**Fields**: `title` (required), `status`, `priority`, `due`, `scheduled`, `tags`, `contexts`, `projects`, `timeEstimate`, `recurrence`, `details`

### Create Task from Natural Language

```bash
curl -s -X POST "http://127.0.0.1:8080/api/nlp/create" \
  -H "Content-Type: application/json" \
  -d '{"text": "Review PR for auth changes tomorrow high priority #code-review"}' | jq '.data'
```

NLP extracts: dates, priority, tags (#), contexts (@), projects ([[...]]).
Use `/api/nlp/parse` for dry-run (no task created).

### Update Task

```bash
TASK_PATH="TaskNotes/Tasks/my-task.md"
curl -s -X PUT "http://127.0.0.1:8080/api/tasks/$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TASK_PATH', safe=''))")" \
  -H "Content-Type: application/json" \
  -d '{"status": "done"}' | jq '.data'
```

Any subset of create fields can be updated. Changing `title` may rename the file.

### Complete a Task

```bash
TASK_PATH="TaskNotes/Tasks/my-task.md"
curl -s -X PUT "http://127.0.0.1:8080/api/tasks/$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TASK_PATH', safe=''))")" \
  -H "Content-Type: application/json" \
  -d '{"status": "done"}' | jq '.data'
```

Or use toggle: `POST /api/tasks/:id/toggle-status`

### Delete Task

```bash
TASK_PATH="TaskNotes/Tasks/my-task.md"
curl -s -X DELETE "http://127.0.0.1:8080/api/tasks/$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TASK_PATH', safe=''))")" | jq '.data'
```

### Query Tasks (Filtered)

GET `/api/tasks` does NOT support filters. Use POST `/api/tasks/query` with a FilterNode body.

**Simple condition** (single filter):

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks/query" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "q1",
    "type": "condition",
    "property": "status",
    "operator": "is",
    "value": "open"
  }' | jq '.data.tasks[] | {title, status, scheduled}'
```

**Group query** (multiple filters with AND/OR, sorting):

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks/query" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "root",
    "type": "group",
    "conjunction": "and",
    "children": [
      {"id": "c1", "type": "condition", "property": "status", "operator": "is", "value": "open"},
      {"id": "c2", "type": "condition", "property": "priority", "operator": "is", "value": "high"}
    ],
    "sortKey": "scheduled",
    "sortDirection": "asc"
  }' | jq '.data.tasks[] | {title, priority, scheduled}'
```

**IMPORTANT**: The `id` field is required on every node (condition or group) or the query silently returns 0 results.

**FilterNode operators by property type**:

| Type | Properties | Operators |
|------|-----------|-----------|
| Text | `title`, `path` | `is`, `is-not`, `contains`, `does-not-contain`, `is-empty`, `is-not-empty` |
| Enum | `status`, `priority` | `is`, `is-not`, `is-empty`, `is-not-empty` |
| Array | `tags`, `contexts`, `projects` | `contains`, `does-not-contain`, `is-empty`, `is-not-empty` |
| Date | `due`, `scheduled`, `completedDate`, `dateCreated`, `dateModified` | `is`, `is-not`, `is-before`, `is-after`, `is-on-or-before`, `is-on-or-after`, `is-empty`, `is-not-empty` |
| Boolean | `archived` | `is-checked`, `is-not-checked` |

### Get Filter Options

```bash
curl -s "http://127.0.0.1:8080/api/filter-options" | jq '.data'
# Returns: {statuses, priorities, contexts, projects, tags, folders, userProperties}
```

## Extended API

For time tracking, pomodoro, webhooks, calendar integration, and the full OpenAPI spec, see:

- **[references/API.md](references/API.md)** — Complete API reference with all endpoints

### Quick Endpoint Summary

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/health` | GET | Health check |
| `/api/stats` | GET | Task statistics |
| `/api/tasks` | GET | List all tasks (paginated) |
| `/api/tasks/:id` | GET | Get single task |
| `/api/tasks` | POST | Create task |
| `/api/tasks/:id` | PUT | Update task |
| `/api/tasks/:id` | DELETE | Delete task |
| `/api/tasks/query` | POST | Query with FilterNode |
| `/api/tasks/:id/toggle-status` | POST | Toggle status |
| `/api/tasks/:id/archive` | POST | Toggle archive |
| `/api/filter-options` | GET | Available filter values |
| `/api/nlp/parse` | POST | Parse NL (dry run) |
| `/api/nlp/create` | POST | Parse NL + create task |
| `/api/tasks/:id/time/start` | POST | Start time tracking |
| `/api/tasks/:id/time/stop` | POST | Stop time tracking |
| `/api/time/active` | GET | Active time sessions |
| `/api/time/summary` | GET | Time summary |
| `/api/docs/ui` | GET | Swagger UI (browser) |

## Common Pitfalls

- **Missing `id` on FilterNode**: Query returns 0 results with no error
- **Using query params on GET /api/tasks**: Returns 400 — use POST `/api/tasks/query`
- **Path not URL-encoded**: `/` -> `%2F`, space -> `%20`
- **Wrong endpoint for filter options**: Use `/api/filter-options` (not `/api/options`)
- **Editing files directly**: Always use the API
