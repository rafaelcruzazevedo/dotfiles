---
name: react-component
description: Create React components following Atomic Design and project patterns. Use when asked to create a new component, build UI, or implement a feature with React.
---

# React Component Creation

## When to Use

- Creating new components
- Building UI features
- Implementing designs
- Adding new pages or views

## Process

1. **Determine Component Level** (Atomic Design)
   - Atom: Basic building blocks (Button, Input, Label)
   - Molecule: Simple combinations (FormField, SearchBar)
   - Organism: Complex UI sections (Header, Card, Modal)

2. **Create Directory Structure**
   ```
   src/components/{level}/{component-name}/
   ├── index.tsx          # Component implementation
   ├── index.test.tsx     # Unit tests
   └── index.stories.tsx  # Storybook stories
   ```

3. **Implement Component** following template

4. **Add Tests** using Testing Library

5. **Create Storybook Story** for documentation

## File Location

| Level | Path |
|-------|------|
| Atoms | `src/components/atoms/{name}/` |
| Molecules | `src/components/molecules/{name}/` |
| Organisms | `src/components/organisms/{name}/` |

## Template

See [template.tsx](template.tsx) for the base component structure.

## Checklist

- [ ] TypeScript props interface defined
- [ ] JSDoc comments added
- [ ] Named export (not default)
- [ ] Default values for optional props
- [ ] Props sorted alphabetically
- [ ] Accessible (semantic HTML, ARIA if needed)
- [ ] Unit tests written
- [ ] Storybook story created

## Example Usage

When asked: "Create a Card component"

1. Determine it's an Atom or Molecule based on complexity
2. Create `src/components/atoms/card/` directory
3. Use the template structure
4. Add props interface with children, variant, etc.
5. Implement with TailwindCSS
6. Write tests
7. Create Storybook story
