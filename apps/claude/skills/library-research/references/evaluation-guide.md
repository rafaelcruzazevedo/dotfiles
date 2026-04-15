# Library Evaluation Guide

Detailed criteria and checklists for evaluating libraries, frameworks, and plugins.

## Research Query Templates

### Context7 Queries (query-docs)

Use these targeted queries to systematically evaluate a library:

| Area | Query |
|---|---|
| Overview | "Getting started, core concepts, and main API" |
| Specific feature | "[feature name] API, configuration, and examples" |
| TypeScript | "TypeScript types, generics, and type-safe usage" |
| Framework integration | "Integration with [React/Vue/Node/etc]" |
| Configuration | "Configuration options, environment variables, and setup" |
| Error handling | "Error handling, debugging, and troubleshooting" |
| Testing | "Testing utilities, mocks, and test helpers" |
| Migration | "Migration guide from [previous version or alternative]" |
| Performance | "Performance optimization, caching, and best practices" |
| Security | "Security considerations, authentication, and authorization" |

### Web Search Queries (when Context7 is insufficient)

- `"[library] changelog [version]"` - Breaking changes for specific versions
- `"[library] vs [alternative] [year]"` - Community comparisons
- `"[library] bundle size bundlephobia"` - Size impact
- `"[library] GitHub issues known bugs"` - Active issues
- `"[library] [framework] integration example"` - Real-world integrations

## Evaluation Scoring Matrix

Rate each criterion 1-5 for comparison:

| Criterion | Weight | What to evaluate |
|---|---|---|
| Feature completeness | High | Does it solve the full problem or only partially? |
| API quality | High | Intuitive? Well-typed? Consistent patterns? |
| Documentation | High | Up-to-date? Examples? Searchable? |
| Bundle size | Medium | Acceptable for the target environment? |
| Maintenance health | Medium | Active releases? Responsive to issues? |
| Community | Medium | Adoption level? Stack Overflow presence? |
| TypeScript support | Medium | Built-in types? Generic support? |
| Testing support | Low | Test utilities? Mockable? |
| Learning curve | Low | Time to productive use? |

## Red Flags

Stop and warn the user when:

- **Last release > 12 months ago** with open security issues
- **No TypeScript types** (built-in or @types) for a TypeScript project
- **Peer dependency conflicts** with existing project dependencies
- **License incompatibility** with the project's license
- **Bundle size > 100KB gzipped** for client-side usage without clear justification
- **Major version 0.x** in production-critical path without alternatives
- **Deprecated** or archived repository

## Implementation Checklist

Before writing integration code, verify:

- [ ] Library version matches documentation queried
- [ ] All peer dependencies are compatible with project
- [ ] TypeScript types available and adequate
- [ ] No duplicate functionality with existing project dependencies
- [ ] License is compatible
- [ ] Import style matches project conventions (ESM/CJS)

After writing integration code, verify:

- [ ] No `any` types introduced
- [ ] Error handling follows project patterns
- [ ] Configuration uses environment variables where appropriate
- [ ] New dependency added to correct package.json (monorepo awareness)
- [ ] TypeScript compiles without errors
- [ ] Linter passes
- [ ] Existing tests pass
- [ ] Integration is tested or manually verified

## Version Mismatch Handling

When the project uses a different version than Context7 documents:

1. Note the version difference to the user
2. Search for migration guides: `query-docs(libraryId, "migration from v[X] to v[Y]")`
3. Check the changelog for breaking changes: `WebSearch("[library] changelog [version]")`
4. Adapt documented patterns to the installed version
5. If the gap is large, recommend upgrading first or find version-specific docs
