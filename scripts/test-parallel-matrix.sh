#!/usr/bin/env sh
# Regression test for parallel-matrix.sh: pairwise overlap verdicts among
# ready tasks files and in-flight worktree claims, over throwaway fixture
# repos built in a temp dir — never this repo's own worktrees.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MATRIX="$SCRIPT_DIR/parallel-matrix.sh"

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

# write_tasks <path> <status> <plan-filename|-> <artifacts-tag-content|->
write_tasks() {
  mkdir -p "$(dirname "$1")"
  {
    printf -- '---\n'
    [ "$3" != "-" ] && printf 'plan: %s\n' "$3"
    printf 'status: %s\n' "$2"
    printf -- '---\n\n# Tasks\n\n'
    if [ "$4" != "-" ]; then
      printf -- '- [ ] T001 do the thing [artifacts: %s]\n' "$4"
    else
      printf -- '- [ ] T001 do the thing\n'
    fi
  } > "$1"
}

# write_plan <path> <features-list-content|->
write_plan() {
  mkdir -p "$(dirname "$1")"
  {
    printf -- '---\nstatus: approved\n'
    [ "$2" != "-" ] && printf 'features: [%s]\n' "$2"
    printf -- '---\n\n# Plan\n'
  } > "$1"
}

repo="$WORK/repo"
mkdir -p "$repo" && cd "$repo"
git init -q -b main
git commit -q --allow-empty -m init

TASKS="$repo/.project/tasks"
PLANS="$repo/.project/plans"

# --- Case f: zero ready files -> no output, exit 0 ---
set +e
out="$(sh "$MATRIX")"
rc=$?
set -e
assert_eq "case-f: zero participants -> empty output" "" "$out"
assert_eq "case-f: exit 0" "0" "$rc"

# --- Case f2: one ready file only -> no output, exit 0 ---
write_plan "$PLANS/plan-a.md" "feat-a"
write_tasks "$TASKS/tasks-aa.md" "ready" "plan-a.md" "constitution"
set +e
out="$(sh "$MATRIX")"
rc=$?
set -e
assert_eq "case-f2: one participant -> empty output" "" "$out"
assert_eq "case-f2: exit 0" "0" "$rc"

# --- Case a: two ready files, disjoint features and artifacts -> independent ---
write_plan "$PLANS/plan-b.md" "feat-b"
write_tasks "$TASKS/tasks-bb.md" "ready" "plan-b.md" "datamodel"
out="$(sh "$MATRIX")"
assert_contains "case-a: disjoint pair -> independent" \
  "pair=.project/tasks/tasks-aa.md:.project/tasks/tasks-bb.md	verdict=independent	features=none	artifacts=none" "$out"

# --- Case b: plans share a feature slug -> shared-feature; wins even when
# artifacts also overlap ---
write_plan "$PLANS/plan-b.md" "feat-b, feat-a"
write_tasks "$TASKS/tasks-bb.md" "ready" "plan-b.md" "constitution"
out="$(sh "$MATRIX")"
assert_contains "case-b: shared feature slug wins over shared artifact" \
  "pair=.project/tasks/tasks-aa.md:.project/tasks/tasks-bb.md	verdict=shared-feature	features=feat-a	artifacts=constitution" "$out"

# --- Case c: disjoint features, shared artifact tag -> shared-artifact ---
write_plan "$PLANS/plan-b.md" "feat-b"
out="$(sh "$MATRIX")"
assert_contains "case-c: shared artifact tag -> shared-artifact" \
  "pair=.project/tasks/tasks-aa.md:.project/tasks/tasks-bb.md	verdict=shared-artifact	features=none	artifacts=constitution" "$out"

# --- Case d: broken plan chain -> features=unknown, never shared-feature ---
# d1: missing plan file, artifacts still overlap -> shared-artifact.
write_tasks "$TASKS/tasks-bb.md" "ready" "plan-missing.md" "constitution"
out="$(sh "$MATRIX")"
assert_contains "case-d1: missing plan -> unknown, artifact verdict still possible" \
  "pair=.project/tasks/tasks-aa.md:.project/tasks/tasks-bb.md	verdict=shared-artifact	features=unknown	artifacts=constitution" "$out"
assert_not_contains "case-d1: never shared-feature on a broken chain" "verdict=shared-feature" "$out"
# d2: plan exists but lacks features:, artifacts disjoint -> independent, unknown.
write_plan "$PLANS/plan-nofeat.md" "-"
write_tasks "$TASKS/tasks-bb.md" "ready" "plan-nofeat.md" "datamodel"
out="$(sh "$MATRIX")"
assert_contains "case-d2: plan without features -> independent, features=unknown" \
  "pair=.project/tasks/tasks-aa.md:.project/tasks/tasks-bb.md	verdict=independent	features=unknown	artifacts=none" "$out"

# --- Case g: both plans exist with explicitly empty features: [] ->
# features=none (never unknown), verdict falls through to artifact comparison ---
write_plan "$PLANS/plan-empty.md" ""
write_tasks "$TASKS/tasks-bb.md" "ready" "plan-empty.md" "datamodel"
out="$(sh "$MATRIX")"
assert_contains "case-g1: empty features list -> features=none, independent" \
  "pair=.project/tasks/tasks-aa.md:.project/tasks/tasks-bb.md	verdict=independent	features=none	artifacts=none" "$out"
assert_not_contains "case-g1: empty list is not unknown" "features=unknown" "$out"
# g2: empty list on one side, shared artifact -> shared-artifact, features=none.
write_tasks "$TASKS/tasks-bb.md" "ready" "plan-empty.md" "constitution"
out="$(sh "$MATRIX")"
assert_contains "case-g2: empty features + shared artifact -> shared-artifact, features=none" \
  "pair=.project/tasks/tasks-aa.md:.project/tasks/tasks-bb.md	verdict=shared-artifact	features=none	artifacts=constitution" "$out"

# --- Case e: ready file vs in-flight worktree claim -> pair line emitted ---
rm "$TASKS/tasks-bb.md"
git add -A && git commit -q -m "state"
git branch feat-w
git worktree add -q "$WORK/wt-w" feat-w
write_plan "$WORK/wt-w/.project/plans/plan-w.md" "feat-a"
write_tasks "$WORK/wt-w/.project/tasks/tasks-ww.md" "in-progress" "plan-w.md" "ui"
out="$(sh "$MATRIX")"
assert_contains "case-e: ready vs in-flight claim pairs, plan read from that worktree" \
  "pair=.project/tasks/tasks-aa.md:$WORK/wt-w/.project/tasks/tasks-ww.md	verdict=shared-feature	features=feat-a	artifacts=none" "$out"

# --- Case h: same tasks file ready-in-primary AND claimed by an in-flight
# worktree -> verdict=claimed, no feature/artifact comparison ---
git branch feat-c
git worktree add -q "$WORK/wt-c" feat-c
write_plan "$WORK/wt-c/.project/plans/plan-a.md" "feat-a"
write_tasks "$WORK/wt-c/.project/tasks/tasks-aa.md" "in-progress" "plan-a.md" "constitution"
out="$(sh "$MATRIX")"
assert_contains "case-h: same-file primary+worktree pair -> claimed" \
  "pair=.project/tasks/tasks-aa.md:$WORK/wt-c/.project/tasks/tasks-aa.md	verdict=claimed	features=none	artifacts=none" "$out"

exit "$fail"
