#!/usr/bin/env bash
set -euo pipefail

# Buttars Development Workflow System — Installer
# Installs skills, agents, and shared references into ~/.claude/

TOOLKIT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"

echo "Installing Buttars Development Workflow System..."
echo "Source: $TOOLKIT_DIR"
echo ""

# Create directories
mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_DIR"

# Symlink all skills
SKILL_COUNT=0
for skill_dir in "$TOOLKIT_DIR"/skills/btrs-*/; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DIR/$skill_name"
  if [ -L "$target" ]; then
    rm "$target"
  fi
  if [ -d "$target" ]; then
    echo "  SKIP $skill_name (directory exists, not a symlink — remove manually to update)"
    continue
  fi
  ln -s "$skill_dir" "$target"
  SKILL_COUNT=$((SKILL_COUNT + 1))
done
echo "Skills:     $SKILL_COUNT linked"

# Symlink shared references
SHARED_TARGET="$SKILLS_DIR/shared"
if [ -L "$SHARED_TARGET" ]; then
  rm "$SHARED_TARGET"
fi
if [ ! -d "$SHARED_TARGET" ]; then
  ln -s "$TOOLKIT_DIR/skills/shared" "$SHARED_TARGET"
  echo "Shared:     linked"
else
  echo "Shared:     SKIP (directory exists, not a symlink)"
fi

# Symlink all agents
AGENT_COUNT=0
for agent_dir in "$TOOLKIT_DIR"/agents/btrs-*/; do
  agent_name="$(basename "$agent_dir")"
  target="$AGENTS_DIR/$agent_name"
  if [ -L "$target" ]; then
    rm "$target"
  fi
  if [ -d "$target" ]; then
    echo "  SKIP $agent_name (directory exists, not a symlink — remove manually to update)"
    continue
  fi
  ln -s "$agent_dir" "$target"
  AGENT_COUNT=$((AGENT_COUNT + 1))
done
echo "Agents:     $AGENT_COUNT linked"

echo ""
echo "Done. Run /btrs-init-project in any repo to get started."
