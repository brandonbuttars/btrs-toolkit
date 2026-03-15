# Buttars Development Workflow System

AI-powered development workflow — code review, planning, implementation, design, documentation, and project management. Built as [Claude Code skills](https://code.claude.com/docs/en/skills) and agents with Obsidian-compatible output.

**36 skills, 8 agents, 11 templates, 10 shared references, 3 living document formats.**

## Commands

### Setup & Maintenance

| Command | Purpose |
|---------|---------|
| `/btrs-init-project` | Initialize any repo — config, Obsidian vault, directories, templates |
| `/btrs-optimize` | Audit all skills for consistency, token efficiency, capability updates |
| `/btrs-update-stack` | Scan project, generate/update tech-stack.md |

### Conversation → Artifact

| Command | Purpose |
|---------|---------|
| `/btrs-think-through` | Talk through anything → right artifact type + summary |
| `/btrs-create-adr` | Guided Architecture Decision Record (MADR) creation |
| `/btrs-plan-feature` | Feature planning → spec + auto-generated todos |
| `/btrs-plan-api` | API design → spec with endpoints, schemas, validation |

### Review & Quality

| Command | Purpose |
|---------|---------|
| `/btrs-review-mr [target]` | Deep MR review (15 categories) |
| `/btrs-audit-css [dir]` | CSS, theming, color palette audit |
| `/btrs-audit-reactivity [dir]` | Reactive leaks, state management audit |
| `/btrs-audit-endpoints [dir]` | REST, WebSocket, API audit |
| `/btrs-audit-components [dir]` | Atomic Design, component reuse audit |
| `/btrs-scan-tech-debt [categories] [dir]` | Full codebase tech debt scan |

### Tracking & Execution

| Command | Purpose |
|---------|---------|
| `/btrs-add-tech-debt ["title"]` | Add a tech debt item |
| `/btrs-do-tech-debt [id\|list\|next]` | Work on a tech debt item |
| `/btrs-add-todo ["title"]` | Add a todo item |
| `/btrs-do-todo [id\|list\|next]` | Work on a todo item |

### Knowledge Capture

| Command | Purpose |
|---------|---------|
| `/btrs-capture` | Quick context/knowledge capture → structured note |
| `/btrs-release-notes <old> <new>` | 3 release docs: customer, engineering, tech debt |

### Documentation

| Command | Purpose |
|---------|---------|
| `/btrs-doc-component [path]` | Generate component docs from source code |
| `/btrs-doc-api [path]` | Generate API reference from endpoint code |
| `/btrs-doc-page` | Conversational doc writing (guides, tutorials, runbooks) |

### Implementation

| Command | Purpose |
|---------|---------|
| `/btrs-implement [id\|spec\|description]` | Write code from spec, todo, tech debt, or description |
| `/btrs-scaffold-component [name]` | Component scaffolding (Atomic Design, framework-aware) |
| `/btrs-scaffold-endpoint [path]` | Endpoint scaffolding (framework-aware) |
| `/btrs-fix-bug [id\|description]` | Root cause investigation and fix |
| `/btrs-refactor [type]` | Guided refactoring (extract, simplify, consolidate, restructure, modernize, types) |

### Design

| Command | Purpose |
|---------|---------|
| `/btrs-design-component [name]` | Component design → spec (props, states, variants, a11y) |
| `/btrs-design-page [name]` | Page layout design → spec (component tree, data flow, responsive) |
| `/btrs-design-system` | Design system audit (tokens, components, patterns, gaps) |

### DevOps

| Command | Purpose |
|---------|---------|
| `/btrs-scaffold-pipeline [platform]` | Generate CI/CD pipeline config (GitHub Actions, GitLab CI, etc.) |
| `/btrs-scaffold-docker [service]` | Generate Dockerfile, docker-compose, .dockerignore |
| `/btrs-deploy [target]` | Deploy to configured target (Vercel, Fly.io, Docker, K8s) |
| `/btrs-audit-infra [scope]` | Audit Docker, CI/CD, K8s, deploy scripts, env config |
| `/btrs-scaffold-release [major\|minor\|patch]` | Version bump, changelog, git tag, deploy trigger |

### Navigation

| Command | Purpose |
|---------|---------|
| `/btrs-next [area]` | Suggest what to work on next, ranked by priority/effort/age |

## Agents

| Agent | Role | Skills |
|-------|------|--------|
| `btrs-planner` | Thinking partner | think-through, create-adr, plan-feature, plan-api |
| `btrs-reviewer` | Code quality | review-mr, 4 audits, scan-tech-debt |
| `btrs-developer` | Implementation | implement, scaffold-component, scaffold-endpoint, fix-bug, refactor |
| `btrs-designer` | Design | design-component, design-page, design-system |
| `btrs-documenter` | Documentation | doc-component, doc-api, doc-page, release-notes |
| `btrs-executor` | Execution | do/add-tech-debt, do/add-todo, capture |
| `btrs-navigator` | Navigation | btrs-next |
| `btrs-devops` | DevOps | scaffold-pipeline, scaffold-docker, deploy, audit-infra, scaffold-release |

## Installation

### Option 1: Claude Code plugin (recommended)

In Claude Code, run:
```
/plugin marketplace add brandonbuttars/btrs-toolkit
/plugin install btrs-toolkit@brandonbuttars-btrs-toolkit
```

### Option 2: Install script

```bash
git clone git@github.com:brandonbuttars/btrs-toolkit.git ~/btrs-toolkit
cd ~/btrs-toolkit
./install.sh
```

This symlinks all 36 skills, 10 shared references, and 8 agents into `~/.claude/`. Run `./uninstall.sh` to remove.

## Quick Start

```bash
cd ~/projects/my-app

# Initialize (once per project)
/btrs-init-project

# Review your branch
/btrs-review-mr

# Plan a feature
/btrs-plan-feature

# Scan for tech debt
/btrs-scan-tech-debt

# See what to work on next
/btrs-next

# Design a component
/btrs-design-component

# Generate docs
/btrs-doc-component src/components/Button.svelte
```

## Configuration

`.btrs-config.json` at project root (created by `/btrs-init-project`):

```json
{
  "version": "1.0.0",
  "basedir": ".local",
  "created": "2025-03-14"
}
```

The `basedir` controls where all generated documents live. Default is `.local`. All skills read this config automatically — no hardcoded paths.

Skills also auto-detect your project's patterns: frameworks, component libraries, styling systems, TypeScript, testing tools, commit conventions, and more.

## Output Structure

```
your-project/
├── .btrs-config.json              # Config (basedir, version)
├── .obsidian/                     # Vault config (gitignored)
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
│   ├── notes/                     # Knowledge capture, research, meetings
│   └── templates/                 # All 11 Obsidian templates
└── src/                           # Source code (wikilinked from docs)
```

## Obsidian Integration

The project root is an Obsidian vault. Documents use:

- **YAML frontmatter** — Searchable properties on every document
- **Wikilinks to source files** — `[[src/components/Button.svelte]]` is clickable
- **Wikilinks between documents** — Tech debt, reviews, specs, and releases cross-reference each other
- **Callouts** — `> [!warning]`, `> [!danger]`, `> [!tip]` for visual severity
- **Hierarchical tags** — `priority/high`, `area/css`, `effort/small`, `risk/medium`

### Templates (11)

| Template | Use for |
|----------|---------|
| `tech-debt-item.md` | Manual tech debt entry |
| `quick-review-note.md` | Informal review notes |
| `adr.md` | Architecture Decision Records (MADR) |
| `bug-report.md` | Structured bug reports |
| `feature-spec.md` | Feature specifications |
| `todo.md` | General-purpose todo |
| `meeting-note.md` | Meeting notes + action items |
| `research-note.md` | Research findings |
| `design-decision.md` | UI/UX design decisions (lighter than ADR) |
| `retrospective.md` | Sprint retros |
| `iteration-plan.md` | Sprint/iteration planning |

## Examples

See `examples/` for sample output demonstrating every document type.

## License

MIT
