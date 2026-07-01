#!/usr/bin/env sh
# Migration 0002: Replace boolean diagram_stale with tri-state diagram_status
# (unrendered / stale / current). The old boolean's "false" default conflated
# "diagram is up to date" with "diagram was never generated" — codify set
# diagram_stale: false on artifacts with no rendered diagram at all, which
# read as "current" when it actually meant "unrendered".
#
# Determines the correct value by checking whether the artifact's target
# README.md section actually exists:
#   - section missing            → unrendered (never actually rendered)
#   - section exists, was true   → stale
#   - section exists, was false  → current
# Idempotent — skips artifacts that already have diagram_status.

TARGET="${1:-.}"
ARTIFACTS_DIR="$TARGET/.project/artifacts"
README="$TARGET/README.md"

header_for() {
  case "$1" in
    datamodel) echo "## Datamodel" ;;
    infrastructure) echo "## Infrastructure" ;;
    ui) echo "## UI" ;;
  esac
}

for name in datamodel infrastructure ui; do
  file="$ARTIFACTS_DIR/$name.md"
  [ -f "$file" ] || continue
  grep -q "^diagram_status:" "$file" && continue

  header="$(header_for "$name")"
  rendered=false
  if [ -f "$README" ] && grep -qF "$header" "$README"; then
    rendered=true
  fi

  if [ "$rendered" = true ]; then
    if grep -q "^diagram_stale: *true" "$file"; then
      status=stale
    else
      status=current
    fi
  else
    status=unrendered
  fi

  if grep -q "^diagram_stale:" "$file"; then
    sed -i '' "s/^diagram_stale:.*/diagram_status: $status/" "$file"
  else
    sed -i '' "/^last_updated:/a\\
diagram_status: $status" "$file"
  fi
  echo "  - $name.md -> diagram_status: $status"
done
