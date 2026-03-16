# BTRS Config Reference

All skills read `.btrs-config.json` at the project root to resolve the base output directory. This avoids hardcoding `.local/` and lets each project customize the location.

## Config file format

```json
{
  "version": "1.0.0",
  "basedir": ".local"
}
```

## Reading the config (Step 0 pattern)

Every skill that writes output files must resolve the basedir before doing anything else. Use this pattern at the start of the skill:

```bash
# 1. Check for config file
if [ -f ".btrs-config.json" ]; then
  BASEDIR=$(cat .btrs-config.json | grep '"basedir"' | sed 's/.*"basedir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
else
  BASEDIR=".local"
fi

# 2. Auto-create the basedir if it doesn't exist
mkdir -p "$BASEDIR"
```

If the config file exists, read `basedir` from it. If not, fall back to `.local`.

If the basedir doesn't exist, create it automatically. Skills should also create any subdirectories they need (e.g., `mkdir -p <basedir>/releases`, `mkdir -p <basedir>/tech-debt`). No separate initialization step is required.

## Using basedir in skills

After resolving basedir, use `<basedir>/` in all output paths:

- `<basedir>/reviews/` — MR reviews, audit reports, scan reports
- `<basedir>/releases/` — Release documentation
- `<basedir>/tech-debt.md` — Tech debt master list
- `<basedir>/tech-debt/` — Tech debt detail files
- `<basedir>/todos.md` — Todo master list
- `<basedir>/todos/` — Todo detail files
- `<basedir>/decisions/` — ADRs
- `<basedir>/bugs/` — Bug reports
- `<basedir>/specs/` — Feature and API specs
- `<basedir>/docs/` — Generated documentation
- `<basedir>/notes/` — Knowledge capture, conversation summaries
- `<basedir>/templates/` — Obsidian templates

## In skill instructions

When writing a SKILL.md, reference this file and use `<basedir>` as a placeholder in all paths. The actual value comes from the config read at runtime.

Example Step 0:

```
## Step 0: Read config

Read the shared config reference:
\```
~/.claude/skills/shared/config.md
\```

Resolve the basedir from `.btrs-config.json` (default: `.local`). Create the basedir and any needed subdirectories if they don't exist.
```
