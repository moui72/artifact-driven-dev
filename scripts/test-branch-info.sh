#!/usr/bin/env sh
# Regression test for branch-info.sh's default-branch fallback chain:
# remote HEAD -> local main -> local master. Builds throwaway git repos
# under a temp dir for each case.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BRANCH_INFO="$SCRIPT_DIR/branch-info.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Throwaway fixture repos under $WORK — no signing needed or wanted, and no
# hooks from the invoking user's global core.hooksPath (e.g. a signing-
# verification pre-push hook) should run against these disposable repos.
git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
assert_contains() {
  label="$1"
  expected="$2"
  actual="$3"
  if ! printf '%s\n' "$actual" | grep -qxF "$expected"; then
    echo "FAIL: $label — expected line '$expected', got:"
    printf '%s\n' "$actual" | sed 's/^/    /'
    fail=1
  else
    echo "ok: $label"
  fi
}

# --- Case 1: remote HEAD configured, points at "trunk" ---
repo="$WORK/case1"
mkdir -p "$repo" && cd "$repo"
git init -q -b trunk
git commit -q --allow-empty -m init
mkdir -p "$WORK/case1-remote"
git init -q --bare "$WORK/case1-remote"
git remote add origin "$WORK/case1-remote"
git push -q origin trunk
git remote set-head origin trunk
git checkout -q -b feature-x
out="$(sh "$BRANCH_INFO")"
assert_contains "case1: current" "current=feature-x" "$out"
assert_contains "case1: default from remote HEAD" "default=trunk" "$out"
assert_contains "case1: on_default false" "on_default=false" "$out"

# --- Case 2: no remote, local main exists ---
repo="$WORK/case2"
mkdir -p "$repo" && cd "$repo"
git init -q -b main
git commit -q --allow-empty -m init
out="$(sh "$BRANCH_INFO")"
assert_contains "case2: default falls back to main" "default=main" "$out"
assert_contains "case2: on_default true" "on_default=true" "$out"

# --- Case 3: no remote, no main, only master ---
repo="$WORK/case3"
mkdir -p "$repo" && cd "$repo"
git init -q -b master
git commit -q --allow-empty -m init
out="$(sh "$BRANCH_INFO")"
assert_contains "case3: default falls back to master" "default=master" "$out"
assert_contains "case3: on_default true" "on_default=true" "$out"

exit "$fail"
