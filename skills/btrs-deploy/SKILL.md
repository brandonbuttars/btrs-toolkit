---
name: btrs-deploy
description: >
  Guide and execute deployment to a configured target. Supports web apps (Vercel,
  Netlify, Fly.io, Docker, K8s), static sites, and self-hosted Docker deployments.
  Generates deploy scripts, validates config, and documents the process.
  Trigger on phrases like "deploy this", "set up deployment", "deploy to production",
  "configure hosting", "push to staging", "deploy guide".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(test *), Bash(ls *), Bash(cat *), Bash(docker *), Bash(fly *), Bash(vercel *), Bash(netlify *), Bash(kubectl *), Bash(ssh *), Bash(scp *), Bash(rsync *), Read, Write, Grep, Glob
argument-hint: "[target]"
---

# Buttars Deploy Skill

Guide deployment setup and execution for the current project.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Read `.btrs-config.json` from the project root. Use the configured `basedir` (default `.local`) for all output paths.

## Step 1: Detect current deploy configuration

Check for existing deploy configs:

```bash
# Platform configs
test -f vercel.json
test -f netlify.toml
test -f fly.toml
test -f render.yaml
test -f Procfile
test -f app.yaml
test -f serverless.yml

# Container configs
test -f Dockerfile
test -f docker-compose.yml || test -f compose.yml

# Kubernetes
ls k8s/ deploy/ kubernetes/ 2>/dev/null
ls *.k8s.yml *.k8s.yaml 2>/dev/null

# Self-hosted
test -f deploy.sh
test -d .deploy/
```

Also check for deploy-related scripts in `package.json`:
```bash
grep -E '"deploy|"release|"publish' package.json 2>/dev/null
```

## Step 2: Determine deploy target

If the user provided a target argument, use that. Otherwise:

**If existing config found:** Confirm the detected target with the user.

**If no config found:** Ask the user their target:

| Target | Best for |
|--------|----------|
| **Vercel** | Next.js, SvelteKit (adapter-vercel), static sites |
| **Netlify** | Static sites, serverless functions |
| **Fly.io** | Docker-based apps, self-hosted alternative |
| **Docker (self-hosted)** | VPS, on-prem, full control |
| **Kubernetes** | Scaled deployments, multiple services |
| **Static hosting** | S3, CloudFront, GitHub Pages |

Ask about:
- **Environments** — production only, or staging + production?
- **Domain** — custom domain configured?
- **Secrets/env vars** — what needs to be set? (names only)

## Step 3: Validate prerequisites

Before proceeding, check that prerequisites are met:

**For Vercel/Netlify:**
- CLI installed (`vercel --version`, `netlify --version`)
- Project linked or ready to link
- Framework adapter installed (e.g., `@sveltejs/adapter-vercel`)

**For Fly.io:**
- CLI installed (`fly version`)
- Authenticated (`fly auth whoami`)
- App created or ready to create

**For Docker (self-hosted):**
- Dockerfile exists (suggest `/btrs-scaffold-docker` if not)
- Remote host accessible
- Docker/compose available on remote

**For Kubernetes:**
- `kubectl` configured
- Cluster context set
- Namespace exists or will be created

Report any missing prerequisites and offer to help fix them.

## Step 4: Generate deploy configuration

Based on the target, generate or update the necessary configuration:

### Vercel
- `vercel.json` with build settings, rewrites, headers, env vars
- Framework-specific adapter config

### Netlify
- `netlify.toml` with build command, publish directory, redirects, headers

### Fly.io
- `fly.toml` with app name, region, services, health checks, scaling
- Ensure Dockerfile exists

### Docker (self-hosted)
Generate a deploy script (`deploy.sh` or `.deploy/deploy.sh`):
- Build and tag image
- Push to registry (or transfer directly)
- SSH to remote, pull image, restart service
- Health check after deploy
- Rollback on failure

### Kubernetes
Generate manifests in `k8s/` or `deploy/`:
- `deployment.yaml` — Pod spec, replicas, resource limits, health checks
- `service.yaml` — ClusterIP or LoadBalancer
- `ingress.yaml` — If external access needed
- `configmap.yaml` — Non-secret configuration
- `secret.yaml` — Template with placeholder values (never real secrets)
- `kustomization.yaml` — If using Kustomize for env overlays

## Step 5: Generate deploy documentation

Create a runbook at `<basedir>/docs/deploy-runbook.md`:

```markdown
---
title: "Deploy Runbook"
date: YYYY-MM-DD
type: doc
category: runbook
tags:
  - doc
  - doc/runbook
  - area/infra
---

# Deploy Runbook

**Target:** <platform>
**Environments:** <list>
**URL:** <production-url>

## Prerequisites

- [ ] <prerequisite-1>
- [ ] <prerequisite-2>

## Deploy to production

<step-by-step commands>

## Deploy to staging

<step-by-step commands — if applicable>

## Environment variables

| Variable | Purpose | Where to set |
|----------|---------|-------------|
| | | |

## Rollback

<rollback procedure>

## Monitoring

<how to check if deploy succeeded>

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| | | |
```

## Step 6: Offer to deploy

If the configuration is ready and the user wants to deploy now:

1. Confirm the target environment
2. Run a dry-run or preview if the platform supports it
3. Show what will happen
4. Wait for explicit confirmation before deploying
5. Execute the deploy
6. Verify with health check

**Never deploy to production without explicit user confirmation.**

Report the outcome:
- Deploy URL
- Any warnings or issues
- Next steps (DNS, monitoring, etc.)
