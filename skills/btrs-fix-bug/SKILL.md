---
name: btrs-fix-bug
description: >
  Work on a bug report from the bugs directory or a freeform description.
  Reads the report, investigates the root cause, plans a fix, implements it,
  and updates the report. Use when the user wants to fix a bug, debug an issue,
  investigate a problem, or asks "fix bug", "btrs fix bug", "debug this",
  "there's a bug in", "this is broken", "investigate this issue".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(npm *), Bash(pnpm *), Bash(npx *), Bash(node *), Read, Write, Edit, Grep, Glob
argument-hint: <bug-report-slug or description>
---

# Fix Bug Skill

Investigate and fix a bug from a report or description.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized.

## Step 1: Understand the bug

`$ARGUMENTS` can be:

- **A bug report slug** — Read `<basedir>/bugs/<slug>.md`
- **A freeform description** — Use it directly
- **No argument** — Check `<basedir>/bugs/` for open reports, or ask what to fix

If working from a bug report, read it for:
- Steps to reproduce
- Expected vs actual behavior
- Environment details
- Affected files/components
- Error messages or stack traces

If freeform, ask clarifying questions:
- What's the observed behavior?
- What's the expected behavior?
- Can you reproduce it consistently?
- When did it start happening?
- Any error messages?

## Step 2: Investigate

### Locate the problem area

Based on the bug description, narrow down where the issue is:

1. Search for relevant code by error messages, component names, or function names
2. Read the affected files identified in the report
3. Trace the data/control flow through the relevant code paths
4. Check git history for recent changes to the affected area:

```bash
git log --oneline -10 -- <affected-files>
```

### Identify the root cause

Look for common bug patterns:
- Off-by-one errors, incorrect conditionals
- Null/undefined access
- Race conditions, async ordering issues
- State management bugs (stale closures, missing reactivity)
- Type mismatches (especially at API boundaries)
- Missing error handling
- Incorrect data transformations
- Edge cases not accounted for

Read the relevant shared audit references if the bug touches those areas:
- Reactivity bugs → `~/.claude/skills/shared/audit-reactivity.md`
- Endpoint bugs → `~/.claude/skills/shared/audit-endpoints.md`
- Component bugs → `~/.claude/skills/shared/audit-components.md`

### Verify understanding

Before planning a fix, confirm the root cause with the user:
- "The issue is in `<file>:<line>` — <explanation of what's wrong>"
- "This happens because <root cause>"
- "Here's the problematic code: <snippet>"

## Step 3: Plan the fix

Present:
1. **Root cause** — What's actually wrong
2. **Fix approach** — What changes will fix it
3. **Files to modify** — Which files and what changes
4. **Risk assessment** — Could this fix break anything else?
5. **Test plan** — How to verify the fix works and doesn't regress

Ask: **"Does this diagnosis look right? Ready to fix?"**

Wait for confirmation.

## Step 4: Implement the fix

1. Make the targeted fix — change only what's needed
2. Don't refactor surrounding code (that's what `/btrs-refactor` is for)
3. If the fix reveals related issues, note them but don't fix them in scope
4. Add or update tests to cover the bug scenario
5. Ensure the test would have caught this bug (fails without the fix, passes with it)

## Step 5: Verify

After implementing:
- Manually trace through the fix to confirm it addresses the root cause
- Check that the fix doesn't introduce new issues in related code paths
- Verify edge cases are handled

## Step 6: Update the bug report

If working from a bug report in `<basedir>/bugs/`, update it:

```markdown
## Resolution

**Date:** YYYY-MM-DD
**Root cause:** <brief explanation>
**Fix:** <what was changed>
**Files modified:**
- [[path/to/file.ts]] — <what changed>

**Verified by:** <how it was verified>
```

Update the frontmatter status to `resolved` and set the resolved date.

If the investigation revealed tech debt, offer to create items via the tech debt backlog.

## Step 7: Present the result

Tell the user:
- Root cause summary
- What was changed and why
- Files modified
- How to verify the fix
- Any related issues found (offer to create tech debt or todo items)
- Suggest: "Run your test suite, then review with `/btrs-review-mr`"
