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
  # $1 = repo, $2 = status
  mkdir -p "$1/.project/tasks"
  cat > "$1/.project/tasks/tasks-demo-0000.md" <<EOF
---
plan: plan-demo-2026-07-05.md
generated: 2026-07-05
status: $2
---

# Tasks
- [x] T001 [artifacts: constitution] Demo task
EOF
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

exit "$fail"
