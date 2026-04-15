# Confluence Cloud REST API Reference

## Authentication

Same as Jira - HTTP Basic Auth with `email:api_token`. The `confluence.sh` wrapper handles this via `curl -u`.

## API Versions

Confluence Cloud has two API versions:
- **V2** (`/wiki/api/v2/`): Modern, cleaner endpoints. Used for most operations.
- **V1** (`/wiki/rest/api/`): Legacy but required for CQL search and some label operations.

## V2 Endpoints

### Get Spaces

```
GET /wiki/api/v2/spaces?limit=25&sort=name
```

Returns spaces with `id`, `key`, `name`, `type`, `status`.

### Get Pages in Space

```
GET /wiki/api/v2/spaces/{spaceId}/pages?limit=25&sort=-modified-date&status=current
```

Sort options: `id`, `-id`, `title`, `-title`, `created-date`, `-created-date`, `modified-date`, `-modified-date`.

### Get Page

```
GET /wiki/api/v2/pages/{pageId}?body-format=storage
```

Body format options:
- `storage` - Confluence storage format (XHTML-like)
- `atlas_doc_format` - Atlassian Document Format (JSON)

Response includes: `id`, `title`, `spaceId`, `status`, `body.storage.value`, `version.number`, `createdAt`, `_links`.

### Create Page

```
POST /wiki/api/v2/pages
Content-Type: application/json

{
  "spaceId": "123456",
  "status": "current",
  "title": "Page Title",
  "parentId": "789012",
  "body": {
    "representation": "storage",
    "value": "<p>Page content in storage format</p>"
  }
}
```

### Update Page

```
PUT /wiki/api/v2/pages/{pageId}
Content-Type: application/json

{
  "id": "123456",
  "status": "current",
  "title": "Updated Title",
  "body": {
    "representation": "storage",
    "value": "<p>Updated content</p>"
  },
  "version": {
    "number": 2,
    "message": "Updated via API"
  }
}
```

The version number must be incremented by 1 from the current version. The script handles this automatically.

### Get Child Pages

```
GET /wiki/api/v2/pages/{pageId}/children?limit=25
```

### Get Footer Comments

```
GET /wiki/api/v2/pages/{pageId}/footer-comments?limit=25&body-format=storage
```

### Add Footer Comment

```
POST /wiki/api/v2/footer-comments
Content-Type: application/json

{
  "pageId": "123456",
  "body": {
    "representation": "storage",
    "value": "<p>Comment text</p>"
  }
}
```

### Get Labels

```
GET /wiki/api/v2/pages/{pageId}/labels
```

## V1 Endpoints

### Search with CQL

```
GET /wiki/rest/api/search?cql={encoded_cql}&limit=20
```

CQL (Confluence Query Language) patterns:
- `type = page AND space = "PROJ"` - pages in space
- `title ~ "meeting"` - title contains
- `text ~ "search term"` - full-text search
- `label = "important"` - by label
- `creator = currentUser()` - my pages
- `lastModified >= "2024-01-01"` - recently modified
- `type = page AND space = "PROJ" ORDER BY lastModified DESC` - sorted
- `ancestor = 123456` - descendants of a page
- `type = blogpost AND space = "PROJ"` - blog posts

### Add Label (V1)

```
POST /wiki/rest/api/content/{pageId}/label
Content-Type: application/json

[{"prefix": "global", "name": "label-name"}]
```

## Confluence Storage Format

Confluence uses XHTML-like storage format for page content:

```html
<!-- Paragraph -->
<p>Simple text</p>

<!-- Heading -->
<h2>Section Title</h2>

<!-- Bold and italic -->
<p><strong>bold</strong> and <em>italic</em></p>

<!-- Bullet list -->
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
</ul>

<!-- Numbered list -->
<ol>
  <li>Step 1</li>
  <li>Step 2</li>
</ol>

<!-- Code block -->
<ac:structured-macro ac:name="code">
  <ac:parameter ac:name="language">javascript</ac:parameter>
  <ac:plain-text-body><![CDATA[const x = 1;]]></ac:plain-text-body>
</ac:structured-macro>

<!-- Info panel -->
<ac:structured-macro ac:name="info">
  <ac:rich-text-body><p>Information note</p></ac:rich-text-body>
</ac:structured-macro>

<!-- Warning panel -->
<ac:structured-macro ac:name="warning">
  <ac:rich-text-body><p>Warning note</p></ac:rich-text-body>
</ac:structured-macro>

<!-- Table -->
<table>
  <thead>
    <tr><th>Header 1</th><th>Header 2</th></tr>
  </thead>
  <tbody>
    <tr><td>Cell 1</td><td>Cell 2</td></tr>
  </tbody>
</table>

<!-- Link -->
<a href="https://example.com">Link text</a>

<!-- Link to another Confluence page -->
<ac:link><ri:page ri:content-title="Page Title" ri:space-key="SPACE" /></ac:link>

<!-- Status macro (colored lozenge) -->
<ac:structured-macro ac:name="status">
  <ac:parameter ac:name="colour">Green</ac:parameter>
  <ac:parameter ac:name="title">DONE</ac:parameter>
</ac:structured-macro>

<!-- Table of contents -->
<ac:structured-macro ac:name="toc" />

<!-- Expand/collapse section -->
<ac:structured-macro ac:name="expand">
  <ac:parameter ac:name="title">Click to expand</ac:parameter>
  <ac:rich-text-body><p>Hidden content</p></ac:rich-text-body>
</ac:structured-macro>
```

## Error Codes

| Code | Meaning |
|------|---------|
| 400  | Bad request (check payload format) |
| 401  | Authentication failed |
| 403  | Permission denied (check space permissions) |
| 404  | Page/space not found |
| 409  | Version conflict (stale version number on update) |
| 429  | Rate limited |

## Rate Limits

Confluence Cloud allows ~100 requests per 10 seconds per user. Same as Jira.

## Tips

- Space IDs are numeric. Use `get-spaces` to find the ID for a space key.
- Page IDs are numeric. Use `search` or `get-pages` to find page IDs.
- When updating pages, the script auto-increments the version number.
- Storage format is XHTML-like. For simple text, wrap in `<p>` tags.
- CQL search requires URL encoding. The script handles this automatically.
