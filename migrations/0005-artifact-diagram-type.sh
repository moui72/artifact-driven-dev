#!/usr/bin/env sh
# Migration 0005: give the historically-renderable artifacts a diagram_type
# (plus an explicit render_section) so they keep rendering after the closed
# render-config table was retired (Principle VII — delete the table, carry
# existing projects forward). /ardd-diagram now renders any artifact that
# declares diagram_type; before this migration datamodel/infrastructure/ui
# declared none and would silently stop rendering on upgrade.
#
# For each of the three that lacks diagram_type, insert the same values the
# standard templates now ship. Idempotent — skips an artifact that already
# declares diagram_type, or is absent.

TARGET="${1:-.}"
ARTIFACTS_DIR="$TARGET/.project/artifacts"

type_for() {
  case "$1" in
    datamodel) echo "erDiagram" ;;
    infrastructure) echo "graph TD" ;;
    ui) echo "graph TD" ;;
  esac
}

section_for() {
  case "$1" in
    datamodel) echo "Datamodel" ;;
    infrastructure) echo "Infrastructure" ;;
    ui) echo "UI" ;;
  esac
}

for name in datamodel infrastructure ui; do
  file="$ARTIFACTS_DIR/$name.md"
  [ -f "$file" ] || continue
  grep -q "^diagram_type:" "$file" && continue

  dtype="$(type_for "$name")"
  dsection="$(section_for "$name")"

  # Insert after last_updated (present in every artifact's frontmatter).
  sed -i.arddbak "/^last_updated:/a\\
diagram_type: $dtype\\
render_section: $dsection" "$file" && rm -f "$file.arddbak"
  echo "  - $name.md -> diagram_type: $dtype, render_section: $dsection"
done
