#!/usr/bin/env sh
# Regression test for defects-unsurfaced.sh: computes stable identifiers
# for DEFECTS.md entries, unions every plan's surfaced-defects: frontmatter
# list, and prints only the defects not yet surfaced to the user.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CHECK="$SCRIPT_DIR/defects-unsurfaced.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

P="$WORK/t/.project"
mkdir -p "$P/plans"

cat > "$P/DEFECTS.md" <<'EOF'
# Defects

_Last verified: 2026-07-06_

## constitution.md
- **Claim:** the hook runs every test script
  **Actual:** four scripts missing
  **Location:** hooks/pre-commit:10
  **Severity:** drift

## datamodel.md
- **Claim:** Patient table has soft deletes
  **Actual:** hard DELETE in repo layer
  **Location:** src/db.ts:42
  **Severity:** broken-contract
EOF

id1="$(printf '%s' "the hook runs every test script" | shasum | cut -c1-8)"
id2="$(printf '%s' "Patient table has soft deletes" | shasum | cut -c1-8)"

# --- Case 1: no plans have surfaced anything -> both print ---
out="$(sh "$CHECK" "$WORK/t")"
echo "$out" | grep -q "^$id1	" && ok "case1: defect 1 printed with id" || bad "case1: defect 1 printed with id — got: $out"
echo "$out" | grep -q "^$id2	Patient table has soft deletes$" && ok "case1: defect 2 id + claim text" || bad "case1: defect 2 id + claim text — got: $out"
[ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" = "2" ] && ok "case1: exactly two lines" || bad "case1: exactly two lines — got: $out"

# --- Case 2: one id surfaced in a plan -> only the other prints ---
cat > "$P/plans/plan-a-2026-07-06.md" <<EOF
---
status: approved
branch: a
created: 2026-07-06
surfaced-defects: [$id1]
---
EOF
out="$(sh "$CHECK" "$WORK/t")"
echo "$out" | grep -q "$id1" && bad "case2: surfaced id suppressed" || ok "case2: surfaced id suppressed"
echo "$out" | grep -q "$id2" && ok "case2: unsurfaced id still printed" || bad "case2: unsurfaced id still printed"

# --- Case 3: both surfaced across two plans -> silent ---
cat > "$P/plans/plan-b-2026-07-06.md" <<EOF
---
status: draft
branch: b
created: 2026-07-06
surfaced-defects: [$id2, deadbeef]
---
EOF
out="$(sh "$CHECK" "$WORK/t")"
[ -z "$out" ] && ok "case3: all surfaced -> silent" || bad "case3: all surfaced -> silent — got: $out"

# --- Case 6: --id names a surfaced entry -> printed anyway (bypasses filter) ---
out="$(sh "$CHECK" --id "$id1" "$WORK/t")"
[ "$out" = "$id1	the hook runs every test script" ] && ok "case6: --id hit prints entry despite surfaced" || bad "case6: --id hit prints entry despite surfaced — got: $out"

# --- Case 6b: --id is repeatable -> both named entries print, in order ---
out="$(sh "$CHECK" --id "$id2" --id "$id1" "$WORK/t")"
expected="$(printf '%s\t%s\n%s\t%s' "$id2" "Patient table has soft deletes" "$id1" "the hook runs every test script")"
[ "$out" = "$expected" ] && ok "case6b: repeated --id prints both entries" || bad "case6b: repeated --id prints both entries — got: $out"

# --- Case 7: --id with an id not in DEFECTS.md -> error ---
if sh "$CHECK" --id cafef00d "$WORK/t" >/dev/null 2>"$WORK/err"; then
  bad "case7: --id miss errors"
else
  ok "case7: --id miss errors"
fi
grep -q "cafef00d" "$WORK/err" && ok "case7: error names the missing id" || bad "case7: error names the missing id — got: $(cat "$WORK/err")"

# --- Case 8: --all prints every entry, including already-surfaced ids ---
out="$(sh "$CHECK" --all "$WORK/t")"
echo "$out" | grep -q "^$id1	the hook runs every test script$" && ok "case8: --all includes surfaced id1" || bad "case8: --all includes surfaced id1 — got: $out"
echo "$out" | grep -q "^$id2	Patient table has soft deletes$" && ok "case8: --all includes surfaced id2" || bad "case8: --all includes surfaced id2 — got: $out"
[ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" = "2" ] && ok "case8: --all exactly two lines" || bad "case8: --all exactly two lines — got: $out"

# --- Case 9: default no-argument mode unchanged (still filtered -> silent) ---
out="$(sh "$CHECK" "$WORK/t")"
[ -z "$out" ] && ok "case9: default mode still filtered after option support" || bad "case9: default mode still filtered after option support — got: $out"

# --- Case 4: all-clear DEFECTS.md -> silent ---
cat > "$P/DEFECTS.md" <<'EOF'
# Defects

_Last verified: 2026-07-06_

No defects found — artifacts match the codebase as of this run.
EOF
out="$(sh "$CHECK" "$WORK/t")"
[ -z "$out" ] && ok "case4: all-clear file -> silent" || bad "case4: all-clear file -> silent — got: $out"

# --- Case 5: no DEFECTS.md -> silent success ---
rm "$P/DEFECTS.md"
sh "$CHECK" "$WORK/t" >/dev/null 2>&1 && ok "case5: missing DEFECTS.md -> exit 0" || bad "case5: missing DEFECTS.md -> exit 0"

exit "$fail"
