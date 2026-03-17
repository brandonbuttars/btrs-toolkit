---
name: btrs-release-notes
description: >
  Generate release documentation by comparing two branches. Produces three
  markdown files: customer-facing release notes (high-level, non-technical),
  engineering release notes (detailed, technical), and a technical debt
  report with specific recommended changes. Use when the user wants release
  notes, a changelog, release documentation, or asks to compare releases
  or branches for a release. Trigger on phrases like "release notes",
  "what changed between releases", "generate changelog", "compare releases",
  "release documentation", "what's in this release", "diff between releases",
  "release summary", "prepare release notes for", "btrs release".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(cat *), Bash(test *), Bash(mkdir *), Read, Write, Grep, Glob
argument-hint: <old-branch> <new-branch>
---

# Release Notes Skill

Generate three levels of release documentation by comparing two branches:

1. **Customer release notes** — High-level, non-technical. What's new, what's fixed, what's improved. Written for end users, stakeholders, and product managers.
2. **Engineering release notes** — Detailed and technical. Full change categorization, affected areas, risk assessment, deployment notes. Written for developers, QA, and DevOps.
3. **Technical debt report** — Quality analysis of the release diff. Identifies patterns of concern, consistency issues, and specific recommended changes. Written for the engineering team to plan follow-up work.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Parse arguments and determine branches

`$ARGUMENTS` should contain two branch names: the old (baseline) release and the new release.

- If two arguments are provided: first is old, second is new
- If one argument is provided: it's the old release; use the current branch (`git branch --show-current`) as the new release
- If no arguments: ask the user which branches to compare

Validate both branches exist:
```bash
git rev-parse --verify <old-branch> 2>/dev/null
git rev-parse --verify <new-branch> 2>/dev/null
```

If either doesn't exist, check if it's a remote branch and fetch:
```bash
git fetch origin <branch> 2>/dev/null
git rev-parse --verify origin/<branch> 2>/dev/null
```

## Step 1b: Read version.json

Check if `version.json` exists at the project root and read it. This file provides
the Component Versions table for the engineering release notes and is required for
Word document generation.

```bash
test -f version.json && cat version.json || echo "VERSION_JSON_NOT_FOUND"
```

The file uses nested objects with `major`, `minor`, `patch`, and optional `revision`
fields per component:

```json
{
  "manager": { "major": 5, "minor": 2, "patch": 3 },
  "arducopter": { "major": 4, "minor": 4, "patch": 4, "revision": 6 },
  "targetassignment": { "major": 1, "minor": 0, "patch": 0 }
}
```

**Parsing rules:**
- Construct the version string as `major.minor.patch`. If `revision` is present,
  append it: `major.minor.patch.revision` (e.g., `4.4.4.6`).
- Convert component keys to human-readable display names using Title Case with
  word separation (e.g., `groundcontrol` → `Ground Control`, `dronehunter` →
  `DroneHunter`, `targetassignment` → `Target Assignment`). Use your best
  judgment for casing — proper nouns and brand names should keep their expected
  capitalization. When unsure, use simple Title Case with spaces at likely word
  boundaries.
- If `version.json` exists: store the parsed component/version data for use in
  Step 9 (Document 2) and Step 10 (Word generation).
- If `version.json` does not exist: the Component Versions section will be omitted
  from the engineering notes, and Word document generation will be skipped in Step 10.

## Step 1c: Capture timestamp

Record the current date and time for use in document frontmatter and body:
```bash
date "+%Y-%m-%d %H:%M"
```

Use this value wherever `YYYY-MM-DD HH:MM` appears in the templates.

## Step 2: Gather raw data

```bash
# Find the common ancestor
git merge-base <old-branch> <new-branch>

# All commits between the two branches (non-merge)
git log <old-branch>..<new-branch> --oneline --no-merges

# Full commit messages (for ticket/issue extraction from body text)
git log <old-branch>..<new-branch> --no-merges --format="%H %s%n%b"

# Merge commits only (these often contain MR/PR titles)
git log <old-branch>..<new-branch> --merges --oneline

# Full merge commit messages (richer detail for MR extraction)
git log <old-branch>..<new-branch> --merges --format="%H %s%n%b"

# Branch names between the two refs (for ticket ID extraction from branch names)
git log <old-branch>..<new-branch> --merges --format="%s" | grep -oP "(?<=')[^']+(?=')" || true

# File change summary
git diff <old-branch>...<new-branch> --stat

# Change count
git diff <old-branch>...<new-branch> --shortstat

# Full diff (for analysis of what actually changed)
git diff <old-branch>...<new-branch>
```

## Step 3: Read shared analysis guidance

Read the shared diff analysis reference for categorization patterns and commit convention detection:
```
~/.claude/skills/shared/diff-analysis.md
```

## Step 4: Detect commit convention and extract changes

Follow the convention detection process from the shared reference. Then extract changes using the best available source:

### Preferred: MR/PR titles from merge commits

Parse merge commit messages for patterns like:
- `Merge branch '<branch>' into '<target>'`
- `Merge pull request #N from ...`
- `See merge request <group>/<project>!N`
- Squash commit messages with `(#N)` or `(!N)` references

When MR titles are found, use them as the primary description of each change. Group the related non-merge commits under each MR.

### Extract ticket/issue references

Scan all commit messages (subjects and bodies), merge commit messages, and branch names for ticket/issue tracker references. Common patterns include:

- Jira-style: `PROJ-1234`, `ABC-567` (uppercase letters, dash, digits)
- Linear-style: `ENG-123`, `FE-45`
- GitHub/GitLab issues: `#123`, `fixes #456`, `closes #789`
- Shorthand in branches: `feature/PROJ-1234-description`, `fix/ABC-567`
- Footer references: `Ticket: PROJ-1234`, `Issue: #123`, `Ref: ABC-567`

Build a mapping of ticket numbers to their associated commits/MRs. A single ticket may span multiple commits or MRs. When a ticket number is found, associate it with the corresponding change entry in the categorization step.

### Fallback: Commit log + diff analysis

If merge commits don't contain useful MR titles (or the repo uses rebase/squash without MR references), fall back to:

1. Group commits by the files they touch (commits touching the same area are likely related)
2. Use conventional commit prefixes if detected
3. Read the diff to understand what each group of changes actually does
4. Write human-readable descriptions based on the actual code changes, not just commit messages

In all cases, read the actual diff for each change group to write accurate descriptions. Commit messages alone are often vague or misleading.

## Step 5: Categorize changes

Organize all changes into these categories (omit any category with no entries):

- **Features** — New functionality, new UI elements, new API endpoints, new capabilities
- **Bug Fixes** — Corrections to existing behavior, error handling fixes
- **Improvements** — Refactors, performance improvements, UX polish, code quality
- **Infrastructure / DevOps** — CI/CD, Docker, deployment, build tooling changes
- **Documentation** — README, docs, comments, changelogs
- **Dependencies** — Package additions, removals, or version changes
- **Breaking Changes** — Removed functionality, changed API contracts, schema changes, config format changes

For each change entry, include:
- A clear, human-readable description of what changed
- The files or areas affected (keep brief)
- The ticket/issue number if available (e.g., `PROJ-1234`, `#123`)
- The MR/PR number if available

## Step 6: Identify affected areas

Scan the changed file paths to determine which parts of the codebase are affected. Dynamically discover the project's structure:

```bash
git diff <old-branch>...<new-branch> --stat | grep -oP '^[^/]+/' | sort -u
```

List each affected area with a brief note about what changed there.

## Step 7: Assess risk and deployment notes

Based on the changes, assess:
- Overall risk level (Low / Medium / High)
- Whether database migrations are present
- Whether config/environment changes are needed
- Whether there are breaking API changes
- Whether new dependencies need to be installed
- Any changes that require special deployment steps

## Step 8: Analyze technical debt across the release diff

This analysis feeds Document 3 (Technical Debt Report). Scan the entire release diff for cross-cutting patterns — not per-file issues but concerns across the release as a whole.

**Component architecture**
- Are new components following Atomic Design patterns (Atoms, Molecules, Organisms, Templates, Pages) consistent with the existing codebase?
- Are there repeated UI patterns across the release that should be extracted into reusable components?
- Are new components monolithic where they should be composed from smaller pieces?

**CSS & color consistency**
- Are new styles using existing CSS variables, design tokens, and theming systems?
- Are there new hardcoded colors that should reference the existing palette?
- Are there near-duplicate colors, shades, or opacity variants that should be consolidated?
- Are there opportunities to reduce the total number of color/spacing/font values?

**Reactivity & state management**
- Are new reactive patterns consistent with existing conventions in the codebase?
- Are there subscription or effect leaks — reactive code without corresponding cleanup?
- Is there unnecessary reactivity (state that should be derived/computed)?
- Are there cascading reactivity chains that indicate fragile state architecture?

**Endpoints & data connections**
- Do new REST endpoints, WebSocket handlers, or other data connections follow consistent patterns for validation, error handling, and auth?
- Are there endpoints missing proper error responses, rate limiting, or input validation?
- Is connection lifecycle (open/close/error/reconnect) fully handled for WebSocket and streaming connections?

**Error handling & resilience**
- Do new UI areas have proper loading, error, and empty states?
- Are there components where a failed data source would crash a parent rather than degrade gracefully?
- Are try/catch blocks present around operations that can fail?

**Bundle & imports**
- Are there new large dependencies that could be replaced by lighter alternatives or existing utilities?
- Are there barrel imports pulling in more than needed?
- Are there code splitting opportunities for new routes or heavy components?

**TypeScript** *(only if the project uses TypeScript)*
- Are there new `any` types, loose generics, or type assertions that weaken type safety?
- Are new types consistent with existing type definitions?

**Accessibility** *(only if the project has a11y patterns or is a user-facing web app)*
- Do new interactive components have keyboard support and ARIA attributes?
- Are there color-only indicators without alternative visual cues?

**i18n** *(only if the project has an i18n system)*
- Are there new hardcoded user-facing strings that should use translation keys?

**Reuse opportunities**
- Are there new functions, utilities, or patterns that duplicate things already in the codebase?
- Could any of the new code be consolidated with existing code to reduce duplication?

## Step 9: Generate three documents

Use the new branch name exactly as provided for the folder name. Do not strip prefixes, replace characters, or transform it in any way.

```bash
mkdir -p "<basedir>/releases/<new-branch>"
```

If files with these names already exist, overwrite them.

---

### Document 1: Customer Release Notes

Filename: `<basedir>/releases/<new-branch>/customer-notes.md`

This is for end users, stakeholders, and product managers. No code, no file paths, no technical jargon. Focus on what the user can now do, what was fixed, and what they need to know.

```markdown
---
title: "What's New in <version/branch>"
date: YYYY-MM-DD HH:MM
type: release-notes-customer
release: "<new-branch>"
compared_against: "<old-branch>"
tags:
  - release
  - release/customer
---

# What's New in <version/branch>

**Generated:** YYYY-MM-DD HH:MM

## Component Versions

| Component | Version |
|-----------|---------|
| <component-name> | <version> |
| ... | ... |

## Highlights

<3-5 sentences summarizing the most impactful changes from the user's perspective.
What can they do now that they couldn't before? What problems were fixed?>

## New Features

- **<Feature name>** — <User-facing description of what this enables. Write as if
  explaining to someone who uses the product but doesn't read code.>

## Fixes

- **<Fix summary>** — <What was broken from the user's perspective and that it's
  now resolved. No stack traces or file names.>

## Improvements

- **<Improvement>** — <What's better now. Performance, usability, reliability.>

## Breaking Changes

> [!warning] Breaking Changes
> <If any changes affect user workflow, explain what changed and what they need to do
> differently. If none, omit this entire section.>

## Known Issues

> [!info] Known Issues
> <Any known issues carried into this release that users should be aware of.
> If none, omit this entire section.>
```

---

### Document 2: Engineering Release Notes

Filename: `<basedir>/releases/<new-branch>/engineering-notes.md`

This is the full technical release documentation for developers, QA, and DevOps.

```markdown
---
title: "Release Notes, <project-name> Version <new-version>"
date: YYYY-MM-DD HH:MM
type: release-notes-engineering
release: "<new-branch>"
compared_against: "<old-branch>"
commits: <count>
merge_requests: <count>
files_changed: <count>
risk: "<low | medium | high>"
tags:
  - release
  - release/engineering
  - "risk/<level>"
---

# Release Notes, <project-name> Version <new-version>

ENGINEERING RELEASE NOTES (<old-version> – <new-version>)

**Generated:** YYYY-MM-DD HH:MM

## Component Versions

| Component | Version |
|-----------|---------|
| <component-name> | <version> |
| ... | ... |

<1-3 sentence summary of the main goal or focus of this release.>

## Change Summary

Group changes under descriptive subtitles based on the logical areas or themes
of the release. Use subtitles that make sense for the actual changes — these are
NOT fixed categories. Examples: "Dashboard Filtering", "Map Performance",
"Notification System", "API Changes", "Infrastructure". Each subtitle groups
related changes regardless of whether they are features, fixes, or improvements.

### <Subtitle — logical grouping>

- <Description of change. Include technical detail: approach, root cause for fixes,
  architecture for features. Reference files/areas and MR numbers inline.>
  _(<files/areas>, MR !N)_

### <Another subtitle>

- <Change description>
  _(<files/areas>, MR !N)_

Continue with as many subtitles as needed to cover all changes. Omit categories
with no entries. If a change doesn't fit a group, use a "General" or
"Other Changes" subtitle.

### Dependencies

- Added/updated/removed `<package>` <old-version> → <new-version> _(reason)_

Include dependency changes as a subtitle under Change Summary only if there are
dependency changes. Omit if none.

### Breaking Changes

> [!danger] Breaking Changes
> - **<What changed>** — <Technical details of the break and migration path>
>   _Migration steps: <specific commands or code changes required>_

Include as a subtitle under Change Summary only if there are breaking changes.
Omit if none.

## Issue Summary

List all ticket/issue references found in commit messages, MR titles, and branch
names. Group by ticket with a brief description of the associated change.

- **<TICKET-123>** — <Brief description of what this ticket covers>
- **<TICKET-456>** — <Brief description>
- **#<N>** — <Brief description>

If no ticket references are found, write "No ticket references found in this release."

## Known Issues / Workarounds

Known issues carried into or introduced by this release, with workarounds where
available.

- **<Issue description>** — <Workaround or status>

If no known issues, write "No known issues at this time."

## Deployment Notes

> [!example] Deployment Notes
> <Specific steps required for this release:
> - Migrations to run (with commands)
> - Environment variables to add/change
> - Services to restart
> - Feature flags to enable/disable
> - Cache invalidation needed
> - Order of operations if multiple services
> Or "No special deployment steps required.">

## Risk Assessment

> [!<callout-type>] Risk Assessment: <Low | Medium | High>
> <Reasoning: scope of changes, breaking changes, areas touched, test coverage,
> data migration risk>

Use the appropriate callout type:
- Low → `[!tip]`
- Medium → `[!warning]`
- High → `[!danger]`

## Screenshots & Walkthrough

<Placeholder section for visual documentation. Add screenshots, diagrams,
or walkthrough notes relevant to the changes in this release.>

## Full Commit Log

<details>
<summary>All commits (<count>)</summary>

| SHA | Message |
|-----|---------|
| <short-sha> | <message> |
| ... | ... |

</details>
```

**IMPORTANT — Component Versions table (applies to BOTH Document 1 and Document 2):**
- If `version.json` was found in Step 1b, you MUST include the `## Component Versions`
  section with the table in BOTH the customer notes AND the engineering notes.
  It MUST be the FIRST section after the title (before Highlights in customer notes,
  before the summary paragraph in engineering notes). Populate each row from the
  parsed version.json data: key = Component display name, value = assembled version string.
- If `version.json` was NOT found, omit the `## Component Versions` section and
  its table entirely from BOTH documents.

---

### Document 3: Technical Debt Summary & Backlog Update

Instead of a standalone tech debt report, this step feeds items into the persistent tech debt backlog and generates a release-specific summary document.

Read the shared tech debt format reference:
```
~/.claude/skills/shared/tech-debt-format.md
```

Create the directories if they don't exist:
```bash
mkdir -p <basedir>/tech-debt
```

#### Step 9a: Read the existing backlog

**You MUST read the existing backlog before writing anything.** This is critical
to avoid duplicates and to correctly update existing items.

1. Read the master list to get all current items:
```bash
cat <basedir>/tech-debt.md 2>/dev/null || echo "NO_EXISTING_BACKLOG"
```

2. If the master list exists, read ALL existing detail files to understand what's
   already tracked:
```bash
ls <basedir>/tech-debt/*.md 2>/dev/null
```
Then read each detail file. You need to know:
- What titles and file paths are already tracked
- What the current highest ID is (for auto-incrementing new IDs)
- Which items are Open vs Done (Open items can be updated; Done items that
  reappear mean regression — create a new item)

3. Build a mental map of existing items: ID, title, status, affected files.

#### Step 9b: Reconcile new findings with existing backlog

For EACH tech debt item identified in Step 8, compare against the existing backlog:

**If a matching item exists and is Open:**
- Do NOT create a new item
- Update the existing detail file: add the new occurrence to its Description
  or Affected Files section
- Update the source in the master list row if the new release is more recent
- Track this as an "updated item" for the release summary

**If a matching item exists and is Done:**
- This is a regression — create a NEW item with a new ID
- In the Context section, add: "Previously addressed in [[<old-ID>]], but has regressed."
- Track this as a "new item" for the release summary

**If no matching item exists:**
- Create a new detail file in `<basedir>/tech-debt/` with the next available ID
- Add a new row to `<basedir>/tech-debt.md`
- Set source to `release/<old-branch>→<new-branch> (YYYY-MM-DD)`
- Track this as a "new item" for the release summary

**Matching criteria** (check in order):
1. Same or very similar title text
2. Same affected file paths (grep detail files for the file paths)
3. Same category + same area + overlapping description

After processing all items, rewrite `<basedir>/tech-debt.md` with the updated
table (existing rows preserved, updated rows modified, new rows appended).

#### Step 9c: Generate the release-specific summary

Then generate a release-specific summary:

Filename: `<basedir>/releases/<new-branch>/tech-debt-notes.md`

This document summarizes the tech debt picture for this specific release but references the persistent backlog for details.

```markdown
---
title: "Technical Debt Summary: <new-branch>"
date: YYYY-MM-DD HH:MM
type: release-notes-tech-debt
release: "<new-branch>"
compared_against: "<old-branch>"
files_analyzed: <count>
new_items: <count>
updated_items: <count>
tags:
  - release
  - release/tech-debt
  - tech-debt
---

# Technical Debt Summary: <new-branch>

**Generated:** YYYY-MM-DD HH:MM

## Overview

<2-3 sentence summary: How much new technical debt was introduced in this release?
Is the overall trajectory improving or declining? How does the backlog look?>

## New Items Added to Backlog

| ID | Priority | Effort | Area | Title |
|----|----------|--------|------|-------|
| [[0012]] | High | Small | CSS | <title> |
| [[0013]] | Medium | Medium | UI | <title> |

## Updated Existing Items

<List any existing backlog items that were updated with new occurrences from this
release. If none, omit this section.>

- [[0005]] — Added new occurrence in `src/components/Dashboard.svelte`

## Patterns & Trends

<Cross-cutting observations about the release as a whole:
- Are certain types of debt accumulating?
- Are there areas of the codebase that consistently introduce issues?
- Are there positive trends (e.g., better test coverage, more consistent patterns)?
- Are there architectural decisions that should be revisited?>

## Backlog Status

**Total open items:** <count>
**High priority:** <count> | **Medium:** <count> | **Low:** <count>

> [!tip] Top items to tackle next
> 1. [[<ID>]] — <title> _(Priority, Effort)_
> 2. [[<ID>]] — <title> _(Priority, Effort)_
> 3. [[<ID>]] — <title> _(Priority, Effort)_
>
> Run `/btrs-do-tech-debt <ID>` to start working on an item.
```
3. **#<ID>** — <title> _(Priority, Effort)_

_Run `/btrs-do-tech-debt <ID>` to start working on an item._
```

## Step 10: Present the results

After writing all files and updating the backlog, tell the user:
- The file paths for all three documents
- The customer highlights summary
- Count of changes by category from the engineering notes
- Risk assessment and deployment notes
- How many new tech debt items were added to the backlog
- How many existing items were updated
- The top 2-3 highest-priority items to tackle next (with IDs for `/btrs-do-tech-debt`)
