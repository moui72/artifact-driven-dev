#!/usr/bin/env sh
# Regression test for sync-divergence.sh: given a features.md Status and its
# linked issue's actual open/closed state, has the tracker diverged from
# features.md (/ardd-tracker's Pull step 2: closed-but-not-implemented, or
# reopened-but-implemented)?

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIVERGE="$SCRIPT_DIR/sync-divergence.sh"

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

out="$(sh "$DIVERGE" widget-export 42 planned open)"
assert_eq "matching state -> no divergence" "" "$out"

out="$(sh "$DIVERGE" widget-export 42 planned closed)"
assert_eq "closed but not implemented -> diverged" \
  "- **Slug:** widget-export — issue #42 is closed, features.md says \`Status: planned\`" \
  "$out"

out="$(sh "$DIVERGE" widget-export 42 implemented open)"
assert_eq "reopened but implemented -> diverged" \
  "- **Slug:** widget-export — issue #42 is open, features.md says \`Status: implemented\`" \
  "$out"

out="$(sh "$DIVERGE" widget-export 42 implemented closed)"
assert_eq "closed and implemented -> no divergence" "" "$out"

exit "$fail"
