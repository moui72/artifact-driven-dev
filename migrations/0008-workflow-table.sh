#!/usr/bin/env sh
# Migration 0008: refresh the "## Skills" table in a target's existing
# .project/WORKFLOW.md from the shipped template, via upsert-section.sh —
# after the v1.0.0 renames/folds a consumer's WORKFLOW.md otherwise keeps
# a table of dead commands. Strict no-op when the target has no
# WORKFLOW.md (it never creates one — /ardd-init owns that). Idempotent:
# the body comes from the template, so re-runs rewrite the same text.
# Runs from the ARDD source checkout (like every migration), so the
# template and upsert-section.sh are addressed relative to this script.

TARGET="${1:-.}"
WF="$TARGET/.project/WORKFLOW.md"
[ -f "$WF" ] || exit 0

MIG_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_ROOT="$(dirname "$MIG_DIR")"
TEMPLATE="$SRC_ROOT/templates/WORKFLOW.md"
UPSERT="$SRC_ROOT/scripts/upsert-section.sh"

if [ ! -f "$TEMPLATE" ] || [ ! -f "$UPSERT" ]; then
  echo "  ! 0008: template or upsert-section.sh missing in source — skipped" >&2
  exit 0
fi

# Extract the Skills section body (without its header) from the template:
# lines after "## Skills" up to the next "## " heading, trimmed of leading
# and trailing blank lines (upsert-section.sh adds its own spacing).
awk '/^## Skills$/{f=1; next} f && /^## /{exit} f' "$TEMPLATE" \
  | awk 'NF{p=1} p' \
  | awk '{a[NR]=$0} END{n=NR; while(n>0 && a[n]=="") n--; for(i=1;i<=n;i++) print a[i]}' \
  | sh "$UPSERT" "$WF" "Skills"

echo "  ✓ refreshed .project/WORKFLOW.md skills table from the shipped template"
