# Component Architecture Audit Reference

Shared analysis guidance for component structure, Atomic Design hierarchy, reuse opportunities, and prop design. Used by `btrs-audit-components` (standalone) and `btrs-review-mr` (as part of the diff review).

## Detect component patterns

Scan the project to understand its component framework and existing organization:

- **Framework** — Svelte, React, Vue, Angular, Web Components, Lit, etc.
- **Directory structure** — Look for existing organizational patterns:
  - Atomic Design: `atoms/`, `molecules/`, `organisms/`, `templates/`, `pages/`
  - Feature-based: `features/<name>/components/`
  - Flat: `components/`
  - Shared/common: `components/shared/`, `components/common/`, `components/ui/`, `components/base/`
  - Design system: `design-system/`, `ui-library/`, `component-library/`
- **Naming conventions** — PascalCase files, kebab-case directories, prefix patterns (e.g., `Base*`, `App*`, `The*`)
- **Existing component library** — Check for Storybook, design system packages, or shared component directories

## Atomic Design hierarchy

Evaluate components against the Atomic Design levels:

**Atoms** — Smallest building blocks. Should be:
- Single-responsibility (one thing: a button, an input, an icon, a label)
- Highly reusable with no domain-specific logic
- Styled via props/variants, not hardcoded
- Examples: `Button`, `Input`, `Icon`, `Badge`, `Avatar`, `Spinner`, `Tooltip`

**Molecules** — Small groups of atoms functioning together:
- Combine 2-4 atoms into a functional unit
- Still relatively generic and reusable
- May have light domain logic (e.g., form validation display)
- Examples: `SearchBar` (input + button), `FormField` (label + input + error), `CardHeader` (avatar + name + date)

**Organisms** — Complex UI sections composed of molecules and atoms:
- Domain-aware, may include data fetching or state management
- Still reusable across pages but more specific
- Examples: `NavigationBar`, `DataTable`, `FilterPanel`, `CommentThread`, `UserProfile`

**Templates** — Page-level layouts defining content structure:
- Define where organisms, molecules, and atoms go
- Handle responsive layout, grid systems, spacing
- No real data — use placeholders or slots
- Examples: `DashboardLayout`, `SidebarLayout`, `AuthLayout`

**Pages** — Specific instances of templates with real data:
- Wire up data sources, route params, and auth context
- Compose templates with real organisms
- Handle page-level state and lifecycle
- Examples: `DashboardPage`, `UserSettingsPage`, `LoginPage`

## What to flag

**Monolithic components** — Components doing too much:
- Over 200 lines of template/markup
- Multiple unrelated concerns in one file
- Mixing layout, data fetching, business logic, and presentation
- Suggestion: identify which Atomic Design level(s) are mixed and propose decomposition

**Missing reuse** — Repeated patterns that should be shared:
- Search for similar markup/component patterns across files using Grep
- Flag the same button+icon pattern in multiple places → extract `IconButton` atom
- Flag similar card layouts across pages → extract `Card` molecule
- Flag repeated form field patterns → extract `FormField` molecule
- Check for existing components in shared/common/ui/base directories that new code could use

**Prop design issues:**
- Overly specific prop names that limit reuse (e.g., `userName` instead of `label`)
- Tightly coupled data shapes (expecting a specific API response shape instead of generic props)
- Boolean prop overload (many boolean flags instead of a variant/type enum)
- Missing default values for optional props
- Props that should be slots/children for flexibility

**Composition vs inheritance:**
- Flag components using inheritance or complex HOC chains where composition would be simpler
- Look for render props or complex slot patterns that could be simplified
- Check for prop drilling through many layers — suggest context/store instead

## Reuse audit

When running as a standalone audit (not just reviewing a diff):

1. Scan all component files in the project
2. Group by similarity — look for components with similar:
   - Template structure (similar HTML/markup patterns)
   - Props interfaces (similar prop shapes)
   - File names (e.g., multiple `*Button*`, `*Card*`, `*Modal*` components)
3. For each group, assess whether they should be consolidated into a single reusable component with variants
4. Check that the shared/common/ui directory (if it exists) is actually being used by feature components

## Where should components live?

Suggest placement based on reuse scope:

- Used in 1 place → Co-located with the feature (`features/<name>/components/`)
- Used in 2-3 places → Shared components directory (`components/shared/`)
- Used across the entire app → Design system / base components (`components/ui/` or `atoms/`)
- Used across projects → Package / library
