#!/usr/bin/env bash
# confluence.sh - Bash wrapper for Confluence Cloud REST API
# Usage: bash confluence.sh <command> [args...]

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
  BASE_V2="https://${JIRA_DOMAIN}/wiki/api/v2"
  BASE_V1="https://${JIRA_DOMAIN}/wiki/rest/api"
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

_urlencode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote('''$1''', safe=''))"
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

cmd_test() {
  echo "Testing Confluence connection to ${JIRA_DOMAIN}..."
  _curl_get "${BASE_V2}/spaces?limit=1" | jq '{status: "ok", firstSpace: .results[0].name}'
}

cmd_get_spaces() {
  local limit="${1:-25}"
  _curl_get "${BASE_V2}/spaces?limit=${limit}&sort=name"
}

cmd_get_pages_in_space() {
  local space_id="$1"
  _require_arg "space ID" "${space_id}"
  local limit="${2:-25}"
  local sort="${3:--modified-date}"
  _curl_get "${BASE_V2}/spaces/${space_id}/pages?limit=${limit}&sort=${sort}&status=current"
}

cmd_get_page() {
  local page_id="$1"
  _require_arg "page ID" "${page_id}"
  local format="${2:-storage}"
  _curl_get "${BASE_V2}/pages/${page_id}?body-format=${format}"
}

cmd_search() {
  local cql="$1"
  _require_arg "CQL query" "${cql}"
  local limit="${2:-20}"
  local encoded_cql
  encoded_cql=$(_urlencode "${cql}")
  _curl_get "${BASE_V1}/search?cql=${encoded_cql}&limit=${limit}"
}

cmd_create_page() {
  local space_id="$1"
  local title="$2"
  local body="$3"
  local parent_id="${4:-}"
  _require_arg "space ID" "${space_id}"
  _require_arg "title" "${title}"
  _require_arg "body" "${body}"

  local payload
  payload=$(jq -n \
    --arg sid "${space_id}" \
    --arg title "${title}" \
    --arg body "${body}" \
    --arg pid "${parent_id}" \
    '{
      spaceId: $sid,
      status: "current",
      title: $title,
      body: {
        representation: "storage",
        value: $body
      }
    } + (if $pid != "" then { parentId: $pid } else {} end)')
  _curl_post "${BASE_V2}/pages" "${payload}"
}

cmd_update_page() {
  local page_id="$1"
  local title="$2"
  local body="$3"
  _require_arg "page ID" "${page_id}"
  _require_arg "title" "${title}"
  _require_arg "body" "${body}"

  # Get current version number
  local current_version
  current_version=$(_curl_get "${BASE_V2}/pages/${page_id}" | jq '.version.number')

  local new_version=$((current_version + 1))

  local payload
  payload=$(jq -n \
    --arg pid "${page_id}" \
    --arg title "${title}" \
    --arg body "${body}" \
    --argjson ver "${new_version}" \
    '{
      id: $pid,
      status: "current",
      title: $title,
      body: {
        representation: "storage",
        value: $body
      },
      version: {
        number: $ver,
        message: "Updated via API"
      }
    }')
  _curl_put "${BASE_V2}/pages/${page_id}" "${payload}"
}

cmd_get_child_pages() {
  local page_id="$1"
  _require_arg "page ID" "${page_id}"
  local limit="${2:-25}"
  _curl_get "${BASE_V2}/pages/${page_id}/children?limit=${limit}"
}

cmd_get_comments() {
  local page_id="$1"
  _require_arg "page ID" "${page_id}"
  local limit="${2:-25}"
  _curl_get "${BASE_V2}/pages/${page_id}/footer-comments?limit=${limit}&body-format=storage"
}

cmd_add_comment() {
  local page_id="$1"
  local body="$2"
  _require_arg "page ID" "${page_id}"
  _require_arg "comment body" "${body}"

  local payload
  payload=$(jq -n \
    --arg pid "${page_id}" \
    --arg body "${body}" \
    '{
      pageId: $pid,
      body: {
        representation: "storage",
        value: $body
      }
    }')
  _curl_post "${BASE_V2}/footer-comments" "${payload}"
}

cmd_get_labels() {
  local page_id="$1"
  _require_arg "page ID" "${page_id}"
  _curl_get "${BASE_V2}/pages/${page_id}/labels"
}

cmd_add_label() {
  local page_id="$1"
  local label="$2"
  _require_arg "page ID" "${page_id}"
  _require_arg "label" "${label}"

  # V1 endpoint for labels (v2 doesn't support adding labels easily)
  _curl_post "${BASE_V1}/content/${page_id}/label" \
    "[$(jq -n --arg l "${label}" '{prefix: "global", name: $l}')]"
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
  test)                cmd_test ;;
  get-spaces)          cmd_get_spaces "${2:-}" ;;
  get-pages)           cmd_get_pages_in_space "${2:-}" "${3:-}" "${4:-}" ;;
  get-page)            cmd_get_page "${2:-}" "${3:-}" ;;
  search)              cmd_search "${2:-}" "${3:-}" ;;
  create-page)         cmd_create_page "${2:-}" "${3:-}" "${4:-}" "${5:-}" ;;
  update-page)         cmd_update_page "${2:-}" "${3:-}" "${4:-}" ;;
  get-child-pages)     cmd_get_child_pages "${2:-}" "${3:-}" ;;
  get-comments)        cmd_get_comments "${2:-}" "${3:-}" ;;
  add-comment)         cmd_add_comment "${2:-}" "${3:-}" ;;
  get-labels)          cmd_get_labels "${2:-}" ;;
  add-label)           cmd_add_label "${2:-}" "${3:-}" ;;
  help|*)
    cat <<'USAGE'
Usage: bash confluence.sh <command> [args...]

Commands:
  test                                          Test authentication
  get-spaces [limit]                            List spaces
  get-pages <SPACE_ID> [limit] [sort]           List pages in space
  get-page <PAGE_ID> [format]                   Get page content (format: storage|atlas_doc_format)
  search <CQL> [limit]                          Search with CQL
  create-page <SPACE_ID> <TITLE> <BODY> [PARENT_ID]  Create a page
  update-page <PAGE_ID> <TITLE> <BODY>          Update a page
  get-child-pages <PAGE_ID> [limit]             Get child pages
  get-comments <PAGE_ID> [limit]                Get footer comments
  add-comment <PAGE_ID> <BODY>                  Add a footer comment
  get-labels <PAGE_ID>                          Get page labels
  add-label <PAGE_ID> <LABEL>                   Add a label to a page

Environment variables required (same as Jira):
  JIRA_DOMAIN or JIRA_URL   e.g. mycompany.atlassian.net
  JIRA_EMAIL                e.g. user@example.com
  JIRA_API_TOKEN            API token from https://id.atlassian.com/manage-profile/security/api-tokens
USAGE
    ;;
esac
