---
name: btrs-plan-api
description: >
  Design an API through guided conversation. Produces an API spec covering
  endpoints, request/response shapes, authentication, validation, error
  handling, and versioning. Use when the user wants to design an API, plan
  endpoints, spec out a REST API, or asks "plan an API", "btrs plan api",
  "design the API for", "spec out the endpoints", "API design for".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: <api-name or description>
---

# Plan API Skill

Design an API through conversation and produce a structured API spec.

## Step 0: Read config and verify project

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Verify the project is initialized.

## Step 1: Understand the context

Read the shared endpoint reference:
```
~/.claude/skills/shared/audit-endpoints.md
```

Check if `<basedir>/tech-stack.md` exists and read it for:
- API framework (SvelteKit, Express, Next.js, etc.)
- Authentication approach
- Database/ORM
- Existing API patterns

Scan existing endpoints to understand conventions:
```bash
# Find existing API routes
find src/ -path "*/api/*" -o -path "*/routes/*+server*" 2>/dev/null | head -20
```

Read 2-3 existing endpoints to understand:
- Response envelope format
- Error response format
- Validation approach
- Auth guard pattern
- Pagination pattern

## Step 2: Understand what to design

If `$ARGUMENTS` is provided, use it as the starting point. Otherwise ask: "What API do you need to design?"

Work through:

### Resources
- What entities/resources does this API manage?
- What are the relationships between them?
- What operations does each resource need? (CRUD + custom actions)

### Consumers
- Who calls this API? (frontend, mobile, third-party, internal services)
- Are there different access levels?
- What's the expected request volume?

### Constraints
- Must it be backward compatible with an existing API?
- Real-time requirements (WebSocket, SSE)?
- File upload/download?
- Rate limiting requirements?

## Step 3: Design the endpoints

For each resource, design the endpoints:

### RESTful design
- `GET /api/<resource>` — List (with filtering, sorting, pagination)
- `GET /api/<resource>/:id` — Get single
- `POST /api/<resource>` — Create
- `PUT /api/<resource>/:id` — Full update
- `PATCH /api/<resource>/:id` — Partial update
- `DELETE /api/<resource>/:id` — Delete

### For each endpoint, define:

**Request:**
- HTTP method and path
- Path parameters
- Query parameters (for GET: filters, sort, pagination)
- Request body schema (for POST/PUT/PATCH)
- Headers (auth, content-type, custom)

**Response:**
- Success status code and body schema
- Error status codes and body schemas
- Headers (pagination links, rate limit info)

**Behavior:**
- Authentication required?
- Authorization rules (who can do what?)
- Validation rules
- Side effects (emails, webhooks, cache invalidation)
- Idempotency requirements

### Non-CRUD endpoints
For actions that don't fit CRUD:
- `POST /api/<resource>/:id/<action>` (e.g., `/api/orders/:id/cancel`)
- Batch operations
- Search endpoints

### Real-time endpoints (if needed)
- WebSocket channels and message types
- SSE event streams
- Subscription/unsubscription flow

## Step 4: Design shared patterns

### Error format
Define a consistent error response:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

### Pagination
Choose and document the pagination approach:
- Offset-based: `?page=2&limit=20`
- Cursor-based: `?cursor=abc123&limit=20`
- Response includes: total count, next/prev links, page info

### Filtering & sorting
- Filter syntax: `?status=active&created_after=2025-01-01`
- Sort syntax: `?sort=created_at:desc`

### Versioning (if applicable)
- URL-based: `/api/v2/...`
- Header-based: `Accept: application/vnd.api.v2+json`

## Step 5: Design validation schemas

For each endpoint that accepts input, define the validation:
- Required vs optional fields
- Type constraints (string, number, enum)
- Format constraints (email, URL, date, UUID)
- Range constraints (min/max length, numeric range)
- Custom validation rules

## Step 6: Write the API spec

Write to `<basedir>/specs/<api-slug>-api.md`:

```markdown
---
title: "API Spec: <API Name>"
date: YYYY-MM-DD
type: api-spec
status: "designed"
tags:
  - spec
  - spec/api
---

# API Spec: <API Name>

## Overview

**Purpose:** <what this API does>
**Consumers:** <who calls it>
**Base path:** `/api/...`
**Auth:** <authentication approach>

## Endpoints

### <Resource Name>

#### `GET /api/<resource>`

List <resources> with optional filtering and pagination.

**Query parameters:**

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| page | number | no | 1 | Page number |
| limit | number | no | 20 | Items per page (max 100) |
| sort | string | no | created_at:desc | Sort field and direction |
| ... | ... | ... | ... | ... |

**Response:** `200 OK`
```json
{
  "data": [{ ... }],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8
  }
}
```

**Errors:**
- `401` — Not authenticated
- `403` — Not authorized

---

#### `GET /api/<resource>/:id`

Get a single <resource> by ID.

**Path parameters:**

| Param | Type | Description |
|-------|------|-------------|
| id | string (UUID) | Resource ID |

**Response:** `200 OK`
```json
{
  "data": { ... }
}
```

**Errors:**
- `404` — Resource not found

---

#### `POST /api/<resource>`

Create a new <resource>.

**Request body:**
```json
{
  "field": "value"
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

**Errors:**
- `400` — Validation error
- `409` — Conflict (duplicate)

---

<Repeat for PUT, PATCH, DELETE, custom actions>

## Shared Patterns

### Error format
```json
{
  "error": {
    "code": "<ERROR_CODE>",
    "message": "<human-readable>",
    "details": []
  }
}
```

### Error codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| VALIDATION_ERROR | 400 | Request validation failed |
| NOT_FOUND | 404 | Resource not found |
| UNAUTHORIZED | 401 | Authentication required |
| FORBIDDEN | 403 | Insufficient permissions |
| CONFLICT | 409 | Resource conflict |
| INTERNAL_ERROR | 500 | Unexpected server error |

### Pagination
<Documented approach>

### Authentication
<How auth works for this API>

## Data Models

### <Entity>
```typescript
interface <Entity> {
  id: string;
  // fields
  created_at: string; // ISO 8601
  updated_at: string;
}
```

## Implementation Notes

<Framework-specific patterns, migration steps, deployment considerations>

## Open Questions

<Unresolved items>
```

## Step 7: Create follow-up items

Offer to create:
- Todo items for each endpoint to implement
- An ADR if significant API design decisions were made
- Component design specs for API consumer UI

## Step 8: Present the result

Tell the user:
- Spec file path
- Endpoint count and resource summary
- Key design decisions (pagination, error format, auth)
- Suggest: "Scaffold endpoints with `/btrs-scaffold-endpoint` or start implementing with `/btrs-implement`"
