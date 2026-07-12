#!/usr/bin/env sh
# Regression test for sync-label-decision.sh: given features.md's Status for
# an entry, the ardd:* label currently on its linked issue (or "none"), and
# the issue's open/closed state, what label-swap or close action does
# /ardd-tracker's Push step 3 need to take?

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DECIDE="$SCRIPT_DIR/sync-label-decision.sh"

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

out="$(sh "$DECIDE" planned ardd:planned open)"
assert_eq "label already matches status -> no change" "" "$out"

out="$(sh "$DECIDE" planned ardd:backlogged open)"
assert_eq "label behind status -> swap pair" "swap ardd:backlogged ardd:planned" "$out"

out="$(sh "$DECIDE" backlogged none open)"
assert_eq "no label yet -> add" "add ardd:backlogged" "$out"

out="$(sh "$DECIDE" implemented ardd:tasked open)"
assert_eq "implemented + still open -> close" "close" "$out"

out="$(sh "$DECIDE" implemented none closed)"
assert_eq "implemented + already closed -> no change" "" "$out"

exit "$fail"
