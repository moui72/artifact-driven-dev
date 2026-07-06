#!/usr/bin/env sh
# Migration 0001: Add diagram_stale frontmatter to renderable artifacts.
# Idempotent — skips artifacts that already have the field.

TARGET="${1:-.}"
ARTIFACTS_DIR="$TARGET/.project/artifacts"

for name in datamodel infrastructure ui; do
  file="$ARTIFACTS_DIR/$name.md"
  if [ ! -f "$file" ]; then
    continue
  fi
  if grep -q "^diagram_stale:" "$file"; then
    continue
  fi
  # Insert diagram_stale: false after the last_updated line
  sed -i.arddbak '/^last_updated:/a\
diagram_stale: false' "$file" && rm -f "$file.arddbak"
  echo "  ✓ added diagram_stale to $name.md"
done
