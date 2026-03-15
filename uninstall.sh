#!/usr/bin/env bash
set -euo pipefail

# Buttars Development Workflow System — Uninstaller
# Removes symlinks from ~/.claude/ (does not touch project files)

SKILLS_DIR="$HOME/.claude/skills"
AGENTS_DIR="$HOME/.claude/agents"

echo "Uninstalling Buttars Development Workflow System..."
echo ""

# Remove skill symlinks
SKILL_COUNT=0
for link in "$SKILLS_DIR"/btrs-*; do
  if [ -L "$link" ]; then
    rm "$link"
    SKILL_COUNT=$((SKILL_COUNT + 1))
  fi
done
echo "Skills:     $SKILL_COUNT removed"

# Remove shared reference symlink
if [ -L "$SKILLS_DIR/shared" ]; then
  rm "$SKILLS_DIR/shared"
  echo "Shared:     removed"
fi

# Remove agent symlinks
AGENT_COUNT=0
for link in "$AGENTS_DIR"/btrs-*; do
  if [ -L "$link" ]; then
    rm "$link"
    AGENT_COUNT=$((AGENT_COUNT + 1))
  fi
done
echo "Agents:     $AGENT_COUNT removed"

echo ""
echo "Done. Project files (.btrs-config.json, basedir contents) are untouched."
