---
name: btrs-audit-reactivity
description: >
  Audit reactive patterns and state management across the codebase.
  Checks for subscription leaks, missing cleanup, unnecessary reactivity,
  stale closures, cascading chains, and inefficient reactive patterns.
  Feeds findings into the tech debt backlog. Use when the user wants to
  check for reactive leaks, audit state management, find subscription
  leaks, review effects/watchers, or asks "check for leaks",
  "audit reactivity", "btrs audit reactivity", "state management audit".
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Grep, Glob
argument-hint: [directory-or-file]
---

# Reactivity & State Management Audit

Audit reactive patterns for leaks, inefficiencies, and architectural issues. Scans the whole codebase by default.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized by checking that `<basedir>/tech-debt/` exists.

## Step 1: Determine scope

- If `$ARGUMENTS` is provided, use as target
- Otherwise, scan the entire project

Find all component and script files:
```bash
find <scope> -type f \( -name "*.svelte" -o -name "*.vue" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.ts" -o -name "*.js" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*"
```

## Step 2: Read the shared audit reference

```
~/.claude/skills/shared/audit-reactivity.md
```

Also read:
```
~/.claude/skills/shared/tech-debt-format.md
```

## Step 3: Detect the reactivity framework

Follow the detection steps from the shared reference.

## Step 4: Run the audit

Work through each section of the shared reactivity audit reference:
1. Subscription leak detection — search for creation patterns, verify cleanup exists
2. Unnecessary vs missing reactivity
3. Reactive dependency issues
4. Expensive computations in reactive contexts
5. Cascading reactivity chains
6. Store/signal architecture review

For each finding, classify by priority:
- **High** — Subscription leaks, missing cleanup (memory leaks)
- **Medium** — Cascading chains, stale closures, unnecessary reactivity
- **Low** — Optimization opportunities, minor architectural improvements

## Step 5: Add findings to the tech debt backlog

Create tech debt items with area `Frontend` and category `reactivity`.

## Step 6: Generate audit report

Write to `<basedir>/reviews/audit-reactivity-<YYYY-MM-DD>.md`:

```markdown
---
title: "Reactivity Audit"
date: YYYY-MM-DD
type: audit-reactivity
scope: "<directory or 'full codebase'>"
framework: "<detected framework>"
findings: <count>
leaks_found: <count>
tags:
  - audit
  - audit/reactivity
---

# Reactivity & State Management Audit

**Scope:** <directory or full codebase>
**Framework:** <detected>
**Files scanned:** <count>

## Subscription Inventory

<Summary of all reactive subscriptions found, grouped by type, with cleanup status>

## Findings

<Findings organized by priority using Obsidian callouts>

## Tech Debt Items Created

<Wikilinks to new backlog items>

## Recommendations

<Summary of most impactful improvements>
```

## Step 7: Present results

Report path, leak count, finding counts by priority.
