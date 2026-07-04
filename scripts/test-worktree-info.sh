#!/usr/bin/env sh
# Regression test for worktree-info.sh: creating a worktree for a slug,
# idempotent re-run against an existing one, and that the worktree branches
# from the default branch's current tip rather than whatever branch happened
# to be checked out when the script ran. Builds a throwaway git repo (with a
# same-named remote-less "origin" clone, to exercise the default-branch
# detection worktree-info.sh delegates to branch-info.sh's logic for) under
# a temp dir.

set -e

# Drop any GIT_DIR/GIT_INDEX_FILE/etc. inherited from an outer git invocation
# (e.g. this test running inside git's own pre-commit hook) — otherwise the
# throwaway repos below inherit them and `git worktree add` resolves against
# the wrong repository entirely.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKTREE_INFO="$SCRIPT_DIR/worktree-info.sh"

WORK="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$WORK"' EXIT

git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
assert_eq() {
  label="$1"
  expected="$2"
  actual="$3"
  if [ "$expected" != "$actual" ]; then
    echo "FAIL: $label — expected '$expected', got '$actual'"
    fail=1
  else
    echo "ok: $label"
  fi
}

repo="$WORK/repo"
mkdir -p "$repo" && cd "$repo"
git init -q -b main
git commit -q --allow-empty -m init

# --- Case 1: create a worktree from scratch while on a different branch ---
git checkout -q -b some-other-branch
path1="$(sh "$WORKTREE_INFO" create demo-slug "$repo")"
base="$(basename "$repo")"
expected_path="$WORK/${base}-wt-demo-slug"
assert_eq "case1: printed path" "$expected_path" "$path1"
[ -d "$path1" ] && echo "ok: case1: worktree dir exists" || { echo "FAIL: case1: worktree dir missing"; fail=1; }

# Verify it branched from main's tip, not some-other-branch
( cd "$path1" && git rev-parse --abbrev-ref HEAD ) > "$WORK/wt-branch.txt"
wt_branch="$(cat "$WORK/wt-branch.txt")"
main_tip="$(git -C "$repo" rev-parse main)"
wt_tip="$(git -C "$path1" rev-parse HEAD)"
assert_eq "case1: worktree branched from main's tip" "$main_tip" "$wt_tip"

# --- Case 2: idempotent re-run returns the same existing path, no duplicate ---
git checkout -q main
git commit -q --allow-empty -m "advance main"
path2="$(sh "$WORKTREE_INFO" create demo-slug "$repo")"
assert_eq "case2: idempotent re-run returns same path" "$path1" "$path2"
count="$(git -C "$repo" worktree list | grep -c "demo-slug" || true)"
assert_eq "case2: still only one worktree for the slug" "1" "$count"

exit "$fail"
