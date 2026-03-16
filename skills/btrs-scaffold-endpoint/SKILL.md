---
name: btrs-scaffold-endpoint
description: >
  Generate endpoint scaffolding following project conventions. Creates the
  route/controller file, validation, types, and optional test file. Use when
  the user wants to create a new endpoint, scaffold an API route, generate
  a route, or asks "create endpoint", "new API route", "btrs scaffold endpoint",
  "add an endpoint for", "scaffold a route".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: <method> <path> [description]
---

# Scaffold Endpoint Skill

Generate endpoint scaffolding following detected project conventions.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.

## Step 1: Detect project conventions

Read the endpoint audit reference:
```
~/.claude/skills/shared/audit-endpoints.md
```

Check if `<basedir>/tech-stack.md` exists and read it. Otherwise detect:

### Framework routing pattern

**SvelteKit:**
```bash
ls src/routes/api/ 2>/dev/null
ls src/routes/*/+server.ts 2>/dev/null
```
- File-based routing: `src/routes/api/<path>/+server.ts`
- Each file exports HTTP method handlers: `GET`, `POST`, `PUT`, `DELETE`

**Next.js:**
```bash
ls app/api/ pages/api/ 2>/dev/null
```
- App Router: `app/api/<path>/route.ts`
- Pages Router: `pages/api/<path>.ts`

**Express/Fastify/Hono:**
```bash
grep -rl "app\.\(get\|post\|put\|delete\|router\)" src/ --include="*.ts" --include="*.js" | head -5
```
- Check for controller pattern vs inline handlers
- Check for router grouping

**NestJS:**
```bash
ls src/**/*.controller.ts 2>/dev/null
```
- Controller + Service + DTO pattern

### Existing patterns

Read 2-3 existing endpoint files to understand:
- Request validation approach (Zod, Joi, class-validator, manual)
- Response format (envelope pattern, direct, JSON API)
- Error handling (try/catch, error middleware, Result types)
- Auth guard pattern (middleware, decorator, inline check)
- Database access (ORM calls, repository pattern, direct queries)
- TypeScript types (shared types file, inline, generated)

### Testing patterns
- Check for endpoint tests (integration tests, supertest, etc.)
- Check test file location and naming

## Step 2: Parse arguments

`$ARGUMENTS` should contain:
- **HTTP method** — `GET`, `POST`, `PUT`, `PATCH`, `DELETE`
- **Path** — e.g., `/users`, `/users/:id`, `/orders/:id/items`
- **Description** (optional) — What the endpoint does

If arguments are incomplete, ask:
- What HTTP method?
- What path/resource?
- What does this endpoint do?
- What data does it accept (for POST/PUT/PATCH)?
- What does it return?
- Does it need authentication?

## Step 3: Plan the scaffolding

Based on the detected framework, determine what files to create:

**SvelteKit example:**
```
src/routes/api/users/+server.ts           # Route handler
src/lib/server/validation/users.ts         # Zod schemas (if project uses Zod)
src/lib/types/users.ts                     # Request/response types (if not colocated)
```

**Express example:**
```
src/routes/users.ts                        # Route handler
src/middleware/validate-users.ts            # Validation middleware
src/types/users.ts                         # Types
```

Present the plan with:
- Files to create
- The request/response shape
- Auth requirements
- Validation approach
- Error handling approach

Ask for confirmation.

## Step 4: Generate the endpoint

### SvelteKit pattern

```typescript
import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ params, locals, url }) => {
  // Auth check (if needed, matching project pattern)

  // Validation (if needed)

  // Business logic

  return json({ /* response */ });
};

export const POST: RequestHandler = async ({ request, locals }) => {
  // Auth check

  // Parse and validate request body
  const body = await request.json();

  // Business logic

  return json({ /* response */ }, { status: 201 });
};
```

### Express pattern

```typescript
import { Router } from 'express';
import type { Request, Response } from 'express';

const router = Router();

router.get('/<path>', async (req: Request, res: Response) => {
  // Auth middleware applied at router level if project uses that pattern

  // Business logic

  res.json({ /* response */ });
});

export default router;
```

For all frameworks:
- Match the exact patterns of existing endpoints (imports, error handling, response format)
- Include input validation using the project's validation library
- Include proper error responses with appropriate status codes
- Add auth guards if the project uses them
- Use the project's database/ORM patterns for data access
- Add TypeScript types for request and response shapes

### Generate validation (if project uses schema validation)

```typescript
import { z } from 'zod'; // or project's validation library

export const createUserSchema = z.object({
  // Fields based on the endpoint description
});

export type CreateUserInput = z.infer<typeof createUserSchema>;
```

### Generate types

```typescript
export interface UserResponse {
  // Response shape
}

export interface CreateUserRequest {
  // Request shape
}
```

## Step 5: Check for conflicts

Before finishing:
- Verify the route path doesn't conflict with existing routes
- Check if similar endpoints already exist
- Verify the validation schemas don't duplicate existing ones

## Step 6: Present the result

Tell the user:
- Files created with paths
- The endpoint: `METHOD /path`
- Request/response shapes
- Auth requirements
- How to test it (curl example or test file)
- Suggest: "Register this route if needed, then test with your API client."
