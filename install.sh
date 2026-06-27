#!/usr/bin/env sh
# Install artifact-driven-dev skills into a target project.
# Usage: ./install.sh [target-dir]
# Defaults to the current directory if no target is given.

set -e

TARGET="${1:-.}"
SKILLS_DIR="$(dirname "$0")/skills"
CLAUDE_SKILLS="$TARGET/.claude/skills"

if [ ! -d "$TARGET" ]; then
  echo "Error: target directory '$TARGET' does not exist." >&2
  exit 1
fi

echo "Installing artifact-driven-dev skills into $TARGET ..."

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  dest="$CLAUDE_SKILLS/$skill_name"
  mkdir -p "$dest"
  cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
  echo "  ✓ $skill_name"
done

echo ""
echo "Done. Next steps:"
echo "  1. Run /ardd-bootstrap in Claude Code to seed your project artifacts."
echo "  2. Run /ardd-analyze to check for cross-artifact issues."
echo "  3. Run /ardd-plan when artifacts are stable."
