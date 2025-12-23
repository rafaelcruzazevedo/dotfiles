---
name: git-workflow
description: Git workflows for branching, committing, and creating PRs. Use when working with Git operations, creating commits, or opening pull requests.
---

# Git Workflow Skill

## When to Use

- Creating new branches
- Writing commit messages
- Creating pull requests
- Resolving merge conflicts
- Managing branch history

## Branch Creation

### Format

```
<branch_type>/<branch_name>
```

### Common Branch Types

| Type | Use For |
|------|---------|
| `feature/` | New functionality |
| `bugfix/` | Bug fixes |
| `hotfix/` | Critical production fixes |
| `enhancement/` | Improvements |
| `docs/` | Documentation |

### Process

```bash
# 1. Ensure you're on main branch
git checkout master
git pull origin master

# 2. Create feature branch
git checkout -b feature/user-authentication

# 3. Work on changes...

# 4. Push branch
git push -u origin feature/user-authentication
```

## Commit Messages

### Format

```
[OPTIONAL-REFERENCE] Verb subject description
```

### Allowed Verbs

- `Add` - New functionality
- `Fix` - Bug fixes
- `Update` - Changes to existing code
- `Remove` - Removing code/files
- `Improve` - Enhancements
- `Migrate` - Data migrations
- `Revert` - Reverting changes

### Examples

```bash
# Simple commit
git commit -m "Add user authentication system"

# With issue reference
git commit -m "[PROJ-123] Fix login error handling"

# Multi-line
git commit -m "Add user profile component

Implements profile editing with avatar upload.
Includes form validation and error states."
```

### Rules

- Verb in PascalCase
- Max 100 characters for header
- No trailing punctuation
- Subject required after verb

## Pull Request Creation

### Pre-PR Checklist

- [ ] Code follows style guidelines
- [ ] Tests pass locally
- [ ] No console.log statements
- [ ] No commented-out code
- [ ] Branch is up to date with base

### Using GitHub CLI

```bash
# Create PR interactively
gh pr create

# Create PR with details
gh pr create \
  --title "Add user authentication" \
  --body "## Summary
Implements JWT authentication.

## Changes
- Add login endpoint
- Add token refresh
- Add protected routes

## Test Plan
1. Login with valid credentials
2. Verify token stored
3. Access protected route"

# Create draft PR
gh pr create --draft
```

### PR Size Guidelines

- **< 400 lines**: Ideal, easy to review
- **400-800 lines**: Consider splitting
- **> 800 lines**: Must split into smaller PRs

## History Management

### Interactive Rebase

```bash
# Rebase last 3 commits
git rebase -i HEAD~3

# Actions:
# pick - use commit
# reword - edit message
# squash - combine with previous
# fixup - combine, discard message
# drop - remove commit
```

### Fixup Commits

```bash
# Create fixup for specific commit
git commit --fixup <commit-hash>

# Auto-squash when rebasing
git rebase -i --autosquash HEAD~5
```

### Keep Branch Updated

```bash
git fetch origin
git rebase origin/master

# Force push if needed (only on feature branches!)
git push --force-with-lease
```

## Checklist for Git Operations

### Creating Branch
- [ ] Start from updated master/main
- [ ] Use correct branch type prefix
- [ ] Use kebab-case for branch name

### Creating Commit
- [ ] Use allowed verb in PascalCase
- [ ] Message describes what AND why
- [ ] No WIP commits in final PR

### Creating PR
- [ ] All tests pass
- [ ] PR description complete
- [ ] Linked to issues if applicable
- [ ] Requested reviewers
