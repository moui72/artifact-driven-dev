#!/usr/bin/env sh
# Regression test for upsert-section.sh: replaces the body of a "## <header>"
# section (from the header to the next "## " or EOF) with stdin, appends the
# section if absent, and never touches anything else.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UP="$SCRIPT_DIR/upsert-section.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

F="$WORK/README.md"
cat > "$F" <<'EOF'
# Title

Intro text.

## Datamodel

old diagram

## Infrastructure

infra body

## Usage

usage text
EOF

# --- replace a middle section ---
printf 'new diagram line 1\nnew diagram line 2\n' | sh "$UP" "$F" "Datamodel"
grep -q 'new diagram line 1' "$F" && ok "replace-middle: new body present" || bad "replace-middle: new body present"
grep -q 'old diagram' "$F" && bad "replace-middle: old body removed" || ok "replace-middle: old body removed"
grep -q 'infra body' "$F" && ok "replace-middle: next section untouched" || bad "replace-middle: next section untouched"
grep -q 'Intro text.' "$F" && ok "replace-middle: preamble untouched" || bad "replace-middle: preamble untouched"

# --- replace the last section ---
printf 'new usage\n' | sh "$UP" "$F" "Usage"
grep -q 'new usage' "$F" && ok "replace-last: new body present" || bad "replace-last: new body present"
grep -q 'usage text' "$F" && bad "replace-last: old body removed" || ok "replace-last: old body removed"

# --- append when absent ---
printf 'ui body\n' | sh "$UP" "$F" "UI"
grep -q '^## UI$' "$F" && ok "append: header added" || bad "append: header added"
grep -q 'ui body' "$F" && ok "append: body added" || bad "append: body added"

# --- header-substring false match guard: "## Data" must not match "## Datamodel" ---
printf 'data body\n' | sh "$UP" "$F" "Data"
n="$(grep -c '^## Data$' "$F")"
[ "$n" = "1" ] && ok "substring guard: exact new section created" || bad "substring guard: exact new section created (count=$n)"
grep -q 'new diagram line 1' "$F" && ok "substring guard: Datamodel untouched" || bad "substring guard: Datamodel untouched"

# --- missing file refused ---
set +e
printf 'x\n' | sh "$UP" "$WORK/nope.md" "X" >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && ok "missing file refused" || bad "missing file refused"

exit "$fail"
