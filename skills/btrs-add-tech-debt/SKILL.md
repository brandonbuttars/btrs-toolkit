---
name: btrs-add-tech-debt
description: >
  Manually add a tech debt item to the backlog. Interactively collects
  title, priority, effort, area, description, and affected files, then
  creates the detail file and updates the master list. Use when the user
  wants to add tech debt, log a tech debt item, create a backlog item,
  or asks "add tech debt", "log tech debt", "btrs add tech debt",
  "create a tech debt item", "I noticed some tech debt".
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Write, Grep, Glob
argument-hint: ["title"]
---

# Add Tech Debt Item

Manually add a tech debt item to the persistent backlog.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized by checking that `<basedir>/tech-debt/` exists.

## Step 1: Read the format reference

```
~/.claude/skills/shared/tech-debt-format.md
```

## Step 2: Collect item details

If `$ARGUMENTS` is provided, use it as the title. Otherwise ask for it.

Then collect the remaining fields interactively. For each field, suggest a default based on context if possible:

1. **Title** — From argument or ask. Short, descriptive, max ~60 characters.
2. **Priority** — Ask: High, Medium, or Low. Explain: High = affects reliability/compounds fast, Medium = maintainability concern, Low = nice-to-have.
3. **Effort** — Ask: Small (<1hr), Medium (1-4hr), Large (>4hr).
4. **Area** — Ask which part of the app: UI, CSS, Frontend, Backend, API, Database, Auth, Tests, Infra, Deps, Types, a11y, i18n, Docs.
5. **Category** — Suggest based on area: Component Architecture, CSS & Styling, Reactivity, Endpoints, Error Handling, Bundle Size, TypeScript, Accessibility, i18n, Reuse.
6. **Description** — Ask the user to describe the issue. Help them be specific — reference file names, component names, function names.
7. **Affected files** — Ask which files are affected. If the user is vague, offer to search the codebase to find relevant files.

## Step 3: Check for duplicates

Before creating the item, search the existing backlog:

1. Search `<basedir>/tech-debt.md` for similar titles
2. Grep `<basedir>/tech-debt/*.md` for the same affected file paths

If a potential duplicate is found, show it to the user and ask if this is the same issue or a new one.

## Step 4: Determine the next ID

```bash
# Find the highest existing ID
ls <basedir>/tech-debt/*.md 2>/dev/null | sort -V | tail -1
```

Increment by 1. If no items exist, start at 0001.

## Step 5: Create the detail file

Write `<basedir>/tech-debt/<ID>.md` following the format from the shared reference, including full YAML frontmatter with tags:

```markdown
---
title: "<title>"
id: "<ID>"
priority: "<priority>"
effort: "<effort>"
area: "<area>"
category: "<category>"
status: "open"
source: "manual (YYYY-MM-DD)"
created: YYYY-MM-DD
resolved: null
tags:
  - tech-debt
  - "priority/<priority>"
  - "area/<area>"
  - "effort/<effort>"
---

# <ID>: <title>

## Description

<user's description>

## Affected Files

- [[path/to/file]]

## Recommended Change

<work with the user to define this, or leave as "TBD — to be determined during implementation">

## Context

Manually added on YYYY-MM-DD.
```

## Step 6: Update the master list

Add a new row to `<basedir>/tech-debt.md`:

```
| [[<ID>]] | <Priority> | <Effort> | <Area> | <Title> | Open | manual (YYYY-MM-DD) |
```

## Step 7: Confirm

Tell the user:
- The item was created: `[[<ID>]]` — <title>
- The file path for the detail file
- Current backlog status (total open items)
- Suggest: "Run `/btrs-do-tech-debt <ID>` when you're ready to work on it."
