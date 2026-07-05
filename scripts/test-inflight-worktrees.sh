#!/usr/bin/env sh
# Regression test for inflight-worktrees.sh: solo mode's coarse-state
# visibility channel over real `git worktree add` fixtures.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFLIGHT="$SCRIPT_DIR/inflight-worktrees.sh"

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
assert_not_contains() {
  label="$1"; unexpected_substr="$2"; actual="$3"
  if printf '%s\n' "$actual" | grep -qF "$unexpected_substr"; then
    echo "FAIL: $label — did not expect to find '$unexpected_substr' in:"
    printf '%s\n' "$actual" | sed 's/^/    /'
    fail=1
  else
    echo "ok: $label"
  fi
}
assert_eq() {
  label="$1"; expected="$2"; actual="$3"
  if [ "$expected" != "$actual" ]; then
    echo "FAIL: $label — expected '$expected', got '$actual'"
    fail=1
  else
    echo "ok: $label"
  fi
}

write_tasks() {
  # $1 = tasks file path, $2 = status, $3 = checked count, $4 = unchecked count
  dir="$(dirname "$1")"
  mkdir -p "$dir"
  {
    printf -- '---\n'
    printf 'status: %s\n' "$2"
    printf -- '---\n\n'
    i=0
    while [ "$i" -lt "$3" ]; do
      printf -- '- [x] done task\n'
      i=$((i + 1))
    done
    i=0
    while [ "$i" -lt "$4" ]; do
      printf -- '- [ ] pending task\n'
      i=$((i + 1))
    done
  } > "$1"
}

repo="$WORK/repo"
mkdir -p "$repo" && cd "$repo"
git init -q -b main
git commit -q --allow-empty -m init

# --- Case 1: no extra worktrees -> empty output, exit 0 ---
set +e
out="$(sh "$INFLIGHT")"
rc=$?
set -e
assert_eq "case1: no worktrees -> empty output" "" "$out"
assert_eq "case1: exit 0" "0" "$rc"

# --- Set up worktrees ---
# The tasks files written below are untracked and do NOT exist on the
# default branch (main), so the already-merged filter must leave them
# alone — each is genuinely in-flight state. Cases 7-8 cover the filter
# itself with files that DO exist on main.
git branch feat-a
git worktree add -q "$WORK/wt-a" feat-a
git branch feat-b
git worktree add -q "$WORK/wt-b" feat-b
git branch feat-c
git worktree add -q "$WORK/wt-c" feat-c

write_tasks "$WORK/wt-a/.project/tasks/tasks-alpha.md" "in-progress" 2 1
write_tasks "$WORK/wt-b/.project/tasks/tasks-beta.md" "completed" 3 0
write_tasks "$WORK/wt-b/.project/tasks/tasks-beta-ready.md" "ready" 0 4
# wt-c: no .project/ at all

out="$(sh "$INFLIGHT")"

assert_contains "case2: in-progress line with progress" \
  "worktree=$WORK/wt-a	branch=feat-a	tasks=.project/tasks/tasks-alpha.md	status=in-progress	progress=2/3" "$out"
assert_contains "case3: completed line with progress" \
  "worktree=$WORK/wt-b	branch=feat-b	tasks=.project/tasks/tasks-beta.md	status=completed	progress=3/3" "$out"
assert_not_contains "case4: ready-status tasks file not reported" "tasks-beta-ready.md" "$out"
assert_contains "case5: worktree with no .project -> tasks=none" \
  "worktree=$WORK/wt-c	branch=feat-c	tasks=none	status=-	progress=-" "$out"

# --- Case 6: run from inside a worktree — sees primary checkout's tasks
# files (untracked in the primary, so not filtered), but not itself ---
mkdir -p "$repo/.project/tasks"
write_tasks "$repo/.project/tasks/tasks-primary.md" "in-progress" 1 0
cd "$WORK/wt-a"
out_from_wt="$(sh "$INFLIGHT")"
assert_contains "case6: from wt-a, sees primary's in-progress tasks" \
  "worktree=$repo	branch=main	tasks=.project/tasks/tasks-primary.md	status=in-progress	progress=1/1" "$out_from_wt"
assert_not_contains "case6: from wt-a, does not report itself" "branch=feat-a" "$out_from_wt"
assert_contains "case6: from wt-a, still sees wt-b's completed tasks" \
  "worktree=$WORK/wt-b	branch=feat-b	tasks=.project/tasks/tasks-beta.md	status=completed	progress=3/3" "$out_from_wt"

# --- Cases 7-8: the already-merged filter. Commit a completed tasks file
# on main, then branch two worktrees from it: one leaves the file identical
# to main (already-merged noise -> filtered, worktree prints tasks=none),
# the other modifies it (differs from main -> reported). ---
cd "$repo"
write_tasks "$repo/.project/tasks/tasks-merged.md" "completed" 2 0
git add .project/tasks/tasks-merged.md
git commit -q -m "merged tasks file on main"

git branch feat-d
git worktree add -q "$WORK/wt-d" feat-d
git branch feat-e
git worktree add -q "$WORK/wt-e" feat-e
# wt-d: tasks-merged.md checked out identical to main — pure history.
# wt-e: same file, but with one task flipped back to unchecked — in-flight.
write_tasks "$WORK/wt-e/.project/tasks/tasks-merged.md" "completed" 1 1

out="$(sh "$INFLIGHT")"
assert_contains "case7: identical-to-default completed file filtered -> tasks=none" \
  "worktree=$WORK/wt-d	branch=feat-d	tasks=none	status=-	progress=-" "$out"
assert_not_contains "case7: identical file not reported" "worktree=$WORK/wt-d	branch=feat-d	tasks=.project/tasks/tasks-merged.md" "$out"
assert_contains "case8: differs-from-default file reported" \
  "worktree=$WORK/wt-e	branch=feat-e	tasks=.project/tasks/tasks-merged.md	status=completed	progress=1/2" "$out"

exit "$fail"
