---
name: btrs-add-todo
description: >
  Add a todo item to the project todo list. Interactively collects title,
  priority, effort, area, description, and affected files, then creates the
  detail file and updates the master list. Use when the user wants to add
  a todo, create a task, log something to do, or asks "add todo", "create
  a todo", "btrs add todo", "I need to do", "add a task", "track this".
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Write, Grep, Glob
argument-hint: ["title"]
---

# Add Todo Item

Add a todo item to the project todo list.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Read the format reference

```
~/.claude/skills/shared/todo-format.md
```

## Step 2: Collect item details

If `$ARGUMENTS` is provided, use it as the title. Otherwise ask for it.

Then collect the remaining fields interactively. For each field, suggest a default based on context if possible:

1. **Title** — From argument or ask. Short, descriptive, max ~60 characters.
2. **Priority** — Ask: High, Medium, or Low. Explain: High = blocking or time-sensitive, Medium = should do soon, Low = when there's time.
3. **Effort** — Ask: Small (<1hr), Medium (1-4hr), Large (>4hr).
4. **Area** — Ask which part of the app: UI, CSS, Frontend, Backend, API, Database, Auth, Tests, Infra, Deps, Types, a11y, i18n, Docs.
5. **Description** — Ask the user to describe what needs to be done. Help them be specific — reference file names, component names, function names. Include acceptance criteria if they have them.
6. **Affected files** — Ask which files are affected. If the user is vague, offer to search the codebase to find relevant files.
7. **Blocked by** — Ask if this is blocked by any other items (tech debt or other todos). If so, collect the IDs.

## Step 3: Check for duplicates

Before creating the item, search for existing items:

1. Search `<basedir>/todos.md` for similar titles
2. Grep `<basedir>/todos/*.md` for the same affected file paths
3. Also check `<basedir>/tech-debt.md` — the work might already be tracked there

If a potential duplicate is found, show it to the user and ask if this is the same item or a new one.

## Step 4: Determine the next ID

```bash
# Find the highest existing ID
ls <basedir>/todos/*.md 2>/dev/null | sort -V | tail -1
```

Increment by 1. If no items exist, start at T0001.

## Step 5: Create the detail file

Write `<basedir>/todos/<ID>.md` following the format from the shared reference, including full YAML frontmatter with tags:

```markdown
---
title: "<title>"
id: "<ID>"
priority: "<priority>"
effort: "<effort>"
area: "<area>"
status: "open"
source: "manual (YYYY-MM-DD)"
created: YYYY-MM-DD
resolved: null
blocked_by: []
tags:
  - todo
  - "priority/<priority>"
  - "area/<area>"
  - "effort/<effort>"
---

# <ID>: <title>

## Description

<user's description>

## Affected Files

- [[path/to/file]]

## Implementation Notes

<work with the user to define this, or "TBD — to be determined during implementation">

## Context

Manually added on YYYY-MM-DD.
```

## Step 6: Update the master list

Add a new row to `<basedir>/todos.md`:

```
| [[<ID>]] | <Priority> | <Effort> | <Area> | <Title> | Open | manual (YYYY-MM-DD) |
```

## Step 7: Confirm

Tell the user:
- The item was created: `[[<ID>]]` — <title>
- The file path for the detail file
- Current list status (total open items)
- Suggest: "Run `/btrs-next` to see prioritized suggestions for what to work on."
