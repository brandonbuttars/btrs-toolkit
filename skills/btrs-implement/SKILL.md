---
name: btrs-implement
description: >
  Write code from a spec, todo item, tech debt item, or freeform description.
  Plans the implementation, writes code following project conventions, and
  updates the source tracking item. Use when the user wants to implement
  something, write code for a feature, build something from a spec, or asks
  "implement this", "build this", "btrs implement", "write the code for",
  "code this up", "let's build".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(npm *), Bash(pnpm *), Bash(npx *), Bash(node *), Read, Write, Edit, Grep, Glob
argument-hint: <item-id or description>
---

# Implement Skill

Write code from a spec, todo, tech debt item, or freeform description.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized.

## Step 1: Determine what to implement

`$ARGUMENTS` can be:

- **A todo ID** (e.g., `T0005`) — Read `<basedir>/todos/T0005.md`
- **A tech debt ID** (e.g., `0012`) — Read `<basedir>/tech-debt/0012.md`
- **A spec path** (e.g., `specs/user-management.md`) — Read `<basedir>/specs/user-management.md`
- **A freeform description** — Use it directly
- **No argument** — Ask what to implement

If working from a tracked item (todo or tech debt), read the detail file to get the full description, affected files, and implementation notes.

## Step 2: Understand project conventions

Check if `<basedir>/tech-stack.md` exists. If so, read it for:
- Framework and language
- Component patterns
- Testing conventions
- Styling approach
- File organization

If tech-stack.md doesn't exist, detect conventions by reading:
- `package.json` for dependencies
- `tsconfig.json` for TypeScript config
- Existing code in `src/` for patterns

Read the shared audit references that are relevant to the work:
- If creating components → `~/.claude/skills/shared/audit-components.md`
- If touching styles → `~/.claude/skills/shared/audit-css.md`
- If creating endpoints → `~/.claude/skills/shared/audit-endpoints.md`
- If working with reactive code → `~/.claude/skills/shared/audit-reactivity.md`

## Step 3: Read existing code

Before writing any code, read the files that will be affected:

1. Read all files listed in the item's "Affected Files" section
2. Read neighboring files to understand patterns (imports, naming, structure)
3. Search for similar implementations in the codebase that this code should match
4. Check for shared utilities, types, or components that should be reused

## Step 4: Plan the implementation

Present the plan before writing code:

1. **Files to create** — New files with their purpose and location
2. **Files to modify** — Existing files and what changes
3. **Dependencies** — Any new packages needed
4. **Types** — New types or interfaces needed
5. **Tests** — What tests to add or update
6. **Approach** — Brief description of the implementation strategy

Follow these quality standards:
- Use existing CSS variables, design tokens, and theming
- Follow Atomic Design patterns for components
- Ensure proper reactivity cleanup for reactive code
- Handle error states and edge cases
- Use existing utilities and shared code
- Maintain TypeScript strictness if the project uses TS
- Match the naming conventions of surrounding code

Ask: **"Ready to proceed? Or would you like to adjust the plan?"**

Wait for confirmation.

## Step 5: Implement

Write the code following the plan. For each file:

1. If modifying an existing file, read it first and use Edit for targeted changes
2. If creating a new file, use Write
3. Follow the project's existing patterns exactly
4. Add tests matching the project's testing conventions
5. Don't over-engineer — implement exactly what was specified

After implementation, verify:
- No import errors (check that all imported modules exist)
- Types are consistent (if TypeScript)
- No obvious runtime errors

## Step 6: Update tracking

If working from a tracked item:

**For todo items** — Read `~/.claude/skills/shared/todo-format.md`. Update the item's status to `Done` in both the master list and detail file. Add a Resolution section.

**For tech debt items** — Read `~/.claude/skills/shared/tech-debt-format.md`. Update the item's status to `Done` in both the master list and detail file. Add a Resolution section.

**For spec items** — Note which parts of the spec have been implemented.

## Step 7: Present the result

Tell the user:
- What files were created/modified
- Brief summary of the implementation approach
- Any decisions made during implementation
- If from a tracked item: confirmation that the item was marked done
- Suggest: "Run your test suite to verify, then review the changes with `/btrs-review-mr`"
