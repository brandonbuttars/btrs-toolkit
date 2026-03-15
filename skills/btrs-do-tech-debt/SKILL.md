---
name: btrs-do-tech-debt
description: >
  Work on a tech debt item from the backlog. Takes an item number and
  implements the recommended changes. Use when the user wants to work on
  tech debt, fix tech debt, tackle a tech debt item, or has downtime to
  make improvements. Trigger on phrases like "do tech debt", "work on
  tech debt", "fix tech debt item", "tackle item", "work on improvement",
  "btrs tech debt", "tech debt number", or when the user references a
  tech debt item by number.
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Write, Grep, Glob, Edit
argument-hint: <item-number> or "list" or "next"
---

# Do Tech Debt Skill

Pick a tech debt item from the backlog and implement the recommended changes.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized by checking that `<basedir>/tech-debt/` exists.

## Step 1: Parse arguments

`$ARGUMENTS` determines what to do:

- **A number** (e.g., `12`) — Work on that specific item
- **`list`** — Show the current backlog summary (just read and display `<basedir>/tech-debt.md`)
- **`next`** — Find the highest-priority open item and work on it
- **No argument** — Same as `next`

## Step 2: Verify the backlog exists

Check that `<basedir>/tech-debt.md` exists:
```bash
test -f <basedir>/tech-debt.md
```

If it doesn't exist, tell the user: "No tech debt backlog found. Run `/review-mr` or `/release-notes` to generate tech debt items, or create `<basedir>/tech-debt.md` manually."

## Step 3: Handle "list" command

If the argument is `list`, read and display `<basedir>/tech-debt.md` with a summary:
- Total items, grouped by status (Open, In Progress, Done)
- Count by priority (High, Medium, Low)
- Count by area (UI, CSS, Frontend, Backend, API, etc.)
- Suggest the highest-priority open item to work on next

Then stop — don't proceed to implementation.

## Step 4: Find the target item

If a number was provided, look it up in `<basedir>/tech-debt.md`. If `next` or no argument, find the first open item with the highest priority (High > Medium > Low), preferring smaller effort (Small > Medium > Large) as a tiebreaker.

Verify the item exists and its status is `Open`:
- If the item doesn't exist, tell the user and show nearby valid IDs
- If the item is already `Done`, tell the user and suggest the next open item
- If the item is `In Progress`, ask if they want to continue or pick a different one

## Step 5: Read the detail file

Read the item's detail file:
```
<basedir>/tech-debt/<ID>.md
```

Where `<ID>` is the zero-padded item number (e.g., `0012.md`).

If the detail file is missing, show whatever info is in the master list and offer to work from that.

## Step 6: Staleness check

Before presenting the plan, check whether the affected files have changed since the item was created. The detail file has a `Created` date and an `Affected Files` list.

```bash
# Check git log for changes to affected files since the item was created
git log --oneline --since="<created-date>" -- <file1> <file2> ...
```

Based on what you find:

- **No changes** — The item is still current. Proceed to Step 7.
- **Minor changes** — Files were touched but the core issue likely remains. Read the current state of the affected files and note what changed. Proceed to Step 7 but mention the recent changes in the plan.
- **Significant changes** — The files were substantially reworked. Read the current code and assess:
  - **Fully addressed** — The issue no longer exists. Tell the user, mark the item as `Done` in both the master list and detail file (add a Resolution noting it was addressed by other work), and suggest the next item.
  - **Partially addressed** — Some of the issue remains. Update the detail file with what's still relevant, remove any recommendations that are no longer applicable, and proceed to Step 7 with the updated scope.
  - **Still present but context changed** — The issue exists but the recommended change needs adjustment. Update the detail file's Recommended Change section and proceed to Step 7.

Always tell the user what you found: "This item was created on YYYY-MM-DD. Since then, <N> commits have touched the affected files. <assessment>."

## Step 7: Present the item and plan

Show the user:

1. **The item** — Full content from the detail file: area, category, description, affected files, recommended change, effort estimate, and source (which MR review or release generated it)

2. **Staleness assessment** — What changed since the item was created (from Step 6)

3. **The implementation plan** — Before touching any code, read the affected files listed in the detail document and create a concrete plan:
   - Which files will be modified, created, or deleted
   - What specific changes will be made in each file
   - Any new files or components that need to be created
   - Any imports or references that need updating
   - Potential risks or side effects of the changes
   - Whether tests need to be added or updated

Present this clearly and ask: **"Ready to proceed? Or would you like to adjust the plan?"**

Wait for the user to confirm before making any changes.

## Step 8: Implement the changes

Once confirmed, make the changes as planned. Follow the same quality standards the review-mr skill checks for — don't introduce new tech debt while fixing existing tech debt:

- Use existing CSS variables, design tokens, and theming
- Follow Atomic Design patterns for component changes
- Ensure proper reactivity cleanup for reactive code
- Handle error states and edge cases
- Use existing utilities and shared code where available
- Maintain TypeScript strictness if the project uses TS

After making changes, give the user a summary of what was changed.

## Step 9: Update the backlog

After changes are complete, update both files:

**In `<basedir>/tech-debt.md`** — Change the item's status from `Open` to `Done` and add the completion date:
```
| 0012 | High | Small | CSS | ~~Consolidate duplicate color variables~~ | Done (YYYY-MM-DD) | release/1.3 |
```

**In `<basedir>/tech-debt/0012.md`** — Add a "Resolution" section at the bottom:
```markdown
## Resolution

**Date:** YYYY-MM-DD
**Changes made:**
- <list of files modified and what was done>

**Notes:** <any relevant context about the implementation>
```

## Step 10: Suggest next item

After completing the item, check if there are more open items and suggest the next highest-priority one: "Item #12 is done. Next highest-priority item is #7: 'Extract reusable Button atom from repeated patterns' (High priority, Small effort). Want to tackle it?"
