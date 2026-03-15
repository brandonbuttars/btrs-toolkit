---
name: btrs-scaffold-release
description: >
  Automate release workflow — version bump, changelog generation, git tag, and
  deploy trigger. Supports semver, conventional commits, and monorepo versioning.
  Trigger on phrases like "create release", "bump version", "tag release",
  "prepare release", "cut a release", "release workflow", "automate releases".
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(test *), Bash(ls *), Bash(cat *), Bash(npm *), Bash(pnpm *), Bash(yarn *), Read, Write, Edit, Grep, Glob
argument-hint: "[major|minor|patch|version]"
---

# Buttars Scaffold Release Skill

Automate the release process — version bump, changelog, tagging, and deploy trigger.

## Step 0: Read config

Read the shared config reference:
```
~/.claude/skills/shared/config.md
```

Read `.btrs-config.json` from the project root. Use the configured `basedir` (default `.local`) for all output paths.

## Step 1: Detect current version and release setup

**Find current version:**
```bash
# package.json
grep '"version"' package.json 2>/dev/null

# Cargo.toml
grep '^version' Cargo.toml 2>/dev/null

# pyproject.toml
grep '^version' pyproject.toml 2>/dev/null

# Go — check git tags
git tag --sort=-v:refname | head -5
```

**Check for existing release tooling:**
```bash
# Changesets
test -d .changeset

# Semantic Release
grep "semantic-release" package.json 2>/dev/null

# Release-it
grep "release-it" package.json 2>/dev/null

# Standard Version / Conventional Changelog
grep "standard-version\|conventional-changelog" package.json 2>/dev/null

# Release scripts
grep '"release\|"publish\|"version' package.json 2>/dev/null
```

**Check commit conventions:**
```bash
# Sample recent commits
git log --oneline -20

# Conventional commits?
git log --oneline -20 | grep -cE '^[a-f0-9]+ (feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert)(\(.+\))?:'
```

If existing release tooling is found, tell the user and ask if they want to use it or set up something new.

## Step 2: Determine release type

If the user provided a version argument:
- `major`, `minor`, `patch` → Calculate next version from current
- Specific version (e.g., `2.0.0`) → Use as-is

If no argument:
- Analyze commits since last tag to suggest the version bump
- If using conventional commits: `feat` → minor, `fix` → patch, breaking change (`!` or `BREAKING CHANGE`) → major
- Present suggestion and ask user to confirm

Show:
```
Current version: X.Y.Z
Commits since last release: <count>
  - <count> feat (features)
  - <count> fix (bug fixes)
  - <count> other
  - <count> breaking changes
Suggested bump: <major|minor|patch> → X.Y.Z
```

## Step 3: Generate changelog entries

Analyze commits since the last tag and generate changelog entries.

**If using conventional commits:**
Group by type:
- **Added** — `feat:` commits
- **Fixed** — `fix:` commits
- **Changed** — `refactor:`, `perf:` commits
- **Breaking Changes** — Commits with `!` or `BREAKING CHANGE` footer

**If not using conventional commits:**
- Use commit messages as-is
- Group by detected intent (feature, fix, chore, docs)
- Prefer MR/PR titles from merge commits

Format as Keep a Changelog entries.

## Step 4: Update version files

**Ask user before making changes.** Present what will be modified:

**package.json:**
```bash
# Update version field
```

**CHANGELOG.md:**
- If exists, insert new version section at top (after header)
- If doesn't exist, create with full history or just this release

**Cargo.toml / pyproject.toml / other:**
- Update version field

**Lock files:**
- Run package manager install to update lock file after version bump
- `pnpm install --lockfile-only` / `npm install --package-lock-only` / `yarn install`

## Step 5: Offer to generate release notes

Ask the user if they also want full release notes via `/btrs-release-notes`:
- This generates the 3-doc set (customer, engineering, tech debt)
- Separate from the CHANGELOG entry, which is more concise

## Step 6: Create git tag

**Ask user before creating the tag.** Present what will happen:

```
The following changes will be committed and tagged:
- package.json (version → X.Y.Z)
- CHANGELOG.md (new entry)
- <any other modified files>

Tag: vX.Y.Z
Message: "Release vX.Y.Z"
```

Wait for explicit confirmation, then:

```bash
git add <modified-files>
git commit -m "chore: release vX.Y.Z"
git tag -a "vX.Y.Z" -m "Release vX.Y.Z"
```

## Step 7: Push and trigger deploy

**Ask user before pushing.** Explain what will happen:

- Push commit and tag to remote
- If CI/CD is configured, this may trigger a deploy

```bash
git push origin <branch>
git push origin "vX.Y.Z"
```

If a deploy pipeline exists, tell the user:
- What pipeline will be triggered
- How to monitor it
- Expected timeline

## Step 8: Document the release

Create a note at `<basedir>/notes/release-vX.Y.Z-YYYY-MM-DD.md`:

```markdown
---
title: "Release vX.Y.Z"
date: YYYY-MM-DD
type: note
category: context
tags:
  - note
  - note/context
  - area/infra
---

# Release vX.Y.Z

**Date:** YYYY-MM-DD
**Previous version:** <prev>
**Commits:** <count>

## Changes

<changelog entries>

## Deploy status

- [ ] Tag pushed
- [ ] Pipeline triggered
- [ ] Deployed to staging
- [ ] Deployed to production
- [ ] Verified in production
```

Report to the user:
- New version number
- Tag name
- What was committed/pushed
- What to do next (monitor deploy, verify, announce)
