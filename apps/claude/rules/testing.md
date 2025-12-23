---
description: Testing standards with Vitest, Testing Library, and Playwright
globs: ["**/*.test.{ts,tsx}", "**/*.spec.{ts,tsx}", "test/**/*"]
---

# Testing Standards

## Philosophy

- **Test behavior, not implementation** - Focus on what users see and do
- **Write tests that catch real bugs** - Avoid testing implementation details
- **Keep tests maintainable** - Use good practices, avoid brittle selectors
- **Balance speed and coverage** - Run fast tests frequently, slow tests on CI

## Test Layers

1. **Unit Tests** (Vitest + Testing Library) - 50% - Fast, isolated
2. **Component Tests** (Storybook + Vitest) - 25% - Browser-based
3. **Visual Tests** (Playwright) - 15% - Screenshot comparison
4. **E2E Tests** (Playwright) - 10% - Full user journeys

## Unit Test Pattern

```tsx
/**
 * Module dependencies.
 */

import { render, screen } from '@testing-library/react';
import { userEvent } from '@testing-library/user-event';
import { describe, expect, it, vi } from 'vitest';
import { Button } from './index';

/**
 * Tests for `Button` component.
 */

describe('Button', () => {
  it('should render children', () => {
    render(<Button>Click me</Button>);

    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('should call onClick when clicked', async () => {
    const handleClick = vi.fn();

    render(<Button onClick={handleClick}>Click me</Button>);

    await userEvent.click(screen.getByRole('button'));

    expect(handleClick).toHaveBeenCalledOnce();
  });

  it('should be disabled when disabled prop is true', () => {
    render(<Button disabled={true}>Click me</Button>);

    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

## Query Priority

Use queries in this order:

1. **Accessible Queries** (prefer these)
   - `getByRole()` - Best choice (semantic, accessible)
   - `getByLabelText()` - Forms
   - `getByPlaceholderText()` - Inputs
   - `getByText()` - Non-interactive content

2. **Semantic Queries**
   - `getByAltText()` - Images
   - `getByTitle()` - Elements with title

3. **Test IDs** (last resort)
   - `getByTestId()` - When no other query works

**Examples**:
```tsx
// Good
screen.getByRole('button', { name: /submit/i })
screen.getByRole('textbox', { name: /email/i })
screen.getByLabelText(/email address/i)

// Bad - Implementation details
screen.getByClassName('btn-primary')
container.querySelector('.button')
```

## Async Testing

```tsx
// Wait for element to appear
const name = await screen.findByText(/john doe/i);

// User interactions
await userEvent.click(screen.getByRole('button'));
await userEvent.type(screen.getByLabelText(/email/i), 'user@example.com');
```

## Testing Custom Hooks

```tsx
import { renderHook, waitFor } from '@testing-library/react';

describe('useDebounce', () => {
  it('should debounce value', async () => {
    const { result, rerender } = renderHook(
      ({ value, delay }) => useDebounce(value, delay),
      { initialProps: { value: 'initial', delay: 300 } }
    );

    expect(result.current).toBe('initial');

    rerender({ value: 'updated', delay: 300 });

    await waitFor(() => expect(result.current).toBe('updated'), { timeout: 400 });
  });
});
```

## Test Naming

- Use `should` prefix: `should render button`, `should call onClick`
- Be specific: `should disable button when isLoading is true`
- User perspective: `should show error message when email is invalid`

## E2E Test Pattern

```typescript
import { expect, test } from '@playwright/test';

test.describe('Login Flow', () => {
  test('should login successfully', async ({ page }) => {
    await page.goto('/login');

    await page.getByLabel(/email/i).fill('user@example.com');
    await page.getByLabel(/password/i).fill('password123');
    await page.getByRole('button', { name: /log in/i }).click();

    await expect(page).toHaveURL('/dashboard');
  });
});
```

## Best Practices

**DO**:
- Test behavior, not implementation
- Use accessible queries
- Write descriptive test names
- Keep tests focused (one concept per test)
- Run tests before committing

**DON'T**:
- Test implementation details (CSS classes, internal state)
- Use brittle selectors (`.btn-primary`, `#submit-btn`)
- Write overly long tests
- Skip tests (fix them instead)
- Use `.only()` or `.skip()` in committed code
