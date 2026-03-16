---
name: btrs-design-page
description: >
  Design a page layout through guided conversation. Produces a page design
  spec covering layout, component composition, data flow, responsive behavior,
  routing, and loading states. Use when the user wants to design a page, plan
  a page layout, spec out a view, or asks "design a page", "btrs design page",
  "layout for the settings page", "how should this page look",
  "plan the dashboard layout".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: <page-name or description>
---

# Design Page Skill

Design a page layout through conversation and produce a structured design spec.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Understand project context

Read the shared references:
```
~/.claude/skills/shared/audit-components.md
~/.claude/skills/shared/audit-css.md
```

Check if `<basedir>/tech-stack.md` exists and read it.

Understand the routing structure:
```bash
# SvelteKit
ls src/routes/ 2>/dev/null | head -20

# Next.js
ls app/ pages/ 2>/dev/null | head -20

# Check for existing layout patterns
find src/ -name "+layout*" -o -name "layout.*" -o -name "_layout.*" 2>/dev/null
```

Read existing page files to understand conventions:
- Layout components and nesting
- Data loading patterns (load functions, getServerSideProps, etc.)
- Shared layout elements (navigation, sidebar, footer)
- Error and loading pages

## Step 2: Understand what to design

If `$ARGUMENTS` is provided, use it as the starting point. Otherwise ask: "What page do you need to design?"

Work through:

### Purpose
- What is this page for?
- What user goal does it serve?
- Where does the user come from? Where do they go next?
- Is this a new page or a redesign of an existing one?

### Users
- Who uses this page?
- What's their primary task on this page?
- Are there different roles with different views?

### Data
- What data does this page display?
- Where does the data come from (API, database, static)?
- How much data? (single record, list, paginated, infinite scroll)
- How fresh does it need to be? (real-time, cached, static)

## Step 3: Design the layout

### Page structure
Work through the layout top-to-bottom:

- **Navigation context** — Where does this page sit in the nav hierarchy?
- **Page header** — Title, breadcrumbs, actions?
- **Primary content area** — What's the main content?
- **Secondary content** — Sidebar, panels, supplementary info?
- **Page footer** — Actions, pagination, metadata?

### Layout approach
- Single column, two column, grid?
- Fixed sidebar vs collapsible?
- Full-width vs max-width container?
- Scrolling behavior (page scroll, section scroll, sticky elements)?

### Component composition
Map the page to components using Atomic Design:

```
Page: <PageName>
├── Template: <LayoutTemplate>
│   ├── Organism: PageHeader
│   │   ├── Molecule: Breadcrumbs
│   │   └── Molecule: ActionBar
│   ├── Organism: <PrimaryContent>
│   │   ├── Molecule: FilterBar
│   │   └── Organism: DataTable / CardGrid / etc.
│   └── Organism: <SecondaryContent> (if applicable)
│       └── Molecule: DetailPanel
```

Identify which components exist and which need to be created.

## Step 4: Design the data flow

### Loading pattern
- Server-side load function (SSR)?
- Client-side fetch?
- Combination (SSR initial + client-side updates)?
- Streaming / deferred loading?

### State management
- What page-level state is needed?
- What state is shared with other pages (global stores)?
- URL-driven state (query params, hash)?
- Form state (if applicable)?

### Data mutations
- What actions can the user take?
- Optimistic updates?
- Error handling for mutations?
- Confirmation dialogs for destructive actions?

### Real-time updates
- Does any data update in real-time (WebSocket, SSE)?
- Polling intervals?
- Stale data indicators?

## Step 5: Design states and transitions

### Page states
- **Loading** — Skeleton, spinner, or progressive loading?
- **Empty** — No data to display. What do we show?
- **Error** — API failure, permission denied, not found?
- **Populated** — Normal state with data
- **Partial** — Some sections loaded, some pending

### Navigation transitions
- How does the user arrive (link, redirect, deep link)?
- Back button behavior?
- Unsaved changes warning?
- Loading indicators during navigation?

## Step 6: Responsive design

- **Desktop** (>1024px) — Full layout
- **Tablet** (768-1024px) — What collapses or stacks?
- **Mobile** (<768px) — What changes fundamentally?

For each breakpoint:
- Layout changes (column collapse, sidebar to drawer)
- Content priority (what hides, what stays)
- Interaction changes (hover → tap, tooltips → inline)
- Navigation changes (top nav → hamburger, tabs → accordion)

## Step 7: Accessibility

- Page title (document title) and heading hierarchy
- Landmark regions (main, nav, aside, footer)
- Focus management on page load and navigation
- Skip-to-content link
- Keyboard-navigable interactive elements
- Screen reader announcements for dynamic content

## Step 8: Write the design spec

Write to `<basedir>/specs/pages/<page-slug>.md`:

```markdown
---
title: "Page Design: <PageName>"
date: YYYY-MM-DD
type: page-spec
route: "<route-path>"
status: "designed"
tags:
  - spec
  - spec/page
---

# Page Design: <PageName>

## Overview

**Purpose:** <what this page is for>
**Route:** `<route-path>`
**Users:** <who uses it and their primary task>
**Navigated from:** <where users come from>

## Layout

### Structure

<ASCII layout diagram or description>

```
┌──────────────────────────────────┐
│ PageHeader                       │
│  Breadcrumbs | Title | Actions   │
├────────────────────┬─────────────┤
│ Primary Content    │ Sidebar     │
│                    │             │
│ FilterBar          │ DetailPanel │
│ DataTable          │             │
│                    │             │
├────────────────────┴─────────────┤
│ Pagination                       │
└──────────────────────────────────┘
```

### Component Tree

```
Page: <PageName>
├── Template: <Layout>
│   ├── Organism: ...
│   │   ├── Molecule: ...
│   │   └── Atom: ...
│   └── Organism: ...
```

### Components needed

| Component | Level | Exists? | Notes |
|-----------|-------|---------|-------|
| ... | atom | ✓ | ... |
| ... | molecule | ✗ needs creation | ... |

## Data Flow

### Loading

| Data | Source | Strategy | Cache |
|------|--------|----------|-------|
| ... | API endpoint | SSR load | 60s |

### State

| State | Scope | Type | Purpose |
|-------|-------|------|---------|
| ... | page | reactive | ... |
| ... | global | store | ... |
| ... | URL | query param | ... |

### Mutations

| Action | Method | Optimistic? | Confirmation? |
|--------|--------|-------------|---------------|
| ... | POST /api/... | yes | no |

## Page States

### Loading
<what the loading state looks like>

### Empty
<what to show when there's no data>

### Error
<error handling approach>

## Responsive Behavior

| Breakpoint | Layout changes |
|------------|---------------|
| Desktop (>1024px) | Full two-column layout |
| Tablet (768-1024px) | ... |
| Mobile (<768px) | ... |

## Accessibility

- **Page title:** `<document title>`
- **Heading hierarchy:** H1: ..., H2: ...
- **Landmarks:** main, nav, aside
- **Focus:** <focus management on load>
- **Keyboard:** <key interactions>

## Implementation Notes

<Framework-specific patterns, performance considerations, edge cases>

## Open Questions

<Anything unresolved>
```

## Step 9: Create follow-up items

After writing the spec, offer to:
- Create todo items for components that need to be built
- Create a component design spec for any new organisms/molecules
- Link to related page specs

## Step 10: Present the result

Tell the user:
- The spec file path
- Page route and layout summary
- Components needed (existing vs new)
- Data sources and loading strategy
- Suggest next steps: design new components, scaffold the page, or start implementing
