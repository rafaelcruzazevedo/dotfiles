---
description: React component patterns and best practices
globs: ["**/*.tsx", "src/components/**/*"]
---

# React Component Standards

## Core Pattern

All components MUST be functional components with TypeScript.

```tsx
/**
 * Module dependencies.
 */

import type { ReactNode } from 'react';

/**
 * Props.
 */

interface ButtonProps {
  children: ReactNode;
  disabled?: boolean;
  onClick?: () => void;
  variant?: 'primary' | 'secondary';
}

/**
 * Export `Button` component.
 */

export function Button({
  children,
  disabled = false,
  onClick,
  variant = 'primary'
}: ButtonProps) {
  return (
    <button
      className={`btn btn-${variant}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

## Props Guidelines

1. **Always Define Props Types**
   - Use explicit interface for props
   - Never use untyped props

2. **Use Optional Props with Defaults**
   - Optional props should have default values
   - Destructure with defaults in function signature

3. **Use ReactNode for Children**
   - `children: ReactNode` accepts anything renderable
   - Never use `JSX.Element` (too restrictive)

4. **Extend HTML Element Props When Needed**
   ```tsx
   interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
     variant?: 'primary' | 'secondary';
   }
   ```

## Component Rules

- **Named Exports**: Always use named exports (not default)
- **Props Interface**: Always define and export props interface
- **Optional Props**: Provide default values
- **Explicit Booleans**: Use `disabled={true}` not just `disabled`
- **Alphabetical Order**: Sort props alphabetically

## Composition Patterns

**Prefer Composition Over Props Drilling**:

```tsx
// Good - Composition
<Card>
  <CardHeader>
    <Title>My Title</Title>
  </CardHeader>
  <CardBody>
    <p>Content</p>
  </CardBody>
</Card>

// Bad - Props drilling
<Card
  title="My Title"
  content={<p>Content</p>}
/>
```

## Hooks Best Practices

1. **Call Hooks at Top Level**
   - Never call hooks inside conditions or loops

2. **Exhaustive Dependencies**
   - All hook dependencies must be included
   - `useEffect(() => { console.log(count); }, [count])`

3. **Extract Complex Logic**
   - Create custom hooks for reusable logic
   - Prefix with `use` (kebab-case file, camelCase function)

## State Management

- **useState**: Component-specific state
- **useReducer**: Complex state with multiple sub-values
- **Context**: State shared across many components
- **Derived State**: Compute values from existing state, don't store redundantly

## Performance

- **React.memo**: For expensive pure components with stable props
- **useMemo**: For expensive calculations
- **useCallback**: For callbacks passed to memoized children

## Error Handling

- **Error Boundaries**: Wrap major routes and critical features
- **Try-Catch in Handlers**: Always handle async errors in event handlers

## File Location (Atomic Design)

- **Atoms**: `src/components/atoms/{name}/`
- **Molecules**: `src/components/molecules/{name}/`
- **Organisms**: `src/components/organisms/{name}/`
