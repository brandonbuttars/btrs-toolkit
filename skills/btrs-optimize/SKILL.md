---
name: btrs-optimize
description: >
  Check and update BTRS skills for consistency, token efficiency, and new
  Claude Code capabilities. Audits all skills, shared references, agents,
  and templates for issues. Use when the user wants to optimize the toolkit,
  check for inconsistencies, update skills, or asks "optimize btrs",
  "btrs optimize", "check skill consistency", "audit the toolkit",
  "update skills for new features".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(ls *), Bash(wc *), Read, Write, Edit, Grep, Glob
---

# Optimize Skills

Audit and optimize the BTRS toolkit for consistency, token efficiency, and correctness.

## Step 1: Inventory all skills

Read every SKILL.md file in the toolkit:

```bash
find ~/.claude/skills/btrs-*/SKILL.md -type f 2>/dev/null
find ~/.claude/skills/shared/*.md -type f 2>/dev/null
```

For each skill, extract:
- Name, description, allowed-tools
- Whether `disable-model-invocation: true` is set
- Step 0 pattern (config reading)
- References to shared files
- Output paths (should use `<basedir>/`)

## Step 2: Consistency checks

### Frontmatter consistency
- All skills have `disable-model-invocation: true`
- All skills have `allowed-tools` defined
- Description format is consistent (starts with verb, includes trigger phrases)
- `argument-hint` is present where applicable

### Step 0 pattern
- All skills that write files have Step 0 reading `config.md`
- All skills reference `~/.claude/skills/shared/config.md`
- No hardcoded `.local/` paths remain

### Shared reference usage
- Skills that write to tech debt backlog reference `tech-debt-format.md`
- Skills that write to todo list reference `todo-format.md`
- Audit skills reference their corresponding `audit-*.md`
- All file paths use `<basedir>/` placeholder

### Output format consistency
- All output files have YAML frontmatter
- All use Obsidian callouts for severity/importance
- All use wikilinks for cross-references
- Tag conventions are consistent (hierarchical: `type/value`)

### Cross-references
- Skills that mention other skills use correct names
- Agent skill lists match actual skill names
- Shared references are all referenced by at least one skill

## Step 3: Token efficiency audit

For each skill, check:
- Total line count (flag if >500 lines)
- Repeated instructions that could be extracted to shared references
- Verbose examples that could be shortened
- Steps that could be combined without loss of clarity

Estimate token cost per skill invocation (prompt size).

## Step 4: Capability check

Check for Claude Code features that skills could leverage:
- New tools available since skills were written
- Improved tool capabilities
- New best practices from Claude Code documentation

## Step 5: Agent consistency

For each agent:
- All listed skills exist
- Skill descriptions match what the skills actually do
- "When to use which skill" table is complete and accurate
- Personality section is actionable, not generic

## Step 6: Template check

For each template:
- YAML frontmatter follows the same conventions as skill outputs
- Templater placeholders use consistent syntax
- Tags follow the hierarchical convention

## Step 7: Generate optimization report

Write to `<basedir>/reviews/optimize-btrs-<YYYY-MM-DD>.md` (if in a project) or present directly:

```markdown
---
title: "BTRS Optimization Report"
date: YYYY-MM-DD
type: optimization
tags:
  - audit
  - audit/meta
---

# BTRS Optimization Report

## Inventory

| Category | Count | Issues |
|----------|-------|--------|
| Skills | <N> | <N issues> |
| Agents | <N> | <N issues> |
| Templates | <N> | <N issues> |
| Shared refs | <N> | <N issues> |

## Issues Found

### Consistency
> [!warning] <issue>
> **File:** <path>
> **Fix:** <what to change>

### Token Efficiency
> [!info] <optimization opportunity>
> **Estimated savings:** <tokens>

### Missing References
> [!warning] <missing cross-reference>

### Capability Updates
> [!tip] <new capability to leverage>

## Recommendations

<Prioritized list of changes to make>
```

## Step 8: Offer to fix

For each issue found, offer to fix it automatically. Group fixes by type:
- Safe fixes (formatting, missing frontmatter) — apply in batch
- Content changes (rewording, restructuring) — present individually for approval

## Step 9: Present the result

Tell the user:
- Total issues found by category
- Top 3 highest-impact optimizations
- Token efficiency summary
- Any new capabilities to consider
