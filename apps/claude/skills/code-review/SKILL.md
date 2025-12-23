---
name: code-review
description: Code review checklist and guidelines. Use when reviewing code, creating review comments, or preparing code for review.
---

# Code Review Skill

## When to Use

- Reviewing pull requests
- Preparing code for review
- Writing review comments
- Responding to review feedback

## Review Checklist

### Code Quality

- [ ] Code follows project style guidelines (Biome)
- [ ] No unnecessary complexity (cognitive complexity < 15)
- [ ] Functions/methods are focused and single-purpose
- [ ] No code duplication
- [ ] Clear variable and function names
- [ ] No commented-out code
- [ ] No console.log or debug statements

### TypeScript

- [ ] No `any` types
- [ ] Proper type definitions
- [ ] Strict mode compliance
- [ ] Zod schemas for runtime validation

### React Components

- [ ] Functional components with TypeScript
- [ ] Props interface defined
- [ ] Named exports used
- [ ] Proper hook usage (exhaustive deps)
- [ ] No prop drilling (composition used)
- [ ] Memoization used appropriately

### Testing

- [ ] Unit tests for new functionality
- [ ] Tests cover happy path and edge cases
- [ ] Accessible queries used (getByRole, getByLabel)
- [ ] No `.only()` or `.skip()` in tests
- [ ] Tests are deterministic (no flaky tests)

### Security

- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] No XSS vulnerabilities
- [ ] External links have `rel="noopener noreferrer"`

### Accessibility

- [ ] Semantic HTML used
- [ ] Alt text for images
- [ ] ARIA labels where needed
- [ ] Keyboard navigation works

### Performance

- [ ] No unnecessary re-renders
- [ ] Large lists virtualized
- [ ] Images optimized
- [ ] No memory leaks (cleanup in useEffect)

## Comment Guidelines

### Prefixes

| Prefix | Meaning |
|--------|---------|
| `nit:` | Minor suggestion, optional |
| `question:` | Seeking clarification |
| `blocker:` | Must fix before merge |
| `suggestion:` | Improvement idea, optional |
| `praise:` | Something well done |

### Writing Good Comments

**DO**:
- Be specific about the issue
- Provide examples or alternatives
- Explain the reasoning
- Link to documentation when relevant

**DON'T**:
- Be vague ("this is wrong")
- Make it personal
- Demand changes without explanation
- Nitpick excessively

### Examples

```markdown
# Good
nit: Consider using `const` instead of `let` here since the value isn't reassigned.

question: What happens if `user` is null here? Should we add a null check?

blocker: This query is vulnerable to SQL injection. Please use parameterized queries.

suggestion: This logic is duplicated in `UserService`. Consider extracting to a shared utility.

# Bad
This is wrong.
Why did you do it this way?
Fix this.
```

## Responding to Reviews

### As Author

- [ ] Read all comments carefully
- [ ] Address each comment (fix or explain)
- [ ] Mark conversations as resolved when done
- [ ] Thank reviewers for feedback
- [ ] Push fixes in separate commits for easy re-review

### Example Responses

```markdown
# Addressing feedback
Done - changed to use `const` as suggested.

# Explaining decision
I chose this approach because [reason]. However, I see your point about [concern]. Would [alternative] work better?

# Requesting clarification
Could you elaborate on what you mean by [X]? I want to make sure I address this correctly.
```

## Before Requesting Review

1. **Self-review your changes**
   - Read through the diff
   - Check for obvious issues
   - Run linting and tests

2. **Clean up commits**
   - Squash WIP commits
   - Use meaningful commit messages
   - Rebase on latest main

3. **Write good PR description**
   - Explain what and why
   - List all changes
   - Include test plan
   - Link related issues

4. **Add context**
   - Screenshots for UI changes
   - Before/after comparisons
   - Performance metrics if relevant
