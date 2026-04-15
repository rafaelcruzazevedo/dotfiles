# Jira Cloud REST API v3 Reference

## Authentication

All requests use HTTP Basic Auth: `email:api_token` (base64-encoded in the `Authorization` header). The `jira.sh` wrapper handles this via `curl -u`.

API tokens: https://id.atlassian.com/manage-profile/security/api-tokens

## Endpoints

### Get Issue

```
GET /rest/api/3/issue/{issueIdOrKey}?fields={fields}
```

Common fields: `summary`, `status`, `issuetype`, `priority`, `assignee`, `reporter`, `description`, `created`, `updated`, `labels`, `components`, `fixVersions`, `parent`, `subtasks`.

### Search with JQL

```
POST /rest/api/3/search
Content-Type: application/json

{
  "jql": "project = PROJ AND status = 'In Progress' ORDER BY priority DESC",
  "maxResults": 20,
  "fields": ["summary", "status", "assignee", "priority"]
}
```

Useful JQL patterns:
- `project = PROJ` - issues in project
- `assignee = currentUser()` - my issues
- `status = "In Progress"` - by status
- `sprint in openSprints()` - current sprint
- `created >= -7d` - last 7 days
- `labels = "bug"` - by label
- `text ~ "search term"` - full-text search
- `priority = High AND status != Done` - compound queries
- `ORDER BY priority DESC, created ASC` - sorting

### Create Issue

```
POST /rest/api/3/issue
Content-Type: application/json

{
  "fields": {
    "project": { "key": "PROJ" },
    "issuetype": { "name": "Task" },
    "summary": "Issue title",
    "description": {
      "type": "doc",
      "version": 1,
      "content": [{
        "type": "paragraph",
        "content": [{ "type": "text", "text": "Description text" }]
      }]
    },
    "priority": { "name": "High" },
    "labels": ["backend", "urgent"],
    "assignee": { "accountId": "5b10ac8d82e05b22cc7d4ef5" },
    "parent": { "key": "PROJ-100" }
  }
}
```

Issue types: `Task`, `Bug`, `Story`, `Epic`, `Sub-task` (project-dependent).

### Edit Issue

```
PUT /rest/api/3/issue/{issueIdOrKey}
Content-Type: application/json

{
  "fields": {
    "summary": "Updated title",
    "priority": { "name": "High" },
    "labels": ["backend"]
  }
}
```

### Get Comments

```
GET /rest/api/3/issue/{issueIdOrKey}/comment?maxResults=20&orderBy=-created
```

### Add Comment

```
POST /rest/api/3/issue/{issueIdOrKey}/comment
Content-Type: application/json

{
  "body": {
    "type": "doc",
    "version": 1,
    "content": [{
      "type": "paragraph",
      "content": [{ "type": "text", "text": "Comment text here" }]
    }]
  }
}
```

### Get Transitions

```
GET /rest/api/3/issue/{issueIdOrKey}/transitions
```

Returns available transitions with their IDs. You must call this first to get the transition ID before transitioning.

### Transition Issue

```
POST /rest/api/3/issue/{issueIdOrKey}/transitions
Content-Type: application/json

{
  "transition": { "id": "31" }
}
```

### Add Worklog

```
POST /rest/api/3/issue/{issueIdOrKey}/worklog
Content-Type: application/json

{
  "timeSpent": "2h 30m",
  "comment": {
    "type": "doc",
    "version": 1,
    "content": [{
      "type": "paragraph",
      "content": [{ "type": "text", "text": "Worked on implementation" }]
    }]
  }
}
```

Time format: `1d`, `2h`, `30m`, `1d 2h 30m`.

### Get Projects

```
GET /rest/api/3/project?maxResults=50&orderBy=name
```

## Atlassian Document Format (ADF)

Jira v3 uses ADF for rich text fields (description, comments). Basic structure:

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "paragraph",
      "content": [{ "type": "text", "text": "Plain text" }]
    },
    {
      "type": "heading",
      "attrs": { "level": 2 },
      "content": [{ "type": "text", "text": "Heading" }]
    },
    {
      "type": "bulletList",
      "content": [{
        "type": "listItem",
        "content": [{
          "type": "paragraph",
          "content": [{ "type": "text", "text": "Item 1" }]
        }]
      }]
    },
    {
      "type": "codeBlock",
      "attrs": { "language": "javascript" },
      "content": [{ "type": "text", "text": "const x = 1;" }]
    }
  ]
}
```

## Error Codes

| Code | Meaning |
|------|---------|
| 400  | Bad request (check JSON payload) |
| 401  | Authentication failed (check email/token) |
| 403  | Permission denied |
| 404  | Issue/resource not found |
| 429  | Rate limited (wait and retry) |

## Rate Limits

Jira Cloud allows ~100 requests per 10 seconds per user. The script uses `--fail-with-body` to surface errors clearly.
