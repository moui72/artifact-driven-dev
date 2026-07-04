#!/usr/bin/env sh
# Regression test for project-lock.sh: a warn-only marker (never blocks a
# run) that lets one skill invocation notice another wrote to the same
# .project/ recently. Builds a throwaway .project/ under a temp dir per
# case, mirroring test-sibling-tasks-complete.sh's style.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCK="$SCRIPT_DIR/project-lock.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

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

# --- Case 1: no lock file yet -> check is silent ---
dir="$WORK/case1"; mkdir -p "$dir"
out="$(sh "$LOCK" check ardd-plan "$dir")"
assert_eq "case1: no lock -> silent" "" "$out"

# --- Case 2: touch then check with the same label -> silent ---
dir="$WORK/case2"; mkdir -p "$dir"
sh "$LOCK" touch ardd-plan "$dir"
out="$(sh "$LOCK" check ardd-plan "$dir")"
assert_eq "case2: same label -> silent" "" "$out"

# --- Case 3: touch then check with a different label -> warns ---
dir="$WORK/case3"; mkdir -p "$dir"
sh "$LOCK" touch ardd-plan "$dir"
out="$(sh "$LOCK" check ardd-tasks "$dir")"
case "$out" in
  *ardd-plan*) echo "ok: case3: different label -> warns, names ardd-plan" ;;
  *) echo "FAIL: case3: expected a warning naming ardd-plan, got: $out"; fail=1 ;;
esac

# --- Case 4: a stale (>5 min old) lock from a different label -> silent ---
dir="$WORK/case4"; mkdir -p "$dir/.project"
old_ts=$(($(date +%s) - 600))
echo "$old_ts ardd-plan" > "$dir/.project/.lock"
out="$(sh "$LOCK" check ardd-tasks "$dir")"
assert_eq "case4: stale lock -> silent" "" "$out"

exit "$fail"
