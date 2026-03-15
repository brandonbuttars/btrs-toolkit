# Infrastructure Audit Reference

Shared guidance for auditing infrastructure configuration. Referenced by `btrs-audit-infra`, `btrs-review-mr`, and `btrs-scan-tech-debt`.

## Dockerfile Analysis

### Security patterns to flag

- `FROM <image>` without version tag or using `:latest`
- `USER root` in final stage (or no `USER` directive)
- `COPY . .` without `.dockerignore` (may copy secrets)
- `ENV` with secret values (passwords, tokens, API keys)
- `apt-get install` without `--no-install-recommends`
- `curl | bash` pattern in RUN commands
- Exposed ports for admin/debug interfaces (9229, 5432, etc.)
- `ADD` with remote URLs (use COPY + explicit download)
- `chmod 777` or overly permissive file modes
- Package manager caches not cleaned (`apt-get clean`, `rm -rf /var/lib/apt/lists/*`)

### Performance patterns to flag

- Not using multi-stage builds when applicable
- Package files (package.json) not copied before source (breaks cache)
- `npm install` instead of `npm ci` in production builds
- Dev dependencies included in production image (`--production` or `--omit=dev` missing)
- Large base images when slim/alpine/distroless would work
- Multiple `RUN apt-get` commands (should be combined)
- No `.dockerignore` or incomplete one

### Reliability patterns to flag

- No `HEALTHCHECK` directive
- No signal handling for PID 1 (no `tini` / `dumb-init`, not using `exec` form of CMD)
- `CMD` using shell form instead of exec form
- No `WORKDIR` set
- `EXPOSE` missing for service ports

## CI/CD Analysis

### Security patterns to flag

- Secrets hardcoded (API keys, passwords, tokens in config)
- GitHub Actions: unpinned actions (`uses: actions/checkout@v4` instead of SHA)
- GitHub Actions: `pull_request_target` with checkout of PR code
- GitHub Actions: `permissions: write-all` or overly broad permissions
- Secrets passed as command arguments (visible in logs)
- Artifact uploads that may include secrets
- Deploy without approval gates or environment protection

### Performance patterns to flag

- No dependency caching configured
- No concurrency control (old runs not cancelled on new push)
- Sequential jobs that could run in parallel
- Full checkout when shallow would suffice (`fetch-depth: 0` without need)
- Rebuilding dependencies in every job instead of sharing via artifacts/cache

### Reliability patterns to flag

- No timeout configured on jobs
- No `fail-fast` on matrix builds (when appropriate)
- No retry on known-flaky steps (npm install, network calls)
- Missing error handling in script steps
- No notification on failure
- Deploy steps without rollback procedure

### Completeness checks

- Lint step present?
- Type check step present?
- Unit tests present?
- Integration/E2E tests present?
- Security scan (dependency audit, SAST)?
- Build step validates successfully?
- Deploy only from protected branches?

## Kubernetes Analysis

### Security patterns to flag

- `runAsRoot: true` or missing `securityContext`
- `privileged: true` on containers
- No `NetworkPolicy` (all pods can talk to all pods)
- Secrets in plain YAML (should use sealed secrets, external secrets, or vault)
- No RBAC configured (default service account with cluster-admin)
- `hostNetwork: true` or `hostPID: true` without justification
- Images pulled from untrusted registries
- No `readOnlyRootFilesystem`

### Reliability patterns to flag

- No resource requests/limits (`resources.requests`, `resources.limits`)
- No liveness probe (`livenessProbe`)
- No readiness probe (`readinessProbe`)
- Single replica for production workloads
- No `PodDisruptionBudget`
- No `topologySpreadConstraints` or `podAntiAffinity` for HA
- `restartPolicy: Never` on long-running services
- No `terminationGracePeriodSeconds` tuning

### Configuration patterns to flag

- Hardcoded values that should be in ConfigMap
- No namespace (deploying to `default`)
- Missing labels and selectors
- No `imagePullPolicy` or using `Always` unnecessarily
- Deployment without `strategy` (rolling update) configuration

## Deploy Script Analysis

### Security patterns to flag

- Passwords/tokens as script variables or arguments
- `ssh -o StrictHostKeyChecking=no`
- Secrets visible in `ps` output (passed as command args)
- No file permission checks
- Remote commands run as root

### Reliability patterns to flag

- No `set -euo pipefail` at script start
- No rollback procedure on failure
- No health check after deploy
- No lock mechanism (concurrent deploys possible)
- No logging of deploy actions
- Assumptions about remote state (directory exists, service running)

## Environment Configuration Analysis

### Security patterns to flag

- `.env` files committed to git (check `git ls-files`)
- `.env` not in `.gitignore`
- Production secrets in development config
- Secrets with default/example values that look real
- Database URLs with credentials in plain text

### Completeness checks

- `.env.example` exists and is up to date?
- All variables referenced in code have corresponding `.env.example` entries?
- Different environments have appropriate variable sets?
- Sensitive variables clearly marked or in separate secret management?
