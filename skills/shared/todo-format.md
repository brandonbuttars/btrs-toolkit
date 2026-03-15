# Todo List Format

This reference defines the format for the todo list used by `btrs-add-todo`, `btrs-do-todo`, and `btrs-next` skills. All skills must read and write using these exact formats to stay consistent.

The basedir (resolved from `.btrs-config.json`, default `.local`) is the output directory. All generated documents use Obsidian-compatible features: YAML frontmatter for properties, tags for filtering, wikilinks for navigation, and callouts for emphasis.

## Master List: `<basedir>/todos.md`

The master list is a clean, scannable table with wikilinks to detail files. One row per item. Do not put detailed descriptions here — they go in the individual detail files.

```markdown
---
tags:
  - todo
  - index
---

# Todo List

| ID | Priority | Effort | Area | Title | Status | Source |
|----|----------|--------|------|-------|--------|--------|
| [[T0001]] | High | Small | Frontend | Add loading state to Dashboard | Open | manual (2025-03-14) |
| [[T0002]] | Medium | Medium | API | Add pagination to user list endpoint | Open | plan-feature/user-mgmt (2025-03-14) |
```

The `[[T0001]]` wikilinks make each ID clickable in Obsidian, navigating directly to the detail file.

### Column definitions

- **ID**: `T` prefix + zero-padded 4-digit number, auto-incrementing. Read the current highest ID and add 1. Wrap in wikilinks: `[[T0001]]`. The `T` prefix distinguishes todos from tech debt items.
- **Priority**: `High`, `Medium`, or `Low`
- **Effort**: `Small` (< 1 hour), `Medium` (1-4 hours), `Large` (> 4 hours)
- **Area**: Which part of the application is affected. Uses the same area tags as tech debt:
  - `UI`, `CSS`, `Frontend`, `Backend`, `API`, `Database`, `Auth`, `Tests`, `Infra`, `Deps`, `Types`, `a11y`, `i18n`, `Docs`
  - If an item spans multiple areas, use the primary one and note others in the detail file
- **Title**: Short, descriptive title. Max ~60 characters.
- **Status**: `Open`, `In Progress`, or `Done (YYYY-MM-DD)`. When marking Done, use strikethrough on the title: `~~Title~~`
- **Source**: Where this item came from. Format:
  - Manually added: `manual (YYYY-MM-DD)`
  - From feature planning: `plan-feature/<feature-name> (YYYY-MM-DD)`
  - From ADR: `adr/<adr-number> (YYYY-MM-DD)`
  - From think-through: `think-through (YYYY-MM-DD)`

### Rules for adding items

- Always check for duplicates before adding — search existing titles and detail files for similar items
- If a similar item already exists, update its detail file rather than creating a duplicate
- Assign the next available ID (read the highest current ID and increment)
- New items always start as `Open`

## Detail Files: `<basedir>/todos/<ID>.md`

Each item gets its own detail file. The filename is just the ID (e.g., `T0001.md`) so wikilinks from the master list resolve correctly.

```markdown
---
title: "<Title>"
id: "<T0001>"
priority: "<high | medium | low>"
effort: "<small | medium | large>"
area: "<area>"
also_affects:
  - "<other area if applicable>"
status: "<open | in-progress | done>"
source: "<source string>"
created: YYYY-MM-DD
resolved: null
blocked_by: []
tags:
  - todo
  - "priority/<high|medium|low>"
  - "area/<area-value>"
  - "effort/<small|medium|large>"
---

# <ID>: <Title>

## Description

<What needs to be done and why. Be specific — reference file names, component names,
function names. Include acceptance criteria if applicable.>

## Affected Files

- [[path/to/file1.ts]]
- [[path/to/file2.svelte]]

## Implementation Notes

<Any known approach, constraints, or considerations. Can be "TBD" if not yet planned.>

## Context

<Where this todo came from, related items as wikilinks (e.g., "Related: [[T0005]]",
"Depends on: [[T0003]]"), relevant specs or decisions (e.g., "See: [[ADR-0003]]").>
```

### Tag conventions

Tags use a hierarchical structure for filtering in Obsidian:

- `todo` — All todo items
- `priority/high`, `priority/medium`, `priority/low`
- `area/ui`, `area/css`, `area/frontend`, `area/backend`, `area/api`, etc.
- `effort/small`, `effort/medium`, `effort/large`

Frontmatter values use lowercase/kebab-case. Display values in the body can use title case for readability.

### When an item is completed, update frontmatter and append:

Update frontmatter:
- Set `status: done`
- Set `resolved: YYYY-MM-DD`

Append to the body:

```markdown
## Resolution

**Date:** YYYY-MM-DD
**Changes made:**
- <list of files modified and what was done>

**Notes:** <any relevant context about the implementation>
```

## Deduplication

Before adding a new item, check for existing items that cover the same work:

1. Search `<basedir>/todos.md` for similar titles
2. Grep `<basedir>/todos/*.md` for the same file paths in "Affected Files"
3. Also check `<basedir>/tech-debt.md` — the work might already be tracked as tech debt
4. If a match is found:
   - If the existing item is `Open` — update its detail file, don't create a new item
   - If the existing item is `Done` — create a new item if the work is genuinely needed again
   - If the existing item is similar but distinct — create a new item and note the relationship: "Related: [[T0005]]"
