# Review Criteria Reference

Additional review criteria organized by domain. The main SKILL.md covers the general review process; this file provides deeper checklists for specific areas when relevant.

## API Changes

When reviewing changes to API endpoints or contracts:

- Are breaking changes documented?
- Is versioning handled correctly?
- Are request/response schemas validated?
- Are error responses consistent and informative?
- Are rate limits or pagination considered for new endpoints?
- Is authentication/authorization enforced on new routes?

## Database / Schema Changes

When reviewing migrations or schema changes:

- Is the migration reversible?
- Are there index additions for new query patterns?
- Could the migration lock tables in production?
- Are default values sensible?
- Is data migration handled (not just schema)?
- Are foreign key constraints correct?

## Frontend / UI Changes

When reviewing UI components:

- Are loading and error states handled?
- Is the component accessible (keyboard nav, ARIA, contrast)?
- Are there unhandled edge cases in user input?
- Is state management appropriate (local vs global)?
- Are event listeners cleaned up on unmount?
- Are there layout issues at different viewport sizes?

## Dependency Changes

When package.json, Cargo.toml, requirements.txt, etc. are modified:

- Is the new dependency well-maintained and trusted?
- Does it introduce license conflicts?
- Is the version pinned appropriately?
- Could an existing dependency cover this functionality?
- Are there known vulnerabilities in the added version?

## Configuration Changes

When .env, config files, or CI/CD pipelines change:

- Are secrets kept out of version control?
- Are environment-specific values properly separated?
- Do CI/CD changes affect deployment for all environments?
- Are feature flags or toggles documented?
