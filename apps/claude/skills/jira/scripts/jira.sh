#!/usr/bin/env bash
# jira.sh - Bash wrapper for Jira Cloud REST API v3
# Usage: bash jira.sh <command> [args...]

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration (deferred until an API call is made)
# ---------------------------------------------------------------------------

_init_config() {
  # Support both JIRA_URL (full URL) and JIRA_DOMAIN (just the hostname)
  if [[ -n "${JIRA_URL:-}" ]]; then
    JIRA_DOMAIN="${JIRA_URL#https://}"
    JIRA_DOMAIN="${JIRA_DOMAIN#http://}"
    JIRA_DOMAIN="${JIRA_DOMAIN%/}"
  fi
  : "${JIRA_DOMAIN:?Set JIRA_DOMAIN or JIRA_URL in your environment (e.g. mycompany.atlassian.net)}"
  : "${JIRA_EMAIL:?Set JIRA_EMAIL in your environment}"
  : "${JIRA_API_TOKEN:?Set JIRA_API_TOKEN in your environment}"
  BASE_URL="https://${JIRA_DOMAIN}/rest/api/3"
  AUTH="${JIRA_EMAIL}:${JIRA_API_TOKEN}"
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_curl_get() {
  local url="$1"
  curl -sS --fail-with-body \
    -u "${AUTH}" \
    -H "Accept: application/json" \
    "${url}"
}

_curl_post() {
  local url="$1"
  local data="$2"
  curl -sS --fail-with-body \
    -u "${AUTH}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -X POST \
    -d "${data}" \
    "${url}"
}

_curl_put() {
  local url="$1"
  local data="$2"
  curl -sS --fail-with-body \
    -u "${AUTH}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -X PUT \
    -d "${data}" \
    "${url}"
}

_require_arg() {
  if [[ -z "${2:-}" ]]; then
    echo "Error: ${1} is required" >&2
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

cmd_test() {
  echo "Testing Jira connection to ${JIRA_DOMAIN}..."
  _curl_get "${BASE_URL}/myself" | jq '{displayName, emailAddress, accountId}'
}

cmd_get_issue() {
  local key="$1"
  _require_arg "issue key" "${key}"
  local fields="${2:-summary,status,issuetype,priority,assignee,reporter,description,created,updated,labels,components}"
  _curl_get "${BASE_URL}/issue/${key}?fields=${fields}"
}

cmd_search() {
  local jql="$1"
  _require_arg "JQL query" "${jql}"
  local max_results="${2:-20}"
  local fields="${3:-summary,status,issuetype,priority,assignee}"
  _curl_post "${BASE_URL}/search" \
    "$(jq -n \
      --arg jql "${jql}" \
      --argjson max "${max_results}" \
      --arg fields "${fields}" \
      '{jql: $jql, maxResults: $max, fields: ($fields | split(","))}'
    )"
}

cmd_create_issue() {
  local project_key="$1"
  local issue_type="$2"
  local summary="$3"
  local description="${4:-}"
  _require_arg "project key" "${project_key}"
  _require_arg "issue type" "${issue_type}"
  _require_arg "summary" "${summary}"

  local payload
  payload=$(jq -n \
    --arg pk "${project_key}" \
    --arg it "${issue_type}" \
    --arg sum "${summary}" \
    --arg desc "${description}" \
    '{
      fields: {
        project: { key: $pk },
        issuetype: { name: $it },
        summary: $sum,
        description: (if $desc != "" then {
          type: "doc",
          version: 1,
          content: [{
            type: "paragraph",
            content: [{ type: "text", text: $desc }]
          }]
        } else null end)
      }
    }')
  _curl_post "${BASE_URL}/issue" "${payload}"
}

cmd_edit_issue() {
  local key="$1"
  local fields_json="$2"
  _require_arg "issue key" "${key}"
  _require_arg "fields JSON" "${fields_json}"
  _curl_put "${BASE_URL}/issue/${key}" "{\"fields\": ${fields_json}}"
}

cmd_get_comments() {
  local key="$1"
  _require_arg "issue key" "${key}"
  local max_results="${2:-20}"
  _curl_get "${BASE_URL}/issue/${key}/comment?maxResults=${max_results}&orderBy=-created"
}

cmd_add_comment() {
  local key="$1"
  local body_text="$2"
  _require_arg "issue key" "${key}"
  _require_arg "comment body" "${body_text}"
  local payload
  payload=$(jq -n --arg text "${body_text}" '{
    body: {
      type: "doc",
      version: 1,
      content: [{
        type: "paragraph",
        content: [{ type: "text", text: $text }]
      }]
    }
  }')
  _curl_post "${BASE_URL}/issue/${key}/comment" "${payload}"
}

cmd_get_transitions() {
  local key="$1"
  _require_arg "issue key" "${key}"
  _curl_get "${BASE_URL}/issue/${key}/transitions"
}

cmd_transition_issue() {
  local key="$1"
  local transition_id="$2"
  _require_arg "issue key" "${key}"
  _require_arg "transition ID" "${transition_id}"
  _curl_post "${BASE_URL}/issue/${key}/transitions" \
    "$(jq -n --arg id "${transition_id}" '{transition: {id: $id}}')"
}

cmd_add_worklog() {
  local key="$1"
  local time_spent="$2"
  _require_arg "issue key" "${key}"
  _require_arg "time spent" "${time_spent}"
  local comment="${3:-}"
  local payload
  payload=$(jq -n \
    --arg ts "${time_spent}" \
    --arg cm "${comment}" \
    '{
      timeSpent: $ts
    } + (if $cm != "" then {
      comment: {
        type: "doc",
        version: 1,
        content: [{
          type: "paragraph",
          content: [{ type: "text", text: $cm }]
        }]
      }
    } else {} end)')
  _curl_post "${BASE_URL}/issue/${key}/worklog" "${payload}"
}

cmd_get_projects() {
  local max_results="${1:-50}"
  _curl_get "${BASE_URL}/project?maxResults=${max_results}&orderBy=name"
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

case "${1:-help}" in
  help)
    ;;
  *)
    _init_config
    ;;
esac

case "${1:-help}" in
  test)               cmd_test ;;
  get-issue)          cmd_get_issue "${2:-}" "${3:-}" ;;
  search)             cmd_search "${2:-}" "${3:-}" "${4:-}" ;;
  create-issue)       cmd_create_issue "${2:-}" "${3:-}" "${4:-}" "${5:-}" ;;
  edit-issue)         cmd_edit_issue "${2:-}" "${3:-}" ;;
  get-comments)       cmd_get_comments "${2:-}" "${3:-}" ;;
  add-comment)        cmd_add_comment "${2:-}" "${3:-}" ;;
  get-transitions)    cmd_get_transitions "${2:-}" ;;
  transition-issue)   cmd_transition_issue "${2:-}" "${3:-}" ;;
  add-worklog)        cmd_add_worklog "${2:-}" "${3:-}" "${4:-}" ;;
  get-projects)       cmd_get_projects "${2:-}" ;;
  help|*)
    cat <<'USAGE'
Usage: bash jira.sh <command> [args...]

Commands:
  test                                    Test authentication
  get-issue <KEY> [fields]                Get issue details
  search <JQL> [maxResults] [fields]      Search issues with JQL
  create-issue <PROJECT> <TYPE> <SUMMARY> [DESCRIPTION]
  edit-issue <KEY> <FIELDS_JSON>          Edit issue fields
  get-comments <KEY> [maxResults]         Get issue comments
  add-comment <KEY> <BODY>               Add a comment
  get-transitions <KEY>                   Get available transitions
  transition-issue <KEY> <TRANSITION_ID>  Transition issue status
  add-worklog <KEY> <TIME> [COMMENT]      Add worklog entry
  get-projects [maxResults]               List projects

Environment variables required:
  JIRA_DOMAIN     e.g. mycompany.atlassian.net
  JIRA_EMAIL      e.g. user@example.com
  JIRA_API_TOKEN  API token from https://id.atlassian.com/manage-profile/security/api-tokens
USAGE
    ;;
esac
