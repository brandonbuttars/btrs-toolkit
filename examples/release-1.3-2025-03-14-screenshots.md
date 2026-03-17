---
title: "Screenshot Notes: release/1.3"
date: 2025-03-14 14:30
last_updated: 2025-03-14 14:30
type: release-notes-screenshots
release: "release/1.3"
compared_against: "release/1.2"
tags:
  - release
  - release/screenshots
---

# Screenshot Notes: release/1.3

**Generated:** 2025-03-14 14:30
**Latest Release:** release/1.3

Screenshots for this release should be saved to:
`.local/releases/release-1.3/assets/`

Naming convention: `release-1.3-<feature-slug>.png`

---

## Dashboard Filtering & Export

### Dashboard Filter Bar

The new filter bar at the top of the dashboard allows filtering by date range and status. Screenshot should show the dashboard with the filter bar visible, ideally with a filter active to show the filtered state.

**Expected screenshot:** Dashboard page with the FilterBar component visible at the top, showing date range and status dropdowns.

![dashboard-filter-bar](assets/release-1.3-dashboard-filter-bar.png)

### CSV Export Button

A new export button in the top-right corner of data tables enables CSV download. Screenshot should show the button and ideally the export in progress or the download prompt.

**Expected screenshot:** Dashboard data table with the ExportButton visible in the top-right corner.

![csv-export-button](assets/release-1.3-csv-export-button.png)

---

## Map Performance

### Canvas-Rendered Map Markers

Map markers now use canvas rendering instead of DOM nodes. The visual appearance should be the same but performance is improved. Screenshot should show the map with a large number of markers (200+) to demonstrate smooth rendering.

**Expected screenshot:** Map view with 200+ markers rendered smoothly, no visual lag indicators.

![map-canvas-markers](assets/release-1.3-map-canvas-markers.png)

---

## Mobile Layout

### Mobile Sidebar Collapse

The sidebar now collapses properly on mobile with a smooth CSS transform animation. Screenshot should show the mobile viewport with the sidebar in both collapsed and expanded states.

**Expected screenshot:** Mobile viewport showing the sidebar in collapsed state with proper layout.

![mobile-sidebar](assets/release-1.3-mobile-sidebar.png)
