# TaskNotes API Reference

Complete API documentation for the TaskNotes Obsidian plugin HTTP API (v4.3.0).

## Base URL

```
http://127.0.0.1:8080/api
```

## Authentication

Optional Bearer token. If `apiAuthToken` is configured in plugin settings:

```
Authorization: Bearer <token>
```

Currently no auth token is set — all requests are unauthenticated.

## Response Envelope

All responses use a standard JSON envelope:

```json
{"success": true, "data": {...}}
{"success": false, "error": "error message"}
```

## Task Object Shape

```json
{
  "id": "TaskNotes/Tasks/my-task.md",
  "path": "TaskNotes/Tasks/my-task.md",
  "title": "My Task Title",
  "status": "open",
  "priority": "normal",
  "archived": false,
  "tags": ["task"],
  "contexts": [],
  "projects": ["[[MyGLG]]"],
  "due": "2026-02-15",
  "scheduled": "2026-02-10",
  "completedDate": null,
  "dateCreated": "2026-02-10T10:00:00.000-05:00",
  "dateModified": "2026-02-11T14:30:00.000-05:00",
  "timeEstimate": 60,
  "recurrence": null,
  "totalTrackedTime": 0,
  "isBlocked": false,
  "isBlocking": false,
  "blocking": [],
  "blockedBy": [],
  "details": "Note body content"
}
```

## Configured Values

**Statuses**: `none` (default), `open`, `in-progress`, `done` (completed)
**Priorities**: `none` (weight 0), `low` (1), `normal` (2), `high` (3)

---

## Task CRUD Endpoints

### GET /api/tasks — List tasks

No filtering. Use POST `/api/tasks/query` for filtered queries.

**Query params**: `offset` (int, default 0), `limit` (int, default 50, max 200)

**Rejected params** (returns 400): `status`, `priority`, `project`, `tag`, `overdue`, `completed`, `archived`, `due_before`, `due_after`, `sort`

```bash
curl -s "http://127.0.0.1:8080/api/tasks?offset=0&limit=50" | jq '.data'
```

**Response**:
```json
{
  "tasks": [/* TaskInfo[] */],
  "pagination": {"total": 42, "offset": 0, "limit": 50, "hasMore": false},
  "vault": {"name": "notes", "path": "/Users/MHuggins/github/mhuggins7278/notes"},
  "note": "For filtering and advanced queries, use POST /api/tasks/query"
}
```

### GET /api/tasks/:id — Get single task

Path param is the URL-encoded file path.

```bash
curl -s "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2FMy%20Task.md" | jq '.data'
```

### POST /api/tasks — Create task

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | string | Yes | Task title |
| `status` | string | No | `none`, `open`, `in-progress`, `done` |
| `priority` | string | No | `none`, `low`, `normal`, `high` |
| `due` | string | No | `YYYY-MM-DD` or `YYYY-MM-DDTHH:MM` |
| `scheduled` | string | No | Same format as `due` |
| `tags` | string[] | No | Array of tag strings |
| `contexts` | string[] | No | Array of context strings |
| `projects` | string[] | No | Array of wikilinks: `["[[Project]]"]` |
| `timeEstimate` | number | No | Estimate in minutes |
| `recurrence` | string | No | RRULE string |
| `details` | string | No | Note body content |
| `reminders` | array | No | Reminder objects |

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Review PR for auth changes",
    "status": "open",
    "priority": "high",
    "scheduled": "2026-02-12",
    "projects": ["[[MyGLG]]"]
  }' | jq '.data'
```

### PUT /api/tasks/:id — Update task

Any subset of create fields. Changing `title` may rename the file if `storeTitleInFilename` is enabled.

```bash
curl -s -X PUT "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2Fmy-task.md" \
  -H "Content-Type: application/json" \
  -d '{"status": "done", "priority": "high"}' | jq '.data'
```

### DELETE /api/tasks/:id — Delete task

```bash
curl -s -X DELETE "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2Fmy-task.md" | jq '.data'
```

### POST /api/tasks/:id/toggle-status — Toggle completion

Toggles between default status and completed status.

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2Fmy-task.md/toggle-status" | jq '.data'
```

### POST /api/tasks/:id/archive — Toggle archive

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2Fmy-task.md/archive" | jq '.data'
```

### POST /api/tasks/:id/complete-instance — Complete recurring instance

For recurring tasks only. Marks one instance complete.

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2Fmy-task.md/complete-instance" \
  -H "Content-Type: application/json" \
  -d '{"date": "2026-02-12"}' | jq '.data'
```

---

## Query Endpoint

### POST /api/tasks/query — Advanced filtered queries

The body is a **FilterNode** — either a `condition` or `group`. The `id` field is **required** on every node or the query silently returns 0 results.

#### Condition Node

```json
{
  "id": "unique-string",
  "type": "condition",
  "property": "status",
  "operator": "is",
  "value": "open"
}
```

#### Group Node (AND/OR)

```json
{
  "id": "root",
  "type": "group",
  "conjunction": "and",
  "children": [
    {"id": "c1", "type": "condition", "property": "status", "operator": "is", "value": "open"},
    {"id": "c2", "type": "condition", "property": "priority", "operator": "is", "value": "high"}
  ],
  "sortKey": "scheduled",
  "sortDirection": "asc",
  "groupKey": "status"
}
```

**Sort/group options** (on root node only):
- `sortKey`: any property name (default: `due`)
- `sortDirection`: `asc` or `desc`
- `groupKey`: group results by property (default: `none`)

#### Filterable Properties and Operators

| Property | Type | Operators |
|----------|------|-----------|
| `title` | text | `is`, `is-not`, `contains`, `does-not-contain`, `is-empty`, `is-not-empty` |
| `path` | text | `contains`, `does-not-contain`, `is-empty`, `is-not-empty` |
| `status` | enum | `is`, `is-not`, `is-empty`, `is-not-empty` |
| `priority` | enum | `is`, `is-not`, `is-empty`, `is-not-empty` |
| `tags` | array | `contains`, `does-not-contain`, `is-empty`, `is-not-empty` |
| `contexts` | array | `contains`, `does-not-contain`, `is-empty`, `is-not-empty` |
| `projects` | array | `contains`, `does-not-contain`, `is-empty`, `is-not-empty` |
| `blockedBy` | array | `contains`, `does-not-contain`, `is-empty`, `is-not-empty` |
| `blocking` | array | `contains`, `does-not-contain`, `is-empty`, `is-not-empty` |
| `due` | date | `is`, `is-not`, `is-before`, `is-after`, `is-on-or-before`, `is-on-or-after`, `is-empty`, `is-not-empty` |
| `scheduled` | date | same as `due` |
| `completedDate` | date | same as `due` |
| `dateCreated` | date | same as `due` |
| `dateModified` | date | same as `due` |
| `archived` | boolean | `is-checked`, `is-not-checked` |
| `user:*` | varies | Custom user-defined fields |

#### Response

```json
{
  "tasks": [/* filtered TaskInfo[] */],
  "total": 42,
  "filtered": 6,
  "vault": {"name": "notes", "path": "..."}
}
```

---

## Metadata Endpoints

### GET /api/health — Health check

```bash
curl -s "http://127.0.0.1:8080/api/health" | jq '.data'
# {status: "ok", timestamp: "...", vault: {name, path}}
```

### GET /api/stats — Task statistics

```bash
curl -s "http://127.0.0.1:8080/api/stats" | jq '.data'
# {total, completed, active, overdue, archived, withTimeTracking}
```

### GET /api/filter-options — Available filter values

```bash
curl -s "http://127.0.0.1:8080/api/filter-options" | jq '.data'
# {statuses[], priorities[], contexts[], projects[], tags[], folders[], userProperties[]}
```

### GET /api/docs — OpenAPI spec (JSON)

### GET /api/docs/ui — Swagger UI (browser)

---

## NLP Endpoints

### POST /api/nlp/parse — Parse natural language (dry run)

```bash
curl -s -X POST "http://127.0.0.1:8080/api/nlp/parse" \
  -H "Content-Type: application/json" \
  -d '{"text": "Review PR tomorrow high priority #code-review"}' | jq '.data'
```

Extracts: dates ("tomorrow", "next Monday"), priority ("high priority"), tags (#tag), contexts (@context), projects ([[Project]]).

### POST /api/nlp/create — Parse and create task

Same body as `/api/nlp/parse` but creates the task. Returns `{task, parsed}`.

---

## Time Tracking Endpoints

### POST /api/tasks/:id/time/start — Start tracking

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2Fmy-task.md/time/start" | jq '.data'
```

### POST /api/tasks/:id/time/stop — Stop tracking

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2Fmy-task.md/time/stop" | jq '.data'
```

### POST /api/tasks/:id/time/start-with-description — Start with description

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks/TaskNotes%2FTasks%2Fmy-task.md/time/start-with-description" \
  -H "Content-Type: application/json" \
  -d '{"description": "Working on implementation"}' | jq '.data'
```

### GET /api/tasks/:id/time — Get task time data

Returns `{task, summary, activeSession, timeEntries}`.

### GET /api/time/active — All active time sessions

Returns `{activeSessions[], totalActiveSessions, totalElapsedMinutes}`.

### GET /api/time/summary — Time tracking summary

**Query params**: `period` (`today`|`week`|`month`|`all`), or `from`/`to` for custom range.

```bash
curl -s "http://127.0.0.1:8080/api/time/summary?period=week" | jq '.data'
# {period, dateRange, summary, topTasks, topProjects, topTags}
```

---

## Pomodoro Endpoints

### POST /api/pomodoro/start — Start pomodoro

```bash
curl -s -X POST "http://127.0.0.1:8080/api/pomodoro/start" \
  -H "Content-Type: application/json" \
  -d '{"taskId": "TaskNotes/Tasks/my-task.md", "duration": 25}' | jq '.data'
```

Optional: `taskId` (file path), `duration` (1-120 minutes).

### POST /api/pomodoro/stop — Stop pomodoro
### POST /api/pomodoro/pause — Pause pomodoro
### POST /api/pomodoro/resume — Resume pomodoro
### GET /api/pomodoro/status — Current status
### GET /api/pomodoro/sessions — Session history (`?date=YYYY-MM-DD`, `?limit=N`)
### GET /api/pomodoro/stats — Statistics (`?date=YYYY-MM-DD`)

---

## Webhook Endpoints

### POST /api/webhooks — Register webhook

```json
{
  "url": "https://example.com/webhook",
  "events": ["task.created", "task.updated", "task.completed", "task.deleted", "task.archived", "task.unarchived", "time.started", "time.stopped"]
}
```

Optional: `id`, `secret`, `active`, `transformFile`, `corsHeaders`.

### GET /api/webhooks — List webhooks
### DELETE /api/webhooks/:id — Delete webhook
### GET /api/webhooks/deliveries — Delivery history

---

## Calendar Endpoints

### GET /api/calendars — Provider overview
### GET /api/calendars/google — Google calendar details
### GET /api/calendars/microsoft — Microsoft calendar details
### GET /api/calendars/subscriptions — ICS subscriptions
### GET /api/calendars/events — Calendar events (`?start=ISO&end=ISO`)

---

## Common Query Examples

### List open tasks sorted by scheduled date

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks/query" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "root",
    "type": "group",
    "conjunction": "and",
    "children": [
      {"id": "c1", "type": "condition", "property": "status", "operator": "is", "value": "open"}
    ],
    "sortKey": "scheduled",
    "sortDirection": "asc"
  }' | jq '.data.tasks[] | "\(.scheduled)  \(.title)"'
```

### List tasks completed this week

```bash
WEEK_START=$(date -v-monday +%Y-%m-%d 2>/dev/null || date -d "last monday" +%Y-%m-%d)

curl -s -X POST "http://127.0.0.1:8080/api/tasks/query" \
  -H "Content-Type: application/json" \
  -d "{
    \"id\": \"root\",
    \"type\": \"group\",
    \"conjunction\": \"and\",
    \"children\": [
      {\"id\": \"c1\", \"type\": \"condition\", \"property\": \"status\", \"operator\": \"is\", \"value\": \"done\"},
      {\"id\": \"c2\", \"type\": \"condition\", \"property\": \"completedDate\", \"operator\": \"is-on-or-after\", \"value\": \"$WEEK_START\"}
    ],
    \"sortKey\": \"completedDate\",
    \"sortDirection\": \"desc\"
  }" | jq '.data.tasks[] | "\(.completedDate)  \(.title)"'
```

### List tasks for a specific project

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks/query" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "q1",
    "type": "condition",
    "property": "projects",
    "operator": "contains",
    "value": "[[MyGLG]]"
  }' | jq '.data.tasks[] | {title, status, scheduled}'
```

### List overdue tasks

```bash
TODAY=$(date +%Y-%m-%d)

curl -s -X POST "http://127.0.0.1:8080/api/tasks/query" \
  -H "Content-Type: application/json" \
  -d "{
    \"id\": \"root\",
    \"type\": \"group\",
    \"conjunction\": \"and\",
    \"children\": [
      {\"id\": \"c1\", \"type\": \"condition\", \"property\": \"status\", \"operator\": \"is-not\", \"value\": \"done\"},
      {\"id\": \"c2\", \"type\": \"condition\", \"property\": \"due\", \"operator\": \"is-before\", \"value\": \"$TODAY\"}
    ]
  }" | jq '.data.tasks[] | {title, due, status}'
```

### List high priority in-progress tasks

```bash
curl -s -X POST "http://127.0.0.1:8080/api/tasks/query" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "root",
    "type": "group",
    "conjunction": "and",
    "children": [
      {"id": "c1", "type": "condition", "property": "status", "operator": "is", "value": "in-progress"},
      {"id": "c2", "type": "condition", "property": "priority", "operator": "is", "value": "high"}
    ]
  }' | jq '.data.tasks[] | {title, priority}'
```
