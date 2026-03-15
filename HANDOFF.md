# Claude Code Handoff

## What this is

The Buttars Development Workflow System — a complete project knowledge base
built as Claude Code skills, agents, and Obsidian templates. Created through
an extended conversation in Claude Chat and built out in Claude Code.

**All 68 items are built:** 36 skills, 8 agents, 11 templates, 10 shared references, 3 living document formats.

## Everything that's built

### Skills (36, all have btrs- prefix)

**Setup & Maintenance (3):**
- `btrs-init-project` — Scaffold project with .btrs-config.json, Obsidian vault, directories, templates
- `btrs-optimize` — Audit skills for consistency, token efficiency, and capability updates
- `btrs-update-stack` — Scan project, generate/update tech-stack.md

**Conversation → Artifact (4):**
- `btrs-think-through` — Talk through anything → right artifact type + conversation summary
- `btrs-create-adr` — Conversational MADR creation with auto-numbering
- `btrs-plan-feature` — Feature planning → spec + auto-generated todos
- `btrs-plan-api` — API design → spec with endpoints, schemas, validation

**Review & Quality (6):**
- `btrs-review-mr` — 15-category deep MR review
- `btrs-audit-css` — CSS/color/theming audit
- `btrs-audit-reactivity` — Reactive leak/state audit
- `btrs-audit-endpoints` — REST/WebSocket/SSE/GraphQL audit
- `btrs-audit-components` — Atomic Design/reuse audit
- `btrs-scan-tech-debt` — Full codebase scan, filterable categories

**Tracking & Execution (4):**
- `btrs-add-tech-debt` — Manual tech debt entry
- `btrs-do-tech-debt` — Execute tech debt items with staleness check
- `btrs-add-todo` — Add todo items interactively
- `btrs-do-todo` — Work on todo items with staleness check

**Knowledge Capture (2):**
- `btrs-capture` — Quick context/knowledge capture → structured note
- `btrs-release-notes` — 3-doc release generation (customer, engineering, tech debt)

**Documentation (3):**
- `btrs-doc-component` — Generate component docs from source code
- `btrs-doc-api` — Generate API reference from endpoint code
- `btrs-doc-page` — Conversational doc writing (guides, tutorials, runbooks, overviews)

**Implementation (5):**
- `btrs-implement` — Write code from spec/todo/tech-debt/description
- `btrs-scaffold-component` — Component scaffolding (Atomic Design, framework-aware)
- `btrs-scaffold-endpoint` — Endpoint scaffolding (framework-aware)
- `btrs-fix-bug` — Root cause investigation and fix
- `btrs-refactor` — Guided refactoring (extract, simplify, consolidate, restructure, modernize, types)

**Design (3):**
- `btrs-design-component` — Component design → spec (props, states, variants, a11y)
- `btrs-design-page` — Page layout design → spec (component tree, data flow, responsive)
- `btrs-design-system` — Design system audit (tokens, components, patterns, gaps)

**Navigation (1):**
- `btrs-next` — Suggest what to work on next, ranked by priority/effort/age

**DevOps (5):**
- `btrs-scaffold-pipeline` — Generate CI/CD pipeline config (GitHub Actions, GitLab CI, etc.)
- `btrs-scaffold-docker` — Generate Dockerfile, docker-compose, .dockerignore
- `btrs-deploy` — Deploy to configured target (Vercel, Fly.io, Docker, K8s, etc.)
- `btrs-audit-infra` — Audit Dockerfiles, CI/CD, K8s manifests, deploy scripts, env config
- `btrs-scaffold-release` — Automate version bump, changelog, git tag, deploy trigger

### Agents (8)

| Agent | Role | Skills |
|-------|------|--------|
| btrs-planner | Thinking partner | think-through, create-adr, plan-feature, plan-api |
| btrs-reviewer | Code quality | review-mr, 4 audits, scan-tech-debt |
| btrs-developer | Implementation | implement, scaffold-component, scaffold-endpoint, fix-bug, refactor |
| btrs-designer | Design | design-component, design-page, design-system |
| btrs-documenter | Documentation | doc-component, doc-api, doc-page, release-notes |
| btrs-executor | Execution | do/add-tech-debt, do/add-todo, capture |
| btrs-navigator | Navigation | btrs-next |
| btrs-devops | DevOps | scaffold-pipeline, scaffold-docker, deploy, audit-infra, scaffold-release |

### Shared References (10)

| Reference | Purpose |
|-----------|---------|
| config.md | .btrs-config.json reading, basedir resolution |
| diff-analysis.md | Commit conventions, file categorization, security patterns |
| tech-debt-format.md | Tech debt backlog format |
| todo-format.md | Todo list format (T-prefixed IDs) |
| obsidian-setup.md | Vault setup, excluded folders, wikilinks |
| audit-css.md | CSS analysis guidance |
| audit-reactivity.md | Reactivity analysis guidance |
| audit-endpoints.md | Endpoint analysis guidance |
| audit-components.md | Component architecture guidance |
| audit-infra.md | Infrastructure/DevOps audit guidance |

### Templates (11)

tech-debt-item.md, todo.md, quick-review-note.md, adr.md, bug-report.md, feature-spec.md, meeting-note.md, research-note.md, design-decision.md, retrospective.md, iteration-plan.md

### Key design decisions

- `.btrs-config.json` at project root stores configurable basedir (default `.local`)
- All skills read config in Step 0 — no hardcoded paths
- All output uses Obsidian features: YAML frontmatter, hierarchical tags, wikilinks, callouts
- Project root is the Obsidian vault (wikilinks work to source files)
- Tech debt IDs: `0001`, Todo IDs: `T0001` — distinct namespaces
- Skills are repo-agnostic — detect patterns automatically
- All skills have `disable-model-invocation: true`
- Skills reference shared audit files (DRY) — improve once, improve everywhere
- Area tags: UI, CSS, Frontend, Backend, API, Database, Auth, Tests, Infra, Deps, Types, a11y, i18n, Docs

## What's next

The system is feature-complete. Potential future work:

- **Testing against real repos** — Run each skill against actual projects to validate output quality
- **Token optimization pass** — Run `/btrs-optimize` to find efficiency gains
- **CLAUDE.md generation** — Auto-generate CLAUDE.md files that reference tech-stack.md
- **Plugin packaging** — Package for distribution via `plugin.json`
- **Additional audit references** — Security audit, performance audit, testing audit

## User preferences

- Svelte 5 + SvelteKit with runes syntax, pnpm, latest LTS Node
- Plan before coding, always
- Terse, direct communication
- Self-hosted, Docker-based, open-source preference
- Works at Fortem Technologies (counter-drone, C2 systems)
- Active Obsidian user with PARA structure, Dataview, Templater
