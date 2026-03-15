# Changelog

All notable changes to the Buttars Code Review Toolkit will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [7.0.0] - 2026-03-14

### Added

**DevOps skills (5):**
- `/btrs-scaffold-pipeline` — Generate CI/CD pipeline config (GitHub Actions, GitLab CI, Bitbucket Pipelines, etc.)
- `/btrs-scaffold-docker` — Generate Dockerfile, docker-compose.yml, .dockerignore with multi-stage builds and security best practices
- `/btrs-deploy` — Deploy to configured target (Vercel, Netlify, Fly.io, Docker self-hosted, Kubernetes) with runbook generation
- `/btrs-audit-infra` — Audit Dockerfiles, CI/CD pipelines, Kubernetes manifests, deploy scripts, and environment config
- `/btrs-scaffold-release` — Automate version bump, changelog generation, git tag, and deploy trigger with semver and conventional commits

**Agent (1):**
- `btrs-devops` — DevOps specialist pre-loading all 5 devops skills

**Shared reference (1):**
- `audit-infra.md` — Infrastructure audit patterns for Docker, CI/CD, Kubernetes, deploy scripts, and environment config

### Summary

**All 68 items complete:** 36 skills, 8 agents, 11 templates, 10 shared references, 3 living document formats.

## [6.0.0] - 2026-03-14

### Added

**Documentation skills (3):**
- `/btrs-doc-component` — Generate component docs from source code (props, events, slots, usage examples from codebase)
- `/btrs-doc-api` — Generate API reference from endpoint source code (routes, params, responses, validation)
- `/btrs-doc-page` — Conversational doc writing for guides, tutorials, overviews, runbooks, onboarding, and howtos

**Optimization skill (1):**
- `/btrs-optimize` — Audit all skills for consistency, token efficiency, capability updates, and cross-reference correctness

**Agents (3):**
- `btrs-documenter` — Documentation specialist pre-loading doc-component, doc-api, doc-page, release-notes
- `btrs-reviewer` — Code quality specialist pre-loading review-mr, 4 audits, scan-tech-debt
- `btrs-executor` — Execution specialist pre-loading do/add-tech-debt, do/add-todo, capture

**Templates (5):**
- `meeting-note.md` — Meeting notes with agenda, decisions, and action items
- `research-note.md` — Research findings with question, analysis, and conclusion
- `design-decision.md` — Lightweight design decisions (lighter than ADR, for UI/UX)
- `retrospective.md` — Sprint retros with what went well/didn't, learnings, and metrics
- `iteration-plan.md` — Sprint/iteration goals with planned work and carry-over tracking

### Summary

**All 61 items complete:** 31 skills, 7 agents, 11 templates, 9 shared references, 3 living document formats.

## [5.0.0] - 2026-03-14

### Added

**Planning & capture skills (4):**
- `/btrs-plan-feature` — Conversational feature planning producing specs with requirements, component breakdown, data model, implementation plan, and auto-generated todo items
- `/btrs-plan-api` — Conversational API design producing specs with endpoint definitions, request/response schemas, validation rules, error format, and pagination patterns
- `/btrs-capture` — Quick context/knowledge capture as structured notes with auto-categorization (decision, research, meeting, howto, context, investigation)
- `/btrs-do-todo` — Work on todo items with staleness check, implementation planning, and backlog updates

## [4.0.0] - 2026-03-14

### Added

**Design skills (3):**
- `/btrs-design-component` — Conversational component design producing specs with props, states, variants, responsive behavior, and accessibility requirements
- `/btrs-design-page` — Conversational page layout design producing specs with component trees, data flow, responsive breakpoints, and loading states
- `/btrs-design-system` — Design system audit: inventories tokens (colors, typography, spacing), components, patterns; identifies gaps, near-duplicates, and inconsistencies

**Agent (1):**
- `btrs-designer` — Design specialist agent pre-loading all 3 design skills

## [3.0.0] - 2026-03-14

### Added

**Implementation skills (5):**
- `/btrs-implement` — Write code from spec, todo, tech debt item, or freeform description with convention detection
- `/btrs-scaffold-component` — Generate component scaffolding with Atomic Design level detection, framework-specific templates (Svelte 5, React, Vue 3)
- `/btrs-scaffold-endpoint` — Generate endpoint scaffolding with framework-specific patterns (SvelteKit, Express, Next.js, NestJS)
- `/btrs-fix-bug` — Investigate and fix bugs from bug reports or descriptions with root cause analysis
- `/btrs-refactor` — Guided refactoring with dependency analysis, safety checks, and multiple refactoring types (extract, simplify, consolidate, restructure, modernize, types)

**Agent (1):**
- `btrs-developer` — Implementation specialist agent pre-loading all 5 coding skills

## [2.0.0] - 2026-03-14

### Added

**New skills (5):**
- `/btrs-update-stack` — Scan project and generate/update tech-stack.md with framework, dependency, and convention detection
- `/btrs-think-through` — Conversational skill for working through problems, ideas, and decisions; identifies the right artifact type and produces it
- `/btrs-create-adr` — Guided Architecture Decision Record creation using MADR format with auto-numbering
- `/btrs-add-todo` — Add todo items to the project todo list with interactive prompts and deduplication
- `/btrs-next` — Suggest what to work on next by ranking open tech debt and todos by priority, effort, age, and dependencies

**Agents (2):**
- `btrs-planner` — Thinking partner agent pre-loading think-through and create-adr skills
- `btrs-navigator` — Project knowledge agent pre-loading btrs-next skill

**Todo system:**
- `todo-format.md` shared reference — Defines todo list format (T-prefixed IDs, master list + detail files)
- `todo.md` template — Obsidian template for manual todo creation

**Config system:**
- `config.md` shared reference — Standard pattern for reading `.btrs-config.json` and resolving basedir
- `.btrs-config.json` support — All skills now read basedir from config instead of hardcoding `.local/`

### Changed

- All 10 existing skills updated to use config-based basedir resolution (Step 0 reads `.btrs-config.json`)
- `btrs-init-project` now asks for basedir, creates `.btrs-config.json`, and sets up todo directories
- `tech-debt-format.md` and `obsidian-setup.md` updated to use `<basedir>/` placeholder instead of hardcoded `.local/`
- Init project now creates additional directories: todos/, decisions/, specs/, docs/, notes/
- Init project now checks for 14 skills (up from 3) and 9 shared references (up from 3)

## [1.0.0] - 2025-03-14

### Added

**Core skills (4):**
- `/btrs-init-project` — Initialize any git repo with Obsidian vault, output directories, and templates
- `/btrs-review-mr` — Deep MR code review with 15 analysis categories, Obsidian callouts, wikilinks to source files
- `/btrs-release-notes` — Three-document release generation (customer, engineering, tech debt summary)
- `/btrs-do-tech-debt` — Execute tech debt backlog items with staleness check and implementation planning

**Tech debt management (2):**
- `/btrs-add-tech-debt` — Manually add items via Claude Code with interactive prompts
- `/btrs-scan-tech-debt` — Full codebase tech debt scan, all categories or filtered

**Standalone audits (4):**
- `/btrs-audit-css` — CSS variables, theming, color palette, duplication
- `/btrs-audit-reactivity` — Subscription leaks, cleanup, state architecture
- `/btrs-audit-endpoints` — REST, WebSocket, SSE, GraphQL validation and lifecycle
- `/btrs-audit-components` — Atomic Design hierarchy, reuse opportunities, prop design

**Obsidian integration:**
- YAML frontmatter on all generated documents
- Hierarchical tags (`priority/`, `area/`, `effort/`, `risk/`)
- Wikilinks to source files and between documents
- Callouts for severity/risk (`[!warning]`, `[!danger]`, `[!tip]`, etc.)
- 5 Obsidian templates: tech debt item, quick review note, ADR (MADR format), bug report, feature spec

**Shared audit references:**
- `audit-css.md` — Styling system detection, variable usage, color palette analysis
- `audit-reactivity.md` — Framework detection, subscription leak patterns, cleanup verification
- `audit-endpoints.md` — Endpoint detection, REST/WebSocket/SSE review checklists
- `audit-components.md` — Atomic Design evaluation, reuse audit, prop design review

**Infrastructure:**
- Persistent tech debt backlog with area tagging (14 areas)
- Deduplication across all skills that write to the backlog
- Staleness check before executing tech debt items
- Claude Code plugin support (`plugin.json`)
- Example output files for every document type
- CONTRIBUTING guide with style guide and testing instructions
