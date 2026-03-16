#!/usr/bin/env bash
set -euo pipefail

# Buttars Development Workflow System — Uninstaller
# Removes symlinks from ~/.claude/ and optionally removes the toolkit clone

CLAUDE_DIR="$HOME/.claude"
TOOLKIT_DIR="$CLAUDE_DIR/btrs-toolkit"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"

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

# Offer to remove the toolkit clone
if [ -d "$TOOLKIT_DIR" ]; then
  read -rp "Remove $TOOLKIT_DIR? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm -rf "$TOOLKIT_DIR"
    echo "Toolkit removed."
  else
    echo "Toolkit kept at $TOOLKIT_DIR"
  fi
fi

echo ""
echo "Done. Project files (.btrs-config.json, basedir contents) are untouched."
