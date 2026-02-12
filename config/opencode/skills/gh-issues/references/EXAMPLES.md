# Zenhub Issue Management Examples

Complete working examples for common issue management tasks.

## Setup

```bash
# Required environment
export ZH_API_KEY="your-zenhub-api-key"
WORKSPACE_ID="5d7a5516d7fbc600019bc8ae"  # Client Solutions Experience
ZENHUB_REPO_ID="Z2lkOi8vcmFwdG9yL1JlcG9zaXRvcnkvMTMzNzc3MjQw"  # For creating Zenhub issues
```

## Example 1: List All Open Issues in "In Progress" Pipeline

```bash
PIPELINE_ID="Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyNDU"

query='
query($pipelineId: ID!, $filters: IssueSearchFiltersInput!) {
  searchIssuesByPipeline(pipelineId: $pipelineId, filters: $filters, first: 100) {
    nodes {
      number title type pullRequest htmlUrl
      estimate { value }
      assignees(first: 10) {
        nodes { ... on User { name login } }
      }
    }
  }
}'

variables=$(jq -n --arg pid "$PIPELINE_ID" '{pipelineId: $pid, filters: {}}')

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')" | \
  jq -r '.data.searchIssuesByPipeline.nodes[] |
    select(.pullRequest == false) |
    "#\(.number)  \(.title)  \(.assignees.nodes | map(.name) | join(", "))  Est: \(.estimate.value // "—")"'
```

## Example 2: Move Issue to Pipeline

```bash
WORKSPACE_ID="5d7a5516d7fbc600019bc8ae"
REPO_GH_ID=$(gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner) --jq .id)
ISSUE_NUMBER=42

# Get issue ID
issue_id=$(curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"query { issueByInfo(repositoryGhId: $REPO_GH_ID, issueNumber: $ISSUE_NUMBER) { id } }\"}" | \
  jq -r '.data.issueByInfo.id')

# Move to "In Progress" (position 0 = top)
pipeline_id="Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyNDU"

mutation='
mutation($input: MoveIssueInput!, $workspaceId: ID!) {
  moveIssue(input: $input) {
    issue { number pipelineIssue(workspaceId: $workspaceId) { pipeline { name } } }
  }
}'

variables=$(jq -n --arg issueId "$issue_id" --arg pipelineId "$pipeline_id" --arg wsId "$WORKSPACE_ID" \
  '{input: {issueId: $issueId, pipelineId: $pipelineId, position: 0}, workspaceId: $wsId}')

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$mutation" --argjson v "$variables" '{query: $q, variables: $v}')" | jq .

echo "Issue #$ISSUE_NUMBER moved to In Progress"
```

## Example 3: Set Estimate

```bash
REPO_GH_ID=$(gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner) --jq .id)

issue_id=$(curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"query { issueByInfo(repositoryGhId: $REPO_GH_ID, issueNumber: 42) { id } }\"}" | \
  jq -r '.data.issueByInfo.id')

mutation='
mutation($input: SetEstimateInput!) {
  setEstimate(input: $input) {
    issue { number estimate { value } }
  }
}'

variables=$(jq -n --arg issueId "$issue_id" '{input: {issueId: $issueId, value: 5}}')

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$mutation" --argjson v "$variables" '{query: $q, variables: $v}')" | \
  jq -r '"Issue #\(.data.setEstimate.issue.number) estimate set to \(.data.setEstimate.issue.estimate.value) points"'
```

## Example 4: Close Issue (GitHub-backed)

```bash
REPO_GH_ID=$(gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner) --jq .id)

issue_response=$(curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"query { issueByInfo(repositoryGhId: $REPO_GH_ID, issueNumber: 42) { id type htmlUrl } }\"}")

issue_id=$(echo "$issue_response" | jq -r '.data.issueByInfo.id')
issue_type=$(echo "$issue_response" | jq -r '.data.issueByInfo.type')

# Close via Zenhub
curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"mutation { closeIssues(input: { issueIds: [\\\"$issue_id\\\"] }) { successCount } }\"}"

# Also close in GitHub if GitHub-backed
if [ "$issue_type" = "GithubIssue" ]; then
  gh issue close 42
fi
```

## Example 5: Create a Zenhub-Native Issue

```bash
ZENHUB_REPO_ID="Z2lkOi8vcmFwdG9yL1JlcG9zaXRvcnkvMTMzNzc3MjQw"

mutation='
mutation($input: CreateIssueInput!) {
  createIssue(input: $input) {
    issue { id number title type }
  }
}'

variables=$(jq -n --arg repoId "$ZENHUB_REPO_ID" \
  '{input: {repositoryId: $repoId, title: "New planning task", body: "Description here"}}')

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$mutation" --argjson v "$variables" '{query: $q, variables: $v}')" | jq .
```

## Example 6: Create a GitHub Issue with Labels and Assignees

```bash
# Get repository ID first
WORKSPACE_ID="5d7a5516d7fbc600019bc8ae"
repo_id=$(curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"query { workspace(id: \\\"$WORKSPACE_ID\\\") { repositoriesConnection { nodes { id name } } } }\"}" | \
  jq -r '.data.workspace.repositoriesConnection.nodes[] | select(.name == "Client-Solutions-Experience") | .id')

mutation='
mutation($input: CreateIssueInput!) {
  createIssue(input: $input) {
    issue { id number title type htmlUrl }
  }
}'

variables=$(jq -n --arg repoId "$repo_id" \
  '{input: {repositoryId: $repoId, title: "Bug: login fails", body: "Steps to reproduce...", labels: ["bug"], assignees: ["mhuggins7278"]}}')

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$mutation" --argjson v "$variables" '{query: $q, variables: $v}')" | jq .
```

## Example 7: Assign a Zenhub-Only Issue

```bash
# Get your Zenhub user ID
my_zenhub_id=$(curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ viewer { id } }"}' | jq -r '.data.viewer.id')

# Assign to issue
mutation='
mutation($input: AddZenhubAssigneesToIssuesInput!) {
  addZenhubAssigneesToIssues(input: $input) {
    issues { id number assignees(first: 10) { nodes { ... on User { name } } } }
  }
}'

variables=$(jq -n --arg issueId "$issue_id" --arg userId "$my_zenhub_id" \
  '{input: {issueIds: [$issueId], zenhubUserIds: [$userId]}}')

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$mutation" --argjson v "$variables" '{query: $q, variables: $v}')" | jq .
```

## Example 8: Search Issues by Label in a Pipeline

```bash
PIPELINE_ID="Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyMjY"  # To Do

query='
query($pipelineId: ID!, $filters: IssueSearchFiltersInput!) {
  searchIssuesByPipeline(pipelineId: $pipelineId, filters: $filters, first: 100) {
    nodes {
      number title htmlUrl
      labels(first: 10) { nodes { name } }
    }
  }
}'

variables=$(jq -n --arg pid "$PIPELINE_ID" \
  '{pipelineId: $pid, filters: { labels: { in: ["bug"] } }}')

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')" | \
  jq -r '.data.searchIssuesByPipeline.nodes[] |
    "#\(.number)  \(.title)  \(.htmlUrl)"'
```

## Example 9: Reopen Issue to Specific Pipeline

```bash
WORKSPACE_ID="5d7a5516d7fbc600019bc8ae"
REPO_GH_ID=$(gh api repos/$(gh repo view --json nameWithOwner -q .nameWithOwner) --jq .id)

issue_id=$(curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"query { issueByInfo(repositoryGhId: $REPO_GH_ID, issueNumber: 42) { id type } }\"}" | \
  jq -r '.data.issueByInfo.id')

pipeline_id="Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyMjY"  # To Do

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"mutation { reopenIssues(input: { issueIds: [\\\"$issue_id\\\"], pipelineId: \\\"$pipeline_id\\\", position: START }) { successCount } }\"}"

# Also reopen in GitHub if GitHub-backed
gh issue reopen 42
```

## Example 10: Paginate Through All Workspace Issues

```bash
WORKSPACE_ID="5d7a5516d7fbc600019bc8ae"
cursor=""
has_next=true

query='
query($workspaceId: ID!, $after: String) {
  workspace(id: $workspaceId) {
    issues(first: 100, after: $after) {
      nodes { number title state }
      pageInfo { hasNextPage endCursor }
    }
  }
}'

while [ "$has_next" = "true" ]; do
  if [ -z "$cursor" ]; then
    variables=$(jq -n --arg wsId "$WORKSPACE_ID" '{workspaceId: $wsId, after: null}')
  else
    variables=$(jq -n --arg wsId "$WORKSPACE_ID" --arg c "$cursor" '{workspaceId: $wsId, after: $c}')
  fi

  response=$(curl -s -X POST "https://api.zenhub.com/public/graphql" \
    -H "Authorization: Bearer $ZH_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')")

  echo "$response" | jq -r '.data.workspace.issues.nodes[] | "#\(.number)  \(.title)  [\(.state)]"'

  has_next=$(echo "$response" | jq -r '.data.workspace.issues.pageInfo.hasNextPage')
  cursor=$(echo "$response" | jq -r '.data.workspace.issues.pageInfo.endCursor')
done
```

## Example 11: Get Board Overview (All Pipelines with Issue Counts)

```bash
WORKSPACE_ID="5d7a5516d7fbc600019bc8ae"

query='
query($workspaceId: ID!) {
  workspace(id: $workspaceId) {
    pipelinesConnection(first: 25) {
      nodes {
        name
        issues(first: 100) {
          nodes { number title estimate { value } }
        }
      }
    }
  }
}'

variables=$(jq -n --arg wsId "$WORKSPACE_ID" '{workspaceId: $wsId}')

curl -s -X POST "https://api.zenhub.com/public/graphql" \
  -H "Authorization: Bearer $ZH_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')" | \
  jq -r '.data.workspace.pipelinesConnection.nodes[] |
    "\(.name): \(.issues.nodes | length) issues, \(.issues.nodes | map(.estimate.value // 0) | add) points"'
```

## Tips

- Always check for API errors in responses before processing data
- Use `jq` for robust JSON parsing
- Use cached pipeline IDs from SKILL.md instead of querying each time
- `type` field: `"GithubIssue"` or `"ZenhubIssue"` (not uppercase/underscore)
- `searchIssuesByPipeline` is better than `workspace.issues` when you need assignee/sprint filters
- Test queries in GraphiQL Explorer first: https://developers.zenhub.com/explorer
- Max complexity per query: 200 points (keep queries lean)
