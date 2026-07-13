#!/usr/bin/env sh
# Regression test for worktree-reap.sh: deterministic removal of merged,
# clean worktrees (and their branches) after a delegated run lands. Builds
# throwaway git repos + worktrees under a temp dir for each case — never
# this repository's own worktrees.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REAP="$SCRIPT_DIR/worktree-reap.sh"

WORK="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$WORK"' EXIT

git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
assert_contains() {
  label="$1"; expected="$2"; actual="$3"
  if ! printf '%s\n' "$actual" | grep -qF "$expected"; then
    echo "FAIL: $label — expected '$expected' in output, got:"
    printf '%s\n' "$actual" | sed 's/^/    /'
    fail=1
  else
    echo "ok: $label"
  fi
}
assert_not_contains() {
  label="$1"; unexpected="$2"; actual="$3"
  if printf '%s\n' "$actual" | grep -qF "$unexpected"; then
    echo "FAIL: $label — output must not contain '$unexpected', got:"
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
assert_dir() {
  label="$1"; dir="$2"
  if [ -d "$dir" ]; then echo "ok: $label"; else
    echo "FAIL: $label — directory '$dir' missing"; fail=1; fi
}
assert_no_dir() {
  label="$1"; dir="$2"
  if [ ! -d "$dir" ]; then echo "ok: $label"; else
    echo "FAIL: $label — directory '$dir' still exists"; fail=1; fi
}
assert_branch() {
  label="$1"; repo="$2"; branch="$3"
  if git -C "$repo" rev-parse --verify --quiet "refs/heads/$branch" > /dev/null; then
    echo "ok: $label"
  else
    echo "FAIL: $label — branch '$branch' missing"; fail=1
  fi
}
assert_no_branch() {
  label="$1"; repo="$2"; branch="$3"
  if git -C "$repo" rev-parse --verify --quiet "refs/heads/$branch" > /dev/null; then
    echo "FAIL: $label — branch '$branch' still exists"; fail=1
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

# --- fixture 1: primary on main; four sibling worktrees in every
# candidacy state ---
repo="$WORK/repo"
mkdir -p "$repo" && cd "$repo"
git init -q -b main
echo base > base.txt
git add base.txt
git commit -q -m init

# merged + clean: branch sits at main's tip (trivially an ancestor)
git branch merged-topic
wt_merged="$WORK/wt-merged"
git worktree add -q "$wt_merged" merged-topic

# unmerged: branch with its own commit main doesn't have
git branch unmerged-topic
wt_unmerged="$WORK/wt-unmerged"
git worktree add -q "$wt_unmerged" unmerged-topic
( cd "$wt_unmerged" && git commit -q --allow-empty -m "unmerged work" )

# merged but dirty: untracked file in the tree
git branch dirty-topic
wt_dirty="$WORK/wt-dirty"
git worktree add -q "$wt_dirty" dirty-topic
echo scratch > "$wt_dirty/uncommitted.txt"

# detached HEAD
wt_detached="$WORK/wt-detached"
git worktree add -q --detach "$wt_detached"

# --- Case 1: --dry-run lists only the merged+clean candidate, mutates
# nothing ---
cd "$repo"
run sh "$REAP" --dry-run
assert_contains "case1: dry-run lists merged+clean candidate" "candidate=$wt_merged branch=merged-topic" "$out"
assert_not_contains "case1: dry-run does not list unmerged" "candidate=$wt_unmerged" "$out"
assert_not_contains "case1: dry-run does not list dirty" "candidate=$wt_dirty" "$out"
assert_not_contains "case1: dry-run does not list detached" "candidate=$wt_detached" "$out"
assert_exit "case1: dry-run exit 0" "0" "$rc"
assert_dir "case1: dry-run left merged worktree intact" "$wt_merged"
assert_branch "case1: dry-run left merged branch intact" "$repo" "merged-topic"

# --- Case 2: real run reaps the merged+clean worktree, keeps the others
# with reasons ---
run sh "$REAP"
assert_contains "case2: merged+clean reaped" "reaped=true path=$wt_merged branch=merged-topic" "$out"
assert_no_dir "case2: merged worktree removed" "$wt_merged"
assert_no_branch "case2: merged branch deleted" "$repo" "merged-topic"
assert_contains "case2: unmerged kept with reason" "reaped=false path=$wt_unmerged branch=unmerged-topic reason=unmerged" "$out"
assert_dir "case2: unmerged worktree intact" "$wt_unmerged"
assert_branch "case2: unmerged branch intact" "$repo" "unmerged-topic"
assert_contains "case2: dirty kept with reason" "reaped=false path=$wt_dirty branch=dirty-topic reason=dirty" "$out"
assert_dir "case2: dirty worktree intact" "$wt_dirty"
assert_branch "case2: dirty branch intact" "$repo" "dirty-topic"
assert_contains "case2: detached kept with reason" "reaped=false path=$wt_detached" "$out"
assert_contains "case2: detached reason" "reason=detached" "$out"
assert_dir "case2: detached worktree intact" "$wt_detached"
assert_exit "case2: exit 0 (everything eligible reaped)" "0" "$rc"

# --- Case 3: the primary worktree is never a candidate ---
assert_not_contains "case3: primary never mentioned" "path=$repo" "$out"

# --- Case 4: the current worktree is never a candidate, even when merged
# and clean (run the script FROM a worktree) ---
cd "$repo"
git branch self-topic
wt_self="$WORK/wt-self"
git worktree add -q "$wt_self" self-topic
git branch other-topic
wt_other="$WORK/wt-other"
git worktree add -q "$wt_other" other-topic
cd "$wt_self"
run sh "$REAP"
assert_contains "case4: sibling candidate reaped from a worktree" "reaped=true path=$wt_other branch=other-topic" "$out"
assert_no_dir "case4: sibling worktree removed" "$wt_other"
assert_not_contains "case4: cwd worktree never a candidate" "path=$wt_self" "$out"
assert_dir "case4: cwd worktree intact" "$wt_self"
assert_branch "case4: cwd branch intact" "$repo" "self-topic"
assert_exit "case4: exit 0" "0" "$rc"

# --- Case 5: a worktree holding the default branch is never reaped (its
# branch is trivially "merged" — deleting it would delete the default
# branch itself) ---
repo2="$WORK/repo2"
mkdir -p "$repo2" && cd "$repo2"
git init -q -b main
git commit -q --allow-empty -m init
git checkout -q -b side
wt_main="$WORK/wt-main"
git worktree add -q "$wt_main" main
run sh "$REAP"
assert_contains "case5: default-branch worktree kept" "reaped=false path=$wt_main branch=main reason=default-branch" "$out"
assert_dir "case5: default-branch worktree intact" "$wt_main"
assert_branch "case5: default branch intact" "$repo2" "main"
assert_exit "case5: exit 0 (nothing eligible)" "0" "$rc"

# --- Case 6: a failed removal attempt reports remove-failed and exits 1 ---
repo3="$WORK/repo3"
mkdir -p "$repo3" && cd "$repo3"
git init -q -b main
git commit -q --allow-empty -m init
git branch locked-topic
wt_locked="$WORK/wt-locked"
git worktree add -q "$wt_locked" locked-topic
git worktree lock "$wt_locked"
run sh "$REAP"
assert_contains "case6: locked worktree remove fails" "reaped=false path=$wt_locked branch=locked-topic reason=remove-failed" "$out"
assert_dir "case6: locked worktree intact" "$wt_locked"
assert_branch "case6: locked branch intact" "$repo3" "locked-topic"
assert_exit "case6: exit 1 (a reap attempt failed)" "1" "$rc"

# --- Case 7: no other worktrees -> silent success ---
repo4="$WORK/repo4"
mkdir -p "$repo4" && cd "$repo4"
git init -q -b main
git commit -q --allow-empty -m init
run sh "$REAP"
assert_exit "case7: exit 0 with no worktrees" "0" "$rc"
if [ -z "$out" ]; then echo "ok: case7: silent with nothing to reap"; else
  echo "FAIL: case7: expected no output, got: $out"; fail=1; fi

# --- Case 8: not a git repo -> error exit 1 ---
notrepo="$WORK/notrepo"
mkdir -p "$notrepo"
cd "$notrepo"
run sh "$REAP"
assert_exit "case8: not-a-repo exit 1" "1" "$rc"

exit "$fail"
