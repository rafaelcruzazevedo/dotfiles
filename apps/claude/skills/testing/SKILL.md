---
name: testing
description: Write tests using Vitest and Testing Library. Use when asked to write tests, add test coverage, or test a component/function.
---

# Testing Skill

## When to Use

- Writing unit tests
- Testing React components
- Adding test coverage
- Testing custom hooks
- E2E test scenarios

## Test Types

| Type | Tool | Purpose |
|------|------|---------|
| Unit | Vitest + Testing Library | Component rendering, hooks, utilities |
| Component | Storybook + Vitest | Browser-based interaction testing |
| Visual | Playwright | Screenshot comparison |
| E2E | Playwright | Full user journeys |

## Process

1. **Identify What to Test**
   - Component rendering
   - User interactions
   - State changes
   - Edge cases and errors

2. **Choose Query Method**
   - Prefer `getByRole`, `getByLabelText`, `getByText`
   - Avoid CSS selectors and implementation details

3. **Write Tests**
   - One concept per test
   - Use descriptive names with `should`
   - Test behavior, not implementation

4. **Verify Coverage**
   - Run `npm run test:coverage`
   - Aim for 80%+ coverage

## Templates

See [templates/](templates/) for test file templates.

## Unit Test Template

```tsx
import { render, screen } from '@testing-library/react';
import { userEvent } from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { Component } from './index';

describe('Component', () => {
  it('should render correctly', () => {
    render(<Component>Test</Component>);

    expect(screen.getByText('Test')).toBeInTheDocument();
  });

  it('should handle click events', async () => {
    const handleClick = vi.fn();

    render(<Component onClick={handleClick}>Click me</Component>);

    await userEvent.click(screen.getByRole('button'));

    expect(handleClick).toHaveBeenCalledOnce();
  });
});
```

## Hook Test Template

```tsx
import { renderHook, waitFor } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { useCustomHook } from './use-custom-hook';

describe('useCustomHook', () => {
  it('should return initial state', () => {
    const { result } = renderHook(() => useCustomHook());

    expect(result.current.value).toBe('initial');
  });
});
```

## E2E Test Template

```typescript
import { expect, test } from '@playwright/test';

test.describe('Feature', () => {
  test('should complete user flow', async ({ page }) => {
    await page.goto('/');

    await page.getByRole('button', { name: /start/i }).click();

    await expect(page).toHaveURL('/next-page');
  });
});
```

## Query Priority

1. `getByRole()` - Best choice
2. `getByLabelText()` - Forms
3. `getByText()` - Content
4. `getByTestId()` - Last resort

## Checklist

- [ ] Tests focus on behavior, not implementation
- [ ] Accessible queries used (getByRole, getByLabel)
- [ ] Async operations properly awaited
- [ ] Edge cases covered
- [ ] No `.only()` or `.skip()` in committed code
- [ ] Test names use `should` prefix
