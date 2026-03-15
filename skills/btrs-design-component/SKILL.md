---
name: btrs-design-component
description: >
  Design a component through guided conversation. Produces a component design
  spec covering purpose, props, states, variants, Atomic Design level,
  accessibility, and implementation guidance. Use when the user wants to design
  a component, spec out a component, plan a component before building, or asks
  "design a component", "btrs design component", "spec out a button",
  "how should we build this component", "component design for".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: <component-name or description>
---

# Design Component Skill

Design a component through conversation and produce a structured design spec.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized.

## Step 1: Understand project context

Read the shared references:
```
~/.claude/skills/shared/audit-components.md
~/.claude/skills/shared/audit-css.md
```

Check if `<basedir>/tech-stack.md` exists and read it for framework, styling approach, and component conventions.

Scan existing components to understand patterns:
```bash
# Find component directory structure
ls -d src/components/ src/lib/components/ 2>/dev/null

# Count components by directory to understand hierarchy
find src/ -name "*.svelte" -o -name "*.vue" -o -name "*.tsx" -o -name "*.jsx" 2>/dev/null | head -20
```

## Step 2: Understand what to design

If `$ARGUMENTS` is provided, use it as the starting point. Otherwise ask: "What component do you need to design?"

Work through these questions conversationally:

### Purpose
- What does this component do?
- What problem does it solve for the user?
- Where will it be used? (which pages, contexts)
- Is there a similar component already? (search the codebase)

### Atomic Design level
Based on the component's role, determine its level:
- **Atom** — Single-purpose, no children components (Button, Input, Badge, Icon, Avatar)
- **Molecule** — Combines atoms into a functional unit (SearchBar, FormField, MenuItem, Card)
- **Organism** — Complex section with business logic (Header, Sidebar, DataTable, CommentThread)
- **Template** — Page layout structure without real data
- **Page** — Template with real data and route logic

Explain the reasoning and confirm with the user.

### Users and contexts
- Who interacts with this component?
- In what contexts does it appear?
- Does it appear in different sizes or layouts (responsive)?

## Step 3: Design the interface

### Props
Work through what data and configuration the component needs:
- Required vs optional props
- Prop types (primitive, enum, object, callback)
- Default values
- Which props control appearance vs behavior

Follow the project's existing prop patterns. Check similar components for conventions.

### Slots / children
- Does the component accept content projection?
- Named slots vs default slot?
- Render props or scoped slots?

### Events / callbacks
- What events does the component emit?
- Event payload shapes
- When do they fire?

### State
- What internal state does the component manage?
- Derived state (computed from props)?
- Side effects (API calls, subscriptions, timers)?
- Cleanup requirements?

## Step 4: Design the variants and states

### Visual variants
- Size variants (sm, md, lg)?
- Color/style variants (primary, secondary, danger)?
- Layout variants (horizontal, vertical, compact)?

### Interactive states
- Default / hover / active / focus / disabled
- Loading state
- Error state
- Empty state
- Selected / checked (if applicable)

### Responsive behavior
- How does it adapt to different screen sizes?
- Does it stack, collapse, or hide elements?
- Touch targets for mobile

## Step 5: Accessibility design

- What ARIA role does it have?
- Keyboard interaction model (what keys do what?)
- Focus management (does it trap focus, manage tab order?)
- Screen reader announcements (aria-live, aria-label)
- Color contrast requirements
- Motion sensitivity (prefers-reduced-motion)

## Step 6: Design the styling

Based on the project's styling approach:

- Which existing design tokens / CSS variables should it use?
- New tokens needed?
- Spacing, typography, and color selections from the existing palette
- How does it integrate with the project's theming (dark mode, etc.)?

## Step 7: Check for reuse and composition

Search the codebase for:
- Components that overlap with this design (could this extend an existing one?)
- Components that should compose with this one
- Shared utilities or hooks this component should use

## Step 8: Write the design spec

Write to `<basedir>/specs/components/<component-slug>.md`:

```markdown
---
title: "Component Design: <ComponentName>"
date: YYYY-MM-DD
type: component-spec
level: "<atom | molecule | organism | template | page>"
status: "designed"
tags:
  - spec
  - spec/component
  - "atomic/<level>"
---

# Component Design: <ComponentName>

## Overview

**Purpose:** <what it does and why>
**Atomic Design level:** <level> — <reasoning>
**Used in:** <pages/contexts where it appears>

## Interface

### Props

| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| ... | ... | ... | ... | ... |

### Slots

| Slot | Purpose | Fallback |
|------|---------|----------|
| ... | ... | ... |

### Events

| Event | Payload | When |
|-------|---------|------|
| ... | ... | ... |

### Internal State

| State | Type | Purpose |
|-------|------|---------|
| ... | ... | ... |

## Variants

### Visual variants

<Description and when to use each>

### States

| State | Appearance | Trigger |
|-------|------------|---------|
| default | ... | ... |
| hover | ... | ... |
| disabled | ... | ... |
| loading | ... | ... |
| error | ... | ... |

## Responsive Behavior

<How the component adapts to different screen sizes>

## Accessibility

- **Role:** <ARIA role>
- **Keyboard:** <interaction model>
- **Screen reader:** <announcements and labels>
- **Focus:** <management approach>

## Styling

- **Tokens used:** <list of CSS variables / design tokens>
- **New tokens needed:** <any new tokens this requires>
- **Theme support:** <dark mode / theming behavior>

## Composition

- **Composes:** <child components it uses>
- **Composed by:** <parent components that use it>
- **Related:** <similar components, wikilinks>

## Implementation Notes

<Any guidance for the developer: edge cases, performance considerations, framework-specific patterns>

## Open Questions

<Anything unresolved>
```

## Step 9: Present the result

Tell the user:
- The spec file path
- Component name, level, and key design decisions
- Any existing components that overlap or compose with it
- Suggest: "Run `/btrs-scaffold-component <ComponentName> --level <level>` to generate the scaffolding."
