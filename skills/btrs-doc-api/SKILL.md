---
name: btrs-doc-api
description: >
  Generate API documentation from code. Reads endpoint source files, extracts
  routes, parameters, request/response shapes, auth requirements, and produces
  structured docs. Use when the user wants to document an API, generate
  endpoint docs, or asks "document the API", "btrs doc api", "generate API
  docs", "document our endpoints", "create API reference".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: [directory-or-file]
---

# Document API Skill

Generate API documentation by analyzing endpoint source code.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Find endpoints

If `$ARGUMENTS` is provided, scope to that path. Otherwise scan the full project.

Read the shared endpoint reference:
```
~/.claude/skills/shared/audit-endpoints.md
```

Detect the framework and find all endpoint files:

**SvelteKit:**
```bash
find src/routes -name "+server.ts" -o -name "+server.js" 2>/dev/null
```

**Next.js:**
```bash
find app/api -name "route.ts" -o -name "route.js" 2>/dev/null
find pages/api -name "*.ts" -o -name "*.js" 2>/dev/null
```

**Express/Fastify:**
```bash
grep -rl "router\.\(get\|post\|put\|patch\|delete\)" src/ --include="*.ts" --include="*.js"
```

## Step 2: Read each endpoint

For each endpoint file, read and extract:

### Route information
- HTTP method(s) exported/defined
- Route path (from file path or route definition)
- Route parameters

### Request shape
- Path parameters and types
- Query parameters and types
- Request body schema (from validation, types, or inline parsing)
- Required headers

### Response shape
- Success response body (from return statements, json() calls)
- Status codes used
- Error responses

### Auth & middleware
- Authentication required?
- Authorization checks (role-based, ownership)
- Rate limiting
- Other middleware

### Validation
- Validation library used (Zod, Joi, etc.)
- Schema definitions
- Custom validation logic

## Step 3: Check for existing API specs

Look for API specs in `<basedir>/specs/`:
```bash
ls <basedir>/specs/*-api.md 2>/dev/null
```

Cross-reference code with specs to identify divergences.

## Step 4: Write the documentation

Write to `<basedir>/docs/api/<api-slug>.md` (or a single file if documenting all endpoints):

```markdown
---
title: "API Reference: <API Name>"
type: api-doc
framework: "<SvelteKit | Express | Next.js | etc.>"
endpoints: <count>
updated: YYYY-MM-DD
tags:
  - doc
  - doc/api
---

# API Reference: <API Name>

**Base URL:** `<base path>`
**Authentication:** <approach>
**Framework:** <detected>

## Endpoints Overview

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /api/... | ... | required |
| POST | /api/... | ... | required |

---

## <Resource Name>

### `GET /api/<resource>`

<Description>

**Source:** [[<path/to/+server.ts>]]

**Query parameters:**

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| ... | ... | ... | ... | ... |

**Response:** `200 OK`
```json
{
  "data": [{ ... }]
}
```

**Errors:**

| Status | Code | Description |
|--------|------|-------------|
| 401 | UNAUTHORIZED | Not authenticated |
| 403 | FORBIDDEN | Insufficient permissions |

---

### `POST /api/<resource>`

<Description>

**Source:** [[<path/to/+server.ts>]]

**Request body:**
```json
{
  "field": "type — description"
}
```

**Validation:**

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| ... | ... | ... | ... |

**Response:** `201 Created`
```json
{
  "data": { ... }
}
```

---

<Repeat for each endpoint>

## Error Format

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message"
  }
}
```

## Authentication

<How authentication works: headers, tokens, sessions>

## Rate Limiting

<Rate limiting details if applicable, or "Not implemented">

## Related

- **API spec:** [[<basedir>/specs/<api-slug>-api]] _(if exists)_
- **Source files:** [[path/to/routes/]]
```

## Step 5: Present the result

Tell the user:
- Doc file path
- Endpoint count and summary
- Any issues found (undocumented params, missing error handling, spec divergences)
- Suggest: "Keep docs in sync by re-running after endpoint changes."
