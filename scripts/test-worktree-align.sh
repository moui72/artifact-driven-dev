#!/usr/bin/env sh
# Regression test for worktree-align.sh: fast-forward alignment of a
# freshly created delegated worktree against the local default branch.
# Builds throwaway git repos + worktrees under a temp dir for each case.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ALIGN="$SCRIPT_DIR/worktree-align.sh"

WORK="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$WORK"' EXIT

git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
assert_contains() {
  label="$1"; expected="$2"; actual="$3"
  if ! printf '%s\n' "$actual" | grep -qxF "$expected"; then
    echo "FAIL: $label — expected line '$expected', got:"
    printf '%s\n' "$actual" | sed 's/^/    /'
    fail=1
  else
    echo "ok: $label"
  fi
}
assert_exit() {
  label="$1"; expected="$2"; actual="$3"
  if [ "$expected" != "$actual" ]; then
    echo "FAIL: $label — expected exit $expected, got $actual"
    fail=1
  else
    echo "ok: $label"
  fi
}

# Runs a command, capturing stdout+stderr into $out and exit code into $rc,
# without letting a nonzero exit trip this script's own `set -e`.
run() {
  set +e
  out="$("$@" 2>&1)"
  rc=$?
  set -e
}

# --- shared repo: main with one commit, a worktree branched from main,
# then main advances (simulating the pre-delegation state-commit) ---
repo="$WORK/repo"
mkdir -p "$repo" && cd "$repo"
git init -q -b main
git commit -q --allow-empty -m init
git branch topic
wt="$WORK/wt"
git worktree add -q "$wt" --detach topic

# --- Case 1: already an ancestor (no-op success) ---
cd "$wt"
run sh "$ALIGN" main
assert_contains "case1: aligned=true (no-op)" "aligned=true" "$out"
assert_exit "case1: exit 0" "0" "$rc"

# --- Case 2: ff-merge success (local main ahead of worktree base) ---
cd "$repo"
git commit -q --allow-empty -m "pre-delegation state commit"
main_head="$(git rev-parse main)"
cd "$wt"
run sh "$ALIGN" main
assert_contains "case2: aligned=true (ff-merge)" "aligned=true" "$out"
assert_contains "case2: head matches main" "head=$main_head" "$out"
assert_exit "case2: exit 0" "0" "$rc"

# --- Case 3: explicit ref argument (default branch via branch-info.sh
# already exercised above; here confirm an arbitrary ref works) ---
cd "$repo"
git checkout -q -b other-ref
git commit -q --allow-empty -m "other ref commit"
other_head="$(git rev-parse other-ref)"
git checkout -q main
cd "$wt"
run sh "$ALIGN" other-ref
assert_contains "case3: explicit ref aligns" "aligned=true" "$out"
assert_contains "case3: head matches other-ref" "head=$other_head" "$out"
assert_exit "case3: exit 0" "0" "$rc"

# --- Case 4: diverged histories -> failure, no merge attempted ---
cd "$wt"
git checkout -q -b wt-own-work
git commit -q --allow-empty -m "worktree-local work"
cd "$repo"
git checkout -q main
git commit -q --allow-empty -m "main diverges further"
cd "$wt"
run sh "$ALIGN" main
assert_contains "case4: diverged -> aligned=false" "aligned=false" "$out"
assert_contains "case4: diverged reason" "reason=diverged" "$out"
assert_exit "case4: exit 1" "1" "$rc"

# --- Case 5: dirty working tree -> failure ---
echo "uncommitted" > "$wt/dirty.txt"
run sh "$ALIGN" main
assert_contains "case5: dirty -> aligned=false" "aligned=false" "$out"
assert_contains "case5: dirty reason" "reason=dirty" "$out"
assert_exit "case5: exit 1" "1" "$rc"
rm -f "$wt/dirty.txt"

# --- Case 6: missing ref -> failure ---
run sh "$ALIGN" no-such-ref-anywhere
assert_contains "case6: no-such-ref -> aligned=false" "aligned=false" "$out"
assert_contains "case6: no-such-ref reason" "reason=no-such-ref" "$out"
assert_exit "case6: exit 1" "1" "$rc"

# --- Case 7: not a git repo -> failure ---
notrepo="$WORK/notrepo"
mkdir -p "$notrepo"
cd "$notrepo"
run sh "$ALIGN" main
assert_contains "case7: not-a-repo -> aligned=false" "aligned=false" "$out"
assert_contains "case7: not-a-repo reason" "reason=not-a-repo" "$out"
assert_exit "case7: exit 1" "1" "$rc"

# --- Case 8: primary checkout itself (not a linked worktree) -> failure ---
cd "$repo"
run sh "$ALIGN" main
assert_contains "case8: not-a-worktree -> aligned=false" "aligned=false" "$out"
assert_contains "case8: not-a-worktree reason" "reason=not-a-worktree" "$out"
assert_exit "case8: exit 1" "1" "$rc"

exit "$fail"
