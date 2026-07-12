#!/usr/bin/env sh
# Regression test for sync-slug-match.sh: given issue candidates (number and
# body, one per stdin line, tab-separated) and a target slug, does any
# candidate's body carry that slug's exact ardd-sync-slug marker? Guards
# against GitHub search returning a similar-but-different slug's issue (see
# skills/ardd-tracker/SKILL.md's marker-format note on why an exact boundary
# match matters, not a loose substring one).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MATCH="$SCRIPT_DIR/sync-slug-match.sh"

fail=0
assert_eq() {
  label="$1"; expected="$2"; actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "ok: $label"
  else
    echo "FAIL: $label — expected '$expected', got '$actual'"
    fail=1
  fi
}

# --- Case 1: no candidates -> no match ---
out="$(printf '' | sh "$MATCH" widget-export)"
assert_eq "case1: no candidates -> empty" "" "$out"

# --- Case 2: exact marker match -> prints that issue number ---
out="$(printf '123\tSome body <!-- ardd-sync-slug-widget-export --> more text\n' | sh "$MATCH" widget-export)"
assert_eq "case2: exact match -> 123" "123" "$out"

# --- Case 3: similar-but-different slug -> no match (boundary safety) ---
out="$(printf '456\tSome body <!-- ardd-sync-slug-widget-export-v2 --> more text\n' | sh "$MATCH" widget-export)"
assert_eq "case3: similar slug prefix -> no match" "" "$out"

# --- Case 4: multiple candidates, second one matches -> prints its number ---
out="$(printf '111\tunrelated body\n222\tbody with <!-- ardd-sync-slug-widget-export -->\n' | sh "$MATCH" widget-export)"
assert_eq "case4: second candidate matches -> 222" "222" "$out"

exit "$fail"
