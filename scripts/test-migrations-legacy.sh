#!/usr/bin/env sh
# Backfilled regression tests for migrations 0001-diagram-stale.sh and
# 0002-diagram-status.sh. Written 2026-07-06 for DEFECTS.md entry
# 58bd7dd2: both scripts used BSD-only `sed -i ''`, which fails under GNU
# sed — so before the portability fix this test is RED on ubuntu CI
# (macOS BSD sed masks it locally; no gsed shim assumed).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MIG_DIR="$(dirname "$SCRIPT_DIR")/migrations"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_grep() { if grep -q "$2" "$3"; then ok "$1"; else bad "$1 — pattern '$2' not in $3"; fi }

mkfix() { # mkfix <dir>  — a pre-0001 project with a rendered README section
  mkdir -p "$1/.project/artifacts"
  cat > "$1/.project/artifacts/datamodel.md" <<'EOF'
---
name: datamodel
status: stable
last_updated: 2026-01-01
---
# Datamodel
EOF
  printf '# T\n\n## Datamodel\n\nold diagram\n' > "$1/README.md"
}

# --- 0001: adds diagram_stale after last_updated; idempotent ---
mkfix "$WORK/a"
sh "$MIG_DIR/0001-diagram-stale.sh" "$WORK/a" >/dev/null
assert_grep "0001: diagram_stale added" "^diagram_stale: false" "$WORK/a/.project/artifacts/datamodel.md"
sh "$MIG_DIR/0001-diagram-stale.sh" "$WORK/a" >/dev/null
n="$(grep -c '^diagram_stale:' "$WORK/a/.project/artifacts/datamodel.md")"
[ "$n" = "1" ] && ok "0001: idempotent" || bad "0001: idempotent (count=$n)"
[ ! -f "$WORK/a/.project/artifacts/datamodel.md.bak" ] && ok "0001: no .bak litter" || bad "0001: no .bak litter"

# --- 0002: converts diagram_stale -> tri-state diagram_status ---
sh "$MIG_DIR/0002-diagram-status.sh" "$WORK/a" >/dev/null
assert_grep "0002: rendered+false -> current" "^diagram_status: current" "$WORK/a/.project/artifacts/datamodel.md"
grep -q '^diagram_stale:' "$WORK/a/.project/artifacts/datamodel.md" && bad "0002: old field removed" || ok "0002: old field removed"
[ ! -f "$WORK/a/.project/artifacts/datamodel.md.bak" ] && ok "0002: no .bak litter" || bad "0002: no .bak litter"

# --- 0002: unrendered (no README section) -> unrendered ---
mkfix "$WORK/b"
rm "$WORK/b/README.md"
sh "$MIG_DIR/0001-diagram-stale.sh" "$WORK/b" >/dev/null
sh "$MIG_DIR/0002-diagram-status.sh" "$WORK/b" >/dev/null
assert_grep "0002: no README -> unrendered" "^diagram_status: unrendered" "$WORK/b/.project/artifacts/datamodel.md"

# --- 0002: rendered + stale=true -> stale ---
mkfix "$WORK/c"
sh "$MIG_DIR/0001-diagram-stale.sh" "$WORK/c" >/dev/null
sed -i.bak 's/^diagram_stale: false/diagram_stale: true/' "$WORK/c/.project/artifacts/datamodel.md" && rm -f "$WORK/c/.project/artifacts/datamodel.md.bak"
sh "$MIG_DIR/0002-diagram-status.sh" "$WORK/c" >/dev/null
assert_grep "0002: rendered+true -> stale" "^diagram_status: stale" "$WORK/c/.project/artifacts/datamodel.md"

exit "$fail"
