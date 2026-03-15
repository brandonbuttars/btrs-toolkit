---
name: btrs-doc-component
description: >
  Generate documentation for a component by reading its source code. Extracts
  props, events, slots, types, and usage patterns to produce a structured
  doc file. Use when the user wants to document a component, generate component
  docs, or asks "document this component", "btrs doc component", "generate
  docs for Button", "create component documentation".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: <component-path or name>
---

# Document Component Skill

Generate documentation for a component by analyzing its source code.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized.

## Step 1: Find the component

If `$ARGUMENTS` is a file path, read it directly. If it's a component name, search:

```bash
# Search for the component by name
find src/ -name "<Name>.svelte" -o -name "<Name>.vue" -o -name "<Name>.tsx" -o -name "<Name>.jsx" 2>/dev/null
```

If multiple matches, ask the user which one. If none found, tell the user.

## Step 2: Read the component source

Read the component file thoroughly. Also read:
- Any colocated test file for usage examples
- Any colocated type file
- The parent directory for sibling components (context)
- Import sources to understand dependencies

Read the shared component audit reference for Atomic Design context:
```
~/.claude/skills/shared/audit-components.md
```

## Step 3: Extract component information

### Props / inputs
Parse the component's prop definitions:
- **Svelte 5:** `$props()` destructuring, `interface Props`
- **Svelte 4:** `export let` declarations
- **React:** Props interface/type, destructured params
- **Vue 3:** `defineProps<>()`, prop definitions

For each prop:
- Name, type, required/optional, default value
- Purpose (infer from name, type, and usage)

### Events / outputs
- **Svelte:** `dispatch()`, `createEventDispatcher`, callback props
- **React:** Callback props (`onClick`, `onChange`, etc.)
- **Vue:** `defineEmits`, `$emit`

For each event:
- Name, payload type, when it fires

### Slots / children
- **Svelte:** `<slot>`, `{#snippet}`, named slots
- **React:** `children`, render props
- **Vue:** `<slot>`, named slots, scoped slots

### Internal state
- Reactive state variables and their purpose
- Derived/computed values
- Effects and side effects

### Styling
- CSS custom properties accepted (theming API)
- CSS classes applied (for utility-class projects)
- Scoped style summary

## Step 4: Find usage examples

Search for how the component is used across the codebase:

```bash
# Find files that import this component
grep -rl "import.*<ComponentName>" src/ --include="*.svelte" --include="*.vue" --include="*.tsx" --include="*.jsx"
```

Extract 2-3 representative usage examples showing different prop combinations.

## Step 5: Check for existing design spec

Look for a design spec in `<basedir>/specs/components/`:
```bash
ls <basedir>/specs/components/ 2>/dev/null
```

If a spec exists, cross-reference the documentation with the spec to note any divergences.

## Step 6: Write the documentation

Write to `<basedir>/docs/components/<ComponentName>.md`:

```markdown
---
title: "<ComponentName>"
type: component-doc
framework: "<Svelte | React | Vue>"
level: "<atom | molecule | organism>"
source: "[[<path/to/Component>]]"
updated: YYYY-MM-DD
tags:
  - doc
  - doc/component
  - "atomic/<level>"
---

# <ComponentName>

<1-2 sentence description of what the component does and when to use it.>

**Source:** [[<path/to/Component>]]
**Level:** <Atom | Molecule | Organism>
**Test:** [[<path/to/Component.test>]] _(if exists)_

## Props

| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| ... | ... | ... | ... | ... |

## Events

| Event | Payload | Description |
|-------|---------|-------------|
| ... | ... | ... |

## Slots

| Slot | Props | Description |
|------|-------|-------------|
| default | — | ... |

## CSS Custom Properties

| Property | Default | Description |
|----------|---------|-------------|
| ... | ... | ... |

_(Omit if component doesn't expose CSS custom properties)_

## Usage Examples

### Basic usage
```svelte
<ComponentName prop="value" />
```

### With all options
```svelte
<ComponentName
  prop1="value"
  prop2={42}
  onEvent={handler}
>
  <span>Slot content</span>
</ComponentName>
```

### From the codebase
```svelte
<!-- From [[path/to/usage]] -->
<ComponentName ... />
```

## Internal State

| State | Type | Purpose |
|-------|------|---------|
| ... | ... | ... |

_(Omit if component is stateless)_

## Dependencies

- [[path/to/ChildComponent]] — <why>
- `<package>` — <why>

## Accessibility

- **Role:** <ARIA role if applicable>
- **Keyboard:** <keyboard interactions>
- **Labels:** <how it's announced>

## Related

- **Design spec:** [[<basedir>/specs/components/<slug>]] _(if exists)_
- **Similar components:** [[<other components>]]
```

## Step 7: Present the result

Tell the user:
- Doc file path
- Component summary (props count, events, level)
- Any issues found (missing types, undocumented props, spec divergences)
- Suggest: "View in Obsidian at `<basedir>/docs/components/`"
