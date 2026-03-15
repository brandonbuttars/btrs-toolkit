# Buttars Development Workflow System — Master Plan

## Everything in one place

---

## Config

`.btrs-config.json` at project root (committed to repo):
```json
{
  "version": "1.0.0",
  "basedir": ".local",
  "created": "2025-03-14"
}
```

`/btrs-init-project` asks for the basedir (defaults to `.local`).
All skills read this config in Step 0 instead of hardcoding `.local/`.

---

## All Skills (36)

### Setup & Maintenance (3)

| # | Command | Purpose | Status |
|---|---------|---------|--------|
| 1 | `/btrs-init-project` | Scaffold project, ask for basedir, Obsidian vault, templates | ✅ Built |
| 2 | `/btrs-optimize` | Check/update skills for new Claude capabilities | ✅ Built |
| 3 | `/btrs-update-stack` | Scan project, generate/update tech-stack.md | ✅ Built |

### Conversation → Artifact (4)

| # | Command | Purpose | Agent | Status |
|---|---------|---------|-------|--------|
| 4 | `/btrs-think-through` | Talk through anything → right artifact + summary | btrs-planner | ✅ Built |
| 5 | `/btrs-create-adr` | Talk through architecture decision → ADR (MADR) | btrs-planner | ✅ Built |
| 6 | `/btrs-plan-feature` | Talk through feature → spec + todos | btrs-planner | ✅ Built |
| 7 | `/btrs-plan-api` | Talk through API design → spec | btrs-planner | ✅ Built |

### Review & Quality (6)

| # | Command | Purpose | Agent | Status |
|---|---------|---------|-------|--------|
| 8 | `/btrs-review-mr` | Deep MR review (15 categories) | btrs-reviewer | ✅ Built |
| 9 | `/btrs-audit-css` | CSS/color/theming audit | btrs-reviewer | ✅ Built |
| 10 | `/btrs-audit-reactivity` | Reactive leak/state audit | btrs-reviewer | ✅ Built |
| 11 | `/btrs-audit-endpoints` | API/WebSocket audit | btrs-reviewer | ✅ Built |
| 12 | `/btrs-audit-components` | Atomic Design audit | btrs-reviewer | ✅ Built |
| 13 | `/btrs-scan-tech-debt` | Full codebase scan (all categories) | btrs-reviewer | ✅ Built |

### Tracking & Execution (4)

| # | Command | Purpose | Agent | Status |
|---|---------|---------|-------|--------|
| 14 | `/btrs-add-todo` | Add a todo (any type) | btrs-executor | ✅ Built |
| 15 | `/btrs-do-todo` | Work on a todo item | btrs-executor | ✅ Built |
| 16 | `/btrs-add-tech-debt` | Add tech debt item | btrs-executor | ✅ Built |
| 17 | `/btrs-do-tech-debt` | Work on tech debt item | btrs-executor | ✅ Built |

### Knowledge Capture (2)

| # | Command | Purpose | Agent | Status |
|---|---------|---------|-------|--------|
| 18 | `/btrs-capture` | Quick context/knowledge capture → note | btrs-executor | ✅ Built |
| 19 | `/btrs-release-notes` | Release documentation (3 docs) | btrs-documenter | ✅ Built |

### Documentation Generation (3)

| # | Command | Purpose | Agent | Status |
|---|---------|---------|-------|--------|
| 20 | `/btrs-doc-component` | Generate component docs from code | btrs-documenter | ✅ Built |
| 21 | `/btrs-doc-api` | Generate API docs from code | btrs-documenter | ✅ Built |
| 22 | `/btrs-doc-page` | Conversational doc writing | btrs-documenter | ✅ Built |

### Implementation (5)

| # | Command | Purpose | Agent | Status |
|---|---------|---------|-------|--------|
| 23 | `/btrs-implement` | Write code from spec/todo/description | btrs-developer | ✅ Built |
| 24 | `/btrs-scaffold-component` | Generate component scaffolding (Atomic Design) | btrs-developer | ✅ Built |
| 25 | `/btrs-scaffold-endpoint` | Generate endpoint scaffolding | btrs-developer | ✅ Built |
| 26 | `/btrs-fix-bug` | Work on a bug report | btrs-developer | ✅ Built |
| 27 | `/btrs-refactor` | Guided refactoring | btrs-developer | ✅ Built |

### Design (3)

| # | Command | Purpose | Agent | Status |
|---|---------|---------|-------|--------|
| 28 | `/btrs-design-component` | Design a component → spec | btrs-designer | ✅ Built |
| 29 | `/btrs-design-page` | Design a page layout → spec | btrs-designer | ✅ Built |
| 30 | `/btrs-design-system` | Audit/evolve design system | btrs-designer | ✅ Built |

### Navigation (1)

| # | Command | Purpose | Agent | Status |
|---|---------|---------|-------|--------|
| 31 | `/btrs-next` | Suggest what to do next based on area | btrs-navigator | ✅ Built |

### DevOps (5)

| # | Command | Purpose | Agent | Status |
|---|---------|---------|-------|--------|
| 32 | `/btrs-scaffold-pipeline` | Generate CI/CD pipeline config | btrs-devops | ✅ Built |
| 33 | `/btrs-scaffold-docker` | Generate Dockerfile + compose | btrs-devops | ✅ Built |
| 34 | `/btrs-deploy` | Deploy to configured target | btrs-devops | ✅ Built |
| 35 | `/btrs-audit-infra` | Audit infra configs (Docker, CI, K8s) | btrs-devops | ✅ Built |
| 36 | `/btrs-scaffold-release` | Automate version bump, tag, changelog | btrs-devops | ✅ Built |

**Total: 36 skills (36 built, 0 to build) ✅ ALL SKILLS COMPLETE**

---

## All Agents (8)

| Agent | Role | Skills | Status |
|-------|------|--------|--------|
| btrs-reviewer | Code quality specialist | review-mr, 4 audits, scan-tech-debt | ✅ Built |
| btrs-planner | Thinking partner | think-through, create-adr, plan-feature, plan-api | ✅ Built |
| btrs-documenter | Documentation specialist | doc-component, doc-api, doc-page, release-notes | ✅ Built |
| btrs-executor | Gets things done | do/add-tech-debt, do/add-todo, capture | ✅ Built |
| btrs-navigator | Project knowledge | next | ✅ Built |
| btrs-developer | Implementation specialist | implement, scaffold-component, scaffold-endpoint, fix-bug, refactor | ✅ Built |
| btrs-designer | Design specialist | design-component, design-page, design-system | ✅ Built |
| btrs-devops | DevOps specialist | scaffold-pipeline, scaffold-docker, deploy, audit-infra, scaffold-release | ✅ Built |

---

## All Templates (11)

| Template | Use case | Status |
|----------|----------|--------|
| tech-debt-item.md | Manual tech debt entry | ✅ Built |
| quick-review-note.md | Informal review notes | ✅ Built |
| adr.md | Architecture Decision Record (MADR) | ✅ Built |
| bug-report.md | Structured bug report | ✅ Built |
| feature-spec.md | Feature specification | ✅ Built |
| todo.md | General-purpose todo | ✅ Built |
| meeting-note.md | Meeting notes + action items | ✅ Built |
| research-note.md | Research findings | ✅ Built |
| design-decision.md | Lighter than ADR, for UI/UX | ✅ Built |
| retrospective.md | What went well/didn't | ✅ Built |
| iteration-plan.md | Sprint/iteration goals | ✅ Built |

---

## Shared References (9)

| Reference | Used by | Status |
|-----------|---------|--------|
| config.md | All skills (Step 0 basedir resolution) | ✅ Built |
| diff-analysis.md | review-mr, release-notes, scan-tech-debt | ✅ Built |
| tech-debt-format.md | All backlog writers | ✅ Built |
| obsidian-setup.md | init-project | ✅ Built |
| audit-css.md | audit-css, review-mr, scan-tech-debt, developer, designer | ✅ Built |
| audit-reactivity.md | audit-reactivity, review-mr, scan-tech-debt, developer | ✅ Built |
| audit-endpoints.md | audit-endpoints, review-mr, scan-tech-debt, developer | ✅ Built |
| audit-components.md | audit-components, review-mr, scan-tech-debt, developer, designer | ✅ Built |
| audit-infra.md | audit-infra, review-mr, scan-tech-debt, devops | ✅ Built |
| todo-format.md | add-todo, do-todo, next, executor | ✅ Built |

---

## Living Documents (per project, auto-generated)

| Document | Generated by | Referenced by | Status |
|----------|-------------|---------------|--------|
| tech-stack.md | btrs-update-stack | CLAUDE.md, all dev/design skills | ✅ Format built |
| tech-debt.md | review-mr, release-notes, audits, add-tech-debt | do-tech-debt, next | ✅ Format built |
| todos.md | add-todo, plan-feature | do-todo, next | ✅ Format built |

---

## Directory Structure (per project)

```
project-root/
├── .btrs-config.json              # Config (basedir, version)
├── .obsidian/                     # Vault config (gitignored)
├── CLAUDE.md                      # References tech-stack.md
├── <basedir>/                     # Default: .local/
│   ├── tech-stack.md              # Living tech stack document
│   ├── tech-debt.md               # Tech debt master list
│   ├── tech-debt/                 # Tech debt detail files
│   ├── todos.md                   # Todo master list
│   ├── todos/                     # Todo detail files
│   ├── reviews/                   # MR reviews, audit reports
│   ├── releases/                  # Release documentation
│   ├── specs/                     # Feature specs, API specs
│   │   ├── components/            # Component design specs
│   │   └── pages/                 # Page design specs
│   ├── decisions/                 # ADRs
│   ├── bugs/                      # Bug reports
│   ├── docs/                      # Generated documentation
│   │   ├── components/            # Component docs
│   │   ├── api/                   # API docs
│   │   └── design-system/         # Design system docs
│   ├── notes/                     # Knowledge capture, conversation
│   │                              #   summaries, research, meetings
│   └── templates/                 # All Obsidian templates
└── src/                           # Source code (wikilinked from docs)
```

---

## Build Phases

### Phase 1: Foundation (conversation, todos, navigation, tech stack)
1. `.btrs-config.json` support + update init-project
2. `/btrs-update-stack` + tech-stack.md format
3. `/btrs-think-through` + conversation summary format
4. Todo system (format, `/btrs-add-todo`, template)
5. `/btrs-next`
6. `/btrs-create-adr`
7. btrs-planner agent
8. btrs-navigator agent

### Phase 2: Implementation (coding)
9. `/btrs-implement`
10. `/btrs-scaffold-component`
11. `/btrs-scaffold-endpoint`
12. `/btrs-fix-bug`
13. `/btrs-refactor`
14. btrs-developer agent

### Phase 3: Design
15. `/btrs-design-component`
16. `/btrs-design-page`
17. `/btrs-design-system`
18. btrs-designer agent

### Phase 4: Planning & capture
19. `/btrs-plan-feature`
20. `/btrs-plan-api`
21. `/btrs-capture` + note template
22. `/btrs-do-todo`

### Phase 5: Documentation
23. `/btrs-doc-component`
24. `/btrs-doc-api`
25. `/btrs-doc-page`
26. btrs-documenter agent

### Phase 6: Optimization, remaining agents & templates
27. `/btrs-optimize`
28. btrs-reviewer agent
29. btrs-executor agent
30. Remaining templates (meeting, research, design decision, retro, iteration)
31. Token optimization pass across all skills
32. Final update to init-project for all new directories/templates

---

## Scorecard

| Category | Built | To build | Total |
|----------|-------|----------|-------|
| Skills | 36 | 0 | 36 |
| Agents | 8 | 0 | 8 |
| Templates | 11 | 0 | 11 |
| Shared references | 10 | 0 | 10 |
| Living documents | 3 | 0 | 3 |
| **Everything** | **68** | **0** | **68** ✅ |
