# Implement Design - Detailed Reference

Extended reference for the implement-design skill. Covers URL parsing, MCP tool details, auto-discovery patterns, mapping tables, asset handling, responsive design, and troubleshooting.

---

## URL Parsing Patterns

### Standard Design URL

```
https://figma.com/design/:fileKey/:fileName?node-id=:nodeId
```

Example: `https://figma.com/design/abc123def/MyProject?node-id=42-1337`
- `fileKey` = `abc123def`
- `nodeId` = `42:1337` (convert `-` to `:`)

Regex:
```
figma\.com/design/([^/]+)/[^?]+\?.*node-id=(\d+-\d+)
```

### Branch URL

```
https://figma.com/design/:fileKey/branch/:branchKey/:fileName?node-id=:nodeId
```

Example: `https://figma.com/design/abc123def/branch/xyz789/MyProject?node-id=10-20`
- `fileKey` = `xyz789` (use branchKey, not the original fileKey)
- `nodeId` = `10:20`

Regex:
```
figma\.com/design/[^/]+/branch/([^/]+)/[^?]+\?.*node-id=(\d+-\d+)
```

### Make URL

```
https://figma.com/make/:makeFileKey/:makeFileName
```

Example: `https://figma.com/make/mak123/MyMakeFile`
- `fileKey` = `mak123`
- `nodeId` = may not be in URL; ask user or use page root

### Node ID Without URL

If the user provides just a node ID like `42-1337` or `42:1337`, you need the fileKey separately. Ask for the Figma file URL.

### Multiple Node IDs

Some URLs contain multiple node IDs or section IDs. The `node-id` parameter is always the target. Ignore `section-id` or other parameters unless specifically asked.

---

## MCP Tool Reference

### `get_design_context`

**Purpose:** Primary tool. Returns layout structure, styles, generated code, and asset download URLs.

**Parameters:**
| Param | Required | Description |
|---|---|---|
| `fileKey` | Yes | Figma file key |
| `nodeId` | Yes | Node ID (format: `123:456`) |
| `clientLanguages` | No | Languages in use (e.g., `typescript,css`) |
| `clientFrameworks` | No | Frameworks in use (e.g., `react,tailwind`) |
| `disableCodeConnect` | No | Set `true` to skip Code Connect |
| `forceCode` | No | Set `true` to force code output even for large nodes |

**When to use:** Always. This is the first and most important call after URL parsing.

**Response includes:**
- Node hierarchy with layout properties
- Typography, color, and spacing values
- Generated code snippet
- `downloadUrls`: `{ "asset-name.png": "https://..." }` for referenced images/icons

### `get_screenshot`

**Purpose:** Visual reference image of the node.

**Parameters:**
| Param | Required | Description |
|---|---|---|
| `fileKey` | Yes | Figma file key |
| `nodeId` | Yes | Node ID (format: `123:456`) |
| `clientLanguages` | No | Languages in use |
| `clientFrameworks` | No | Frameworks in use |

**When to use:** Always, immediately after `get_design_context`. The screenshot is your visual ground truth.

### `get_variable_defs`

**Purpose:** Returns design token variable definitions applied to a node.

**Parameters:**
| Param | Required | Description |
|---|---|---|
| `fileKey` | Yes | Figma file key |
| `nodeId` | Yes | Node ID (format: `123:456`) |
| `clientLanguages` | No | Languages in use |
| `clientFrameworks` | No | Frameworks in use |

**Response format:**
```json
{
  "icon/default/secondary": "#949494",
  "bg/surface/primary": "#FFFFFF",
  "spacing/md": "16"
}
```

**When to use:** Always. Tokens from this tool map directly to the project's design token system.

### `get_code_connect_map`

**Purpose:** Returns mappings from Figma component instances to codebase component files.

**Parameters:**
| Param | Required | Description |
|---|---|---|
| `fileKey` | Yes | Figma file key |
| `nodeId` | Yes | Node ID (format: `123:456`) |
| `codeConnectLabel` | No | Filter by framework (e.g., `React`) |
| `clientLanguages` | No | Languages in use |
| `clientFrameworks` | No | Frameworks in use |

**Response format:**
```json
{
  "1:2": {
    "codeConnectSrc": "https://github.com/org/repo/src/components/Button.tsx",
    "codeConnectName": "Button"
  }
}
```

**When to use:** Always. If mappings exist, read the source component to understand its API before using it.

### `get_metadata`

**Purpose:** XML overview of node structure -- IDs, layer types, names, positions, sizes. Lightweight.

**Parameters:**
| Param | Required | Description |
|---|---|---|
| `fileKey` | Yes | Figma file key |
| `nodeId` | Yes | Node ID (can be page ID like `0:1`) |
| `clientLanguages` | No | Languages in use |
| `clientFrameworks` | No | Frameworks in use |

**When to use:** Only when you need to explore the node hierarchy without fetching full design context. Useful for large pages where you need to identify which child nodes to fetch individually.

---

## Auto-Discovery Commands

Run these before writing any code. Group independent searches into parallel calls.

### UI Library Detection

```bash
# Check package.json for UI libraries
Grep: "shadcn\|radix\|@headlessui\|@chakra-ui\|@mantine\|antd\|@mui" in package.json

# Find UI component directories
Glob: **/components/ui/**/*.{tsx,jsx,vue,svelte}
Glob: **/components/common/**/*.{tsx,jsx,vue,svelte}

# Check for component library config
Glob: **/components.json                    # shadcn config
Glob: **/theme.config.{ts,js,mjs}           # Theme config
```

### Design Token System

```bash
# CSS custom properties
Glob: **/{tokens,variables,theme}.css
Grep: ":root" AND "--" in **/*.css

# Tailwind configuration
Glob: **/tailwind.config.{js,ts,mjs,cjs}
Grep: "extend.*colors" in tailwind config

# Token files (JS/TS)
Glob: **/{tokens,theme,design-tokens}.{ts,js,json}
Glob: **/styles/{tokens,variables,theme}.*
```

### Component Architecture

```bash
# Component file structure
Glob: **/components/**/*.{tsx,jsx,vue,svelte}

# Check for barrel exports
Glob: **/components/**/index.{ts,tsx,js}
Grep: "export.*from" in **/components/**/index.*

# Props patterns
Grep: "interface.*Props" in **/components/**/*.tsx
Grep: "type.*Props" in **/components/**/*.tsx
```

### File Naming Conventions

```bash
# Detect convention by sampling existing files
Glob: **/components/**/*.*

# Look for:
# - PascalCase: Button.tsx, UserProfile.tsx
# - kebab-case: button.tsx, user-profile.tsx
# - With index: button/index.tsx, button/Button.tsx
```

### Import Aliases

```bash
# Check tsconfig for path aliases
Grep: "paths" in **/tsconfig.json
Grep: "alias" in **/vite.config.{ts,js}
Grep: "alias" in **/webpack.config.{ts,js}

# Sample existing imports
Grep: "from ['\"](@|~|#)" in **/components/**/*.{tsx,jsx}
```

### Styling Approach

```bash
# Tailwind
Glob: **/tailwind.config.*
Grep: "className" in **/components/**/*.tsx

# CSS Modules
Glob: **/*.module.css
Glob: **/*.module.scss
Grep: "styles\." in **/components/**/*.tsx

# Styled Components / Emotion
Grep: "styled\." in **/components/**/*.tsx
Grep: "from '@emotion" in **/components/**/*.tsx

# CSS-in-JS
Grep: "sx=" in **/components/**/*.tsx

# Utility function (cn, clsx, classnames)
Grep: "from.*['\"]clsx\|classnames\|class-variance-authority\|tailwind-merge" in **/*.{ts,tsx}
Grep: "function cn\|const cn\|export.*cn" in **/lib/**/*.*
```

### Icon Library

```bash
# Package-based icons
Grep: "lucide-react\|@heroicons\|react-icons\|@phosphor-icons\|@tabler/icons" in package.json

# Custom icons
Glob: **/icons/**/*.{tsx,jsx,svg}
Glob: **/assets/icons/**/*.svg

# Icon usage patterns
Grep: "Icon" in **/components/**/*.tsx | head -5
```

### Finding Reference Implementations

Look for components structurally similar to what you're building:

```bash
# Cards / list items
Glob: **/components/**/*{Card,Item,Tile,Row}*.{tsx,jsx}

# Forms
Glob: **/components/**/*{Form,Input,Select,Field}*.{tsx,jsx}

# Modals / dialogs
Glob: **/components/**/*{Modal,Dialog,Sheet,Drawer}*.{tsx,jsx}

# Layout
Glob: **/components/**/*{Layout,Container,Sidebar,Header,Nav}*.{tsx,jsx}

# Tables / lists
Glob: **/components/**/*{Table,List,Grid,DataGrid}*.{tsx,jsx}
```

Read the most relevant reference component in full before implementing.

---

## Figma-to-Code Mapping Tables

### Layout

| Figma Property | CSS/Tailwind |
|---|---|
| Auto layout: Horizontal | `flex flex-row` |
| Auto layout: Vertical | `flex flex-col` |
| Gap: N | `gap-{token}` (e.g., `gap-4` for 16px) |
| Padding: T R B L | `pt-{n} pr-{n} pb-{n} pl-{n}` or `p-{n}` if uniform |
| Alignment: Top Left | `items-start justify-start` |
| Alignment: Center | `items-center justify-center` |
| Alignment: Space Between | `justify-between` |
| Fill container (horizontal) | `w-full` or `flex-1` |
| Fill container (vertical) | `h-full` or `flex-1` |
| Hug contents | `w-fit` / `h-fit` (often default) |
| Fixed width: N | `w-[Npx]` (prefer token if close match) |
| Wrap | `flex-wrap` |
| Absolute position | `absolute` + `top-{n} left-{n}` etc. |
| Clip content | `overflow-hidden` |

### Typography

| Figma Property | CSS/Tailwind |
|---|---|
| Font size: 12px | `text-xs` (or project token) |
| Font size: 14px | `text-sm` |
| Font size: 16px | `text-base` |
| Font size: 18px | `text-lg` |
| Font size: 20px | `text-xl` |
| Font size: 24px | `text-2xl` |
| Font weight: 400 | `font-normal` |
| Font weight: 500 | `font-medium` |
| Font weight: 600 | `font-semibold` |
| Font weight: 700 | `font-bold` |
| Line height: 1.25 | `leading-tight` |
| Line height: 1.5 | `leading-normal` |
| Line height: 2 | `leading-loose` |
| Letter spacing: -0.02em | `tracking-tight` |
| Letter spacing: 0.05em | `tracking-wide` |
| Text align: center | `text-center` |
| Text decoration: underline | `underline` |
| Text overflow: ellipsis | `truncate` |
| Text transform: uppercase | `uppercase` |

### Colors

**Strategy:** Never hardcode hex values. Always follow this resolution order:

1. **Design token from `get_variable_defs`** - If the variable name maps to a project token, use it (e.g., `bg/surface/primary` -> `bg-background`)
2. **Semantic class** - If the project has semantic color classes (e.g., `text-muted-foreground`, `bg-destructive`), match by intent
3. **Theme variable** - Use CSS variable: `text-[var(--color-name)]`
4. **Closest Tailwind color** - As last resort: `text-blue-500`

### Borders & Radius

| Figma Property | CSS/Tailwind |
|---|---|
| Border: 1px solid | `border` |
| Border color | `border-{token}` |
| Border radius: 4px | `rounded` or `rounded-sm` |
| Border radius: 6px | `rounded-md` |
| Border radius: 8px | `rounded-lg` |
| Border radius: 12px | `rounded-xl` |
| Border radius: 9999px | `rounded-full` |
| Individual corners | `rounded-tl-{n} rounded-tr-{n}` etc. |

### Shadows

| Figma Property | CSS/Tailwind |
|---|---|
| Small shadow (0 1px 2px) | `shadow-sm` |
| Medium shadow (0 4px 6px) | `shadow-md` |
| Large shadow (0 10px 15px) | `shadow-lg` |
| XL shadow (0 20px 25px) | `shadow-xl` |
| Inner shadow | `shadow-inner` (or `inset` variant) |

### Opacity & Effects

| Figma Property | CSS/Tailwind |
|---|---|
| Opacity: 50% | `opacity-50` |
| Blur: 8px | `blur-sm` |
| Blur: 16px | `blur-md` |
| Backdrop blur | `backdrop-blur-{n}` |

---

## Common UI Component Mappings

When `get_design_context` returns Figma components, map them to existing project components:

| Figma Component Pattern | Likely Project Component | Check For |
|---|---|---|
| Rectangle with text + click area | `Button` | Variant props, size props |
| Text field with label + border | `Input` | With `Label` wrapper |
| Checkbox / toggle | `Checkbox`, `Switch` | Controlled vs uncontrolled |
| Radio circles | `RadioGroup` | Item pattern |
| Dropdown with options | `Select` | Trigger + Content pattern |
| Card container with content | `Card` | Header/Content/Footer slots |
| Overlay with backdrop | `Dialog`, `Modal` | Trigger pattern |
| Toast / snackbar | `Toast`, `Sonner` | Toast hook/function |
| Tabs with panels | `Tabs` | TabsList + TabsTrigger + TabsContent |
| Navigation items | `NavigationMenu` | Link vs button items |
| Breadcrumb path | `Breadcrumb` | Separator pattern |
| Badge / tag / chip | `Badge` | Variant prop |
| Avatar / profile image | `Avatar` | Fallback pattern |
| Progress indicator | `Progress` | Value prop |
| Tooltip on hover | `Tooltip` | Trigger + Content pattern |
| Accordion / expandable | `Accordion` | Item + Trigger + Content |
| Table with rows | `Table` | Head/Body/Row/Cell pattern |
| Separator line | `Separator` | Horizontal vs vertical |
| Skeleton placeholder | `Skeleton` | Width/height matching |

**Always check the actual component source** to understand its exact API before using it. Don't assume props -- read the file.

---

## Asset Handling

### Processing `downloadUrls`

The `get_design_context` response includes a `downloadUrls` object:

```json
{
  "hero-image.png": "https://figma-alpha-api.s3.us-west-2.amazonaws.com/...",
  "icon-arrow.svg": "https://figma-alpha-api.s3.us-west-2.amazonaws.com/..."
}
```

**Workflow:**

1. **Check for existing assets first:**
   ```
   Glob: **/assets/**/{asset-name}*
   Glob: **/public/**/{asset-name}*
   Glob: **/images/**/{asset-name}*
   ```

2. **Determine asset directory:**
   ```
   Glob: **/assets/**                # Find where assets live
   Glob: **/public/images/**         # Public static assets
   Glob: **/src/assets/**            # Source assets (bundled)
   ```

3. **Download missing assets:**
   ```bash
   curl -L -o <target-path>/<asset-name> "<download-url>"
   ```

4. **For SVG icons:** Check if the icon already exists in the icon library (Lucide, Heroicons, etc.) before downloading. Many common icons have existing equivalents.

5. **For images:** Consider if the image needs optimization. If the project uses `next/image` or similar, place it accordingly.

### Asset Naming

Match the project's existing convention:
- `kebab-case.svg` (most common)
- `camelCase.svg`
- `PascalCase.svg`
- Check existing assets to determine the pattern.

---

## Responsive Design Translation

Figma designs typically show a single viewport. Translate to responsive code:

### Strategy

1. **Mobile-first** (default): Build the mobile layout, then add breakpoints for larger screens.
2. **Desktop-first**: If the Figma shows desktop, consider what collapses or stacks on mobile.

### Common Responsive Patterns

| Figma (Desktop) | Mobile Adaptation |
|---|---|
| Horizontal row of cards | Stack vertically: `flex-col md:flex-row` |
| Sidebar + content | Full width content, sidebar becomes top nav or drawer |
| Multi-column grid | Single column: `grid-cols-1 md:grid-cols-2 lg:grid-cols-3` |
| Large padding | Reduced padding: `p-4 md:p-8 lg:p-12` |
| Fixed width container | Full width with max-width: `w-full max-w-7xl mx-auto` |
| Horizontal navigation | Hamburger menu on mobile |
| Large font sizes | Slightly smaller: `text-2xl md:text-4xl` |

### Breakpoint Reference (Tailwind defaults)

| Prefix | Min-width | Typical Device |
|---|---|---|
| `sm:` | 640px | Landscape phone |
| `md:` | 768px | Tablet |
| `lg:` | 1024px | Laptop |
| `xl:` | 1280px | Desktop |
| `2xl:` | 1536px | Large desktop |

Always check the project's Tailwind config for custom breakpoints before using defaults.

---

## Troubleshooting

### Permission Errors

**Problem:** `get_design_context` returns 403 or "access denied".
**Solution:** The user needs view access to the Figma file. Ask them to:
1. Check they're logged into the correct Figma account
2. Verify they have at least "can view" permission on the file
3. Check if the file is in an organization with restricted sharing

### Truncated or Missing Output

**Problem:** `get_design_context` returns metadata but no code.
**Solution:** The node may be too large. Try:
1. Use `forceCode: true` parameter
2. Use `get_metadata` to identify child nodes, then fetch them individually
3. Break the design into smaller sections

### Missing Design Tokens

**Problem:** `get_variable_defs` returns empty or partial results.
**Solution:** The Figma file may not use variables. Fall back to:
1. Extract colors manually from `get_design_context` response
2. Match extracted values to the closest project tokens
3. If no tokens exist in the project, use the values directly with CSS variables

### Wrong Import Paths

**Problem:** Generated code uses wrong import paths.
**Solution:** Always check the project's `tsconfig.json` or bundler config for aliases:
```
Grep: "paths" in **/tsconfig.json
Grep: "alias" in **/vite.config.*
```
Then rewrite imports to match the project's convention.

### Component API Mismatch

**Problem:** Using a UI component with wrong props.
**Solution:** Always read the actual component source before using it:
```
Read: <path-to-component>
```
Check the props interface, required vs optional props, and variant options.

### Assets Not Loading

**Problem:** Downloaded assets don't render.
**Solution:**
1. Verify the download URL hasn't expired (Figma URLs are temporary)
2. Check the file was saved in the correct directory
3. Verify the import path in the component matches the asset location
4. For SVGs, check if they need to be imported as React components vs `<img>` tags

### Large/Complex Designs

**Problem:** Full page designs with many components.
**Solution:** Break down the implementation:
1. Use `get_metadata` to get the page structure overview
2. Identify the top-level sections/components
3. Implement each section separately using `get_design_context` on individual nodes
4. Compose the sections together in the page component
