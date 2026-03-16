---
name: btrs-refactor
description: >
  Guided refactoring of code. Analyzes the target code, proposes a refactoring
  plan with safety checks, implements the changes, and verifies nothing broke.
  Use when the user wants to refactor code, clean up code, restructure
  something, extract a component, simplify logic, or asks "refactor this",
  "btrs refactor", "clean this up", "extract this into", "simplify this",
  "this code needs restructuring".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(npm *), Bash(pnpm *), Bash(npx *), Bash(node *), Read, Write, Edit, Grep, Glob
argument-hint: <file-or-directory> [refactoring-type]
---

# Refactor Skill

Guided, safe refactoring of code with analysis, planning, and verification.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Determine refactoring scope

`$ARGUMENTS` can be:

- **A file path** — Refactor that file (e.g., `src/components/Dashboard.svelte`)
- **A directory** — Refactor across a directory (e.g., `src/lib/utils/`)
- **A file + type** — e.g., `src/components/Header.svelte extract` for a specific refactoring type
- **No argument** — Ask what to refactor

### Refactoring types

If no type is specified, analyze the code and suggest the most impactful refactoring. Types:

- **extract** — Extract component, function, or module from a larger one
- **simplify** — Reduce complexity, flatten nesting, remove dead code
- **consolidate** — Merge similar/duplicate code into shared abstractions
- **restructure** — Change file/directory organization
- **modernize** — Update to current framework patterns (e.g., Options API → Composition API, class components → hooks, Svelte stores → runes)
- **types** — Improve TypeScript types (remove `any`, add interfaces, tighten generics)

## Step 2: Analyze the code

Read the target file(s) thoroughly. Then analyze for:

### Code smells
- Functions/components that are too long (>100 lines for components, >30 for functions)
- Deep nesting (>3 levels)
- Duplicated logic across files
- God objects/components that do too many things
- Primitive obsession (passing many individual values instead of objects)
- Feature envy (code that uses another module's data more than its own)

### Pattern violations
Read relevant shared audit references:
- Components → `~/.claude/skills/shared/audit-components.md` (Atomic Design)
- CSS → `~/.claude/skills/shared/audit-css.md` (token usage)
- Reactivity → `~/.claude/skills/shared/audit-reactivity.md` (subscription patterns)
- Endpoints → `~/.claude/skills/shared/audit-endpoints.md` (API patterns)

### Dependencies
Search for all files that import from or reference the target:

```bash
# Find all files that import the target
grep -rl "import.*from.*<target-module>" src/ --include="*.ts" --include="*.svelte" --include="*.vue" --include="*.tsx" --include="*.jsx"
```

Map out the dependency graph so changes don't break consumers.

## Step 3: Plan the refactoring

Present a detailed plan:

1. **Current state** — What the code looks like now and why it needs refactoring
2. **Target state** — What it should look like after
3. **Steps** — Ordered list of changes, each small enough to verify independently
4. **Files affected** — Every file that will be created, modified, or deleted
5. **Import updates** — All files that import from changed modules
6. **Risk assessment** — What could go wrong, how to verify
7. **Rollback** — How to undo if something goes wrong (usually: `git checkout`)

Key principles:
- Each step should leave the code in a working state
- Behavior should not change — refactoring is structure, not logic
- Prefer smaller, verifiable steps over large sweeping changes
- If the refactoring is large, suggest breaking it into multiple sessions

Ask: **"Does this plan look right? Ready to proceed?"**

Wait for confirmation.

## Step 4: Implement step by step

For each step in the plan:

1. Make the change
2. Update all imports and references
3. Verify consistency (no dangling imports, no type errors)
4. Move to the next step

Common refactoring operations:

### Extract component
1. Identify the extractable section (markup + logic + styles)
2. Determine props needed (what data flows in)
3. Determine events/callbacks (what flows back out)
4. Create the new component file
5. Replace the original section with the new component
6. Move relevant styles to the new component

### Extract function/module
1. Identify the extractable logic
2. Determine parameters and return type
3. Create or find the appropriate module file
4. Extract the function with proper types
5. Update the original file to import and use it
6. Search for other files with similar logic that should also use it

### Consolidate duplicates
1. Identify all instances of the duplicated code
2. Find the best location for the shared version
3. Create the shared abstraction with a clean interface
4. Replace each instance one at a time
5. Verify each replacement preserves behavior

### Modernize patterns
1. Read the current pattern
2. Write the modern equivalent
3. Verify behavior is identical
4. Update tests if the testing interface changed

## Step 5: Verify

After all changes:
- Trace through the refactored code to verify behavior is preserved
- Check all import chains are valid
- Verify no dead code was left behind
- Check that TypeScript types are consistent

## Step 6: Check for tech debt resolution

Check if this refactoring resolves any existing tech debt items:

```bash
# Search tech debt for items related to the refactored files
```

If any items are now resolved, update them in the backlog.

## Step 7: Present the result

Tell the user:
- Summary of what was refactored and why
- Files created/modified/deleted
- Any tech debt items resolved
- Suggest: "Run your test suite to verify behavior is preserved, then review with `/btrs-review-mr`"
