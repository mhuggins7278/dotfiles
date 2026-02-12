# Zenhub GraphQL API Reference

Complete API documentation for Zenhub GraphQL operations.
Source: https://developers.zenhub.com/graphql-api-docs/getting-started

## Endpoint

```
POST https://api.zenhub.com/public/graphql
```

## Authentication

```bash
curl -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "...", "variables": {...}}'
```

## Helper Function

```bash
zh_graphql() {
  local query="$1"
  local variables="${2:-{}}"
  curl -s -X POST "https://api.zenhub.com/public/graphql" \
    -H "Authorization: Bearer $ZH_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')"
}
```

## Limits

- **Pagination**: Max 100 items per page (`first` or `last` param)
- **Complexity**: Max 200 per query. Each property = 1 point, connections multiply children by `first:` value
- **Processing time**: 90 seconds per minute per API key
- **Concurrent requests**: Max 30 per token

## Queries

### Get Current User (Viewer)

```graphql
query {
  viewer {
    id        # ZenhubUser ID (use for zenhubUserIds)
    name
    githubUser {
      id      # User ID (use for assigneeIds)
      login   # GitHub handle
      name    # Display name
    }
  }
}
```

Note: `viewer` returns a `ZenhubUser`, not `User`. GitHub info is nested under `githubUser`.

### List Workspaces

```graphql
query {
  viewer {
    searchWorkspaces(query: "") {
      nodes {
        id
        name
        description
        zenhubOrganization { id name }
        zenhubRepository { id }
        repositoriesConnection {
          nodes { id name ghId }
        }
      }
    }
  }
}
```

### Get Workspace Info (Pipelines, Repos, Org)

```graphql
query getWorkspaceInfo($workspaceId: ID!) {
  workspace(id: $workspaceId) {
    id
    name
    zenhubOrganization { id name }
    zenhubRepository { id }
    pipelinesConnection(first: 25) {
      nodes { id name }
    }
    repositoriesConnection {
      nodes { id name ghId }
    }
  }
}
```

### List All Issues in Workspace

Returns open AND closed issues. Filter state client-side with jq.

`workspace.issues` only supports these filters: `labels`, `parentIssues`, `issueIssueTypes`, `issueIssueTypeDisposition`, `ignoreWorkspaceLabels`. NO assignee or state filter.

```graphql
query workspaceIssues($workspaceId: ID!) {
  workspace(id: $workspaceId) {
    issues(first: 100) {
      nodes {
        id
        number
        title
        type        # "GithubIssue" or "ZenhubIssue"
        state       # "OPEN" or "CLOSED"
        pullRequest # true/false
        htmlUrl     # empty string for ZenHub-only issues
        closedAt
        repository { name ghId }
        pipelineIssue(workspaceId: $workspaceId) {
          pipeline { id name }
        }
        estimate { value }
        issueType {
          ... on ZenhubIssueType { id name level }
          ... on GithubIssueType { id name level }
        }
        labels(first: 10) {
          nodes { name color }
        }
        assignees(first: 10) {
          nodes {
            ... on User { id login name }
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
```

### Search Issues by Pipeline

Richer filtering than `workspace.issues`. Use this when you need to filter by assignee, label, sprint, or estimate.

```graphql
query searchIssues($pipelineId: ID!, $filters: IssueSearchFiltersInput!) {
  searchIssuesByPipeline(
    pipelineId: $pipelineId
    filters: $filters
    first: 100
  ) {
    nodes {
      id number title type state htmlUrl
      estimate { value }
      assignees(first: 10) {
        nodes { ... on User { name login } }
      }
    }
  }
}
```

**`IssueSearchFiltersInput` fields**:
- `assignees: { in: ["github_login"] }` — filter by GitHub login
- `assigneeIds: { in: ["user_id"] }` — filter by Zenhub user ID
- `labels: { in: ["label_name"] }` — filter by label
- `sprints: { in: ["sprint_id"] }` — filter by sprint
- `estimates: { ... }` — filter by estimate value
- `repositoryIds: [...]` — limit to specific repos
- `displayType` — ENUM filter
- `matchType` — ENUM filter
- `parentIssues` — filter by parent issue
- `issueIssueTypes: { in: ["type_name"] }` — filter by issue type

### Get Single Issue Details

```graphql
query getIssue($repositoryGhId: Int!, $issueNumber: Int!, $workspaceId: ID!) {
  issueByInfo(repositoryGhId: $repositoryGhId, issueNumber: $issueNumber) {
    id number title body type state htmlUrl closedAt
    repository { id name ghId }
    estimate { value }
    pipelineIssue(workspaceId: $workspaceId) {
      pipeline { id name }
      priority { id name color }
    }
    issueType {
      ... on ZenhubIssueType { id name level disposition }
      ... on GithubIssueType { id name level disposition }
    }
    sprints(first: 10) {
      nodes { id name state startOn endOn }
    }
    labels(first: 20) {
      nodes { id name color }
    }
    assignees(first: 10) {
      nodes {
        ... on User { id login name }
      }
    }
  }
}
```

### Get Single Issue by ID

```graphql
query getIssueById($issueId: ID!) {
  node(id: $issueId) {
    ... on Issue {
      id number title body type state htmlUrl
      repository { id name }
      assignees(first: 10) {
        nodes { ... on User { id login name } }
      }
    }
  }
}
```

### Get Entity IDs

**Repository IDs** (for a workspace):
```graphql
query getRepoIds($workspaceId: ID!) {
  workspace(id: $workspaceId) {
    repositoriesConnection {
      nodes { id name ghId }
    }
    zenhubRepository { id }
  }
}
```

**Zenhub Organization ID**:
```graphql
query getZenhubOrgId($workspaceId: ID!) {
  workspace(id: $workspaceId) {
    zenhubOrganization { id name }
  }
}
```

**Issue Type IDs** (for a repository in a workspace):
```graphql
query getIssueTypes($repositoryId: ID!, $workspaceId: ID!) {
  node(id: $repositoryId) {
    ... on Repository {
      assignableIssueTypes(workspaceId: $workspaceId) {
        nodes {
          ... on GithubIssueType { id name level disposition }
          ... on ZenhubIssueType { id name level disposition }
        }
      }
    }
  }
}
```

## Mutations

### Create Issue

Works for both GitHub and Zenhub issues. The `repositoryId` determines the type:
- Use a GitHub repository ID to create a GitHub issue
- Use the workspace's `zenhubRepository.id` to create a Zenhub-only issue

```graphql
mutation createIssue($input: CreateIssueInput!) {
  createIssue(input: $input) {
    issue {
      id number title type
      issueType {
        ... on ZenhubIssueType { name level }
        ... on GithubIssueType { name level }
      }
    }
  }
}
```

**`CreateIssueInput` fields**:
- `repositoryId: ID!` — GitHub repo ID or Zenhub repo ID
- `title: String!`
- `body: String`
- `labels: [String]` — GitHub issues only
- `assignees: [String]` — GitHub issues only (GitHub logins)
- `issueTypeId: ID` — set issue type (Epic, Story, Task, etc.)
- `parentIssueId: ID` — create as sub-issue
- `zenhubAssigneeIds: [ID]` — Zenhub issues only
- `zenhubLabelInfos: [{name, color}]` — Zenhub issues only

Note: For Zenhub issues, use `addZenhubAssigneesToIssues` and `addZenhubLabelsToIssues` mutations after creation.

### Update Issue

```graphql
mutation updateIssue($issueId: ID!, $title: String, $body: String) {
  updateIssue(input: { issueId: $issueId, title: $title, body: $body }) {
    issue { id title body }
  }
}
```

### Close Issues

```graphql
mutation closeIssues($input: CloseIssuesInput!) {
  closeIssues(input: $input) {
    successCount
  }
}
```

Variables: `{ "input": { "issueIds": ["issue-id-1"] } }`

### Reopen Issues

```graphql
mutation reopenIssues($input: ReopenIssuesInput!) {
  reopenIssues(input: $input) {
    successCount
  }
}
```

Variables: `{ "input": { "issueIds": ["id"], "pipelineId": "pipeline-id", "position": "START" } }`

### Move Issue Between Pipelines

```graphql
mutation moveIssue($input: MoveIssueInput!, $workspaceId: ID!) {
  moveIssue(input: $input) {
    issue {
      id number
      pipelineIssue(workspaceId: $workspaceId) {
        pipeline { id name }
      }
    }
  }
}
```

Variables: `{ "input": { "issueId": "id", "pipelineId": "id", "position": 0 }, "workspaceId": "id" }`

Position: `0` = top of pipeline.

### Set Issue Estimate

```graphql
mutation setEstimate($input: SetEstimateInput!) {
  setEstimate(input: $input) {
    issue { id number estimate { value } }
  }
}
```

Variables: `{ "input": { "issueId": "id", "value": 5 } }`

### Assign Issues (GitHub-backed)

```graphql
mutation addAssignees($input: AddAssigneesToIssuesInput!) {
  addAssigneesToIssues(input: $input) {
    issues { id assignees(first: 10) { nodes { ... on User { name } } } }
  }
}
```

Variables: `{ "input": { "issueIds": ["id"], "assigneeIds": ["user-id"] } }`

`assigneeIds` are the `id` field from `User` type (the `... on User { id }` from assignee queries).

### Assign Issues (Zenhub-only)

```graphql
mutation addZenhubAssignees($input: AddZenhubAssigneesToIssuesInput!) {
  addZenhubAssigneesToIssues(input: $input) {
    issues { id assignees(first: 10) { nodes { ... on User { name } } } }
  }
}
```

Variables: `{ "input": { "issueIds": ["id"], "zenhubUserIds": ["zenhub-user-id"] } }`

`zenhubUserIds` are from the `ZenhubUser` type (e.g., `viewer.id`).

### Remove Assignees

```graphql
mutation removeAssignees($input: RemoveAssigneesFromIssuesInput!) {
  removeAssigneesFromIssues(input: $input) {
    issues { id assignees(first: 10) { nodes { ... on User { name } } } }
  }
}
```

Variables: `{ "input": { "issueIds": ["id"], "assigneeIds": ["user-id"] } }`

### Add Labels (Zenhub)

```graphql
mutation addLabels($input: AddZenhubLabelsToIssuesInput!) {
  addZenhubLabelsToIssues(input: $input) {
    issues { id labels(first: 10) { nodes { name } } }
  }
}
```

### Change Issue Type

```graphql
mutation changeType($input: ChangeIssueTypeOfIssuesInput!) {
  changeIssueTypeOfIssues(input: $input) {
    successCount
    failedIssues { id title }
  }
}
```

Variables (set type): `{ "input": { "issueIds": ["id"], "issueTypeId": "type-id" } }`
Variables (remove type): `{ "input": { "issueIds": ["id"], "removeIssueType": true } }`

### Add Issues to Sprint

```graphql
mutation addToSprint($input: AddIssuesToSprintsInput!) {
  addIssuesToSprints(input: $input) {
    sprintIssues { id }
  }
}
```

Variables: `{ "input": { "issueIds": ["id"], "sprintIds": ["sprint-id"] } }`

## Pagination

Uses Relay-style cursor pagination. Always specify `first` or `last` (max 100).

```graphql
query paginated($workspaceId: ID!, $after: String) {
  workspace(id: $workspaceId) {
    issues(first: 100, after: $after) {
      nodes { id number title }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
```

Pass `pageInfo.endCursor` as `$after` for next page. Loop while `hasNextPage` is true.

## Issue Type Values

- `type` field: `"GithubIssue"` or `"ZenhubIssue"`
- `state` field: `"OPEN"` or `"CLOSED"`
- `pullRequest` field: `true` or `false`
- `issueType.disposition`: `"BOARD"` or `"PLANNING_PANEL"`
- `issueType.level`: 1 (Initiative) through 5 (Sub-task)

## Error Handling

```bash
response=$(zh_graphql "$query" "$variables")

if echo "$response" | jq -e '.errors' > /dev/null 2>&1; then
  echo "Zenhub API Error:"
  echo "$response" | jq -r '.errors[].message'
  exit 1
fi
```

## Resources

- GraphiQL Explorer: https://developers.zenhub.com/explorer
- API Documentation: https://developers.zenhub.com/
- Examples: https://developers.zenhub.com/graphql-api-docs/examples
- Guides: https://developers.zenhub.com/guides/working-with-issues
