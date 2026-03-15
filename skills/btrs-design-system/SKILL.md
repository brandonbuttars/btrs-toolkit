---
name: btrs-design-system
description: >
  Audit and evolve the project's design system. Inventories design tokens,
  components, patterns, and identifies gaps, inconsistencies, and opportunities
  for consolidation. Use when the user wants to audit the design system, review
  design tokens, check consistency, evolve the system, or asks "audit design
  system", "btrs design system", "review our tokens", "are our components
  consistent?", "design system health check", "what tokens do we have?".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: [focus-area]
---

# Design System Skill

Audit and evolve the project's design system. Inventories tokens, components, and patterns, then identifies gaps and recommends improvements.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized.

## Step 1: Parse arguments

`$ARGUMENTS` can be:
- **No arguments** — Full design system audit
- **Focus area** — One of: `tokens`, `colors`, `typography`, `spacing`, `components`, `patterns`, `a11y`

## Step 2: Read shared references

```
~/.claude/skills/shared/audit-css.md
~/.claude/skills/shared/audit-components.md
```

Check if `<basedir>/tech-stack.md` exists and read it.

## Step 3: Inventory design tokens

### Color tokens
Find and catalog all color definitions:
- CSS custom properties (`--color-*`, `--*-color`)
- Tailwind config colors
- SCSS/Less variables
- Hardcoded colors in component styles

For each color:
- Name, value (hex/rgb/hsl)
- Where defined
- Usage count across the codebase
- Group by hue family

Flag:
- Near-duplicate colors (within ΔE < 5 or similar hex ranges)
- Hardcoded colors that should use tokens
- Unused token definitions
- Inconsistent naming patterns

### Typography tokens
Catalog:
- Font families (defined vs used)
- Font sizes (tokens vs hardcoded)
- Font weights
- Line heights
- Letter spacing

Flag:
- Hardcoded font sizes not in the token scale
- Inconsistent font stacks
- Missing responsive typography

### Spacing tokens
Catalog:
- Spacing scale (if defined)
- Margin/padding values used across components
- Gap values in flex/grid layouts

Flag:
- Values outside the spacing scale
- Inconsistent spacing patterns between similar components

### Other tokens
- Border radius values
- Shadow definitions
- Transition/animation durations
- Z-index scale
- Breakpoint definitions

## Step 4: Inventory components

Scan all component files and catalog:

| Component | Location | Level | Props count | Lines | Uses tokens? |
|-----------|----------|-------|-------------|-------|--------------|

For each component, note:
- Atomic Design level (atom/molecule/organism)
- Whether it uses design tokens or hardcodes values
- Prop interface consistency with similar components
- Test coverage

### Component patterns
Identify recurring patterns:
- Common prop interfaces (size, variant, disabled)
- Event handling patterns
- Slot/children patterns
- Styling approach consistency

## Step 5: Identify gaps and inconsistencies

### Token gaps
- Are there values used repeatedly that should be tokens but aren't?
- Are there token categories missing (e.g., spacing scale exists but no border-radius scale)?
- Is there a dark mode / theme system? Is it complete?

### Component gaps
- Are there UI patterns repeated across pages that should be shared components?
- Are Atomic Design levels complete? (atoms exist but some common molecules are missing?)
- Are variant APIs consistent across similar components?

### Naming inconsistencies
- Token naming patterns (kebab-case? BEM? semantic vs literal?)
- Component naming patterns
- Prop naming patterns across similar components

### Accessibility gaps
- Components missing ARIA attributes
- Missing focus styles
- Color contrast issues with current token values
- Missing reduced-motion support

## Step 6: Generate recommendations

Prioritize findings by impact:

**High impact:**
- Token consolidation that reduces palette by >20%
- Missing components that are duplicated in 3+ places
- Accessibility violations

**Medium impact:**
- Naming inconsistencies across >5 files
- Missing token categories
- Component prop API inconsistencies

**Low impact:**
- Minor consolidation opportunities
- Style preference suggestions
- Documentation gaps

## Step 7: Write the audit report

Write to `<basedir>/docs/design-system/audit-<YYYY-MM-DD>.md`:

```markdown
---
title: "Design System Audit"
date: YYYY-MM-DD
type: design-system-audit
scope: "<focus area or 'full'>"
tags:
  - audit
  - audit/design-system
---

# Design System Audit

**Date:** YYYY-MM-DD
**Scope:** <focus area or full audit>

## Token Inventory

### Colors

| Token | Value | Usage count | Group |
|-------|-------|-------------|-------|
| ... | ... | ... | ... |

**Total unique colors:** <count>
**Token coverage:** <% of color usages that reference tokens>

> [!warning] Near-duplicates found
> <list of color pairs that are too similar>

### Typography

| Token | Value | Usage count |
|-------|-------|-------------|
| ... | ... | ... |

### Spacing

| Token | Value | Usage count |
|-------|-------|-------------|
| ... | ... | ... |

### Other tokens

<Border radius, shadows, transitions, z-index, breakpoints>

## Component Inventory

### By Atomic Design level

| Level | Count | Examples |
|-------|-------|---------|
| Atoms | <N> | Button, Input, Badge |
| Molecules | <N> | SearchBar, FormField |
| Organisms | <N> | Header, DataTable |

### Token adoption

| Component | Uses tokens | Hardcoded values | Status |
|-----------|-------------|------------------|--------|
| ... | 8/10 | 2 colors | Needs update |

## Gaps & Inconsistencies

### High priority
> [!danger] <finding>
> <details and recommendation>

### Medium priority
> [!warning] <finding>
> <details and recommendation>

### Low priority
> [!info] <finding>
> <details and recommendation>

## Recommendations

### Token consolidation
<Specific tokens to merge, rename, or create>

### Component extraction
<UI patterns that should become shared components>

### Naming standardization
<Naming changes to improve consistency>

### Accessibility improvements
<Specific a11y fixes needed>

## Roadmap

> [!tip] Suggested evolution path
> 1. <Highest impact improvement>
> 2. <Second priority>
> 3. <Third priority>
```

## Step 8: Create follow-up items

For actionable findings, offer to create:
- Tech debt items for token consolidation and fixing inconsistencies
- Todo items for new components that need to be built
- Component design specs for missing shared components

## Step 9: Present the result

Tell the user:
- Report path
- Token counts and coverage
- Component inventory summary
- Top 3 highest-impact recommendations
- Suggest next actions based on findings
