# GitHub CLI (`gh`) Detailed Command Reference

## Authentication

`gh` manages authentication automatically. Tokens are stored securely by the CLI.

```bash
gh auth login                    # Interactive login (browser or token)
gh auth login --with-token < token.txt  # Non-interactive
gh auth status                   # Check current auth state
gh auth token                    # Print current token
gh auth refresh -s repo,read:org # Add scopes
```

## Pull Requests - Full Options

### Create

```bash
gh pr create \
  --title "Title" \
  --body "Description" \
  --base main \
  --head feature-branch \
  --label "bug,urgent" \
  --assignee "@me,teammate" \
  --reviewer "reviewer1,reviewer2" \
  --milestone "v1.0" \
  --project "Board Name" \
  --draft                        # Create as draft
```

Use `--body-file` to read body from a file:

```bash
gh pr create --title "Title" --body-file pr-description.md
```

### List with Filters

```bash
gh pr list --state open          # Default
gh pr list --state closed
gh pr list --state merged
gh pr list --state all
gh pr list --label "bug"
gh pr list --assignee "@me"
gh pr list --author "username"
gh pr list --base main           # PRs targeting main
gh pr list --head feature        # PRs from feature branch
gh pr list --search "is:draft"   # GitHub search syntax
gh pr list --limit 50
```

### View with JSON

```bash
# Available JSON fields:
gh pr view 123 --json \
  number,title,state,body,author,baseRefName,headRefName,\
  url,createdAt,updatedAt,closedAt,mergedAt,mergeable,\
  additions,deletions,changedFiles,commits,\
  labels,assignees,reviewRequests,reviews,\
  comments,files,checks,milestone,projectCards,\
  isDraft,reviewDecision,statusCheckRollup

# Common patterns:
gh pr view 123 --json title,state,body
gh pr view 123 --json reviews --jq '.reviews[] | "\(.author.login): \(.state)"'
gh pr view 123 --json files --jq '.files[].path'
gh pr view 123 --json statusCheckRollup --jq '.statusCheckRollup[] | "\(.name): \(.conclusion)"'
```

### Merge Options

```bash
gh pr merge 123 --merge           # Merge commit (default)
gh pr merge 123 --squash          # Squash and merge
gh pr merge 123 --rebase          # Rebase and merge
gh pr merge 123 --auto            # Enable auto-merge when checks pass
gh pr merge 123 --delete-branch   # Delete branch after merge
gh pr merge 123 --squash --subject "feat: add auth" --body "Closes #456"
```

### Edit

```bash
gh pr edit 123 \
  --title "New title" \
  --body "New body" \
  --base main \
  --add-label "ready" \
  --remove-label "wip" \
  --add-assignee "user" \
  --remove-assignee "user" \
  --add-reviewer "user" \
  --remove-reviewer "user" \
  --milestone "v1.0"
```

### Update Branch

```bash
gh pr update-branch 123          # Merge base into PR branch
gh pr update-branch 123 --rebase # Rebase PR branch onto base
```

### Review

```bash
gh pr review 123 --approve
gh pr review 123 --approve --body "Looks good!"
gh pr review 123 --comment --body "Some thoughts..."
gh pr review 123 --request-changes --body "Please fix X"
```

### Lock/Unlock

```bash
gh pr lock 123 --reason "resolved"   # Reasons: off-topic, too-heated, resolved, spam
gh pr unlock 123
```

## Issues - Full Options

### Create

```bash
gh issue create \
  --title "Bug: login fails" \
  --body "Steps to reproduce..." \
  --label "bug,priority:high" \
  --assignee "@me" \
  --milestone "v1.0" \
  --project "Board Name"

gh issue create --body-file issue-template.md --title "Title"
```

### List with Filters

```bash
gh issue list --state open
gh issue list --state closed
gh issue list --state all
gh issue list --label "bug"
gh issue list --label "bug,urgent"  # AND logic
gh issue list --assignee "@me"
gh issue list --author "username"
gh issue list --milestone "v1.0"
gh issue list --search "is:open label:bug sort:created-asc"
gh issue list --limit 100
```

### View with JSON

```bash
# Available JSON fields:
gh issue view 456 --json \
  number,title,state,body,author,url,\
  createdAt,updatedAt,closedAt,\
  labels,assignees,comments,milestone,\
  projectCards,reactionGroups,isPinned

gh issue view 456 --json comments --jq '.comments[] | "\(.author.login): \(.body)"'
```

### Edit

```bash
gh issue edit 456 \
  --title "New title" \
  --body "Updated description" \
  --add-label "confirmed" \
  --remove-label "needs-triage" \
  --add-assignee "user" \
  --remove-assignee "user" \
  --milestone "v2.0"
```

### Develop (Create Branch for Issue)

```bash
gh issue develop 456                # Creates branch issue-456
gh issue develop 456 --name "fix-login"  # Custom branch name
gh issue develop 456 --base main    # Specify base branch
gh issue develop 456 --checkout     # Create and checkout
```

## Repository - Full Options

### View

```bash
gh repo view                     # Current repo
gh repo view owner/repo
gh repo view owner/repo --json name,description,url,stargazerCount,forkCount,defaultBranchRef
gh repo view --web               # Open in browser
```

### List

```bash
gh repo list owner               # User's repos
gh repo list org-name            # Org repos
gh repo list --language go       # Filter by language
gh repo list --visibility public # public/private/internal
gh repo list --source            # Non-forks only
gh repo list --fork              # Forks only
gh repo list --limit 50
gh repo list --json name,description,url,isPrivate,primaryLanguage
```

### Create

```bash
gh repo create my-repo --public --clone
gh repo create my-repo --private --add-readme
gh repo create org/repo --public --template owner/template-repo
```

### Fork & Sync

```bash
gh repo fork owner/repo          # Fork to your account
gh repo fork owner/repo --clone  # Fork and clone locally
gh repo sync                     # Sync current fork with upstream
gh repo sync owner/fork --source owner/upstream  # Sync specific fork
```

## CI/CD - Workflow Runs

### List Runs

```bash
gh run list                      # Recent runs
gh run list --workflow "ci.yml"  # Filter by workflow
gh run list --branch main        # Filter by branch
gh run list --status failure     # Filter by status (queued, in_progress, completed)
gh run list --user username      # Filter by trigger user
gh run list --limit 20
gh run list --json databaseId,name,status,conclusion,headBranch,createdAt
```

### View Run Details

```bash
gh run view <run-id>
gh run view <run-id> --json jobs --jq '.jobs[] | "\(.name): \(.conclusion)"'
gh run view <run-id> --log       # Full log output
gh run view <run-id> --log-failed # Only failed step logs
```

### Manage Runs

```bash
gh run watch <run-id>            # Watch live until complete
gh run rerun <run-id>            # Rerun entire run
gh run rerun <run-id> --failed   # Rerun only failed jobs
gh run cancel <run-id>           # Cancel running workflow
gh run download <run-id>         # Download artifacts
gh run download <run-id> -n "artifact-name"
```

### Trigger Workflows

```bash
gh workflow run ci.yml                    # Trigger workflow_dispatch
gh workflow run ci.yml --ref feature      # On specific branch
gh workflow run ci.yml -f param1=value1   # With input parameters
```

## Releases

### Create

```bash
gh release create v1.0.0                 # Interactive
gh release create v1.0.0 --title "v1.0.0" --notes "Release notes here"
gh release create v1.0.0 --notes-file CHANGELOG.md
gh release create v1.0.0 --generate-notes  # Auto-generate from commits
gh release create v1.0.0 --draft           # Create as draft
gh release create v1.0.0 --prerelease      # Mark as pre-release
gh release create v1.0.0 --target main     # Target specific branch
gh release create v1.0.0 ./dist/*.tar.gz   # Upload assets
```

### View & Download

```bash
gh release view v1.0.0
gh release view v1.0.0 --json tagName,name,body,assets,createdAt
gh release download v1.0.0                 # Download all assets
gh release download v1.0.0 -p "*.tar.gz"   # Pattern match
gh release download --latest                # Latest release
```

### Edit & Delete

```bash
gh release edit v1.0.0 --title "New Title" --notes "Updated notes"
gh release edit v1.0.0 --draft=false       # Publish a draft
gh release delete v1.0.0 --yes             # Delete without confirm
gh release upload v1.0.0 ./new-asset.zip   # Upload additional assets
```

## Search

### GitHub Search Syntax

```bash
# Repositories
gh search repos "react framework" --language typescript --stars ">1000"
gh search repos "org:facebook" --limit 10

# Issues
gh search issues "memory leak" --repo owner/repo --state open
gh search issues "label:bug" --repo owner/repo --sort created --order desc
gh search issues "is:open assignee:username" --limit 20

# Pull Requests
gh search prs "author:username" --repo owner/repo --state open
gh search prs "review:approved" --repo owner/repo

# Code
gh search code "TODO" --repo owner/repo
gh search code "function authenticate" --repo owner/repo --filename "*.ts"
gh search code "import express" --language javascript

# Commits
gh search commits "fix typo" --repo owner/repo
gh search commits "author:username" --since "2024-01-01"
```

### JSON Output for Search

```bash
gh search issues "bug" --repo owner/repo --json number,title,state,url \
  --jq '.[] | "\(.number) \(.title) [\(.state)]"'
```

## Raw API Access (`gh api`)

For any GitHub REST or GraphQL endpoint not covered by built-in commands.

### REST API

```bash
# GET requests
gh api repos/{owner}/{repo}
gh api repos/{owner}/{repo}/pulls/123/comments
gh api repos/{owner}/{repo}/branches --jq '.[].name'

# POST requests
gh api repos/{owner}/{repo}/issues/123/comments -f body="Comment text"

# PUT/PATCH/DELETE
gh api repos/{owner}/{repo}/issues/123 -X PATCH -f state="closed"
gh api repos/{owner}/{repo}/git/refs/heads/old-branch -X DELETE

# Typed parameters
gh api repos/{owner}/{repo}/issues -f title="Bug" -F draft=true -F number:=42

# Pagination
gh api repos/{owner}/{repo}/issues --paginate --jq '.[].title'

# With headers
gh api repos/{owner}/{repo} -H "Accept: application/vnd.github.v3+json"

# Response filtering
gh api repos/{owner}/{repo}/pulls --jq '.[] | {number, title, user: .user.login}'
```

### GraphQL API

```bash
# Simple query
gh api graphql -f query='{ viewer { login name } }'

# With variables
gh api graphql -f query='
  query($owner: String!, $repo: String!) {
    repository(owner: $owner, name: $repo) {
      issues(first: 10, states: OPEN) {
        nodes { number title }
      }
    }
  }
' -f owner="owner" -f repo="repo"

# Mutations
gh api graphql -f query='
  mutation($id: ID!) {
    addStar(input: {starrableId: $id}) {
      starrable { stargazerCount }
    }
  }
' -f id="MDEwOlJlcG9zaXRvcnkxMjM="
```

### Useful REST Endpoints

| Endpoint | Description |
|----------|-------------|
| `repos/{owner}/{repo}` | Repo metadata |
| `repos/{owner}/{repo}/pulls/{number}/comments` | PR review comments |
| `repos/{owner}/{repo}/pulls/{number}/files` | PR changed files |
| `repos/{owner}/{repo}/commits/{sha}/status` | Commit status |
| `repos/{owner}/{repo}/branches/{branch}/protection` | Branch protection rules |
| `repos/{owner}/{repo}/collaborators` | Repo collaborators |
| `repos/{owner}/{repo}/actions/workflows` | Workflow definitions |
| `repos/{owner}/{repo}/actions/runs` | Workflow runs |
| `repos/{owner}/{repo}/deployments` | Deployments |
| `orgs/{org}/repos` | Organization repositories |
| `orgs/{org}/members` | Organization members |
| `user/repos` | Authenticated user's repos |
| `notifications` | User notifications |

## Labels

```bash
gh label list                     # List all labels
gh label create "priority:high" --color "FF0000" --description "High priority"
gh label edit "bug" --name "type:bug" --color "CC0000"
gh label delete "old-label" --yes
gh label clone owner/source-repo  # Clone labels from another repo
```

## Projects (v2)

```bash
gh project list --owner "@me"
gh project view 1 --owner "@me"
gh project item-list 1 --owner "@me" --format json
gh project item-add 1 --owner "@me" --url "https://github.com/owner/repo/issues/123"
gh project field-list 1 --owner "@me"
```

## Additional Utilities

```bash
gh browse                        # Open repo in browser
gh browse 123                    # Open issue/PR #123 in browser
gh browse --settings             # Open repo settings
gh status                        # Show notifications and assigned items
gh cache list                    # List GitHub Actions caches
gh cache delete <key>            # Delete a cache entry
gh secret list                   # List repo secrets
gh variable list                 # List repo variables
```

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `GH_TOKEN` | Override authentication token |
| `GH_HOST` | Target GitHub Enterprise host |
| `GH_REPO` | Override repository context |
| `GH_EDITOR` | Editor for interactive commands |
| `GH_PAGER` | Pager for long output |
| `NO_COLOR` | Disable color output |
| `GH_DEBUG` | Enable debug logging |

## Rate Limits

GitHub API rate limits:
- **Authenticated**: 5,000 requests/hour (REST), 5,000 points/hour (GraphQL)
- **Search API**: 30 requests/minute

Check current limits:

```bash
gh api rate_limit --jq '.resources.core | "Used: \(.used)/\(.limit), Resets: \(.reset)"'
```
