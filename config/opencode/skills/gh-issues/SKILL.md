---
name: gh-issues
description: Always use this skill for ALL GitHub issue operations including listing, searching, viewing, closing, moving, and managing issues. Provides GitHub CLI and Zenhub GraphQL API integration.
---

# GitHub Issues + Zenhub Skill

Manage GitHub and Zenhub issues using the Zenhub GraphQL API and `gh` CLI.

## When to Use

- List, search, view, close, move, or manage GitHub issues
- Work with Zenhub-specific data (pipelines, estimates, sprints)
- User requests like "list issues", "show my issues", "list team issues", "move issue to pipeline"

## Prerequisites

- Environment variable `ZH_API_KEY` must be set (get from https://app.zenhub.com/settings/tokens)
- `gh` CLI installed and authenticated
- `jq` for JSON parsing

## Default Configuration

**Default Workspace**: Client Solutions Experience
- Workspace ID: `5d7a5516d7fbc600019bc8ae`
- URL: https://app.zenhub.com/workspaces/client-solutions-experience-5d7a5516d7fbc600019bc8ae
- Zenhub Org ID: `Z2lkOi8vcmFwdG9yL1plbmh1Yk9yZ2FuaXphdGlvbi8xMjUx`
- Zenhub Repository ID: `Z2lkOi8vcmFwdG9yL1JlcG9zaXRvcnkvMTMzNzc3MjQw` (for creating Zenhub-native issues)

**Pipelines** (in board order):
| Pipeline    | ID                                            |
|-------------|-----------------------------------------------|
| Inbox       | `Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcxMzU`   |
| To Do       | `Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyMjY`   |
| In Progress | `Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyNDU`   |
| On Hold     | `Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMzNjcyODA`   |
| In Test     | `Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMyNjUwMDA`   |

**Team Members**:
- Mark Huggins
- Jess Chadwick
- David Hayes
- Ronan O'Malley
- Priya Darshani
- John Lemberger

## Safety Checks

- NEVER proceed if `ZH_API_KEY` is not set
- Verify workspace and repository context before operations
- Handle API rate limits gracefully (100 issues per query max, 200 complexity limit)
- Determine whether the issue is GitHub-backed or ZenHub-only before assigning

## GitHub vs ZenHub Ownership

We use a mix of GitHub issues and ZenHub-only tickets depending on how the issue was created.

- **GitHub-backed issue** (`type: "GithubIssue"`): has a GitHub URL and a concrete repo/issue number. Use `gh` (or `addAssigneesToIssues` mutation) for assignees. Use ZenHub for pipeline/estimate.
- **ZenHub-only ticket** (`type: "ZenhubIssue"`): has empty `htmlUrl`. Use `addZenhubAssigneesToIssues` mutation with `zenhubUserIds` for assignment. Use `createIssue` with the Zenhub Repository ID to create new ones.

### Quick Ownership Check

Check the `type` field from any issue query. If `type == "ZenhubIssue"` or `htmlUrl` is empty, treat it as ZenHub-only.

## Quick Reference

### Environment Check

```bash
if [ -z "$ZH_API_KEY" ]; then
  echo "Error: ZH_API_KEY not set. Get it from: https://app.zenhub.com/settings/tokens"
  exit 1
fi
```

### Helper Function

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

### List My Issues

```bash
WORKSPACE_ID="5d7a5516d7fbc600019bc8ae"
current_user=$(gh api user --jq .name)

query='
query($workspaceId: ID!) {
  workspace(id: $workspaceId) {
    issues(first: 100) {
      nodes {
        number
        title
        type
        state
        htmlUrl
        pipelineIssue(workspaceId: $workspaceId) {
          pipeline { name }
        }
        estimate { value }
        assignees(first: 10) {
          nodes { ... on User { name } }
        }
      }
    }
  }
}'

variables="{\"workspaceId\": \"$WORKSPACE_ID\"}"

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')" | \
  jq -r --arg user "$current_user" \
    '.data.workspace.issues.nodes[] |
     select(.state == "OPEN") |
     select(.assignees.nodes[]?.name == $user) |
     "#\(.number)  \(.title)  [\(.pipelineIssue.pipeline.name)]  Est: \(.estimate.value // "—")  \(.htmlUrl // "Zenhub-only")"'
```

### List Team Issues

```bash
WORKSPACE_ID="5d7a5516d7fbc600019bc8ae"
TEAM_MEMBERS=("Mark Huggins" "Jess Chadwick" "David Hayes" "Ronan O'Malley" "Priya Darshani" "John Lemberger")

query='
query($workspaceId: ID!) {
  workspace(id: $workspaceId) {
    issues(first: 100) {
      nodes {
        number
        title
        type
        state
        htmlUrl
        pipelineIssue(workspaceId: $workspaceId) {
          pipeline { name }
        }
        estimate { value }
        assignees(first: 10) {
          nodes { ... on User { name } }
        }
      }
    }
  }
}'

variables="{\"workspaceId\": \"$WORKSPACE_ID\"}"

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')" | \
  jq -r --argjson team "$(printf '%s\n' "${TEAM_MEMBERS[@]}" | jq -R . | jq -s .)" \
    '.data.workspace.issues.nodes[] |
     select(.state == "OPEN") |
     select(.assignees.nodes[]?.name as $assignee | $team | any(. == $assignee)) |
     "\(.assignees.nodes | map(.name) | join(", "))  #\(.number)  \(.title)  [\(.pipelineIssue.pipeline.name)]  Est: \(.estimate.value // "—")  \(.htmlUrl // "Zenhub-only")"' | sort -u
```

### List Recently Closed Team Issues (Last 2 Weeks)

```bash
WORKSPACE_ID="5d7a5516d7fbc600019bc8ae"
TEAM_MEMBERS=("Mark Huggins" "Jess Chadwick" "David Hayes" "Ronan O'Malley" "Priya Darshani" "John Lemberger")
TWO_WEEKS_AGO=$(date -u -v-14d +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d "14 days ago" +"%Y-%m-%dT%H:%M:%SZ")

query='
query($workspaceId: ID!) {
  workspace(id: $workspaceId) {
    issues(first: 100) {
      nodes {
        number
        title
        type
        state
        htmlUrl
        closedAt
        estimate { value }
        assignees(first: 10) {
          nodes { ... on User { name } }
        }
      }
    }
  }
}'

variables="{\"workspaceId\": \"$WORKSPACE_ID\"}"

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')" | \
  jq -r --argjson team "$(printf '%s\n' "${TEAM_MEMBERS[@]}" | jq -R . | jq -s .)" \
    --arg cutoff "$TWO_WEEKS_AGO" \
    '.data.workspace.issues.nodes[] |
     select(.state == "CLOSED") |
     select(.closedAt != null and .closedAt >= $cutoff) |
     select(.assignees.nodes | length > 0) |
     select(.assignees.nodes[]?.name as $assignee | $team | any(. == $assignee)) |
     "\(.closedAt[:10])  \(.assignees.nodes | map(.name) | join(", "))  #\(.number)  \(.title)  Est: \(.estimate.value // "—")  \(.htmlUrl // "Zenhub-only")"' | sort -ru
```

### Search Issues by Pipeline (with filters)

Use `searchIssuesByPipeline` for richer filtering (assignees, labels, sprints, estimates).
Note: `workspace.issues` does NOT support assignee or state filters.

```bash
PIPELINE_ID="Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyNDU"  # In Progress

query='
query($pipelineId: ID!, $filters: IssueSearchFiltersInput!) {
  searchIssuesByPipeline(pipelineId: $pipelineId, filters: $filters, first: 100) {
    nodes {
      id number title type state htmlUrl
      estimate { value }
      assignees(first: 10) {
        nodes { ... on User { name } }
      }
    }
  }
}'

variables=$(jq -n --arg pid "$PIPELINE_ID" '{pipelineId: $pid, filters: { assignees: { in: ["mhuggins7278"] } }}')

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')" | jq .
```

**Available `IssueSearchFiltersInput` fields**: `assignees` (GitHub login), `assigneeIds`, `labels`, `sprints`, `releases`, `estimates`, `repositoryIds`, `displayType`, `matchType`, `parentIssues`, `issueIssueTypes`

### Get Issue Details

```bash
WORKSPACE_ID="5d7a5516d7fbc600019bc8ae"
REPO_GH_ID=$(gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner) --jq .id)
ISSUE_NUMBER=123

query='
query($repositoryGhId: Int!, $issueNumber: Int!, $workspaceId: ID!) {
  issueByInfo(repositoryGhId: $repositoryGhId, issueNumber: $issueNumber) {
    id number title body type state htmlUrl
    estimate { value }
    pipelineIssue(workspaceId: $workspaceId) {
      pipeline { id name }
      priority { id name color }
    }
    issueType {
      ... on ZenhubIssueType { id name level }
      ... on GithubIssueType { id name level }
    }
    sprints(first: 10) {
      nodes { id name state startOn endOn }
    }
    labels(first: 20) {
      nodes { id name color }
    }
    assignees(first: 10) {
      nodes { ... on User { id login name } }
    }
  }
}'

variables=$(jq -n --argjson repoId "$REPO_GH_ID" --argjson issueNum "$ISSUE_NUMBER" --arg wsId "$WORKSPACE_ID" \
  '{repositoryGhId: $repoId, issueNumber: $issueNum, workspaceId: $wsId}')

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')" | jq .
```

## Mutations (Write Operations)

For mutations like moving issues, assigning, closing, creating, setting estimates, and updating issues, see the reference files:

- **[references/API.md](references/API.md)** — Full GraphQL schema: all mutation signatures, input types, and variables
- **[references/EXAMPLES.md](references/EXAMPLES.md)** — Working bash examples for every operation

### Quick Mutation Summary

| Operation | Mutation | Key Input |
|-----------|----------|-----------|
| Move to pipeline | `moveIssue` | `{issueId, pipelineId, position}` |
| Close issue | `closeIssues` | `{issueIds: [...]}` |
| Reopen issue | `reopenIssues` | `{issueIds, pipelineId, position}` |
| Set estimate | `setEstimate` | `{issueId, value}` |
| Update title/body | `updateIssue` | `{issueId, title?, body?}` |
| Create issue | `createIssue` | `{repositoryId, title, body?}` |
| Assign (GitHub) | `addAssigneesToIssues` | `{issueIds, assigneeIds}` |
| Assign (Zenhub) | `addZenhubAssigneesToIssues` | `{issueIds, zenhubUserIds}` |
| Remove assignees | `removeAssigneesFromIssues` | `{issueIds, assigneeIds}` |
| Add labels | `addZenhubLabelsToIssues` | `{issueIds, ...}` |
| Change issue type | `changeIssueTypeOfIssues` | `{issueIds, issueTypeId}` |
| Add to sprint | `addIssuesToSprints` | `{issueIds, sprintIds}` |

For GitHub-backed issues, `gh issue edit` is often simpler for assign/label/close operations.

## Tips

- Zenhub API limit: 100 issues per query, 200 complexity per query
- `workspace.issues` does NOT support assignee or state filters — use `searchIssuesByPipeline` for those
- `type` field values are `"GithubIssue"` and `"ZenhubIssue"` (not uppercase/underscore)
- Pipeline names and IDs are workspace-specific
- `viewer` returns a `ZenhubUser`; get GitHub info via `viewer { githubUser { login name } }`
- Use GraphiQL explorer: https://developers.zenhub.com/explorer
- Combine with `gh` CLI for GitHub operations (create, edit, assign, label)
