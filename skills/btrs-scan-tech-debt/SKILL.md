---
name: btrs-scan-tech-debt
description: >
  Run a comprehensive tech debt scan across the codebase. Executes all
  audit categories (CSS, reactivity, endpoints, components) plus additional
  checks for TypeScript, accessibility, i18n, error handling, bundle
  efficiency, and code reuse. Feeds all findings into the tech debt
  backlog. Use when the user wants a full tech debt scan, codebase audit,
  quality check, or asks "scan for tech debt", "full audit", "codebase
  health check", "btrs scan", "what tech debt do we have?".
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Grep, Glob
argument-hint: [category-filter] [directory]
---

# Tech Debt Scanner

Run a comprehensive tech debt analysis across the codebase. By default runs all audit categories. Optionally filter to specific categories.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Parse arguments

`$ARGUMENTS` can contain:
- **No arguments** — Run all categories against the full codebase
- **Category filter** — Comma-separated list of categories to run: `css`, `reactivity`, `endpoints`, `components`, `typescript`, `a11y`, `i18n`, `errors`, `bundle`, `reuse`
- **Directory** — A path to scope the scan (can combine with categories: `css,reactivity src/`)

Examples:
```
/btrs-scan-tech-debt                           # All categories, full codebase
/btrs-scan-tech-debt css,reactivity            # Only CSS and reactivity
/btrs-scan-tech-debt src/components/           # All categories, scoped to directory
/btrs-scan-tech-debt css src/styles/           # CSS only, scoped to styles dir
```

## Step 2: Read shared references

Read all relevant audit references based on the selected categories:

```
~/.claude/skills/shared/audit-css.md            # For: css
~/.claude/skills/shared/audit-reactivity.md     # For: reactivity
~/.claude/skills/shared/audit-endpoints.md      # For: endpoints
~/.claude/skills/shared/audit-components.md     # For: components
~/.claude/skills/shared/diff-analysis.md        # For: general patterns
~/.claude/skills/shared/tech-debt-format.md     # Always (for backlog writes)
```

## Step 3: Detect project patterns

Read the "Detecting Project Patterns" section from `diff-analysis.md`. Detect:
- Styling system, component patterns, reactivity framework
- TypeScript, i18n, a11y, endpoint patterns

Use detection results to determine which conditional categories apply.

## Step 4: Run selected audits

For each selected category, follow the analysis guidance from the corresponding shared reference. Categories not covered by a dedicated shared reference use inline analysis:

**Always available:**
- `css` — Follow `audit-css.md`
- `reactivity` — Follow `audit-reactivity.md`
- `endpoints` — Follow `audit-endpoints.md`
- `components` — Follow `audit-components.md`
- `reuse` — Search for duplicate functions, utilities, and patterns across the codebase
- `errors` — Check for missing error boundaries, try/catch, loading/error/empty states
- `bundle` — Check for barrel imports, large dependencies, missing code splitting, unused imports

**Conditional (only if detected in the project):**
- `typescript` — Check for `any` types, loose generics, type assertions, missing return types
- `a11y` — Check for ARIA attributes, keyboard support, color-only indicators, label associations
- `i18n` — Check for hardcoded user-facing strings, missing translation keys

If running all categories, skip conditional ones that don't apply to the project.

## Step 5: Consolidate and deduplicate findings

Before writing to the backlog:
1. Merge findings that describe the same underlying issue from different angles
2. Check existing backlog items for duplicates
3. Assign priority and effort based on the analysis
4. Assign the appropriate area tag for each item

## Step 6: Add findings to the tech debt backlog

Create tech debt items following the shared format. Source: `scan-tech-debt (YYYY-MM-DD)`.

## Step 7: Generate scan report

Write to `<basedir>/reviews/scan-tech-debt-<YYYY-MM-DD>.md`:

```markdown
---
title: "Tech Debt Scan"
date: YYYY-MM-DD
type: scan-tech-debt
scope: "<directory or 'full codebase'>"
categories: [<list of categories run>]
findings: <count>
tags:
  - audit
  - audit/full-scan
---

# Tech Debt Scan

**Scope:** <directory or full codebase>
**Categories:** <list of categories run>
**Files scanned:** <count>

## Summary

<Overview: total findings, breakdown by category, top concerns>

## Findings by Category

### CSS & Styling
<findings or "Not scanned" or "No issues found">

### Reactivity & State Management
<findings>

### Endpoints & Data Connections
<findings>

### Component Architecture
<findings>

### Error Handling
<findings>

### Bundle & Imports
<findings>

### Code Reuse
<findings>

### TypeScript
<findings or "N/A — project does not use TypeScript">

### Accessibility
<findings or "N/A — no a11y patterns detected">

### Internationalization
<findings or "N/A — no i18n system detected">

## New Tech Debt Items

| ID | Priority | Effort | Area | Title |
|----|----------|--------|------|-------|
| [[<ID>]] | ... | ... | ... | ... |

## Backlog Status After Scan

**Total open items:** <count>
**High:** <count> | **Medium:** <count> | **Low:** <count>

> [!tip] Top items to tackle
> 1. [[<ID>]] — <title> _(Priority, Effort)_
> 2. [[<ID>]] — <title> _(Priority, Effort)_
> 3. [[<ID>]] — <title> _(Priority, Effort)_
>
> Run `/btrs-do-tech-debt <ID>` to start working on an item.
```

## Step 8: Present results

Tell the user: report path, total findings by category, new backlog items created, top 3 items to tackle.
