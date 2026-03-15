---
title: "MR Review: feature/dashboard-filters → develop"
date: 2025-03-14
reviewer: Claude (automated)
branch: "feature/dashboard-filters"
target: "develop"
merge_base: "a3f8c2d"
commits: 8
files_changed: 12
risk: "medium"
tags:
  - review
  - risk/medium
---

# MR Review: feature/dashboard-filters → develop

## Summary

This MR adds date range and status filters to the main dashboard. It introduces a new `FilterBar` component, modifies the dashboard data fetching logic to accept filter parameters, and adds corresponding API query parameter support on the backend endpoint.

The implementation is generally solid, but there are concerns around reactivity cleanup in the filter component and some hardcoded color values that should use the existing design tokens. The API changes are backward-compatible.

> [!warning] Risk Assessment: Medium
> 12 files changed across frontend and backend. The dashboard is a high-traffic area. Filter state management introduces new reactive subscriptions that need cleanup verification. API changes are additive (new query params) so backward-compatible.

## Changed Files

| File | Status | +/- | Category |
|------|--------|-----|----------|
| [[src/components/Dashboard/FilterBar.svelte]] | Added | +142/-0 | UI |
| [[src/components/Dashboard/Dashboard.svelte]] | Modified | +38/-12 | UI |
| [[src/components/Dashboard/DashboardStore.ts]] | Modified | +25/-8 | Frontend |
| [[src/api/dashboard.ts]] | Modified | +18/-3 | API |
| [[src/styles/dashboard.css]] | Modified | +32/-0 | CSS |
| [[server/routes/dashboard.ts]] | Modified | +15/-2 | Backend |
| [[server/middleware/validateQuery.ts]] | Modified | +8/-0 | Backend |
| [[src/types/dashboard.ts]] | Modified | +12/-0 | Types |
| [[tests/components/FilterBar.test.ts]] | Added | +86/-0 | Tests |
| [[tests/api/dashboard.test.ts]] | Modified | +24/-6 | Tests |
| [[src/utils/dateFormat.ts]] | Added | +18/-0 | Frontend |
| [[src/styles/variables.css]] | Modified | +2/-0 | CSS |

## Findings

### Critical

> [!tip] No critical findings.

### Warnings

> [!warning] [[src/components/Dashboard/FilterBar.svelte]]:47 — Subscription not cleaned up on destroy
> The `$effect` on line 47 subscribes to `filterStore.dateRange` but there's no cleanup when the component is destroyed. This will leak memory if the dashboard is mounted/unmounted repeatedly.
> **Why this matters:** In a single-page app where the dashboard view is toggled, each mount creates a new subscription without releasing the old one.
> **Suggested fix:** Return a cleanup function from the `$effect`, or use `$derived` if the value is purely computed.

> [!warning] [[src/api/dashboard.ts]]:23 — No abort controller for filter requests
> When filters change rapidly (e.g., user typing a date), each change fires a new API request. There's no `AbortController` to cancel the previous request, so stale responses could arrive after newer ones.
> **Why this matters:** Race condition — older, slower requests could overwrite newer results in the store.
> **Suggested fix:** Create an `AbortController` per request and cancel the previous one when a new filter change triggers.

### Suggestions

> [!info] [[src/styles/dashboard.css]]:18 — Hardcoded color values
> Lines 18-24 use hardcoded hex colors (`#3b82f6`, `#e5e7eb`, `#1e293b`) instead of the existing CSS custom properties defined in [[src/styles/variables.css]].
> **Consider:** Replace with `var(--color-primary)`, `var(--color-border)`, and `var(--color-text-primary)` respectively.

> [!info] [[src/components/Dashboard/FilterBar.svelte]] — Candidate for Atomic Design decomposition
> The `FilterBar` component contains a date range picker, a status dropdown, and a reset button all in one file (142 lines). These could be separate Atoms/Molecules that are composed together.
> **Consider:** Extract `DateRangePicker` and `StatusDropdown` as reusable Molecules. The reset button could use an existing `Button` atom if one exists.

> [!info] [[src/utils/dateFormat.ts]] — Duplicate utility
> The `formatDateRange()` function duplicates logic that exists in [[src/utils/format.ts]] (`formatDate()`). The new function could compose the existing one.
> **Consider:** Import and extend `formatDate` from the existing utils rather than creating a parallel implementation.

### Notes

> [!note] Good test coverage
> The new `FilterBar.test.ts` covers the main interaction flows well. The existing dashboard API tests were updated for the new query params. Overall test coverage for this MR looks solid.

## Tech Debt Items Created

- [[0001]] — Consolidate date formatting utilities
- [[0002]] — Extract FilterBar into Atomic Design components

## Commit Log

| SHA | Message |
|-----|---------|
| f8a2c1d | Add FilterBar component with date range and status filters |
| b3e7f4a | Wire filter params to dashboard API |
| 9c1d8e2 | Add query param validation to dashboard endpoint |
| a5f3b7c | Add filter state to DashboardStore |
| 2d6e9a1 | Style filter bar |
| e4c8f2d | Add FilterBar tests |
| 7b1a3c5 | Update dashboard API tests for filter params |
| 3f9d2e8 | Add dateFormat utility |
