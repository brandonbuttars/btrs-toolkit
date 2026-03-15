# Contributing

Guide for adding, modifying, and testing skills in the Buttars Code Review Toolkit.

## Repository Structure

```
skills/                          # Claude Code skills
  btrs-init-project/             # Project initialization
  btrs-review-mr/                # MR code review
  btrs-release-notes/            # Release documentation
  btrs-do-tech-debt/             # Execute backlog items
  btrs-add-tech-debt/            # Manual tech debt entry
  btrs-scan-tech-debt/           # Full codebase scan
  btrs-audit-css/                # CSS/styling audit
  btrs-audit-reactivity/         # Reactivity audit
  btrs-audit-endpoints/          # API/endpoint audit
  btrs-audit-components/         # Component architecture audit
  shared/                        # Shared references (NOT a skill)
templates/                       # Obsidian templates
examples/                        # Sample output files
docs/                            # Documentation
```

## Architecture

Skills reference **shared audit files** rather than duplicating analysis logic:

```
btrs-review-mr      → reads shared/audit-css.md, audit-reactivity.md, etc.
btrs-audit-css      → reads shared/audit-css.md (same file)
btrs-scan-tech-debt → reads all shared/audit-*.md files
```

This means improvements to an audit reference automatically improve both the standalone audit and the MR review.

## Adding a New Skill

1. Create `skills/btrs-<name>/SKILL.md` with YAML frontmatter
2. Use `btrs-` prefix in the `name` field
3. Set `disable-model-invocation: true` for skills with side effects
4. Write a "pushy" description with many trigger phrases
5. Add Step 0 init check: `test -d ".local/tech-debt"`
6. If the skill writes findings, use `shared/tech-debt-format.md`
7. Update `plugin.json` with the new skill path
8. Add example output to `examples/`
9. Update README and CHANGELOG

## Adding a New Audit Category

1. Create `skills/shared/audit-<name>.md` with the analysis guidance
2. Create `skills/btrs-audit-<name>/SKILL.md` referencing it
3. Add the category to `btrs-scan-tech-debt` (Step 4)
4. Add the category to `btrs-review-mr` (Step 3 conditional loading + Step 4)
5. Update the README command table

## Modifying Shared References

Files in `skills/shared/` are used by multiple skills:

| File | Used by |
|------|---------|
| `diff-analysis.md` | review-mr, release-notes, scan-tech-debt |
| `tech-debt-format.md` | All skills that write to the backlog |
| `obsidian-setup.md` | init-project |
| `audit-css.md` | audit-css, review-mr, scan-tech-debt |
| `audit-reactivity.md` | audit-reactivity, review-mr, scan-tech-debt |
| `audit-endpoints.md` | audit-endpoints, review-mr, scan-tech-debt |
| `audit-components.md` | audit-components, review-mr, scan-tech-debt |

Check all consuming skills for compatibility when modifying.

## Adding an Obsidian Template

1. Create `templates/<name>.md` with `{{date}}`, `{{title}}`, `{{id}}` placeholders
2. Include full YAML frontmatter with tags
3. Add the template to the copy list in `btrs-init-project` (Step 2b)
4. Create a corresponding output directory in Step 2 if needed

## Style Guide

- Skills use imperative voice ("Check for...", "Flag...", "Verify...")
- Explain the *why*, not just the *what*
- Keep SKILL.md under 500 lines; use shared references for deep guidance
- Descriptions should be "pushy" — list many trigger phrases
- `disable-model-invocation: true` for anything with side effects
- YAML frontmatter values: lowercase/kebab-case
- Display values in markdown body: Title Case
- All commands prefixed with `btrs-`

## Versioning

- **Major** — Breaking changes to output format or backlog structure
- **Minor** — New skills, new audit categories, new templates
- **Patch** — Bug fixes, wording improvements, documentation
