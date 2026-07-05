#!/usr/bin/env sh
# Regression test for completion-flip-check.sh: the orphaned-completion-flip
# detector. Builds a throwaway repo with a .project/ directory at its root
# (tasks/, plans/, artifacts/features.md) and exercises each short-circuit
# plus the one case that should actually print an orphaned slug.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CHECK="$SCRIPT_DIR/completion-flip-check.sh"

WORK="$(cd "$(mktemp -d)" && pwd -P)"
trap 'rm -rf "$WORK"' EXIT

git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
assert_eq() {
  label="$1"; expected="$2"; actual="$3"
  if [ "$expected" != "$actual" ]; then
    echo "FAIL: $label — expected '$expected', got '$actual'"
    fail=1
  else
    echo "ok: $label"
  fi
}

write_features() {
  # $1 = repo, $2 = status word for slug "demo-feature"
  mkdir -p "$1/.project/artifacts"
  cat > "$1/.project/artifacts/features.md" <<EOF
---
last_updated: 2026-07-05
---

# Features

## Demo feature

_Slug: \`demo-feature\` · Status: $2 · Logged 2026-07-05_
Demo.
EOF
}

write_plan() {
  # $1 = repo, $2 = branch field, $3 = features field
  mkdir -p "$1/.project/plans"
  cat > "$1/.project/plans/plan-demo-2026-07-05.md" <<EOF
---
status: approved
branch: $2
created: 2026-07-05
features: $3
---

# Plan
EOF
}

write_tasks() {
  # $1 = repo, $2 = status, $3 = optional worktree_branch value
  mkdir -p "$1/.project/tasks"
  {
    printf -- '---\n'
    printf 'plan: plan-demo-2026-07-05.md\n'
    printf 'generated: 2026-07-05\n'
    printf 'status: %s\n' "$2"
    [ -n "$3" ] && printf 'worktree_branch: %s\n' "$3"
    printf -- '---\n\n# Tasks\n- [x] T001 [artifacts: constitution] Demo task\n'
  } > "$1/.project/tasks/tasks-demo-0000.md"
}

# --- shared repo setup: main with one commit ---
repo="$WORK/repo"
mkdir -p "$repo" && cd "$repo"
git init -q -b main
git commit -q --allow-empty -m init

# --- Case 1: tasks file not completed -> silent ---
write_tasks "$repo" "in-progress"
write_plan "$repo" "some-branch" "[demo-feature]"
write_features "$repo" "tasked"
out="$(sh "$CHECK" "$repo/.project/tasks/tasks-demo-0000.md")"
assert_eq "case1: not completed -> silent" "" "$out"

# --- Case 2: completed, but plan's branch never created/merged -> silent ---
write_tasks "$repo" "completed"
out="$(sh "$CHECK" "$repo/.project/tasks/tasks-demo-0000.md")"
assert_eq "case2: unmerged branch -> silent" "" "$out"

# --- Case 3: completed, branch exists but unmerged (diverged) -> silent ---
git checkout -q -b unmerged-branch
git commit -q --allow-empty -m "unmerged work"
git checkout -q main
write_plan "$repo" "unmerged-branch" "[demo-feature]"
out="$(sh "$CHECK" "$repo/.project/tasks/tasks-demo-0000.md")"
assert_eq "case3: diverged branch -> silent" "" "$out"

# --- Case 4: completed, branch merged, feature still tasked -> prints slug ---
git checkout -q -b merged-branch
git commit -q --allow-empty -m "merged work"
git checkout -q main
git merge -q merged-branch -m "merge merged-branch"
write_plan "$repo" "merged-branch" "[demo-feature]"
out="$(sh "$CHECK" "$repo/.project/tasks/tasks-demo-0000.md")"
assert_eq "case4: merged + tasked -> prints slug" "demo-feature" "$out"

# --- Case 5: same as case 4 but feature already implemented -> silent ---
write_features "$repo" "implemented"
out="$(sh "$CHECK" "$repo/.project/tasks/tasks-demo-0000.md")"
assert_eq "case5: merged + already implemented -> silent" "" "$out"

# --- Case 6: plan has no bound features ([]) -> silent ---
write_features "$repo" "tasked"
write_plan "$repo" "merged-branch" "[]"
out="$(sh "$CHECK" "$repo/.project/tasks/tasks-demo-0000.md")"
assert_eq "case6: no bound features -> silent" "" "$out"

# --- Case 7 (delegated scenario): plan's own branch: field is a name that
# was never created/merged (the ephemeral-name-mismatch bug), but the
# tasks file's worktree_branch: (a DIFFERENT, real branch) IS merged and
# the feature is still tasked -> must follow worktree_branch, print slug ---
git checkout -q -b agent-actual-branch
git commit -q --allow-empty -m "actual delegated work"
git checkout -q main
git merge -q agent-actual-branch -m "merge agent-actual-branch"
write_features "$repo" "tasked"
write_plan "$repo" "never-created-branch" "[demo-feature]"
write_tasks "$repo" "completed" "agent-actual-branch"
out="$(sh "$CHECK" "$repo/.project/tasks/tasks-demo-0000.md")"
assert_eq "case7: delegated — follows worktree_branch, not plan.branch" "demo-feature" "$out"

# --- Case 8: same as case 7, but worktree_branch is unmerged -> silent,
# even though plan.branch is unrelated/nonexistent (would be a false
# negative either way, but confirms worktree_branch is actually consulted
# rather than always falling back) ---
git checkout -q -b agent-unmerged-branch
git commit -q --allow-empty -m "unmerged delegated work"
git checkout -q main
write_tasks "$repo" "completed" "agent-unmerged-branch"
out="$(sh "$CHECK" "$repo/.project/tasks/tasks-demo-0000.md")"
assert_eq "case8: delegated, worktree_branch unmerged -> silent" "" "$out"

exit "$fail"
