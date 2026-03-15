---
name: btrs-init-project
description: >
  Initialize the current project for the Buttars development workflow system.
  Sets up .btrs-config.json, Obsidian vault, output directories, templates,
  and validates everything is ready. Use when starting to use any btrs- skill
  in a new repo. Trigger on phrases like "btrs init", "init project",
  "set up project for reviews", "initialize for code review",
  "set up tech debt tracking", "prepare this repo".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(mkdir *), Bash(test *), Bash(cat *), Bash(ls *), Read, Write, Grep, Glob
---

# Buttars Init Project Skill

Initialize the current project to work with the Buttars development workflow system. Sets up config, directories, Obsidian vault, templates, and validates skill availability.

This skill is idempotent — running it multiple times is safe. It detects what's already set up and only creates what's missing.

## Step 1: Verify we're in a git repository

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

If not a git repo, tell the user and stop: "This doesn't appear to be a git repository. These skills require git to function."

Also determine the project root:
```bash
git rev-parse --show-toplevel
```

All setup happens relative to the project root.

## Step 2: Read or create `.btrs-config.json`

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Check if `.btrs-config.json` already exists at the project root:

```bash
test -f .btrs-config.json
```

**If it exists:** Read it and use the configured basedir. Tell the user: "Found existing config — basedir is `<basedir>`."

**If it doesn't exist:** Ask the user what basedir to use. Explain:
- The basedir is where all generated documents live (reviews, tech debt, releases, notes, etc.)
- Default is `.local` — keeps outputs out of the way but accessible
- Common alternatives: `.btrs`, `.docs`, `docs/local`, `.dev`
- The directory will be created if it doesn't exist

Wait for the user's choice (or confirmation of the default), then create the config:

```json
{
  "version": "1.0.0",
  "basedir": "<chosen-basedir>",
  "created": "YYYY-MM-DD"
}
```

Use the chosen basedir for all subsequent steps.

## Step 3: Create output directories

```bash
mkdir -p <basedir>/reviews
mkdir -p <basedir>/releases
mkdir -p <basedir>/tech-debt
mkdir -p <basedir>/todos
mkdir -p <basedir>/decisions
mkdir -p <basedir>/bugs
mkdir -p <basedir>/specs/components
mkdir -p <basedir>/specs/pages
mkdir -p <basedir>/docs/components
mkdir -p <basedir>/docs/api
mkdir -p <basedir>/docs/design-system
mkdir -p <basedir>/notes
mkdir -p <basedir>/templates
```

## Step 3b: Copy Obsidian templates

Copy the templates from the toolkit into the project's `<basedir>/templates/` directory so Obsidian's Templates plugin can find them:

```bash
# Copy templates from the toolkit
for tmpl in tech-debt-item.md quick-review-note.md adr.md bug-report.md feature-spec.md todo.md meeting-note.md research-note.md design-decision.md retrospective.md iteration-plan.md; do
  if [ ! -f "<basedir>/templates/$tmpl" ]; then
    cp ~/.claude/skills/btrs-code-review-toolkit/templates/$tmpl <basedir>/templates/$tmpl 2>/dev/null || \
    cp ~/.claude/skills/shared/../../../templates/$tmpl <basedir>/templates/$tmpl 2>/dev/null || \
    echo "Template $tmpl not found in toolkit — skipping"
  fi
done
```

If the templates can't be found automatically, tell the user where to copy them from.

## Step 4: Set up Obsidian vault

Read the shared Obsidian setup reference for details:
```
~/.claude/skills/shared/obsidian-setup.md
```

### Create `.obsidian/` if it doesn't exist

```bash
if [ ! -d ".obsidian" ]; then
  mkdir -p .obsidian
fi
```

### Configure excluded folders

Create `.obsidian/app.json` with excluded folders. Scan the project to only include exclusions that are relevant:

```bash
# Check which common build/dependency directories exist
for dir in node_modules .git dist build .output .nuxt .svelte-kit .next .cache coverage __pycache__ target vendor .terraform; do
  test -d "$dir" && echo "$dir/"
done
```

Build the `userIgnoreFilters` array from what actually exists, plus common generated file patterns (`*.min.js`, `*.min.css`, `*.map`).

If `.obsidian/app.json` already exists, read it and merge — add any missing exclusions but don't remove user customizations.

## Step 5: Initialize the tech debt backlog

If `<basedir>/tech-debt.md` doesn't exist, create it with the header:

```markdown
---
tags:
  - tech-debt
  - index
---

# Tech Debt Backlog

| ID | Priority | Effort | Area | Title | Status | Source |
|----|----------|--------|------|-------|--------|--------|
```

If it already exists, leave it alone.

## Step 5b: Initialize the todo list

If `<basedir>/todos.md` doesn't exist, create it with the header:

```markdown
---
tags:
  - todo
  - index
---

# Todo List

| ID | Priority | Effort | Area | Title | Status | Source |
|----|----------|--------|------|-------|--------|--------|
```

If it already exists, leave it alone.

## Step 6: Update .gitignore

Check `.gitignore` for the necessary entries. Report what's missing but **do not modify `.gitignore` automatically** — present the suggested additions and ask the user to confirm before making changes.

Entries to check for:

```
# Obsidian vault config (personal settings)
.obsidian/

# BTRS outputs (optional — some teams may want to commit these)
# <basedir>/reviews/
# <basedir>/releases/
# <basedir>/tech-debt/
# <basedir>/todos/
# <basedir>/notes/
```

Present this to the user and explain:
- `.obsidian/` should always be gitignored (personal editor config)
- `<basedir>/` directories are optional — some teams want docs committed, others don't
- Ask the user which entries to add

Wait for confirmation before modifying `.gitignore`.

## Step 7: Verify skill availability

Check that the companion skills are installed:

```bash
# Check for each skill
for skill in btrs-review-mr btrs-release-notes btrs-do-tech-debt btrs-add-tech-debt btrs-scan-tech-debt btrs-audit-css btrs-audit-reactivity btrs-audit-endpoints btrs-audit-components btrs-update-stack btrs-add-todo btrs-think-through btrs-next btrs-create-adr btrs-scaffold-pipeline btrs-scaffold-docker btrs-deploy btrs-audit-infra btrs-scaffold-release; do
  if [ -f "$HOME/.claude/skills/$skill/SKILL.md" ]; then
    echo "✓ $skill"
  else
    echo "✗ $skill — not found in ~/.claude/skills/"
  fi
done

# Check shared references
for ref in diff-analysis.md tech-debt-format.md todo-format.md obsidian-setup.md config.md audit-css.md audit-reactivity.md audit-endpoints.md audit-components.md audit-infra.md; do
  if [ -f "$HOME/.claude/skills/shared/$ref" ]; then
    echo "✓ shared/$ref"
  else
    echo "✗ shared/$ref — not found"
  fi
done
```

If any skills or references are missing, tell the user how to install them.

## Step 8: Report setup status

Present a summary of what was done and what was already in place:

```
> [!tip] Project initialized for BTRS workflow system
>
> **Git repo:** ✓ <repo-name>
> **Default branch:** <detected-default-branch>
> **Config:** .btrs-config.json — basedir: `<basedir>`
>
> **Directories:**
> - <basedir>/reviews/ — ✓ created / ✓ already existed
> - <basedir>/releases/ — ✓ created / ✓ already existed
> - <basedir>/tech-debt/ — ✓ created / ✓ already existed
> - <basedir>/todos/ — ✓ created / ✓ already existed
> - <basedir>/decisions/ — ✓ created / ✓ already existed
> - <basedir>/specs/ — ✓ created / ✓ already existed
> - <basedir>/docs/ — ✓ created / ✓ already existed
> - <basedir>/notes/ — ✓ created / ✓ already existed
>
> **Obsidian vault:**
> - .obsidian/ — ✓ created / ✓ already existed
> - Excluded folders: <count> directories configured
>
> **Tech debt backlog:** ✓ initialized / ✓ already existed (<count> items)
> **Todo list:** ✓ initialized / ✓ already existed (<count> items)
>
> **Gitignore:** <status — updated / needs update / already configured>
>
> **Available skills:** <count>/19 installed
```

End with a quick-start suggestion:
- "Run `/btrs-review-mr` to review your current branch"
- "Run `/btrs-update-stack` to generate a tech stack document"
- "Run `/btrs-scan-tech-debt` to scan for tech debt"
- "Run `/btrs-next` to see what to work on next"
