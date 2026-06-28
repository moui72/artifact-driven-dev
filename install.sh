#!/usr/bin/env sh
# Install or upgrade artifact-driven-dev skills into a target project.
# Usage: ./install.sh [target-dir]
# Defaults to the current directory if no target is given.
# Safe to re-run — skills are overwritten, migrations are applied once.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-.}"
SKILLS_DIR="$SCRIPT_DIR/skills"
MIGRATIONS_DIR="$SCRIPT_DIR/migrations"
CLAUDE_SKILLS="$TARGET/.claude/skills"
APPLIED_FILE="$TARGET/.ardd-applied"

if [ ! -d "$TARGET" ]; then
  echo "Error: target directory '$TARGET' does not exist." >&2
  exit 1
fi

# --- Skills ---
echo "Installing artifact-driven-dev skills into $TARGET ..."

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  dest="$CLAUDE_SKILLS/$skill_name"
  mkdir -p "$dest"
  cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
  echo "  ✓ $skill_name"
done

# --- Migrations ---
if [ -d "$MIGRATIONS_DIR" ]; then
  echo ""
  echo "Applying migrations ..."

  touch "$APPLIED_FILE"
  any_new=0

  for migration in "$MIGRATIONS_DIR"/*.sh; do
    [ -f "$migration" ] || continue
    migration_name="$(basename "$migration")"
    if grep -qxF "$migration_name" "$APPLIED_FILE"; then
      echo "  – $migration_name (already applied)"
    else
      sh "$migration" "$TARGET"
      echo "$migration_name" >> "$APPLIED_FILE"
      echo "  ✓ $migration_name"
      any_new=1
    fi
  done

  if [ "$any_new" -eq 0 ]; then
    echo "  (none pending)"
  fi
fi

echo ""
echo "Done. Next steps for a new project:"
echo "  1. Run /ardd-bootstrap in Claude Code to seed your project artifacts."
echo "  2. Run /ardd-analyze to check for cross-artifact issues."
echo "  3. Run /ardd-plan when artifacts are stable."
echo ""
echo "For an existing project, run /ardd-analyze to verify everything looks right."
