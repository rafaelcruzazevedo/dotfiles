---
description: Git branch naming, commit format, and PR guidelines
globs: []
---

# Git Workflow Standards

## Branch Naming

**Format**: `<branch_type>/<branch_name>`

### Branch Types

| Type | Purpose |
|------|---------|
| `feature/` | New functionality |
| `enhancement/` | Improvements to existing features |
| `bugfix/` | Bug fixes |
| `hotfix/` | Critical production fixes |
| `support/` | Support tasks (docs, config) |
| `docs/` | Documentation updates |
| `test/` | Test additions or modifications |
| `ci/` | CI/CD configuration |
| `bump/` | Dependency updates |

### Guidelines

- Use lowercase with hyphens
- Short but descriptive
- Reflects the work being done

**Examples**:
```bash
# Good
feature/user-authentication
bugfix/login-error-handling
support/update-readme
hotfix/payment-processing-crash

# Bad
feature/new_stuff
my-branch
fix
feature/PROJ-123  # Don't use ticket IDs as branch names
```

## Commit Message Format

**Header**: `[OPTIONAL-REFERENCE] Verb subject description`

### Allowed Verbs (PascalCase)

| Verb | Purpose |
|------|---------|
| `Add` | New functionality or files |
| `Disable` | Disabling features |
| `Enable` | Enabling features |
| `Fix` | Bug fixes |
| `Improve` | Enhancements to existing functionality |
| `Migrate` | Migrations or data transformations |
| `Move` | Moving files or code |
| `Release` | Version releases |
| `Remove` | Removing functionality or files |
| `Replace` | Replacing implementations |
| `Revert` | Reverting previous changes |
| `Update` | Updates to existing functionality |

### Commit Rules

- Verb must be PascalCase
- Maximum length: 100 characters
- No trailing punctuation
- No quotes or backticks
- Subject is required after verb

**Examples**:
```text
# Good
Add user authentication system
Fix payment processing error
Update dependencies to latest versions
[PROJ-123] Add user authentication

# Bad
add user authentication    # Wrong case
Create new feature         # Invalid verb
Add.                       # Trailing punctuation
Add "new feature"          # Using quotes
```

### Atomic Commits

- Each commit should address ONE specific change
- Commits should be logical units of work
- Test your changes before committing

## Pull Request Guidelines

### Before Creating PR

- All commits follow commit guidelines
- Tests are passing
- Code follows quality standards
- Branch is up to date with base branch
- No console.log or debug code
- No commented-out code

### PR Description Template

```markdown
## Summary

Brief description of the changes

## Changes

- Change 1
- Change 2
- Change 3

## Test Plan

1. Step to test
2. Expected result

## Related Issues

Closes #123
Related to PROJ-456
```

### PR Best Practices

- Keep PRs focused and small
- One feature/fix per PR
- Add screenshots for UI changes
- Link related issues
- Request specific reviewers

**Size Guidelines**:
- < 400 lines: Easy to review
- 400-800 lines: Consider splitting
- > 800 lines: Must split

## Code Review

### As PR Author

- Be open to feedback
- Explain decisions with arguments
- Mark conversations as resolved when addressed

### As Reviewer

- Review code thoroughly
- Ask questions when unclear
- Suggest improvements constructively
- Check for: code quality, test coverage, performance, security, accessibility

**Comment Prefixes**:
- `nit:` - Minor suggestions
- `question:` - Seeking clarification
- `blocker:` - Must fix before merge
- `suggestion:` - Optional improvement

## Merge Strategy

- Prefer "Squash and merge" for feature branches
- Use "Rebase and merge" for clean commit history
- Never merge your own PR
- All comments must be resolved
- CI/CD checks must pass

## GitHub CLI (gh)

```bash
# Create PR
gh pr create --title "Add feature" --body "Description"

# View PR
gh pr view 123

# Checkout PR locally
gh pr checkout 123

# Approve PR
gh pr review 123 --approve

# Merge PR with squash
gh pr merge 123 --squash --delete-branch
```
