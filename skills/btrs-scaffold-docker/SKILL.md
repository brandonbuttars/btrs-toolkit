---
name: btrs-scaffold-docker
description: >
  Generate Dockerfile, docker-compose.yml, and .dockerignore for the current project.
  Detects framework and produces multi-stage builds with security best practices.
  Trigger on phrases like "add Docker", "create Dockerfile", "dockerize",
  "scaffold docker", "add docker-compose", "containerize this project".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(test *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: "[service-name]"
---

# Buttars Scaffold Docker Skill

Generate production-ready Docker configuration for the current project.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Read `.btrs-config.json` from the project root. Use the configured `basedir` (default `.local`) for all output paths.

## Step 1: Check existing Docker config

```bash
test -f Dockerfile
test -f docker-compose.yml || test -f docker-compose.yaml || test -f compose.yml || test -f compose.yaml
test -f .dockerignore
```

If any exist, read them and ask the user if they want to extend or replace.

## Step 2: Detect project type

Scan the project to determine the application type:

**Web frameworks (Node.js):**
- SvelteKit → Node adapter or static adapter
- Next.js → Standalone output mode
- Nuxt → Nitro server
- Express/Fastify → Direct Node server
- Astro → SSR or static

**Other runtimes:**
- Go → Static binary build
- Rust → Static binary build
- Python (Django/Flask/FastAPI) → Gunicorn/Uvicorn
- Ruby (Rails) → Puma

**Static sites:**
- Vite/CRA → Nginx serving build output

**Database/services:**
- PostgreSQL config → Add postgres service
- Redis config → Add redis service
- MongoDB config → Add mongo service

Detect package manager (pnpm/yarn/npm/bun) for install commands.

Check for `.env.example` or `.env.template` for environment variables.

## Step 3: Ask user about requirements

Present the detected setup and ask:
- **Service name** (default: directory name)
- **Exposed port** (detect from framework config or default)
- **Additional services** (database, cache, queue — based on detection)
- **Development compose** — Include dev profile with hot reload?
- **Health check** — Include health check endpoint?

## Step 4: Generate Dockerfile

Generate a multi-stage Dockerfile following best practices:

### Stage patterns

**Node.js apps:**
```
Stage 1: deps — Install dependencies only (cached layer)
Stage 2: build — Copy source, build
Stage 3: runtime — Copy build output, minimal image
```

**Go/Rust apps:**
```
Stage 1: build — Compile static binary
Stage 2: runtime — Scratch or distroless, copy binary
```

**Python apps:**
```
Stage 1: deps — Install requirements
Stage 2: runtime — Copy venv and source
```

### Security best practices

- Use specific image tags, not `latest`
- Run as non-root user (`USER node`, `USER app`)
- Don't copy `.env` files, secrets, or `node_modules`
- Use `COPY --chown` to set file ownership
- Minimize layer count in final stage
- Set `NODE_ENV=production` for Node.js
- Use `dumb-init` or `tini` for signal handling if needed

### Performance best practices

- Order COPY commands for optimal caching (package files first, then source)
- Use `.dockerignore` to exclude unnecessary files
- Use `--mount=type=cache` for package manager caches where supported
- Multi-stage to keep final image small

## Step 5: Generate .dockerignore

Generate `.dockerignore` based on project detection:

```
node_modules
.git
.gitignore
*.md
.env*
.local/
.obsidian/
dist/
build/
.svelte-kit/
.next/
coverage/
*.log
.DS_Store
Dockerfile
docker-compose*.yml
```

Adapt based on actual project structure.

## Step 6: Generate docker-compose.yml

If the user wants compose, generate `docker-compose.yml`:

- **App service** with build context, ports, environment, volumes
- **Database service** if detected (with named volume for data persistence)
- **Cache service** if detected
- **Networks** for service isolation
- **Dev profile** with source mounting and hot reload if requested
- **Health checks** on services

Use compose file version `3.8` or later.

Include comments explaining each section.

## Step 7: Write files and document

Write all generated files to the project root.

Create a note at `<basedir>/notes/docker-setup-YYYY-MM-DD.md`:

```markdown
---
title: "Docker Setup"
date: YYYY-MM-DD
type: note
category: context
tags:
  - note
  - note/context
  - area/infra
---

# Docker Setup

**Base image:** <image>
**Final image size:** ~<estimated-size>
**Services:** <list>

## Files created

- `Dockerfile` — Multi-stage build (<stage-count> stages)
- `docker-compose.yml` — <service-count> services
- `.dockerignore` — <entry-count> exclusion patterns

## Usage

```bash
# Build
docker compose build

# Run
docker compose up -d

# Dev mode (if dev profile included)
docker compose --profile dev up

# View logs
docker compose logs -f <service>
```

## Environment variables

| Variable | Purpose | Default |
|----------|---------|---------|
| | | |
```

Tell the user what was created and how to run it.
