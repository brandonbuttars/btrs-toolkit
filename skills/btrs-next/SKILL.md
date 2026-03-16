---
name: btrs-next
description: >
  Suggest what to work on next. Reads open tech debt items and todos, ranks
  them by priority, effort, dependencies, and age, and presents 3-5
  recommendations. Optionally filter by area. Use when the user asks "what
  should I work on?", "what's next?", "btrs next", "suggest something to do",
  "what's the highest priority?", "what needs attention?", "pick something
  for me".
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Grep, Glob
argument-hint: [area-filter]
---

# Next Suggestion Skill

Read all open items (tech debt + todos), rank them, and suggest the best 3-5 to work on next.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Parse arguments

`$ARGUMENTS` can contain:
- **No arguments** — Show suggestions across all areas
- **Area filter** — One or more comma-separated areas to focus on: `UI`, `CSS`, `Frontend`, `Backend`, `API`, `Database`, `Auth`, `Tests`, `Infra`, `Deps`, `Types`, `a11y`, `i18n`, `Docs`

Examples:
```
/btrs-next                    # All areas
/btrs-next Frontend           # Frontend only
/btrs-next CSS,UI             # CSS and UI items
```

## Step 2: Gather all open items

Read both backlogs:

1. `<basedir>/tech-debt.md` — Parse all rows with status `Open` or `In Progress`
2. `<basedir>/todos.md` — Parse all rows with status `Open` or `In Progress`

If a filtered area was specified, only include items matching that area.

For each open item, also read its detail file to get:
- Full description and context
- Blocked-by dependencies (for todos)
- Created date (for age calculation)
- Affected files (for relevance scoring)

## Step 3: Check for blockers

For todo items with `blocked_by` fields, check if the blocking items are still open. Mark blocked items so they can be deprioritized in the ranking.

## Step 4: Rank items

Score each item using these factors (weighted):

1. **Priority** (40%) — High = 3, Medium = 2, Low = 1
2. **Effort** (20%) — Prefer smaller items to build momentum: Small = 3, Medium = 2, Large = 1
3. **Age** (15%) — Older items score higher. Days since created / 30, capped at 3.
4. **Type** (10%) — Tech debt items get a slight boost if there are many (backlog pressure). Todos get a boost if they're blocking other items.
5. **Blocked** (15%) — Not blocked = 3, blocked = 0

Sort by composite score descending.

## Step 5: Check recent git activity

For the top candidates, check if their affected files have been recently modified:

```bash
git log --oneline --since="7 days ago" -- <affected-files>
```

If files were recently touched, note this — it might be a good time to address the item while the area is fresh in mind.

## Step 6: Present recommendations

Show the top 3-5 items:

```markdown
> [!tip] Suggested next items
>
> **1. [[<ID>]] — <Title>**
> _<Type> · <Priority> priority · <Effort> effort · <Age> days old_
> <1-2 sentence summary of what this is and why it's ranked high>
> <If recently active: "📍 Files recently modified — good time to address this">
> Run: `/btrs-do-tech-debt <ID>` or `/btrs-do-todo <ID>`
>
> **2. [[<ID>]] — <Title>**
> ...
>
> **3. [[<ID>]] — <Title>**
> ...
```

Also show a brief status summary:

```
**Backlog status:**
- Tech debt: <N> open (<H> high, <M> medium, <L> low)
- Todos: <N> open (<H> high, <M> medium, <L> low)
- Blocked items: <N>
```

If the area filter was used, mention what other areas have items waiting.

## Step 7: Offer next actions

Ask the user:
- "Want to start on one of these? Tell me the number or ID."
- "Want to see a different area? Try `/btrs-next <area>`."
- "Want to add something new? Try `/btrs-add-todo` or `/btrs-add-tech-debt`."
