---
name: btrs-audit-components
description: >
  Audit component architecture using Atomic Design principles. Checks for
  monolithic components, reuse opportunities, prop design issues, and
  organizational consistency. Feeds findings into the tech debt backlog.
  Use when the user wants to audit components, check for reusable
  components, review component architecture, or asks "audit components",
  "check for reusable components", "btrs audit components",
  "component architecture review", "are there components we can reuse?".
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Grep, Glob
argument-hint: [directory-or-file]
---

# Component Architecture Audit

Audit component structure, Atomic Design hierarchy, reuse opportunities, and prop design. Scans the whole codebase by default.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized by checking that `<basedir>/tech-debt/` exists.

## Step 1: Determine scope

- If `$ARGUMENTS` is provided, use as target
- Otherwise, scan the entire project

Find all component files:
```bash
find <scope> -type f \( -name "*.svelte" -o -name "*.vue" -o -name "*.jsx" -o -name "*.tsx" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*"
```

## Step 2: Read the shared audit reference

```
~/.claude/skills/shared/audit-components.md
```

Also read:
```
~/.claude/skills/shared/tech-debt-format.md
```

## Step 3: Detect component patterns

Follow the detection steps from the shared reference to understand the project's framework, directory structure, and naming conventions.

## Step 4: Run the audit

Work through each section of the shared component audit reference:
1. Evaluate components against Atomic Design hierarchy
2. Flag monolithic components
3. Identify reuse opportunities (search for similar patterns across files)
4. Review prop design
5. Check composition patterns
6. Run the reuse audit (group by similarity)
7. Assess component placement

For each finding, classify by priority:
- **High** — Heavily duplicated UI patterns that should be shared components
- **Medium** — Monolithic components, poor prop design limiting reuse
- **Low** — Minor organizational improvements, component placement suggestions

## Step 5: Add findings to the tech debt backlog

Create tech debt items with area `UI` and category `component-architecture`.

## Step 6: Generate audit report

Write to `<basedir>/reviews/audit-components-<YYYY-MM-DD>.md`:

```markdown
---
title: "Component Architecture Audit"
date: YYYY-MM-DD
type: audit-components
scope: "<directory or 'full codebase'>"
framework: "<detected framework>"
components_found: <count>
findings: <count>
tags:
  - audit
  - audit/components
---

# Component Architecture Audit

**Scope:** <directory or full codebase>
**Framework:** <detected>
**Components found:** <count>

## Component Inventory

<Table of all components: name, location, estimated Atomic Design level, line count>

## Atomic Design Map

<Visual breakdown of how many components exist at each level:
Atoms, Molecules, Organisms, Templates, Pages>

## Reuse Opportunities

<Groups of similar components that could be consolidated>

## Findings

<Findings organized by priority using Obsidian callouts>

## Tech Debt Items Created

<Wikilinks to new backlog items>

## Recommendations

<Summary of most impactful improvements, suggested component extractions>
```

## Step 7: Present results

Report path, component count, reuse opportunities found, finding counts by priority.
