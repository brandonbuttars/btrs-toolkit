---
name: btrs-do-todo
description: >
  Work on a todo item from the todo list. Takes an item ID and implements
  the work described. Use when the user wants to work on a todo, do a task,
  tackle a todo item, or asks "do todo", "work on todo", "btrs do todo",
  "tackle T0005", "work on task", or references a todo item by ID.
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(npm *), Bash(pnpm *), Bash(npx *), Bash(node *), Read, Write, Edit, Grep, Glob
argument-hint: <item-id> or "list" or "next"
---

# Do Todo Skill

Pick a todo item from the list and implement it.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized by checking that `<basedir>/todos/` exists.

## Step 1: Parse arguments

`$ARGUMENTS` determines what to do:

- **An ID** (e.g., `T0005`) — Work on that specific item
- **`list`** — Show the current todo list summary (read and display `<basedir>/todos.md`)
- **`next`** — Find the highest-priority unblocked item and work on it
- **No argument** — Same as `next`

## Step 2: Verify the todo list exists

```bash
test -f <basedir>/todos.md
```

If it doesn't exist, tell the user: "No todo list found. Run `/btrs-add-todo` to create items, or `/btrs-init-project` to initialize."

## Step 3: Handle "list" command

If the argument is `list`, read and display `<basedir>/todos.md` with a summary:
- Total items, grouped by status (Open, In Progress, Done)
- Count by priority (High, Medium, Low)
- Count by area
- Blocked items and what blocks them
- Suggest the highest-priority unblocked item

Then stop.

## Step 4: Find the target item

If an ID was provided, look it up in `<basedir>/todos.md`. If `next` or no argument, find the first unblocked open item with the highest priority (High > Medium > Low), preferring smaller effort as a tiebreaker.

Verify the item exists and its status is `Open`:
- If the item doesn't exist, tell the user and show nearby valid IDs
- If the item is already `Done`, tell the user and suggest the next open item
- If the item is `In Progress`, ask if they want to continue or pick a different one
- If the item is blocked, show what blocks it and suggest an unblocked item instead

## Step 5: Read the detail file

Read `<basedir>/todos/<ID>.md`.

If the detail file is missing, show whatever info is in the master list and offer to work from that.

## Step 6: Staleness check

Check whether the affected files have changed since the item was created:

```bash
git log --oneline --since="<created-date>" -- <file1> <file2> ...
```

- **No changes** — Item is current. Proceed.
- **Minor changes** — Note the changes, proceed with awareness.
- **Significant changes** — Read the current code and assess:
  - **Already done** — Mark done, suggest next item.
  - **Partially done** — Update the detail file, proceed with remaining scope.
  - **Still needed but context changed** — Update the detail file, proceed.

Tell the user what you found.

## Step 7: Present the item and plan

Show the user:

1. **The item** — Full content from the detail file
2. **Staleness assessment** — What changed since creation
3. **Implementation plan** — Read the affected files and create a concrete plan:
   - Files to create, modify, or delete
   - Specific changes in each file
   - Dependencies and imports to update
   - Tests to add or update
   - Risks or side effects

Ask: **"Ready to proceed? Or would you like to adjust the plan?"**

Wait for confirmation.

## Step 8: Implement

Once confirmed, implement following the plan. Apply the same quality standards as `/btrs-implement`:

- Read shared audit references relevant to the work
- Follow existing project patterns
- Use existing utilities and shared code
- Handle error states and edge cases
- Add tests matching project conventions

## Step 9: Update the todo list

Read `~/.claude/skills/shared/todo-format.md`.

**In `<basedir>/todos.md`** — Change the item's status from `Open` to `Done (YYYY-MM-DD)` and strikethrough the title.

**In `<basedir>/todos/<ID>.md`** — Update frontmatter (`status: done`, `resolved: YYYY-MM-DD`) and append:

```markdown
## Resolution

**Date:** YYYY-MM-DD
**Changes made:**
- <list of files modified and what was done>

**Notes:** <any relevant context about the implementation>
```

## Step 10: Suggest next item

After completing, check for more open items and suggest the next highest-priority unblocked one: "Todo T0005 is done. Next up is T0003: '<title>' (High priority, Small effort). Want to tackle it?"
