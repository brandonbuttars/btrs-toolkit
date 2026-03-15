---
name: btrs-scaffold-pipeline
description: >
  Generate CI/CD pipeline configuration for the current project. Detects platform
  (GitHub Actions, GitLab CI, Bitbucket Pipelines), framework, and test setup to
  produce build/test/deploy stages. Trigger on phrases like "set up CI",
  "add pipeline", "create GitHub Actions", "scaffold CI/CD", "add deploy pipeline",
  "set up continuous integration".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(test *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: "[platform]"
---

# Buttars Scaffold Pipeline Skill

Generate CI/CD pipeline configuration tailored to the current project's stack and hosting.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Read `.btrs-config.json` from the project root. Use the configured `basedir` (default `.local`) for all output paths.

## Step 1: Detect platform and existing config

Check for existing CI/CD configuration:

```bash
# GitHub Actions
test -d .github/workflows && ls .github/workflows/

# GitLab CI
test -f .gitlab-ci.yml

# Bitbucket Pipelines
test -f bitbucket-pipelines.yml

# CircleCI
test -d .circleci

# Jenkins
test -f Jenkinsfile

# Azure DevOps
test -f azure-pipelines.yml
```

If the user provided a platform argument, use that. Otherwise:
- If existing config found, ask if they want to extend or replace it
- If no config found, ask which platform they use (default to GitHub Actions)

## Step 2: Detect project stack

Scan the project to determine:

**Package manager:**
- `pnpm-lock.yaml` → pnpm
- `yarn.lock` → yarn
- `package-lock.json` → npm
- `bun.lockb` → bun

**Framework:**
- `svelte.config.js/ts` → SvelteKit
- `next.config.*` → Next.js
- `nuxt.config.*` → Nuxt
- `astro.config.*` → Astro
- `vite.config.*` → Vite
- `angular.json` → Angular
- `Cargo.toml` → Rust
- `go.mod` → Go
- `requirements.txt` / `pyproject.toml` → Python

**Testing:**
- `vitest.config.*` → Vitest
- `jest.config.*` → Jest
- `playwright.config.*` → Playwright
- `cypress.config.*` → Cypress

**Containerization:**
- `Dockerfile` → Docker build stage available
- `docker-compose*.yml` → Compose available

**Deployment target** (check for config files):
- `vercel.json` or `.vercel/` → Vercel
- `netlify.toml` → Netlify
- `fly.toml` → Fly.io
- `render.yaml` → Render
- `Procfile` → Heroku
- `app.yaml` → Google Cloud
- Kubernetes manifests (`k8s/`, `deploy/`, `*.k8s.yml`)
- `serverless.yml` → Serverless Framework

Also read `<basedir>/tech-stack.md` if it exists for additional context.

## Step 3: Determine pipeline stages

Based on detection, propose pipeline stages. Present to the user for confirmation:

**Standard stages:**
1. **Install** — Dependencies with caching
2. **Lint** — ESLint, Prettier, type checking
3. **Test** — Unit tests, integration tests
4. **Build** — Production build
5. **Deploy** — To detected/configured target

**Optional stages** (ask user):
- **E2E tests** — If Playwright/Cypress detected
- **Security scan** — Dependency audit, SAST
- **Docker build** — If Dockerfile exists
- **Preview deploys** — For PRs/MRs
- **Release** — Version bump, changelog, tag

Ask the user:
- Which stages to include
- Which branches trigger deploys (default: `main`)
- Whether PRs should get preview deploys
- Any secrets/env vars needed (list names only, never values)

## Step 4: Generate pipeline config

Generate the pipeline configuration file(s) for the chosen platform.

### GitHub Actions patterns

- Use `actions/checkout@v4`, `actions/setup-node@v4` (or equivalent)
- Cache dependencies with the appropriate action
- Use `concurrency` to cancel superseded runs
- Use environment protection for production deploys
- Use `needs` for stage dependencies
- Pin action versions to full SHA for security

### GitLab CI patterns

- Use `stages` for pipeline structure
- Cache `node_modules` or equivalent with key
- Use `rules` instead of `only/except`
- Use `extends` for shared job config
- Use `environment` for deploy tracking

### General patterns (all platforms)

- **Caching:** Cache package manager store, not `node_modules`
- **Node version:** Read from `.nvmrc`, `package.json engines`, or `.node-version` if present
- **Fail fast:** Run lint and type check before tests
- **Parallelism:** Run independent jobs concurrently
- **Artifacts:** Upload test results and coverage reports
- **Secrets:** Reference by name, add comments for what needs to be configured

## Step 5: Generate supporting files

If needed, also generate:

- `.nvmrc` or `.node-version` if not present and Node.js detected
- `Makefile` or `justfile` with matching commands (if user wants local parity)

## Step 6: Write files and document

Write the pipeline config file(s) to the appropriate location.

Create a note at `<basedir>/notes/pipeline-setup-YYYY-MM-DD.md`:

```markdown
---
title: "CI/CD Pipeline Setup"
date: YYYY-MM-DD
type: note
category: context
tags:
  - note
  - note/context
  - area/infra
---

# CI/CD Pipeline Setup

**Platform:** <platform>
**Stages:** <list>
**Deploy target:** <target>
**Trigger branches:** <branches>

## Configuration files

- `<path-to-pipeline-config>`

## Secrets to configure

| Secret | Purpose | Where to set |
|--------|---------|-------------|
| | | |

## Manual steps

<!-- Any manual setup needed in the CI platform -->
```

Tell the user:
- What files were created
- What secrets need to be configured in the CI platform (names only)
- Any manual steps needed (enabling pipelines, connecting deploy targets)
