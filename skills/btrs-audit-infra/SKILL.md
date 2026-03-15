---
name: btrs-audit-infra
description: >
  Audit infrastructure configuration — Dockerfiles, CI/CD pipelines, Kubernetes
  manifests, deploy scripts, and environment config for security, performance,
  and reliability issues. Trigger on phrases like "audit infra", "review docker",
  "check CI config", "audit pipeline", "review deploy config", "infra review".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(test *), Bash(ls *), Read, Write, Grep, Glob
argument-hint: "[scope]"
---

# Buttars Audit Infra Skill

Audit infrastructure and deployment configuration for security, performance, reliability, and best practice issues.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Read `.btrs-config.json` from the project root. Use the configured `basedir` (default `.local`) for all output paths.

Read the shared infra audit reference:
```
~/.claude/skills/shared/audit-infra.md
```

## Step 1: Discover infrastructure files

Scan for all infrastructure-related files:

**Containerization:**
```bash
# Dockerfiles (may be in subdirs for monorepos)
find . -name "Dockerfile*" -not -path "*/node_modules/*" -not -path "*/.git/*"
find . -name "docker-compose*.yml" -o -name "compose*.yml" -not -path "*/node_modules/*"
find . -name ".dockerignore"
```

**CI/CD:**
```bash
ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null
test -f .gitlab-ci.yml
test -f bitbucket-pipelines.yml
test -f Jenkinsfile
test -f .circleci/config.yml
test -f azure-pipelines.yml
```

**Kubernetes / orchestration:**
```bash
find . -name "*.k8s.yml" -o -name "*.k8s.yaml" 2>/dev/null
ls k8s/ deploy/ kubernetes/ manifests/ 2>/dev/null
find . -name "kustomization.yaml" 2>/dev/null
find . -name "Chart.yaml" 2>/dev/null  # Helm
```

**Deploy configs:**
```bash
test -f vercel.json
test -f netlify.toml
test -f fly.toml
test -f render.yaml
test -f serverless.yml
test -f deploy.sh
ls .deploy/ 2>/dev/null
```

**Environment:**
```bash
find . -name ".env*" -not -path "*/node_modules/*" -not -path "*/.git/*"
find . -name "*.env" -not -path "*/node_modules/*"
```

If the user provided a scope argument, limit to that category (docker, ci, k8s, deploy, env).

## Step 2: Audit each category

Read every discovered file and analyze against the patterns in the shared audit-infra.md reference.

### Dockerfile Audit

Check for:
- **Security:** Running as root, using `latest` tag, copying secrets, exposed sensitive ports, `apt-get` without `--no-install-recommends`
- **Performance:** Layer ordering (dependencies before source), unnecessary files in image, no `.dockerignore`, redundant layers
- **Reliability:** No health check, no signal handling (PID 1 problem), missing `WORKDIR`
- **Size:** Not using multi-stage, unnecessary dev dependencies in final image, large base image when alpine/slim/distroless would work
- **Caching:** Package manager cache not leveraged, poor COPY ordering breaks cache

### CI/CD Audit

Check for:
- **Security:** Secrets in config (not references), unpinned action versions (use SHA), write permissions without need, `pull_request_target` misuse
- **Performance:** No dependency caching, no concurrency control, redundant jobs, missing `fail-fast`
- **Reliability:** No timeout on jobs, missing error handling, no retry on flaky steps
- **Completeness:** Missing lint, missing tests, no type check, no security scan
- **Branch protection:** Deploy without approval gates, no environment protection

### Kubernetes Audit

Check for:
- **Security:** Running as root, no `securityContext`, no `NetworkPolicy`, secrets in manifests (not sealed/external), no RBAC
- **Reliability:** No resource limits, no health checks (liveness/readiness), no PodDisruptionBudget, single replica for stateful services
- **Configuration:** Hardcoded values that should be configurable, no namespace, no labels/selectors

### Deploy Script Audit

Check for:
- **Security:** Passwords/tokens in scripts, insecure SSH options, secrets in command args (visible in ps)
- **Reliability:** No error handling (`set -e`), no rollback procedure, no health check after deploy, no lock to prevent concurrent deploys
- **Idempotency:** Commands that fail on re-run, state assumptions

### Environment Config Audit

Check for:
- **Security:** `.env` files committed to git, secrets without `.env.example` pattern, production secrets in dev config
- **Completeness:** `.env.example` out of date, missing variables between environments
- **Gitignore:** `.env` files properly gitignored

## Step 3: Compile findings

Organize findings by severity:

- **`[!danger]`** — Security vulnerabilities, exposed secrets, running as root in production
- **`[!warning]`** — Reliability risks, missing health checks, no rollback, unpinned versions
- **`[!tip]`** — Performance improvements, caching, image size, build speed
- **`[!info]`** — Best practice suggestions, conventions

## Step 4: Write audit report

Write the report to `<basedir>/reviews/infra-audit-YYYY-MM-DD.md`:

```markdown
---
title: "Infrastructure Audit"
date: YYYY-MM-DD
type: review
category: infra-audit
tags:
  - review
  - review/infra
  - area/infra
---

# Infrastructure Audit — YYYY-MM-DD

## Summary

| Category | Files | Critical | Warning | Info |
|----------|-------|----------|---------|------|
| Docker | <count> | <count> | <count> | <count> |
| CI/CD | <count> | <count> | <count> | <count> |
| Kubernetes | <count> | <count> | <count> | <count> |
| Deploy | <count> | <count> | <count> | <count> |
| Environment | <count> | <count> | <count> | <count> |

## Docker

### <finding-title>

> [!danger/warning/tip/info] <one-line summary>
>
> **File:** [[<path>]]
> **Line:** <line-number>
>
> <description of the issue>
>
> **Fix:**
> ```
> <suggested fix>
> ```

<!-- Repeat for each finding -->

## CI/CD

<!-- findings -->

## Kubernetes

<!-- findings -->

## Deploy Scripts

<!-- findings -->

## Environment

<!-- findings -->
```

## Step 5: Add tech debt items

For critical and warning findings, add items to the tech debt backlog.

Read the shared tech-debt-format reference:
```
~/.claude/skills/shared/tech-debt-format.md
```

Deduplicate against existing backlog entries before adding.

## Step 6: Report

Present a summary to the user:
- Total files audited
- Finding counts by severity
- Top 3 most critical issues to fix first
- Link to the full report
