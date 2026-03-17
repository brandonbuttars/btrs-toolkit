# Tech Debt Backlog Format

This reference defines the format for the tech debt backlog used by `review-mr`, `release-notes`, and `do-tech-debt` skills. All three skills must read and write using these exact formats to stay consistent.

The basedir (resolved from `.btrs-config.json`, default `.local`) is the output directory. All generated documents use Obsidian-compatible features: YAML frontmatter for properties, tags for filtering, wikilinks for navigation, and callouts for emphasis. These features don't affect Claude's ability to read or write the files.

## Master List: `<basedir>/tech-debt.md`

The master list is a clean, scannable table with wikilinks to detail files. One row per item. Do not put detailed descriptions here — they go in the individual detail files.

```markdown
---
last_updated: YYYY-MM-DD HH:MM
tags:
  - tech-debt
  - index
---

# Tech Debt Backlog

| ID | Priority | Effort | Area | Title | Status | Source |
|----|----------|--------|------|-------|--------|--------|
| [[0001]] | High | Small | CSS | Consolidate duplicate color variables | Open | review-mr/feature-dashboard (2025-03-14) |
| [[0002]] | Medium | Medium | UI | Extract Button atom from repeated patterns | Open | release/1.2→1.3 (2025-03-14) |
| [[0003]] | Low | Large | Frontend | Migrate inline styles to CSS custom properties | Open | release/1.2→1.3 (2025-03-14) |
```

The `[[0001]]` wikilinks make each ID clickable in Obsidian, navigating directly to the detail file.

### Column definitions

- **ID**: Zero-padded 4-digit number, auto-incrementing. Read the current highest ID and add 1. Wrap in wikilinks: `[[0001]]`
- **Priority**: `High`, `Medium`, or `Low`
- **Effort**: `Small` (< 1 hour), `Medium` (1-4 hours), `Large` (> 4 hours)
- **Area**: Which part of the application is affected. Use the most specific applicable tag:
  - `UI` — Components, layouts, visual elements, Atomic Design
  - `CSS` — Styles, variables, theming, colors, design tokens
  - `Frontend` — Frontend logic, routing, state management, reactivity
  - `Backend` — Server-side logic, business rules, data processing
  - `API` — REST endpoints, WebSocket handlers, GraphQL, data connections
  - `Database` — Schema, migrations, queries, data models
  - `Auth` — Authentication, authorization, permissions, security
  - `Tests` — Test coverage, test infrastructure, test utilities
  - `Infra` — CI/CD, Docker, deployment, build tooling
  - `Deps` — Dependencies, package management, bundle size
  - `Types` — TypeScript types, interfaces, type safety
  - `a11y` — Accessibility
  - `i18n` — Internationalization
  - `Docs` — Documentation
  - If an item spans multiple areas, use the primary one and note others in the detail file
- **Title**: Short, descriptive title. Max ~60 characters.
- **Status**: `Open`, `In Progress`, or `Done (YYYY-MM-DD)`. When marking Done, use strikethrough on the title: `~~Title~~`
- **Source**: Where this item was discovered. Format:
  - From MR review: `review-mr/<branch-name> (YYYY-MM-DD)`
  - From release notes: `release/<old>→<new> (YYYY-MM-DD)`
  - Manually added: `manual (YYYY-MM-DD)`

### Rules for adding items

- Always check for duplicates before adding — search existing titles and detail files for similar issues
- If a similar item already exists, update its detail file with the new occurrence rather than creating a duplicate
- Assign the next available ID (read the highest current ID and increment)
- New items always start as `Open`

## Detail Files: `<basedir>/tech-debt/<ID>.md`

Each item gets its own detail file. The filename is just the zero-padded ID (e.g., `0012.md`) so wikilinks from the master list resolve correctly.

All metadata goes in YAML frontmatter so Obsidian surfaces it as properties and makes it searchable/filterable.

```markdown
---
title: "<Title>"
id: "<0012>"
priority: "<high | medium | low>"
effort: "<small | medium | large>"
area: "<ui | css | frontend | backend | api | database | auth | tests | infra | deps | types | a11y | i18n | docs>"
also_affects:
  - "<other area if applicable>"
category: "<component-architecture | css-styling | reactivity | endpoints | error-handling | bundle-size | typescript | accessibility | i18n | reuse>"
status: "<open | in-progress | done>"
source: "<source string>"
created: YYYY-MM-DD
resolved: null
tags:
  - tech-debt
  - "priority/<high|medium|low>"
  - "area/<area-value>"
  - "effort/<small|medium|large>"
---

# <ID>: <Title>

## Description

<What the issue is and why it matters. Be specific — reference actual file names,
component names, variable names, function names.>

## Affected Files

- [[path/to/file1.ts]]
- [[path/to/file2.svelte]]
- [[path/to/styles.css]]

## Recommended Change

<Specific, actionable description of what to do. An engineer should be able to
read this and start working without additional research. Reference source files
with wikilinks like [[src/utils/helpers.ts]] so they're clickable in Obsidian.>

<Optional: code snippet showing current pattern vs recommended pattern>

## Context

<Additional context: which review or release surfaced this, related items in the
backlog as wikilinks (e.g., "Related: [[0005]]"), relevant source files
(e.g., "See also: [[src/components/shared/Button.svelte]]").>
```

### Tag conventions

Tags use a hierarchical structure for filtering in Obsidian:

- `tech-debt` — All tech debt items
- `priority/high`, `priority/medium`, `priority/low`
- `area/ui`, `area/css`, `area/frontend`, `area/backend`, `area/api`, etc.
- `effort/small`, `effort/medium`, `effort/large`
- `status/open`, `status/done` — Optional, since status is also a frontmatter property

Frontmatter values use lowercase/kebab-case. Display values in the body can use title case for readability.

### When an item is completed by `/btrs-do-tech-debt`, update frontmatter and append:

Update frontmatter:
- Set `status: done`
- Set `resolved: YYYY-MM-DD`
- Add `status/done` tag, remove `status/open` if present

Append to the body:

```markdown
## Resolution

**Date:** YYYY-MM-DD
**Changes made:**
- <list of files modified and what was done>

**Notes:** <any relevant context about the implementation>
```

## Deduplication

Before adding a new item, check for existing items that cover the same concern:

1. Search `<basedir>/tech-debt.md` for similar titles
2. Grep `<basedir>/tech-debt/*.md` for the same file paths in "Affected Files"
3. If a match is found:
   - If the existing item is `Open` — update its detail file with the new occurrence, don't create a new item
   - If the existing item is `Done` — create a new item (the issue has regressed). Add a wikilink to the previous item in the Context section: "Previously addressed in [[0005]], but has regressed."
   - If the existing item is similar but distinct — create a new item and note the relationship: "Related: [[0005]]"
