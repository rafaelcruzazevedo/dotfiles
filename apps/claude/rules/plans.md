---
paths:
  - .claude/plans/**
---

# Plan File Format

Every plan file MUST begin with the following YAML frontmatter:

```
---
title: <Short readable title describing the plan>
description: <What this plan is about — enough context to judge relevance without opening the file>
status: draft | active | completed | abandoned | superseded | blocked
reason: <Required when status is completed, abandoned, superseded, or blocked>
createdAt: <YYYY-MM-DD>
updatedAt: <YYYY-MM-DD>
---
```

## Status values

| Status | Meaning | `reason` required? |
|--------|---------|-------------------|
| `draft` | Plan in progress, still being discussed | No |
| `active` | Approved, implementation underway | No |
| `completed` | Work finished and merged | Yes — what was delivered (e.g., "Merged in PR #456") |
| `abandoned` | Plan discarded, will not be implemented | Yes — why it was dropped (e.g., "Requirements changed, no longer needed") |
| `superseded` | Replaced by a newer plan | Yes — which plan replaced it (e.g., "Replaced by ai-agent-react-web-sdk.md") |
| `blocked` | Waiting on external dependency | Yes — what is blocking (e.g., "Waiting on PR #123 to merge first") |

## Rules

- `title`: A human-readable name (e.g., "AI Agent React SDK Restructure", "Fix auth redirect loop"). This is the primary way to identify the plan
- `description`: Explains what the plan covers — the problem, scope, or goal. Keep it concise but don't sacrifice clarity for brevity
- `status`: Set to `draft` when first created, `active` when implementation begins
- `reason`: MUST be provided when status is `completed`, `abandoned`, `superseded`, or `blocked`. Omit for `draft` and `active`
- `updatedAt`: Update this date every time the plan content changes
- When updating an existing plan, preserve the `createdAt` and update `updatedAt` and `status` as needed
