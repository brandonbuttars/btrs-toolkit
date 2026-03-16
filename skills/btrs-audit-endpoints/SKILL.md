---
name: btrs-audit-endpoints
description: >
  Audit REST endpoints, WebSocket handlers, SSE streams, GraphQL resolvers,
  and data connections across the codebase. Checks validation, error handling,
  auth guards, lifecycle management, CORS, and consistency. Feeds findings
  into the tech debt backlog. Use when the user wants to audit APIs,
  check endpoints, review WebSocket handlers, audit data connections,
  or asks "audit our API", "check endpoints", "btrs audit endpoints",
  "review our WebSocket handlers", "API audit".
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Grep, Glob
argument-hint: [directory-or-file]
---

# Endpoints & Data Connections Audit

Audit all data connections for validation, error handling, auth, and lifecycle management. Scans the whole codebase by default.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Determine scope

- If `$ARGUMENTS` is provided, use as target
- Otherwise, scan the entire project

Find endpoint and connection files:
```bash
# Server-side routes
find <scope> -type f \( -name "*.ts" -o -name "*.js" \) -path "*/routes/*" -o -path "*/api/*" -o -path "*/endpoints/*" -o -path "*/controllers/*" -o -path "*/resolvers/*"

# Client-side API consumers
grep -rl "fetch\|axios\|WebSocket\|EventSource\|graphql" <scope> --include="*.ts" --include="*.js" --include="*.svelte" --include="*.vue" --include="*.jsx" --include="*.tsx"
```

## Step 2: Read the shared audit reference

```
~/.claude/skills/shared/audit-endpoints.md
```

Also read:
```
~/.claude/skills/shared/tech-debt-format.md
```

## Step 3: Detect endpoint patterns

Follow the detection steps from the shared reference to understand the project's conventions.

## Step 4: Run the audit

Work through each section of the shared endpoint audit reference:
1. REST endpoint review (request handling, responses, auth, pagination)
2. WebSocket review (lifecycle, message handling, security)
3. SSE & streaming review
4. Client-side data fetching (race conditions, state management, CORS)
5. Connection teardown verification

For each finding, classify by priority:
- **High** — Missing auth guards, unvalidated input, connection leaks, missing error handling
- **Medium** — Inconsistent response formats, missing pagination, no abort controllers
- **Low** — Missing rate limiting, minor validation gaps, optimization opportunities

## Step 5: Add findings to the tech debt backlog

Create tech debt items with area `API` and category `endpoints`.

## Step 6: Generate audit report

Write to `<basedir>/reviews/audit-endpoints-<YYYY-MM-DD>.md`:

```markdown
---
title: "Endpoints Audit"
date: YYYY-MM-DD
type: audit-endpoints
scope: "<directory or 'full codebase'>"
findings: <count>
endpoints_found: <count>
websockets_found: <count>
tags:
  - audit
  - audit/endpoints
---

# Endpoints & Data Connections Audit

**Scope:** <directory or full codebase>
**Files scanned:** <count>

## Endpoint Inventory

<Table of all endpoints found: method, path, auth status, validation status>

## WebSocket / SSE Connections

<List of all persistent connections with lifecycle status>

## Findings

<Findings organized by priority using Obsidian callouts>

## Tech Debt Items Created

<Wikilinks to new backlog items>

## Recommendations

<Summary of most impactful improvements>
```

## Step 7: Present results

Report path, endpoint count, finding counts by priority.
