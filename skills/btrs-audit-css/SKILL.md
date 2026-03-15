---
name: btrs-audit-css
description: >
  Audit CSS, styling, theming, and color palette consistency across the
  codebase. Checks for hardcoded values that should use design tokens,
  near-duplicate colors, missing theme variable usage, style duplication,
  and opportunities to consolidate. Feeds findings into the tech debt
  backlog. Use when the user wants to audit CSS, check styles, review
  the color palette, audit design tokens, check theming consistency,
  or asks "are we using our design tokens?", "audit the CSS",
  "check our colors", "btrs audit css", "style audit".
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Grep, Glob
argument-hint: [directory-or-file]
---

# CSS & Styling Audit

Audit CSS, styling, theming, and color palette consistency. Scans the whole codebase by default, or a specific directory/file if provided.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized by checking that `<basedir>/tech-debt/` exists.

## Step 1: Determine scope

- If `$ARGUMENTS` is provided, use it as the target directory or file
- Otherwise, scan the entire project (excluding `node_modules/`, `.git/`, `dist/`, `build/`, etc.)

Find all style files in scope:
```bash
find <scope> -type f \( -name "*.css" -o -name "*.scss" -o -name "*.less" -o -name "*.svelte" -o -name "*.vue" -o -name "*.jsx" -o -name "*.tsx" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*"
```

## Step 2: Read the shared audit reference

```
~/.claude/skills/shared/audit-css.md
```

Follow all the guidance in that reference. Also read the tech debt format:
```
~/.claude/skills/shared/tech-debt-format.md
```

## Step 3: Detect the styling system

Follow the detection steps from the shared reference to understand what the project uses before flagging anything.

## Step 4: Run the audit

Work through each section of the shared CSS audit reference:
1. Variable & token usage
2. Color & palette analysis
3. Style duplication & optimization
4. Consistency checks

For each finding, classify by priority:
- **High** — Hardcoded colors bypassing an established token system, significant duplication
- **Medium** — Near-duplicate values, inconsistent naming, missing theme support
- **Low** — Minor consolidation opportunities, style preference suggestions

## Step 5: Add findings to the tech debt backlog

For each actionable finding, create a tech debt item following the shared format. Set area to `CSS` and category to `css-styling`.

## Step 6: Generate audit report

Write the report to `<basedir>/reviews/audit-css-<YYYY-MM-DD>.md`:

```markdown
---
title: "CSS Audit"
date: YYYY-MM-DD
type: audit-css
scope: "<directory or 'full codebase'>"
findings: <count>
tags:
  - audit
  - audit/css
---

# CSS & Styling Audit

**Scope:** <directory or full codebase>
**Files scanned:** <count>
**Styling system:** <detected system>

## Palette Inventory

<List all unique colors found, grouped by hue family, with their source locations>

## Findings

<Findings organized by priority, using Obsidian callouts>

## Tech Debt Items Created

<Wikilinks to any new backlog items>

## Recommendations

<Summary of the most impactful improvements>
```

## Step 7: Present results

Tell the user the report path, finding counts by priority, and the most impactful recommendations.
