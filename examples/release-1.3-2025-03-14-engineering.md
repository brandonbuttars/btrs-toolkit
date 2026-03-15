---
title: "Engineering Release Notes: release/1.3"
date: 2025-03-14
type: release-notes-engineering
release: "release/1.3"
compared_against: "release/1.2"
commits: 47
merge_requests: 12
files_changed: 89
risk: "medium"
tags:
  - release
  - release/engineering
  - risk/medium
---

# Engineering Release Notes: release/1.3

## Summary

Release 1.3 focuses on dashboard filtering, map rendering performance, and notification latency. The dashboard work introduces a new FilterBar component and adds query parameter support to the dashboard API. Map performance was addressed by switching to canvas-based rendering for markers via the `leaflet-canvas-markers` plugin. Notification latency was reduced by replacing the polling mechanism with a WebSocket subscription.

12 MRs merged with 47 commits across 89 files.

## Features

- **Dashboard date/status filters** — New `FilterBar` Svelte component with reactive filter state in `DashboardStore`. Backend adds validated query params to the dashboard endpoint. _([[src/components/Dashboard/]], [[server/routes/dashboard.ts]], MR !142)_

- **CSV export** — New `ExportButton` component with streaming CSV generation using `papaparse`. Supports all dashboard data tables. _([[src/components/Export/]], MR !148)_

## Bug Fixes

- **Map canvas rendering** — Replaced DOM-based markers with `leaflet-canvas-markers` for O(1) render performance beyond 200 markers. Root cause was individual DOM node creation per marker. _([[src/components/Map/]], MR !139)_

- **Notification WebSocket migration** — Replaced 5-second polling with WebSocket subscription to `/ws/notifications`. Includes reconnection logic with exponential backoff. _([[src/services/notifications.ts]], MR !144)_

- **Session timeout** — Activity heartbeat was not being sent during map interactions (drag, zoom). Added `mapInteraction` event to the heartbeat tracker. _([[src/services/session.ts]], MR !146)_

## Improvements

- **Data fetching optimization** — Dashboard and map endpoints now use cursor-based pagination instead of offset. Reduces query time by ~40% for large datasets. _([[server/routes/]], MR !141)_

- **Mobile sidebar** — Sidebar uses CSS `transform` for collapse animation instead of `width` transitions, eliminating layout thrashing. _([[src/components/Layout/Sidebar.svelte]], MR !150)_

## Dependencies

- Added `leaflet-canvas-markers` 1.2.0 _(map performance)_
- Added `papaparse` 5.4.1 _(CSV export)_
- Updated `svelte` 5.1.0 → 5.2.1 _(bug fixes)_

> [!danger] Breaking Changes
> - **Dashboard API** — The `/api/dashboard` endpoint now returns paginated results by default (cursor-based). Clients must handle the `{ data, nextCursor }` response shape. The old flat array response is available via `?legacy=true` query param through release 1.4.
>   _Migration: Update API client to use `fetchDashboardPaginated()` from `src/api/dashboard.ts`._

## Affected Areas

- **src/components/Dashboard/** — Filter bar, store changes, export button
- **src/components/Map/** — Canvas rendering, marker management
- **server/routes/** — Pagination, query params, WebSocket endpoint
- **src/services/** — Notification WebSocket, session heartbeat

> [!warning] Risk Assessment: Medium
> Dashboard API pagination is a breaking change (mitigated by legacy param). WebSocket notification path is new infrastructure. Map rendering engine swap is significant but well-tested. 89 files across frontend and backend with 12 MRs.

> [!example] Deployment Notes
> 1. Run database migration: `npm run migrate` (adds index for cursor pagination)
> 2. Add env var: `WS_NOTIFICATIONS_ENABLED=true`
> 3. Restart the notification service after deploy
> 4. Monitor WebSocket connection counts for the first hour
> 5. The `?legacy=true` dashboard param will be removed in release 1.4 — notify API consumers

## Full Commit Log

<details>
<summary>All commits (47)</summary>

| SHA | Message |
|-----|---------|
| f8a2c1d | feat: add FilterBar component |
| b3e7f4a | feat: wire filter params to API |
| ... | _(45 more commits)_ |

</details>
