#!/usr/bin/env sh
# Regression test for migrations/0005-artifact-diagram-type.sh: inserts
# diagram_type + render_section into the historically-renderable artifacts
# (datamodel/infrastructure/ui) that lack diagram_type, leaves an artifact
# that already declares diagram_type untouched, and skips an absent artifact.
# Idempotent.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MIG="$(dirname "$SCRIPT_DIR")/migrations/0005-artifact-diagram-type.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_grep() { if grep -q "$2" "$3"; then ok "$1"; else bad "$1 — pattern '$2' not in $3"; fi }

mkdir -p "$WORK/t/.project/artifacts"

# datamodel: lacks diagram_type -> should be added
cat > "$WORK/t/.project/artifacts/datamodel.md" <<'EOF'
---
name: datamodel
status: stable
last_updated: 2026-01-01
diagram_status: current
---

# Data Model
EOF

# infrastructure: already declares diagram_type -> must be left untouched
cat > "$WORK/t/.project/artifacts/infrastructure.md" <<'EOF'
---
name: infrastructure
status: stable
last_updated: 2026-01-01
diagram_status: current
diagram_type: flowchart LR
render_section: Infra
---

# Infrastructure
EOF

# ui: absent entirely

sh "$MIG" "$WORK/t" > "$WORK/out1.txt"

D="$WORK/t/.project/artifacts/datamodel.md"
assert_grep "datamodel: diagram_type added" "^diagram_type: erDiagram" "$D"
assert_grep "datamodel: render_section added" "^render_section: Datamodel" "$D"

I="$WORK/t/.project/artifacts/infrastructure.md"
assert_grep "infrastructure: existing diagram_type preserved" "^diagram_type: flowchart LR" "$I"
assert_grep "infrastructure: existing render_section preserved" "^render_section: Infra" "$I"
if grep -q "^diagram_type: graph TD" "$I"; then
  bad "infrastructure: existing diagram_type must not be overwritten"
else
  ok "infrastructure: not overwritten with the template default"
fi

# absent ui: no file created, no error
[ ! -f "$WORK/t/.project/artifacts/ui.md" ] && ok "absent artifact skipped" || bad "absent artifact skipped — ui.md created"

# idempotent: second run is silent and does not duplicate the field
sh "$MIG" "$WORK/t" > "$WORK/out2.txt"
[ -s "$WORK/out2.txt" ] && bad "re-run silent — got: $(cat "$WORK/out2.txt")" || ok "re-run is silent"
count="$(grep -c "^diagram_type:" "$D")"
[ "$count" -eq 1 ] && ok "datamodel: single diagram_type after re-run" || bad "datamodel: $count diagram_type lines after re-run"

# a project with an empty artifacts dir: no-op success
mkdir -p "$WORK/empty/.project/artifacts"
if sh "$MIG" "$WORK/empty" >/dev/null; then ok "no artifacts: no-op success"; else bad "no artifacts: no-op success"; fi

exit "$fail"
