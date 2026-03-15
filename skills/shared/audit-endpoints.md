# Endpoints & Data Connections Audit Reference

Shared analysis guidance for REST endpoints, WebSocket handlers, SSE streams, GraphQL resolvers, and any other data connections. Used by `btrs-audit-endpoints` (standalone) and `btrs-review-mr` (as part of the diff review).

## Detect endpoint patterns

Scan the codebase for how endpoints are defined and consumed:

- **Server-side frameworks** — Express, Fastify, Hono, SvelteKit endpoints, Next.js API routes, Django, Flask, etc.
- **API client patterns** — fetch wrappers, axios instances, tRPC clients, GraphQL clients (Apollo, urql)
- **WebSocket** — `ws`, `socket.io`, native WebSocket, SvelteKit WebSocket handlers
- **SSE** — `EventSource`, server-sent event endpoints
- **GraphQL** — Schema definitions, resolvers, client queries/mutations
- **gRPC** — Proto definitions, service implementations

Understand the project's conventions before flagging inconsistencies.

## REST endpoint review

**Request handling:**
- Verify correct HTTP methods for each operation (GET for reads, POST for creates, PUT/PATCH for updates, DELETE for deletes)
- Check that all endpoints validate and sanitize input — path params, query params, request bodies, headers
- Look for validation libraries in use (`zod`, `joi`, `yup`, `class-validator`, `ajv`) and verify new endpoints use them
- Flag endpoints that accept user input without any visible validation

**Response handling:**
- Verify consistent response shapes across endpoints (e.g., `{ data, error, meta }`)
- Check that correct HTTP status codes are used (201 for creation, 404 for not found, 422 for validation errors, etc.)
- Flag generic 500 errors that should be more specific
- Verify error responses include useful messages without leaking internal details

**Authentication & authorization:**
- Check that endpoints have appropriate auth guards/middleware
- Verify authorization checks exist for resource-specific operations (not just authentication)
- Flag any endpoints that skip auth without explicit documentation of why

**Pagination, rate limiting, and size:**
- Flag list endpoints without pagination
- Check for rate limiting on public or expensive endpoints
- Verify request body size limits on upload or data-entry endpoints
- Look for missing `Content-Type` validation

## WebSocket review

**Lifecycle management:**
- Verify the full lifecycle is handled: open, message, error, close
- Check for reconnection logic with backoff (exponential or linear)
- Verify connections are properly closed on component unmount or navigation
- Flag WebSocket connections that don't handle the `error` event
- Check for heartbeat/ping-pong to detect stale connections

**Message handling:**
- Verify incoming messages are validated before processing
- Check for message type/format consistency (e.g., JSON with a `type` field)
- Flag missing error handling for malformed messages
- Look for message queuing during disconnection (messages sent while reconnecting)

**Security:**
- Verify WebSocket upgrade requests include authentication
- Check that sensitive data isn't sent over unencrypted WebSocket connections
- Flag WebSocket endpoints without origin validation

## SSE & streaming review

- Verify backpressure handling for high-throughput streams
- Check reconnection logic (SSE has built-in reconnection via `Last-Event-ID`)
- Verify streams are closed when no longer needed (component unmount, navigation)
- Flag missing error event handling

## Client-side data fetching

**Race conditions:**
- Look for missing `AbortController` when requests can be superseded (e.g., rapid filter changes)
- Flag stale response handling — older slow requests overwriting newer results
- Check for proper cancellation on component unmount

**State management:**
- Verify loading, error, and empty states are handled (not just the happy path)
- Check that error states provide meaningful feedback to the user
- Flag infinite loading spinners — verify timeout handling exists
- Look for missing retry logic on transient failures

**CORS:**
- Check for proper CORS configuration on new endpoints
- Verify allowed origins, methods, and headers are appropriate

## Connection teardown

Verify that teardown happens in ALL exit paths, not just the happy path:
- Component unmount/destroy
- Navigation away
- Error conditions
- User-initiated cancellation
- Session timeout
- Tab/window close (if relevant, via `beforeunload`)
