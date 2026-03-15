# Diff Analysis Reference

Shared guidance for analyzing git diffs across any repository. Both the `review-mr` and `release-notes` skills reference this file.

## Detecting Commit Conventions

Before categorizing changes, detect which commit convention the repo uses by sampling the last 20-50 commits:

1. **Conventional Commits** — Look for prefixes like `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`, `ci:`, `perf:`, `build:`, `style:`. If >60% of commits match, treat as conventional.
2. **MR/PR merge commits** — Look for patterns like `Merge branch '...' into '...'`, `Merge pull request #N`, `See merge request !N`. Extract MR titles and numbers when present.
3. **Squash merges** — Look for commits that reference MR/PR numbers in the message body (e.g., `(#123)`, `(!456)`).
4. **Freeform** — No consistent pattern detected. Fall back to diff-based analysis.

Use whichever convention is detected. If mixed, prefer MR titles when available, then conventional commit prefixes, then diff analysis.

## Categorizing File Changes

Infer categories from file paths and content, not just filenames. Common patterns across repos:

| Path pattern | Likely category |
|---|---|
| `src/components/`, `src/views/`, `src/pages/`, `app/`, `lib/ui/` | UI / Frontend |
| `src/api/`, `src/services/`, `server/`, `backend/`, `controllers/` | Backend / API |
| `src/stores/`, `src/state/`, `redux/`, `vuex/`, `pinia/` | State management |
| `test/`, `tests/`, `__tests__/`, `spec/`, `*.test.*`, `*.spec.*` | Tests |
| `docs/`, `*.md`, `README*`, `CHANGELOG*` | Documentation |
| `Dockerfile*`, `docker-compose*`, `.gitlab-ci*`, `.github/`, `Makefile`, `Jenkinsfile` | Infrastructure / CI/CD |
| `package.json`, `Cargo.toml`, `requirements.txt`, `go.mod`, `*.lock` | Dependencies |
| `*.config.*`, `.env*`, `settings.*`, `config/` | Configuration |
| `migrations/`, `schema/`, `*.sql` | Database / Schema |
| `*.css`, `*.scss`, `*.less`, `tailwind*` | Styling |

When in doubt, read the file content to understand the nature of the change.

## Assessing Change Impact

For each changed file, consider:

- **Scope**: Is this isolated or does it affect shared utilities/types used elsewhere?
- **Risk**: Does it touch auth, permissions, networking, data persistence, or financial logic?
- **Breaking potential**: Are function signatures changed? Are exports removed? Are config formats altered?
- **Test coverage**: Are there corresponding test changes for logic changes?

## Handling Large Diffs

If the diff exceeds ~500 files or ~10,000 lines:

1. Start with `git diff --stat` to get the high-level picture
2. Group changes by top-level directory
3. Identify the highest-impact areas (most lines changed, most files touched)
4. Analyze high-impact areas in detail first
5. Summarize lower-impact areas at directory level
6. Ask the user if they want deeper analysis of specific areas

## Security-Sensitive Patterns to Flag

Always flag these regardless of repo type:

- Hardcoded secrets, API keys, tokens, passwords (strings that look like credentials)
- Changes to authentication or authorization logic
- New network endpoints or URL handling
- File system operations (read/write/delete)
- SQL or database query construction (injection risk)
- User input handling without visible sanitization
- Permission or access control changes
- Cryptography changes
- Dependency additions (especially from unfamiliar sources)
- Changes to `.env` files or secret management
- Disabled security checks or commented-out validation

## Detecting Project Patterns

Both skills benefit from understanding what patterns and systems the project already has in place. Early in the analysis, detect these so subsequent checks are relevant:

**Styling system** — Search for CSS custom properties in `:root` or theme files, SCSS/LESS variable files, Tailwind config (`tailwind.config.*`), or design token JSON files. Understanding the existing color palette, spacing scale, and typography tokens prevents flagging things that aren't relevant.

**Component patterns** — Look at existing component directories for Atomic Design structure (`atoms/`, `molecules/`, `organisms/`, `templates/`) or similar organizational patterns (`base/`, `common/`, `shared/`, `ui/`, `layout/`). Check if there's a component library or design system directory.

**Reactivity framework** — Detect from package.json and file extensions: Svelte (`.svelte`, runes like `$state`, `$derived`, `$effect`), React (`.jsx`/`.tsx`, hooks), Vue (`.vue`, `ref()`, `computed()`), Angular, Solid, etc. This determines which reactivity leak patterns to check for.

**TypeScript** — Check for `tsconfig.json` and `.ts`/`.tsx` files. If present, TypeScript strictness checks apply.

**i18n** — Look for i18n libraries in package.json (`i18next`, `vue-i18n`, `svelte-i18n`, `@angular/localize`, etc.), `$t()` or `t()` function calls, locale files, or translation key patterns. Only flag hardcoded strings if an i18n system exists.

**a11y** — Look for ARIA attributes in existing components, a11y testing libraries (`@testing-library`, `jest-axe`, `pa11y`), a11y linting rules (`eslint-plugin-jsx-a11y`), or `role` attributes. Also consider whether the project is a user-facing web application.

**Endpoint patterns** — Look for route definitions, middleware patterns, request validation libraries (`zod`, `joi`, `yup`, class-validator), and error response conventions to understand what "consistent" means for this codebase.
