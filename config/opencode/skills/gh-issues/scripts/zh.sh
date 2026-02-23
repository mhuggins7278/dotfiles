#!/usr/bin/env bash
# zh.sh — Zenhub CLI helper for issue management
# Usage: bash scripts/zh.sh <command> [args...]
set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
ZH_API_URL="https://api.zenhub.com/public/graphql"
WORKSPACE_ID="5d7a5516d7fbc600019bc8ae"
ZENHUB_REPO_ID="Z2lkOi8vcmFwdG9yL1JlcG9zaXRvcnkvMTMzNzc3MjQw"
TEAM_MEMBERS=("Mark Huggins" "Jess Chadwick" "David Hayes" "Ronan O'Malley" "Priya Darshani" "John Lemberger")
TEAM_LOGINS=("mhuggins7278" "jchadwick" "drhayes" "Ronanj7" "pdarshani" "JohnLemberger")

# ── Pipeline ID lookup ───────────────────────────────────────────────────────
pipeline_id() {
  case "$1" in
    inbox)        echo "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcxMzU" ;;
    todo|to-do)   echo "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyMjY" ;;
    in-progress)  echo "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyNDU" ;;
    on-hold)      echo "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMzNjcyODA" ;;
    in-test)      echo "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMyNjUwMDA" ;;
    *) echo "Unknown pipeline: '$1'. Use: inbox, todo, in-progress, on-hold, in-test" >&2; return 1 ;;
  esac
}

# ── Preflight ────────────────────────────────────────────────────────────────
if [ -z "${ZH_API_KEY:-}" ]; then
  echo "Error: ZH_API_KEY not set. Get it from: https://app.zenhub.com/settings/tokens" >&2
  exit 1
fi

# ── Core helpers ─────────────────────────────────────────────────────────────

zh_graphql() {
  local query="$1"
  local variables="${2:-}"
  [ -z "$variables" ] && variables='{}'
  curl -s -X POST "$ZH_API_URL" \
    -H "Authorization: Bearer $ZH_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')"
}

zh_check_errors() {
  local response="$1"
  if echo "$response" | jq -e '.errors' > /dev/null 2>&1; then
    echo "Zenhub API Error:" >&2
    echo "$response" | jq -r '.errors[].message' >&2
    return 1
  fi
}

# Numeric GitHub repo ID for the current repo
repo_gh_id() {
  gh api "repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)" --jq .id
}

# Fetch id + type + htmlUrl for an issue by number
issue_info() {
  local repo_gh_id="$1" issue_number="$2"
  zh_graphql "query { issueByInfo(repositoryGhId: $repo_gh_id, issueNumber: $issue_number) { id type htmlUrl } }"
}

# ── Commands ─────────────────────────────────────────────────────────────────

cmd_help() {
  cat <<'USAGE'
zh.sh — Zenhub issue management

Usage: bash zh.sh <command> [args...]

Read:
  list-mine                          My open issues (excludes epics)
  list-team                          Team open issues (excludes epics)
  list-epics [--mine]                Team epics (--mine: only assigned to me)
  list-closed [--days N]             Closed team issues (default: 14)
  board                              Pipeline overview with counts + points
  show <issue-number>                Issue details (requires repo context)
  search <pipeline> [--assignee X]   Search pipeline; filters optional
                    [--label X]
  epic-issues <epic-number>          Child issues of an epic
  viewer                             Current authenticated user info

Write:
  move <issue-number> <pipeline>     Move issue to pipeline
  close <issue-number>               Close issue (handles GH + ZH)
  reopen <issue-number> [pipeline]   Reopen issue (default pipeline: todo)
  estimate <issue-number> <points>   Set estimate
  create <title> [--body TEXT]       Create GitHub-backed issue
         [--zenhub]                  Create Zenhub-only issue instead
  assign <issue-number> <login>      Assign user (auto-detects GH vs ZH)
  unassign <issue-number> <login>    Remove assignee (GH-backed only)

Pipelines: inbox | todo | in-progress | on-hold | in-test
USAGE
}

cmd_viewer() {
  zh_graphql 'query { viewer { id name githubUser { id login name } } }' | \
    jq '.data.viewer'
}

cmd_list_mine() {
  local login
  login=$(gh api user --jq .login)

  local PIPELINES=(
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcxMzU"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyMjY"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyNDU"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMzNjcyODA"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMyNjUwMDA"
  )

  local query='query($pipelineId: ID!, $wsId: ID!, $filters: IssueSearchFiltersInput!) {
    searchIssuesByPipeline(pipelineId: $pipelineId, filters: $filters, first: 100) {
      nodes {
        number title state
        pipelineIssue(workspaceId: $wsId) { pipeline { name } }
        estimate { value }
        issueType {
          ... on ZenhubIssueType { name }
          ... on GithubIssueType { name }
        }
        assignees(first: 10) { nodes { ... on User { name } } }
        zenhubAssignees(first: 10) { nodes { githubUser { name } } }
      }
    }
  }'

  local filters
  filters=$(jq -n --arg login "$login" \
    '{assignees: {in: [$login]}, issueIssueTypes: {nin: ["Epic"]}}')

  local all_issues="[]"
  for pid in "${PIPELINES[@]}"; do
    local result
    result=$(zh_graphql "$query" \
      "$(jq -n --arg pid "$pid" --arg wsId "$WORKSPACE_ID" --argjson f "$filters" \
         '{pipelineId: $pid, wsId: $wsId, filters: $f}')" | \
      jq '.data.searchIssuesByPipeline.nodes // []')
    all_issues=$(echo "$all_issues $result" | jq -s 'add')
  done

  echo "$all_issues" | \
    jq -r \
      '.[] |
       select(.state == "OPEN") |
       (.assignees.nodes | map(.name)) + (.zenhubAssignees.nodes | map(.githubUser.name // empty)) as $all_assignees |
       "#\(.number)  [\(.pipelineIssue.pipeline.name // "—")]  \(.issueType.name // "—")  \(.title)  Est: \(.estimate.value // "—")"'
}

cmd_list_team() {
  local team_logins_json
  team_logins_json=$(printf '%s\n' "${TEAM_LOGINS[@]}" | jq -R . | jq -s .)

  local PIPELINES=(
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcxMzU"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyMjY"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyNDU"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMzNjcyODA"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMyNjUwMDA"
  )

  local query='query($pipelineId: ID!, $wsId: ID!, $filters: IssueSearchFiltersInput!) {
    searchIssuesByPipeline(pipelineId: $pipelineId, filters: $filters, first: 100) {
      nodes {
        number title state
        pipelineIssue(workspaceId: $wsId) { pipeline { name } }
        estimate { value }
        issueType {
          ... on ZenhubIssueType { name }
          ... on GithubIssueType { name }
        }
        assignees(first: 10) { nodes { ... on User { name } } }
        zenhubAssignees(first: 10) { nodes { githubUser { name } } }
      }
    }
  }'

  local filters
  filters=$(jq -n --argjson logins "$team_logins_json" \
    '{matchType: "any", assignees: {in: $logins}}')

  local all_issues="[]"
  for pid in "${PIPELINES[@]}"; do
    local result
    result=$(zh_graphql "$query" \
      "$(jq -n --arg pid "$pid" --arg wsId "$WORKSPACE_ID" --argjson f "$filters" \
         '{pipelineId: $pid, wsId: $wsId, filters: $f}')" | \
      jq '.data.searchIssuesByPipeline.nodes // []')
    all_issues=$(echo "$all_issues $result" | jq -s 'add')
  done

  echo "$all_issues" | \
    jq -r \
      '.[] |
       select(.state == "OPEN") |
       select(.issueType.name != "Epic") |
       (.assignees.nodes | map(.name)) + (.zenhubAssignees.nodes | map(.githubUser.name // empty)) as $all_assignees |
       "\($all_assignees | join(", "))  #\(.number)  [\(.pipelineIssue.pipeline.name // "—")]  \(.issueType.name // "—")  \(.title)  Est: \(.estimate.value // "—")"' | sort -u
}

cmd_list_epics() {
  local mine=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mine) mine=true; shift ;;
      *) echo "Unknown arg: $1" >&2; return 1 ;;
    esac
  done

  local login=""
  if [ "$mine" = true ]; then
    login=$(gh api user --jq .login)
  fi

  local PIPELINES=(
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcxMzU"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyMjY"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyNDU"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMzNjcyODA"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMyNjUwMDA"
  )

  local query='query($pipelineId: ID!, $wsId: ID!, $filters: IssueSearchFiltersInput!) {
    searchIssuesByPipeline(pipelineId: $pipelineId, filters: $filters, first: 100) {
      nodes {
        number title state
        pipelineIssue(workspaceId: $wsId) { pipeline { name } }
        estimate { value }
        issueType {
          ... on ZenhubIssueType { name }
          ... on GithubIssueType { name }
        }
        assignees(first: 10) { nodes { ... on User { name } } }
        zenhubAssignees(first: 10) { nodes { githubUser { name } } }
      }
    }
  }'

  local filters
  if [ "$mine" = true ]; then
    filters=$(jq -n --arg login "$login" \
      '{assignees: {in: [$login]}, issueIssueTypes: {in: ["Epic"]}}')
  else
    filters='{"issueIssueTypes": {"in": ["Epic"]}}'
  fi

  local all_issues="[]"
  for pid in "${PIPELINES[@]}"; do
    local result
    result=$(zh_graphql "$query" \
      "$(jq -n --arg pid "$pid" --arg wsId "$WORKSPACE_ID" --argjson f "$filters" \
         '{pipelineId: $pid, wsId: $wsId, filters: $f}')" | \
      jq '.data.searchIssuesByPipeline.nodes // []')
    all_issues=$(echo "$all_issues $result" | jq -s 'add')
  done

  echo "$all_issues" | \
    jq -r \
      '.[] |
       select(.state == "OPEN") |
       (.assignees.nodes | map(.name)) + (.zenhubAssignees.nodes | map(.githubUser.name // empty)) as $all_assignees |
       "#\(.number)  [\(.pipelineIssue.pipeline.name // "—")]  \(.title)  Est: \(.estimate.value // "—")  \($all_assignees | join(", "))"' | sort -u
}

cmd_epic_issues() {
  local epic_number="${1:?Usage: zh.sh epic-issues <epic-number>}"

  # Step 1: Find the epic across all pipelines to get its Zenhub node ID
  local PIPELINES=(
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcxMzU"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyMjY"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyNDU"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMzNjcyODA"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMyNjUwMDA"
  )
  local search_query='query($pipelineId: ID!, $filters: IssueSearchFiltersInput!) {
    searchIssuesByPipeline(pipelineId: $pipelineId, filters: $filters, first: 100) {
      nodes { id number type htmlUrl repository { ghId } }
    }
  }'

  local found=""
  for pid in "${PIPELINES[@]}"; do
    local vars result
    vars=$(jq -n --arg pid "$pid" '{pipelineId: $pid, filters: {}}')
    result=$(zh_graphql "$search_query" "$vars" | \
      jq --argjson num "$epic_number" \
        'first(.data.searchIssuesByPipeline.nodes[] | select(.number == $num)) // empty')
    if [ -n "$result" ]; then
      found="$result"
      break
    fi
  done

  if [ -z "$found" ]; then
    echo "Error: Epic #$epic_number not found in any pipeline." >&2
    return 1
  fi

  local epic_id
  epic_id=$(echo "$found" | jq -r '.id')

  # Step 2: Fetch child issues of the epic
  local query='query($workspaceId: ID!, $epicId: ID!) {
    workspace(id: $workspaceId) {
      issues(first: 100, filters: { parentIssues: { ids: [$epicId] } }) {
        nodes {
          number title state htmlUrl
          pipelineIssue(workspaceId: $workspaceId) { pipeline { name } }
          estimate { value }
          issueType {
            ... on ZenhubIssueType { name }
            ... on GithubIssueType { name }
          }
          assignees(first: 10) { nodes { ... on User { name } } }
        }
      }
    }
  }'

  zh_graphql "$query" \
    "$(jq -n --arg wsId "$WORKSPACE_ID" --arg epicId "$epic_id" '{workspaceId: $wsId, epicId: $epicId}')" | \
    jq -r --argjson epicNum "$epic_number" \
      '.data.workspace.issues.nodes[] |
       select(.number != $epicNum) |
       "#\(.number)  [\(.pipelineIssue.pipeline.name // "—")]  \(.issueType.name // "—")  \(.title)  Est: \(.estimate.value // "—")  \(.assignees.nodes | map(.name) | join(", "))"'
}

cmd_list_closed() {
  local days=14
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --days) days="$2"; shift 2 ;;
      *) echo "Unknown arg: $1" >&2; return 1 ;;
    esac
  done

  local cutoff
  cutoff=$(date -u -v-"${days}"d +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || \
           date -u -d "$days days ago" +"%Y-%m-%dT%H:%M:%SZ")

  local query='query($workspaceId: ID!) {
    workspace(id: $workspaceId) {
      issues(first: 100) {
        nodes {
          number title state htmlUrl closedAt
          estimate { value }
          assignees(first: 10) { nodes { ... on User { name } } }
        }
      }
    }
  }'

  local team_json
  team_json=$(printf '%s\n' "${TEAM_MEMBERS[@]}" | jq -R . | jq -s .)

  zh_graphql "$query" "$(jq -n --arg wsId "$WORKSPACE_ID" '{workspaceId: $wsId}')" | \
    jq -r --argjson team "$team_json" --arg cutoff "$cutoff" \
      '.data.workspace.issues.nodes[] |
       select(.state == "CLOSED") |
       select(.closedAt != null and .closedAt >= $cutoff) |
       select(.assignees.nodes | length > 0) |
       select(.assignees.nodes[]?.name as $a | $team | any(. == $a)) |
       "\(.closedAt[:10])  \(.assignees.nodes | map(.name) | join(", "))  #\(.number)  \(.title)  Est: \(.estimate.value // "—")"' | sort -ru
}

cmd_board() {
  local query='query($workspaceId: ID!) {
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

  zh_graphql "$query" "$(jq -n --arg wsId "$WORKSPACE_ID" '{workspaceId: $wsId}')" | \
    jq -r '.data.workspace.pipelinesConnection.nodes[] |
      "\(.name): \(.issues.nodes | length) issues, \(.issues.nodes | map(.estimate.value // 0) | add // 0) points"'
}

cmd_show() {
  local issue_number="${1:?Usage: zh.sh show <issue-number>}"

  # Search each pipeline to find which repo this issue belongs to
  local PIPELINES=(
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcxMzU"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyMjY"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzIwMjcyNDU"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMzNjcyODA"
    "Z2lkOi8vcmFwdG9yL1BpcGVsaW5lLzMyNjUwMDA"
  )
  local search_query='query($pipelineId: ID!, $filters: IssueSearchFiltersInput!) {
    searchIssuesByPipeline(pipelineId: $pipelineId, filters: $filters, first: 100) {
      nodes { id number type htmlUrl repository { ghId } }
    }
  }'

  local found=""
  for pid in "${PIPELINES[@]}"; do
    local vars result
    vars=$(jq -n --arg pid "$pid" '{pipelineId: $pid, filters: {}}')
    result=$(zh_graphql "$search_query" "$vars" | \
      jq --argjson num "$issue_number" \
        'first(.data.searchIssuesByPipeline.nodes[] | select(.number == $num)) // empty')
    if [ -n "$result" ]; then
      found="$result"
      break
    fi
  done

  if [ -z "$found" ]; then
    echo "Error: Issue #$issue_number not found in any pipeline." >&2
    return 1
  fi

  local issue_type repo_gh_id
  issue_type=$(echo "$found" | jq -r '.type')
  repo_gh_id=$(echo "$found" | jq -r '.repository.ghId // empty')

  if [ "$issue_type" = "ZenhubIssue" ] || [ -z "$repo_gh_id" ]; then
    # Zenhub-only: fetch via node ID
    local node_id
    node_id=$(echo "$found" | jq -r '.id // empty')
    zh_graphql "query { node(id: \"$node_id\") {
      ... on Issue {
        id number title body type state
        estimate { value }
        issueType { ... on ZenhubIssueType { name level } }
        assignees(first: 10) { nodes { ... on User { login name } } }
        labels(first: 20) { nodes { name } }
      }
    } }" | jq '.data.node'
    return
  fi

  local query='query($repoId: Int!, $num: Int!, $wsId: ID!) {
    issueByInfo(repositoryGhId: $repoId, issueNumber: $num) {
      id number title body type state htmlUrl
      estimate { value }
      pipelineIssue(workspaceId: $wsId) {
        pipeline { id name }
        priority { name color }
      }
      issueType {
        ... on ZenhubIssueType { name level }
        ... on GithubIssueType { name level }
      }
      sprints(first: 10) { nodes { id name state startAt endAt } }
      labels(first: 20) { nodes { name color } }
      assignees(first: 10) { nodes { ... on User { id login name } } }
    }
  }'

  zh_graphql "$query" \
    "$(jq -n --argjson repoId "$repo_gh_id" --argjson num "$issue_number" --arg wsId "$WORKSPACE_ID" \
       '{repoId: $repoId, num: $num, wsId: $wsId}')" | \
    jq '.data.issueByInfo'
}

cmd_search() {
  local pipeline_name="${1:?Usage: zh.sh search <pipeline> [--assignee X] [--label X]}"
  shift
  local pid
  pid=$(pipeline_id "$pipeline_name")

  local assignee="" label=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --assignee) assignee="$2"; shift 2 ;;
      --label)    label="$2"; shift 2 ;;
      *) echo "Unknown arg: $1" >&2; return 1 ;;
    esac
  done

  local filters="{}"
  [ -n "$assignee" ] && filters=$(echo "$filters" | jq --arg a "$assignee" '. + {assignees: {in: [$a]}}')
  [ -n "$label" ]    && filters=$(echo "$filters" | jq --arg l "$label"    '. + {labels: {in: [$l]}}')

  local query='query($pipelineId: ID!, $filters: IssueSearchFiltersInput!) {
    searchIssuesByPipeline(pipelineId: $pipelineId, filters: $filters, first: 100) {
      nodes {
        number title type state htmlUrl
        estimate { value }
        assignees(first: 10) { nodes { ... on User { name login } } }
      }
    }
  }'

  zh_graphql "$query" \
    "$(jq -n --arg pid "$pid" --argjson f "$filters" '{pipelineId: $pid, filters: $f}')" | \
    jq -r '.data.searchIssuesByPipeline.nodes[] |
      select(.pullRequest != true) |
      "#\(.number)  \(.title)  \(.assignees.nodes | map(.name) | join(", "))  Est: \(.estimate.value // "—")"'
}

cmd_move() {
  local issue_number="${1:?Usage: zh.sh move <issue-number> <pipeline>}"
  local pipeline_name="${2:?Usage: zh.sh move <issue-number> <pipeline>}"
  local pid repo_id iid
  pid=$(pipeline_id "$pipeline_name")
  repo_id=$(repo_gh_id)
  iid=$(issue_info "$repo_id" "$issue_number" | jq -r '.data.issueByInfo.id')

  local mutation='mutation($input: MoveIssueInput!, $wsId: ID!) {
    moveIssue(input: $input) {
      issue { number pipelineIssue(workspaceId: $wsId) { pipeline { name } } }
    }
  }'

  local response
  response=$(zh_graphql "$mutation" \
    "$(jq -n --arg iid "$iid" --arg pid "$pid" --arg wsId "$WORKSPACE_ID" \
       '{input: {issueId: $iid, pipelineId: $pid, position: 0}, wsId: $wsId}')")
  zh_check_errors "$response"
  echo "Issue #$issue_number moved to $(echo "$response" | jq -r '.data.moveIssue.issue.pipelineIssue.pipeline.name')"
}

cmd_close() {
  local issue_number="${1:?Usage: zh.sh close <issue-number>}"
  local repo_id
  repo_id=$(repo_gh_id)

  local info iid issue_type
  info=$(issue_info "$repo_id" "$issue_number")
  iid=$(echo "$info" | jq -r '.data.issueByInfo.id')
  issue_type=$(echo "$info" | jq -r '.data.issueByInfo.type')

  local response
  response=$(zh_graphql "mutation { closeIssues(input: { issueIds: [\"$iid\"] }) { successCount } }")
  zh_check_errors "$response"

  [ "$issue_type" = "GithubIssue" ] && gh issue close "$issue_number" 2>/dev/null || true
  echo "Issue #$issue_number closed"
}

cmd_reopen() {
  local issue_number="${1:?Usage: zh.sh reopen <issue-number> [pipeline]}"
  local pipeline_name="${2:-todo}"
  local pid repo_id
  pid=$(pipeline_id "$pipeline_name")
  repo_id=$(repo_gh_id)

  local info iid issue_type
  info=$(issue_info "$repo_id" "$issue_number")
  iid=$(echo "$info" | jq -r '.data.issueByInfo.id')
  issue_type=$(echo "$info" | jq -r '.data.issueByInfo.type')

  local response
  response=$(zh_graphql "mutation { reopenIssues(input: { issueIds: [\"$iid\"], pipelineId: \"$pid\", position: START }) { successCount } }")
  zh_check_errors "$response"

  [ "$issue_type" = "GithubIssue" ] && gh issue reopen "$issue_number" 2>/dev/null || true
  echo "Issue #$issue_number reopened to $pipeline_name"
}

cmd_estimate() {
  local issue_number="${1:?Usage: zh.sh estimate <issue-number> <points>}"
  local value="${2:?Usage: zh.sh estimate <issue-number> <points>}"
  local repo_id iid
  repo_id=$(repo_gh_id)
  iid=$(issue_info "$repo_id" "$issue_number" | jq -r '.data.issueByInfo.id')

  local mutation='mutation($input: SetEstimateInput!) {
    setEstimate(input: $input) {
      issue { number estimate { value } }
    }
  }'

  local response
  response=$(zh_graphql "$mutation" \
    "$(jq -n --arg iid "$iid" --argjson val "$value" '{input: {issueId: $iid, value: $val}}')")
  zh_check_errors "$response"
  echo "$response" | jq -r '"Issue #\(.data.setEstimate.issue.number) estimate set to \(.data.setEstimate.issue.estimate.value) points"'
}

cmd_create() {
  local zenhub=false title="" body=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --zenhub)     zenhub=true; shift ;;
      --body)       body="$2"; shift 2 ;;
      --)           shift; title="$*"; break ;;
      *)            title="${title:+$title }$1"; shift ;;
    esac
  done

  [ -z "$title" ] && { echo "Usage: zh.sh create <title> [--body TEXT] [--zenhub]" >&2; return 1; }

  local repo_id
  if [ "$zenhub" = true ]; then
    repo_id="$ZENHUB_REPO_ID"
  else
    local gh_repo_name
    gh_repo_name=$(gh repo view --json name -q .name)
    repo_id=$(zh_graphql "query { workspace(id: \"$WORKSPACE_ID\") { repositoriesConnection { nodes { id name } } } }" | \
      jq -r --arg name "$gh_repo_name" \
        '.data.workspace.repositoriesConnection.nodes[] | select(.name == $name) | .id')
    [ -z "$repo_id" ] || [ "$repo_id" = "null" ] && {
      echo "Error: Could not find repo '$gh_repo_name' in workspace. Use --zenhub for a Zenhub-only issue." >&2
      return 1
    }
  fi

  local input
  input=$(jq -n --arg rid "$repo_id" --arg t "$title" '{repositoryId: $rid, title: $t}')
  [ -n "$body" ] && input=$(echo "$input" | jq --arg b "$body" '. + {body: $b}')

  local mutation='mutation($input: CreateIssueInput!) {
    createIssue(input: $input) {
      issue { id number title type htmlUrl }
    }
  }'

  local response
  response=$(zh_graphql "$mutation" "$(jq -n --argjson input "$input" '{input: $input}')")
  zh_check_errors "$response"
  echo "$response" | jq -r '.data.createIssue.issue |
    "Created #\(.number): \(.title) (\(.type)) \(.htmlUrl // "Zenhub-only")"'
}

cmd_assign() {
  local issue_number="${1:?Usage: zh.sh assign <issue-number> <login>}"
  local login="${2:?Usage: zh.sh assign <issue-number> <login>}"
  local repo_id
  repo_id=$(repo_gh_id)

  local info iid issue_type
  info=$(issue_info "$repo_id" "$issue_number")
  iid=$(echo "$info" | jq -r '.data.issueByInfo.id')
  issue_type=$(echo "$info" | jq -r '.data.issueByInfo.type')

  if [ "$issue_type" = "GithubIssue" ]; then
    gh issue edit "$issue_number" --add-assignee "$login"
  else
    # Zenhub-only: resolve Zenhub user ID for the viewer only
    local viewer_info
    viewer_info=$(zh_graphql 'query { viewer { id githubUser { login } } }')
    local viewer_login zh_user_id
    viewer_login=$(echo "$viewer_info" | jq -r '.data.viewer.githubUser.login')
    zh_user_id=$(echo "$viewer_info" | jq -r '.data.viewer.id')

    [ "$login" != "$viewer_login" ] && {
      echo "Error: Can only auto-assign the current viewer ($viewer_login) to Zenhub-only issues." >&2
      echo "For other users, use the Zenhub UI or provide their Zenhub user ID directly." >&2
      return 1
    }

    local mutation='mutation($input: AddZenhubAssigneesToIssuesInput!) {
      addZenhubAssigneesToIssues(input: $input) {
        issues { number assignees(first: 10) { nodes { ... on User { name } } } }
      }
    }'
    local response
    response=$(zh_graphql "$mutation" \
      "$(jq -n --arg iid "$iid" --arg uid "$zh_user_id" \
         '{input: {issueIds: [$iid], zenhubUserIds: [$uid]}}')")
    zh_check_errors "$response"
  fi

  echo "Assigned $login to #$issue_number"
}

cmd_unassign() {
  local issue_number="${1:?Usage: zh.sh unassign <issue-number> <login>}"
  local login="${2:?Usage: zh.sh unassign <issue-number> <login>}"
  local repo_id
  repo_id=$(repo_gh_id)

  local issue_type
  issue_type=$(issue_info "$repo_id" "$issue_number" | jq -r '.data.issueByInfo.type')

  if [ "$issue_type" = "GithubIssue" ]; then
    gh issue edit "$issue_number" --remove-assignee "$login"
    echo "Unassigned $login from #$issue_number"
  else
    echo "Error: Unassign for Zenhub-only issues requires the Zenhub UI." >&2
    return 1
  fi
}

# ── Dispatch ─────────────────────────────────────────────────────────────────
command="${1:-help}"
shift || true

case "$command" in
  help|--help|-h) cmd_help ;;
  viewer)         cmd_viewer ;;
  list-mine)      cmd_list_mine ;;
  list-team)      cmd_list_team ;;
  list-epics)     cmd_list_epics "$@" ;;
  list-closed)    cmd_list_closed "$@" ;;
  epic-issues)    cmd_epic_issues "$@" ;;
  board)          cmd_board ;;
  show)           cmd_show "$@" ;;
  search)         cmd_search "$@" ;;
  move)           cmd_move "$@" ;;
  close)          cmd_close "$@" ;;
  reopen)         cmd_reopen "$@" ;;
  estimate)       cmd_estimate "$@" ;;
  create)         cmd_create "$@" ;;
  assign)         cmd_assign "$@" ;;
  unassign)       cmd_unassign "$@" ;;
  *) echo "Unknown command: '$command'. Run 'zh.sh help' for usage." >&2; exit 1 ;;
esac
