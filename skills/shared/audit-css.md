# CSS & Styling Audit Reference

Shared analysis guidance for CSS, styling, theming, and color palette consistency. Used by `btrs-audit-css` (standalone) and `btrs-review-mr` (as part of the diff review).

## Detect the styling system

Before auditing, understand what the project uses:

1. **CSS custom properties** — Search for `--` declarations in `:root`, theme files, or `variables.css`/`variables.scss`
2. **SCSS/LESS variables** — Search for `$variable` or `@variable` declarations
3. **Tailwind** — Check for `tailwind.config.*` and utility classes in templates
4. **Design tokens** — Look for JSON/JS token files, `tokens/`, or `design-tokens/` directories
5. **CSS-in-JS** — Check for styled-components, emotion, vanilla-extract, etc.
6. **Scoped styles** — Svelte `<style>`, Vue `<style scoped>`, CSS modules

Build a picture of the existing system before flagging violations.

## Variable & token usage

- Search the codebase for existing CSS custom properties, SCSS/LESS variables, or design tokens
- Flag hardcoded values in stylesheets that should use existing variables instead:
  - Colors: any `#hex`, `rgb()`, `rgba()`, `hsl()`, `hsla()` not inside a variable definition
  - Spacing: hardcoded `px`, `rem`, `em` values that don't match the project's spacing scale
  - Typography: hardcoded `font-size`, `font-weight`, `line-height`, `font-family` values
  - Breakpoints: hardcoded media query values that don't use the project's breakpoint variables
  - Shadows, borders, border-radius: values that appear in variables but are hardcoded elsewhere
- Check if the project has a theming system and verify new styles leverage it rather than introducing one-off values

## Color & palette analysis

- Grep the codebase for all color definitions — build a complete inventory of the palette
- Flag new hardcoded colors not referencing an existing variable or token
- Identify near-duplicate colors: values within ~5% of an existing palette color (e.g., `#2563eb` vs `#2564ec`, or `rgba(0,0,0,0.5)` vs `rgba(0,0,0,0.45)`)
- Suggest consolidation when multiple opacity variants of the same base color exist — use a single base color variable with opacity applied via `rgba()`, `color-mix()`, `opacity`, or similar
- Flag colors that break the palette's logical structure (e.g., a new blue unrelated to the established blue scale)
- Look for opportunities to map ad-hoc hex values to a consistent scale (e.g., 50-900 shade scale per hue)
- Check that dark mode / theme variants use the same token names with different values, not separate hardcoded colors

## Style duplication & optimization

- Look for duplicate or near-duplicate style declarations — both within and across files
- Identify opportunities to reduce CSS specificity and combine selectors
- Flag repeated patterns that could be extracted into reusable classes or mixins
- If utility classes (e.g., Tailwind) are used, flag custom CSS that duplicates utility functionality
- Check for unused CSS classes (if tooling is available in the project)
- Look for overly specific selectors that could be simplified

## Consistency checks

- Are naming conventions consistent? (BEM, utility-first, component-scoped, etc.)
- Are units consistent? (mixing `px` and `rem` without a system)
- Are z-index values managed via a scale or ad-hoc?
- Are transitions/animations using consistent durations and easing functions?
