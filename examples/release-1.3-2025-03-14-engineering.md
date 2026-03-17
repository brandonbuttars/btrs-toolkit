---
title: "Release Notes, Example App Version 1.3"
date: 2025-03-14 14:30
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

# Release Notes, Example App Version 1.3

ENGINEERING RELEASE NOTES (1.2 – 1.3)

**Generated:** 2025-03-14 14:30

## Component Versions

<!-- Populated from version.json at project root. Keys are converted to display
     names, versions assembled from major.minor.patch[.revision] fields. -->

| Component | Version |
|-----------|---------|
| Manager | 5.2.3 |
| TrueView | 4.6.1 |
| SkyDome | 5.2.3 |
| Ground Control | 8.1.2 |
| DroneHunter | 8.1.3 |
| Arducopter | 4.4.4.6 |
| Target Assignment | 1.0.0 |
| EULA | 9.15.22 |

The main goal of this release is dashboard filtering, map rendering performance, and notification latency improvements.

## Change Summary

### Dashboard Filtering & Export

- **Dashboard date/status filters** — New `FilterBar` Svelte component with reactive filter state in `DashboardStore`. Backend adds validated query params to the dashboard endpoint.
  _(src/components/Dashboard/, server/routes/dashboard.ts, MR !142)_

- **CSV export** — New `ExportButton` component with streaming CSV generation using `papaparse`. Supports all dashboard data tables.
  _(src/components/Export/, MR !148)_

- **Data fetching optimization** — Dashboard and map endpoints now use cursor-based pagination instead of offset. Reduces query time by ~40% for large datasets.
  _(server/routes/, MR !141)_

### Map Performance

- **Map canvas rendering** — Replaced DOM-based markers with `leaflet-canvas-markers` for O(1) render performance beyond 200 markers. Root cause was individual DOM node creation per marker.
  _(src/components/Map/, MR !139)_

### Notification System

- **Notification WebSocket migration** — Replaced 5-second polling with WebSocket subscription to `/ws/notifications`. Includes reconnection logic with exponential backoff.
  _(src/services/notifications.ts, MR !144)_

### Session Management

- **Session timeout fix** — Activity heartbeat was not being sent during map interactions (drag, zoom). Added `mapInteraction` event to the heartbeat tracker.
  _(src/services/session.ts, MR !146)_

### Mobile Layout

- **Mobile sidebar** — Sidebar uses CSS `transform` for collapse animation instead of `width` transitions, eliminating layout thrashing.
  _(src/components/Layout/Sidebar.svelte, MR !150)_

### Dependencies

- Added `leaflet-canvas-markers` 1.2.0 _(map performance)_
- Added `papaparse` 5.4.1 _(CSV export)_
- Updated `svelte` 5.1.0 → 5.2.1 _(bug fixes)_

### Breaking Changes

> [!danger] Breaking Changes
> - **Dashboard API** — The `/api/dashboard` endpoint now returns paginated results by default (cursor-based). Clients must handle the `{ data, nextCursor }` response shape. The old flat array response is available via `?legacy=true` query param through release 1.4.
>   _Migration: Update API client to use `fetchDashboardPaginated()` from `src/api/dashboard.ts`._

## Issue Summary

No ticket references found in this release.

## Known Issues / Workarounds

- **Legacy dashboard param** — The `?legacy=true` query param for the old flat array response will be removed in release 1.4. API consumers should migrate to paginated responses before then.

## Deployment Notes

> [!example] Deployment Notes
> 1. Run database migration: `npm run migrate` (adds index for cursor pagination)
> 2. Add env var: `WS_NOTIFICATIONS_ENABLED=true`
> 3. Restart the notification service after deploy
> 4. Monitor WebSocket connection counts for the first hour
> 5. The `?legacy=true` dashboard param will be removed in release 1.4 — notify API consumers

## Risk Assessment

> [!warning] Risk Assessment: Medium
> Dashboard API pagination is a breaking change (mitigated by legacy param). WebSocket notification path is new infrastructure. Map rendering engine swap is significant but well-tested. 89 files across frontend and backend with 12 MRs.

## Screenshots & Walkthrough

_No screenshots or walkthrough materials for this release._

## Full Commit Log

<details>
<summary>All commits (47)</summary>

| SHA | Message |
|-----|---------|
| f8a2c1d | feat: add FilterBar component |
| b3e7f4a | feat: wire filter params to API |
| ... | _(45 more commits)_ |

</details>
