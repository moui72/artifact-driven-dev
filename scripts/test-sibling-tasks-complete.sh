#!/usr/bin/env sh
# Regression test for sibling-tasks-complete.sh: single tasks file, multiple
# siblings still in progress, all completed, and abandoned siblings that
# shouldn't block completion (but shouldn't fake it either).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CHECK="$SCRIPT_DIR/sibling-tasks-complete.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

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

write_tasks() {
  path="$1"; plan="$2"; status="$3"
  cat > "$path" <<EOF
---
plan: $plan
generated: 2026-01-01
status: $status
---

# Tasks
EOF
}

# --- Case 1: single tasks file, completed ---
dir="$WORK/case1"; mkdir -p "$dir"
write_tasks "$dir/tasks-foo-aaaa.md" "plan-foo-2026-01-01.md" "completed"
out="$(sh "$CHECK" "$dir/tasks-foo-aaaa.md")"
assert_contains "case1: plan" "plan=plan-foo-2026-01-01.md" "$out"
assert_contains "case1: siblings" "siblings=tasks-foo-aaaa.md" "$out"
assert_contains "case1: all_complete true" "all_complete=true" "$out"

# --- Case 2: two siblings, one still in-progress ---
dir="$WORK/case2"; mkdir -p "$dir"
write_tasks "$dir/tasks-foo-aaaa.md" "plan-foo-2026-01-01.md" "completed"
write_tasks "$dir/tasks-foo-bbbb.md" "plan-foo-2026-01-01.md" "in-progress"
out="$(sh "$CHECK" "$dir/tasks-foo-aaaa.md")"
assert_contains "case2: all_complete false" "all_complete=false" "$out"

# --- Case 3: two siblings, both completed ---
dir="$WORK/case3"; mkdir -p "$dir"
write_tasks "$dir/tasks-foo-aaaa.md" "plan-foo-2026-01-01.md" "completed"
write_tasks "$dir/tasks-foo-bbbb.md" "plan-foo-2026-01-01.md" "completed"
out="$(sh "$CHECK" "$dir/tasks-foo-aaaa.md")"
assert_contains "case3: all_complete true" "all_complete=true" "$out"

# --- Case 4: unrelated plan's tasks file isn't counted as a sibling ---
dir="$WORK/case4"; mkdir -p "$dir"
write_tasks "$dir/tasks-foo-aaaa.md" "plan-foo-2026-01-01.md" "completed"
write_tasks "$dir/tasks-bar-cccc.md" "plan-bar-2026-01-01.md" "in-progress"
out="$(sh "$CHECK" "$dir/tasks-foo-aaaa.md")"
assert_contains "case4: siblings excludes other plan" "siblings=tasks-foo-aaaa.md" "$out"
assert_contains "case4: all_complete true" "all_complete=true" "$out"

# --- Case 5: an abandoned sibling doesn't block completion ---
dir="$WORK/case5"; mkdir -p "$dir"
write_tasks "$dir/tasks-foo-aaaa.md" "plan-foo-2026-01-01.md" "abandoned"
write_tasks "$dir/tasks-foo-bbbb.md" "plan-foo-2026-01-01.md" "completed"
out="$(sh "$CHECK" "$dir/tasks-foo-bbbb.md")"
assert_contains "case5: all_complete true despite abandoned sibling" "all_complete=true" "$out"

# --- Case 6: every sibling abandoned, none completed — not done ---
dir="$WORK/case6"; mkdir -p "$dir"
write_tasks "$dir/tasks-foo-aaaa.md" "plan-foo-2026-01-01.md" "abandoned"
write_tasks "$dir/tasks-foo-bbbb.md" "plan-foo-2026-01-01.md" "abandoned"
out="$(sh "$CHECK" "$dir/tasks-foo-aaaa.md")"
assert_contains "case6: all abandoned, none completed -> false" "all_complete=false" "$out"

exit "$fail"
