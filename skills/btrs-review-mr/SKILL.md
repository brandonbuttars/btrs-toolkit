---
name: btrs-review-mr
description: >
  Perform a deep code review of merge request changes. Compares the current
  branch against its target branch, analyzes every changed file line-by-line,
  and produces a structured markdown review document. Use when the user wants
  to review an MR, review a branch, do a code review, check changes, audit
  a diff, or asks anything like "review my MR", "review this branch",
  "what changed", "check my code", "code review", "review changes before merge",
  "btrs review". Also trigger when the user says "review" in the context of
  git branches.
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Grep, Glob
argument-hint: [target-branch]
---

# MR Review Skill

Perform a thorough, line-by-line code review of the current branch's changes against a target branch. Output a structured markdown review file.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Determine branches

Get the current branch:
```
git branch --show-current
```

Determine the target branch:
- If `$ARGUMENTS` is provided, use it as the target branch
- Otherwise, auto-detect the default branch by checking (in order):
  1. `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null` (the remote default)
  2. Check if `main` exists: `git rev-parse --verify origin/main 2>/dev/null`
  3. Check if `master` exists: `git rev-parse --verify origin/master 2>/dev/null`
  4. Check if `develop` exists: `git rev-parse --verify origin/develop 2>/dev/null`
  5. If none found, ask the user

Verify the target branch exists:
```
git rev-parse --verify <target> 2>/dev/null
```

Find the merge base to get a clean diff (changes on this branch only):
```
git merge-base <target> HEAD
```

## Step 2: Gather diff data

Run these commands to collect the raw data:

```bash
# File change summary
git diff <merge-base>..HEAD --stat

# Full diff
git diff <merge-base>..HEAD

# Commit list
git log <merge-base>..HEAD --oneline --no-merges

# Count of changes
git diff <merge-base>..HEAD --shortstat
```

If the diff is very large (>200 files), summarize by directory first and inform the user of the scope before proceeding with the full analysis.

## Step 3: Read shared analysis guidance

Read the shared references that apply to this diff. Always read the general reference:
```
~/.claude/skills/shared/diff-analysis.md
```

Then read the audit-specific references based on what's in the diff. Check the file types in the diff to decide which to load:

- If the diff includes `.css`, `.scss`, `.less`, `.svelte`, `.vue`, or Tailwind classes → read `~/.claude/skills/shared/audit-css.md`
- If the diff includes reactive code (effects, hooks, stores, signals, watchers) → read `~/.claude/skills/shared/audit-reactivity.md`
- If the diff includes API routes, fetch calls, WebSocket, SSE, or GraphQL → read `~/.claude/skills/shared/audit-endpoints.md`
- If the diff includes UI component files (`.svelte`, `.vue`, `.jsx`, `.tsx`) → read `~/.claude/skills/shared/audit-components.md`

## Step 4: Analyze every changed file

For each changed file, perform a line-by-line review. Read the full diff hunk for each file and assess across all applicable categories. The categories below are always checked; the shared audit references provide deeper guidance for their respective areas.

**Correctness**
- Logic errors, off-by-one mistakes, incorrect conditionals
- Null/undefined handling, missing error cases
- Race conditions or async issues
- Incorrect assumptions about data shape or types

**Security**
- Refer to the security patterns in the shared diff-analysis reference
- Consider the context of the application (web app, API, CLI, library, etc.)

**Endpoints & data connections**
When the diff touches data connections, follow the guidance in `audit-endpoints.md`. Key checks: input validation, correct HTTP methods/status codes, auth guards, error handling on both client and server, WebSocket lifecycle (open/close/error/reconnect), connection teardown in all exit paths, race conditions in data fetching, CORS, rate limiting.

**Performance**
- Unnecessary loops, repeated computations, N+1 patterns
- Large allocations, memory leaks, missing cleanup
- Blocking operations in async contexts

**Reactivity & state management**
When the diff includes reactive code, follow the guidance in `audit-reactivity.md`. Key checks: subscription leak detection (every subscribe needs cleanup on destroy), unnecessary vs missing reactivity, stale closures, expensive computations in reactive contexts, cascading reactivity chains, store ownership and coupling.

**Code quality**
- Readability and naming clarity
- Duplication that could be extracted
- Consistency with patterns visible in surrounding code
- Dead code, commented-out blocks, TODO/FIXME additions

**Reuse & duplication**
- For every new function, method, class, constant, or utility introduced in the diff, search the broader codebase using Grep and Glob for similar or identical functionality
- Flag cases where existing code could be imported instead of reimplemented
- Check for near-duplicates that could be consolidated
- Look at imports in neighboring files to see what shared modules are already in use

**Component architecture (Atomic Design)**
When the diff includes UI components, follow the guidance in `audit-components.md`. Key checks: evaluate against Atomic Design hierarchy (Atoms → Molecules → Organisms → Templates → Pages), flag monolithic components, search for existing reusable components, check prop design for composability.

**CSS & styling**
When the diff includes style changes, follow the guidance in `audit-css.md`. Key checks: existing variable/token usage, hardcoded values, color palette consistency, near-duplicate colors and shades, opacity variant consolidation, style duplication, theme compliance.

**Error boundaries & graceful degradation**
- Check that components handling async data have explicit loading, error, and empty states
- Flag components where a failed data source would crash a parent rather than degrade gracefully
- Verify try/catch around operations that can fail, with meaningful recovery
- Check for error boundary components around sections that can independently fail

**Bundle & import efficiency**
- Flag barrel imports pulling in more than needed
- Identify large dependencies imported for a single utility
- Look for missing dynamic/lazy imports on heavy components
- Flag duplicate or unused imports

**TypeScript strictness** *(apply only when the project uses TypeScript)*
- Flag new `any` types, type assertions (`as`), loose generics
- Verify explicit return types on public/exported APIs
- Check for new types duplicating or conflicting with existing definitions

**Accessibility (a11y)** *(apply when the project has a11y patterns or is a user-facing web app)*
- Check keyboard accessibility and focus indicators on interactive elements
- Verify alt text/aria-label on images and icons
- Flag color-only indicators, missing form labels, heading hierarchy issues

**Internationalization (i18n) readiness** *(apply only when the project has an i18n system)*
- Flag hardcoded user-facing strings that should use translation keys
- Flag string concatenation in user-facing messages
- Verify locale-aware formatting for dates, numbers, currency

**Test coverage**
- Are new logic paths covered by tests?
- Are edge cases tested?
- If tests are modified, do they still test the right things?

**Documentation**
- Are public APIs documented?
- Do complex algorithms have explanatory comments?
- Are there README or doc updates needed?

Classify each finding by severity:
- **Critical** — Bugs, security vulnerabilities, data loss risk. Must fix before merge.
- **Warning** — Potential issues, risky patterns, missing error handling. Should fix.
- **Suggestion** — Improvements to readability, performance, or maintainability. Nice to have.
- **Note** — Observations, questions, or context for the author. Informational only.

## Step 5: Generate the review document

Create the output directory if it doesn't exist, then write the review:

```bash
mkdir -p <basedir>/reviews
```

Filename: `<basedir>/reviews/review-<branch-name>-<YYYY-MM-DD>.md`

If a file with that name already exists, append a counter: `-2`, `-3`, etc.

Use this structure for the review document:

```markdown
---
title: "MR Review: <current-branch> → <target-branch>"
date: YYYY-MM-DD
reviewer: Claude (automated)
branch: "<current-branch>"
target: "<target-branch>"
merge_base: "<short-sha>"
commits: <count>
files_changed: <count>
risk: "<low | medium | high | critical>"
tags:
  - review
  - "risk/<level>"
---

# MR Review: <current-branch> → <target-branch>

## Summary

<2-3 paragraph overall assessment. What is this MR doing? Is it ready to merge?
What are the most important concerns?>

> [!<callout-type>] Risk Assessment: <Low | Medium | High | Critical>
> <Brief reasoning for the risk level. Consider scope of changes, areas touched,
> test coverage, and severity of findings.>

Use the appropriate callout type for the risk level:
- Low → `[!tip]`
- Medium → `[!warning]`
- High → `[!danger]`
- Critical → `[!failure]`

## Changed Files

| File | Status | +/- | Category |
|------|--------|-----|----------|
| [[path/to/file.ts]] | Modified | +25/-10 | Frontend |
| ... | ... | ... | ... |

## Findings

### Critical

> [!failure] [[path/to/file.ts]]:42 — <Brief title>
> <Description of the issue>
> ```
> <relevant code snippet, kept brief>
> ```
> **Why this matters:** <explanation>
> **Suggested fix:** <concrete suggestion>

If no critical findings, write:
> [!tip] No critical findings.

### Warnings

> [!warning] [[path/to/file.ts]]:line — <Brief title>
> <Description of the issue>
> **Why this matters:** <explanation>
> **Suggested fix:** <concrete suggestion>

### Suggestions

> [!info] [[path/to/file.ts]]:line — <Brief title>
> <Description of the issue>
> **Consider:** <concrete suggestion>

### Notes

> [!note] <Brief title>
> <Observations, questions for the author, or context>

## Tech Debt Items Created

<If any findings were added to the tech debt backlog, list them here with wikilinks:>
- [[0012]] — <title>
- [[0013]] — <title>

<If none, omit this section.>

## Commit Log

| SHA | Message |
|-----|---------|
| <short-sha> | <message> |
| ... | ... |
```

## Step 6: Update the tech debt backlog

After generating the review, identify findings that represent tech debt — items classified as Suggestions or Notes that aren't blocking the MR but should be addressed later. Also include Warnings that the author might choose to defer.

Read the shared tech debt format reference:
```
~/.claude/skills/shared/tech-debt-format.md
```

For each tech debt item:
1. Check `<basedir>/tech-debt.md` for duplicates (search titles and grep detail files for same file paths)
2. If no duplicate exists, create a new detail file in `<basedir>/tech-debt/` and add a row to `<basedir>/tech-debt.md`
3. If a duplicate exists and is Open, update the detail file with the new occurrence
4. Set the source to `review-mr/<branch-name> (YYYY-MM-DD)`

Create the directories if they don't exist:
```bash
mkdir -p <basedir>/tech-debt
```

Not every finding becomes a tech debt item. Only add items that represent recurring patterns, structural issues, or improvements that would benefit the codebase long-term. One-off nitpicks or style preferences don't belong in the backlog.

## Step 7: Present the result

After writing the review file, tell the user:
- The file path
- A brief summary: how many findings at each severity level
- The overall risk assessment
- Whether you recommend merging as-is, merging with fixes, or requesting changes
- How many new tech debt items were added to the backlog (if any)
