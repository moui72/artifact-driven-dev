#!/usr/bin/env sh
# Regression test for fold-to-main.sh: fast-forward fold of the current
# feature branch into the local default branch, then checkout default.
# Builds throwaway git repos under a temp dir for each case.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FOLD="$SCRIPT_DIR/fold-to-main.sh"

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

run() {
  set +e
  out="$("$@" 2>&1)"
  rc=$?
  set -e
}

# --- fresh repo helper: main with one commit + a feature branch ahead ---
fresh_repo() {
  r="$WORK/$1"
  mkdir -p "$r" && cd "$r"
  git init -q -b main
  git commit -q --allow-empty -m init
  git checkout -q -b feature
  git commit -q --allow-empty -m "feature work"
}

# --- Case 1: clean fast-forward fold, on a feature branch ---
fresh_repo repo1
feature_head="$(git rev-parse feature)"
run sh "$FOLD"
assert_contains "case1: folded=true" "folded=true" "$out"
assert_contains "case1: head is feature tip" "head=$feature_head" "$out"
assert_exit "case1: exit 0" "0" "$rc"
assert_contains "case1: now on default" "main" "$(git branch --show-current)"
assert_contains "case1: main fast-forwarded to feature tip" "$feature_head" "$(git rev-parse main)"

# --- Case 2: already on default -> no-op success ---
fresh_repo repo2
git checkout -q main
run sh "$FOLD"
assert_contains "case2: folded=true (no-op on default)" "folded=true" "$out"
assert_exit "case2: exit 0" "0" "$rc"

# --- Case 3: dirty working tree -> refused ---
fresh_repo repo3
echo uncommitted > "$WORK/repo3/dirty.txt"
run sh "$FOLD"
assert_contains "case3: dirty -> folded=false" "folded=false" "$out"
assert_contains "case3: dirty reason" "reason=dirty" "$out"
assert_exit "case3: exit 1" "1" "$rc"
rm -f "$WORK/repo3/dirty.txt"

# --- Case 4: diverged (default has a commit the branch lacks) -> refused,
# unchanged (still on feature) ---
fresh_repo repo4
git checkout -q main
git commit -q --allow-empty -m "main diverges"
git checkout -q feature
run sh "$FOLD"
assert_contains "case4: diverged -> folded=false" "folded=false" "$out"
assert_contains "case4: diverged reason" "reason=diverged" "$out"
assert_exit "case4: exit 1" "1" "$rc"
assert_contains "case4: unchanged, still on feature" "feature" "$(git branch --show-current)"

# --- Case 5: detached HEAD -> refused ---
fresh_repo repo5
git checkout -q --detach
run sh "$FOLD"
assert_contains "case5: detached -> folded=false" "folded=false" "$out"
assert_contains "case5: detached reason" "reason=detached" "$out"
assert_exit "case5: exit 1" "1" "$rc"

# --- Case 6: not a git repo -> refused ---
notrepo="$WORK/notrepo"
mkdir -p "$notrepo" && cd "$notrepo"
run sh "$FOLD"
assert_contains "case6: not-a-repo -> folded=false" "folded=false" "$out"
assert_contains "case6: not-a-repo reason" "reason=not-a-repo" "$out"
assert_exit "case6: exit 1" "1" "$rc"

exit "$fail"
