---
name: btrs-scaffold-component
description: >
  Generate component scaffolding following Atomic Design patterns and project
  conventions. Creates the component file, test file, and optional style file.
  Use when the user wants to create a new component, scaffold a component,
  generate a component, or asks "create component", "new component",
  "btrs scaffold component", "scaffold a button", "make a component for".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: <component-name> [--level atom|molecule|organism|template|page]
---

# Scaffold Component Skill

Generate component scaffolding following Atomic Design patterns and detected project conventions.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Detect project conventions

Read the component audit reference for Atomic Design guidance:
```
~/.claude/skills/shared/audit-components.md
```

Check if `<basedir>/tech-stack.md` exists and read it. Otherwise detect:

### Framework detection
- `.svelte` files → Svelte (check for runes syntax: `$state`, `$derived`, `$effect`)
- `.vue` files → Vue (check for Composition API vs Options API)
- `.jsx`/`.tsx` files → React
- Check `package.json` for framework versions

### Component directory structure
```bash
# Find where components live
ls -d src/components/ src/lib/components/ app/components/ components/ 2>/dev/null
```

Examine the existing structure:
- Flat: all components in one directory
- Type-based: atoms/, molecules/, organisms/
- Feature-based: feature-name/ComponentName/
- Hybrid: shared atoms/molecules + feature-based organisms

### File conventions
- Check existing components for naming (PascalCase, kebab-case)
- Check for colocation patterns (Component.svelte + Component.test.ts + Component.css in same dir)
- Check for index files (barrel exports)
- Check for TypeScript (prop types, interfaces)

### Styling conventions
Read the CSS audit reference:
```
~/.claude/skills/shared/audit-css.md
```
- Scoped styles (`<style>` in .svelte/.vue)
- CSS Modules
- Tailwind classes
- CSS custom properties / design tokens

### Testing conventions
- Check for `*.test.ts`, `*.spec.ts`, `*.test.js`
- Check testing library: Vitest, Jest, Testing Library
- Check if tests are colocated or in a separate `__tests__/` directory

## Step 2: Parse arguments

`$ARGUMENTS` should contain:
- **Component name** (required) — e.g., `Button`, `UserCard`, `NavigationBar`
- **Level flag** (optional) — `--level atom`, `--level molecule`, etc.

If no level is specified, infer from the component name and description:
- Simple, single-purpose UI elements → atom (Button, Input, Badge, Icon, Label)
- Combinations of atoms → molecule (SearchBar, FormField, NavItem, Card)
- Complex sections with business logic → organism (Header, Sidebar, UserTable, CommentThread)
- Page layouts → template
- Route-level → page

Ask the user to confirm the level if you're unsure.

Also ask:
- Brief description of what the component does
- Any specific props it needs
- Whether it needs to fetch data or manage state

## Step 3: Plan the scaffolding

Determine what files to create based on project conventions:

**For Svelte 5 (runes):**
```
src/lib/components/<level>/<ComponentName>.svelte
src/lib/components/<level>/<ComponentName>.test.ts  (if tests are colocated)
```

**For React/TSX:**
```
src/components/<level>/<ComponentName>/<ComponentName>.tsx
src/components/<level>/<ComponentName>/<ComponentName>.test.tsx
src/components/<level>/<ComponentName>/index.ts
```

**For Vue:**
```
src/components/<level>/<ComponentName>.vue
src/components/<level>/<ComponentName>.test.ts
```

Adapt the exact paths to match the project's existing directory structure. Always follow what's already there rather than imposing a new pattern.

Present the plan and ask for confirmation.

## Step 4: Generate the component

### Svelte 5 (runes) template

```svelte
<script lang="ts">
  import type { Snippet } from 'svelte';

  interface Props {
    // Props derived from user's description
  }

  let { ...props }: Props = $props();
</script>

<!-- Component markup -->

<style>
  /* Scoped styles using project's CSS variables */
</style>
```

### React/TSX template

```tsx
interface <ComponentName>Props {
  // Props derived from user's description
}

export function <ComponentName>({ ...props }: <ComponentName>Props) {
  return (
    // Component markup
  );
}
```

### Vue 3 (Composition API) template

```vue
<script setup lang="ts">
interface Props {
  // Props derived from user's description
}

const props = defineProps<Props>();
</script>

<template>
  <!-- Component markup -->
</template>

<style scoped>
/* Scoped styles using project's CSS variables */
</style>
```

For all frameworks:
- Use the project's existing CSS variables and design tokens
- Follow the prop naming patterns of sibling components
- Include TypeScript types if the project uses TS
- Add JSDoc/comments only where the purpose isn't self-evident

### Generate the test file

Match the project's testing patterns:

```ts
import { render, screen } from '@testing-library/svelte'; // or react/vue
import { describe, it, expect } from 'vitest'; // or jest
import <ComponentName> from './<ComponentName>.svelte';

describe('<ComponentName>', () => {
  it('renders', () => {
    render(<ComponentName>, { props: { /* minimal valid props */ } });
    // Basic render assertion
  });
});
```

## Step 5: Check for reuse opportunities

Before finishing, search for similar components:

```bash
# Search for components with similar names or purposes
```

If similar components exist, tell the user and ask if they should extend the existing one instead.

## Step 6: Present the result

Tell the user:
- Files created with paths
- The Atomic Design level and reasoning
- Props interface
- How to import and use the component
- Suggest: "Run your tests to verify, then flesh out the implementation."
