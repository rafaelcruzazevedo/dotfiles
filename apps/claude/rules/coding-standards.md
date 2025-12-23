---
description: Biome formatting, naming conventions, and TypeScript standards
globs: ["**/*.{ts,tsx,js,jsx}"]
---

# Coding Standards

## Formatting (Biome)

- **Indentation**: 2 spaces (no tabs)
- **Line Width**: Maximum 120 characters
- **Line Ending**: LF (Unix style)
- **Quotes**: Single quotes for strings and JSX attributes
- **Semicolons**: Always required
- **Trailing Commas**: Never
- **Bracket Spacing**: Spaces inside braces `{ like: this }`
- **Bracket Same Line**: Closing bracket on new line for JSX
- **Arrow Parentheses**: Omit for single parameter `x => x * 2`

## File & Folder Naming

- **Pattern**: kebab-case for all files and folders
- **Examples**:
  - `user-profile.tsx`, `api-client.ts`
  - `product-feature/`, `invoice-line/`
- **Never**: `userProfile.ts`, `ApiClient.tsx`, `ProductFeature/`

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files/Folders | kebab-case | `user-profile.tsx` |
| Components/Types | PascalCase | `UserProfile`, `ButtonProps` |
| Variables/Functions | camelCase | `userData`, `handleClick` |
| Constants | UPPERCASE_SNAKE | `MAX_ATTEMPTS`, `API_KEY` |
| Booleans | is/has/can prefix | `isActive`, `hasPermission`, `canEdit` |
| Event Handlers | handle prefix | `handleClick`, `handleSubmit` |
| Custom Hooks | use prefix | `useAuth`, `useDebounce` |
| Arrays | Plural names | `users`, `orderItems` |

## TypeScript Standards

- **Strict Mode**: Always enabled
- **No Explicit Any**: Never use `any` - use `unknown` or specific types
- **Primitives**: Use `string`, `number`, `boolean` (not `String`, `Number`, `Boolean`)
- **Type vs Interface**: Prefer `type` over `interface` for object structures
- **Validation**: Use Zod for runtime schema validation

## Code Organization

- **Named Exports**: Prefer over default exports
  - `export function Component() {}` not `export default Component`
- **Alphabetical Sorting**: Sort imports, object keys, props, and attributes
- **const by Default**: Use `const` unless value needs reassignment

## DocBlock Convention

```typescript
/**
 * Module dependencies.
 */

import Something from 'something';

/**
 * `ClassName` or brief description.
 */

class ClassName {
  /**
   * Method description.
   */

  methodName() {
    // implementation
  }
}

/**
 * Export `ClassName`.
 */

export { ClassName };
```

**Rules**:
- Add `/** Module dependencies. */` before imports
- Simple one-line comments: `/** Description. */`
- Use backticks for class/module names: `` `ClassName` ``
- End with period inside comment
- NO `@param`, `@returns`, `@description` tags

## Quality Standards

- **Cognitive Complexity**: Maximum 15
- **No Console**: Remove console statements
- **No Unused Variables**: All variables must be used
- **Error Boundaries**: Required for major routes
- **Async Error Handling**: Always use try-catch

## Accessibility

- **Semantic HTML**: Always use appropriate elements
- **Alt Text**: Required for all images
- **ARIA Roles**: Add when semantic HTML is insufficient
- **Keyboard Navigation**: All interactive elements must be keyboard accessible

## Linting

- Use **Biome** (not ESLint/Prettier)
- Run `npm run check` after writing code
- Follow project `biome.json` configuration
