#!/usr/bin/env sh
# Regression test for ardd-state.sh — the deterministic state-mutation
# dispatcher (constitution Principle II: prose decides when, scripts
# write). Each subcommand gets good + bad cases against throwaway
# .project/ fixtures under a temp dir.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATE="$SCRIPT_DIR/ardd-state.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()   { echo "ok: $1"; }
bad()  { echo "FAIL: $1"; fail=1; }

# assert_exit <label> <expected-exit> <actual-exit>
assert_exit() {
  [ "$3" -eq "$2" ] && ok "$1" || bad "$1 — expected exit $2, got $3"
}
# assert_grep <label> <pattern> <file-or-string-mode:file> <target>
assert_file_grep() {
  if grep -q "$2" "$3"; then ok "$1"; else bad "$1 — pattern '$2' not in $3"; fi
}

# --- Case: no arguments prints usage and exits 2 ---
set +e
out="$(sh "$STATE" 2>&1)"; rc=$?
set -e
assert_exit "no-args exits 2" 2 "$rc"
case "$out" in
  *usage*|*Usage*) ok "no-args prints usage" ;;
  *) bad "no-args prints usage — got: $out" ;;
esac

# --- Case: unknown subcommand exits 2 ---
set +e
out="$(sh "$STATE" no-such-subcommand 2>&1)"; rc=$?
set -e
assert_exit "unknown subcommand exits 2" 2 "$rc"

# --- slug: kebab sanitization ---
assert_eq() { [ "$3" = "$2" ] && ok "$1" || bad "$1 — expected '$2', got '$3'"; }

assert_eq "slug: simple"      "add-user-auth" "$(sh "$STATE" slug 'Add User Auth')"
assert_eq "slug: punctuation" "fix-api-v2-parsing" "$(sh "$STATE" slug 'fix: API/v2 (parsing!)')"
assert_eq "slug: collapse runs + trim edges" "a-b" "$(sh "$STATE" slug '--a---b--')"
long="$(sh "$STATE" slug 'this is a very long feature description that keeps going and going')"
[ "${#long}" -le 30 ] && ok "slug: truncated to <=30" || bad "slug: truncated to <=30 — got ${#long} chars: $long"
case "$long" in *-) bad "slug: no trailing dash after truncation — got '$long'" ;; *) ok "slug: no trailing dash after truncation" ;; esac
set +e
sh "$STATE" slug '' >/dev/null 2>&1; rc=$?
set -e
assert_exit "slug: empty input exits 2" 2 "$rc"
set +e
sh "$STATE" slug '!!!' >/dev/null 2>&1; rc=$?
set -e
assert_exit "slug: no alphanumerics exits 1" 1 "$rc"

# --- mint: filename minting ---
today="$(date +%Y-%m-%d)"
assert_eq "mint plan: date-stamped" "plan-auth-flow-$today.md" "$(sh "$STATE" mint plan auth-flow)"
t1="$(sh "$STATE" mint tasks auth-flow)"
case "$t1" in
  tasks-auth-flow-[0-9a-f][0-9a-f][0-9a-f][0-9a-f].md) ok "mint tasks: slug + 4-hex" ;;
  *) bad "mint tasks: slug + 4-hex — got '$t1'" ;;
esac
t2="$(sh "$STATE" mint tasks auth-flow)"
[ "$t1" != "$t2" ] && ok "mint tasks: tokens unique across calls" || bad "mint tasks: tokens unique across calls — got '$t1' twice"
f1="$(sh "$STATE" mint feedback repo-critique)"
case "$f1" in
  feedback-repo-critique-[0-9a-f][0-9a-f][0-9a-f][0-9a-f].md) ok "mint feedback: slug + 4-hex" ;;
  *) bad "mint feedback: slug + 4-hex — got '$f1'" ;;
esac
assert_eq "mint research: date-stamped" "research-sqlite-fts-$today.md" "$(sh "$STATE" mint research sqlite-fts)"
set +e
sh "$STATE" mint nope x >/dev/null 2>&1; rc=$?
set -e
assert_exit "mint: unknown kind exits 2" 2 "$rc"
set +e
sh "$STATE" mint plan 'Not A Slug!' >/dev/null 2>&1; rc=$?
set -e
assert_exit "mint: rejects non-kebab slug" 1 "$rc"

# --- plan-flip ---
PLANS="$WORK/p1/.project/plans"; mkdir -p "$PLANS"
cat > "$PLANS/plan-x-2026-07-06.md" <<'EOF'
---
status: draft        # draft -> approved -> superseded
branch: x
created: 2026-07-06
---
# Plan
EOF
sh "$STATE" plan-flip "$PLANS/plan-x-2026-07-06.md" approved
assert_file_grep "plan-flip: draft->approved" "^status: *approved" "$PLANS/plan-x-2026-07-06.md"
assert_file_grep "plan-flip: trailing comment preserved" "# draft -> approved -> superseded" "$PLANS/plan-x-2026-07-06.md"
set +e
sh "$STATE" plan-flip "$PLANS/plan-x-2026-07-06.md" approved >/dev/null 2>&1; rc=$?
set -e
assert_exit "plan-flip: same-state is a no-op success" 0 "$rc"
sh "$STATE" plan-flip "$PLANS/plan-x-2026-07-06.md" superseded >/dev/null
assert_file_grep "plan-flip: approved->superseded" "^status: *superseded" "$PLANS/plan-x-2026-07-06.md"
set +e
sh "$STATE" plan-flip "$PLANS/plan-x-2026-07-06.md" approved >/dev/null 2>&1; rc=$?
set -e
assert_exit "plan-flip: superseded->approved refused" 1 "$rc"
set +e
sh "$STATE" plan-flip "$PLANS/no-such-plan.md" approved >/dev/null 2>&1; rc=$?
set -e
assert_exit "plan-flip: missing file refused" 1 "$rc"
printf '# no frontmatter\n' > "$PLANS/plan-bad-2026-07-06.md"
set +e
sh "$STATE" plan-flip "$PLANS/plan-bad-2026-07-06.md" approved >/dev/null 2>&1; rc=$?
set -e
assert_exit "plan-flip: missing status field refused" 1 "$rc"
set +e
sh "$STATE" plan-flip "$PLANS/plan-x-2026-07-06.md" bogus >/dev/null 2>&1; rc=$?
set -e
assert_exit "plan-flip: unknown target status usage error" 2 "$rc"

# --- tasks-flip / task-check / next-task ---
TASKS="$WORK/p1/.project/tasks"; mkdir -p "$TASKS"
TF="$TASKS/tasks-x-ab12.md"
cat > "$TF" <<'EOF'
---
plan: plan-x-2026-07-06.md
generated: 2026-07-06
status: generating   # generating -> ready -> in-progress -> completed
---
# Tasks
## Phase 1
- [ ] T001 [artifacts: constitution] First task
- [ ] T002 [parallel] Second task
EOF
sh "$STATE" tasks-flip "$TF" ready >/dev/null
assert_file_grep "tasks-flip: generating->ready" "^status: *ready" "$TF"
set +e
sh "$STATE" tasks-flip "$TF" completed >/dev/null 2>&1; rc=$?
set -e
assert_exit "tasks-flip: ready->completed refused (skips in-progress)" 1 "$rc"
sh "$STATE" tasks-flip "$TF" in-progress >/dev/null
assert_file_grep "tasks-flip: ready->in-progress" "^status: *in-progress" "$TF"

nt="$(sh "$STATE" next-task "$TF")"
case "$nt" in
  *T001*) ok "next-task: finds first unchecked" ;;
  *) bad "next-task: finds first unchecked — got '$nt'" ;;
esac
sh "$STATE" task-check "$TF" T001 >/dev/null
assert_file_grep "task-check: T001 checked" "^- \[x\] T001 " "$TF"
set +e
sh "$STATE" task-check "$TF" T001 >/dev/null 2>&1; rc=$?
set -e
assert_exit "task-check: already-checked is no-op success" 0 "$rc"
set +e
sh "$STATE" task-check "$TF" T099 >/dev/null 2>&1; rc=$?
set -e
assert_exit "task-check: unknown task ID refused" 1 "$rc"
nt="$(sh "$STATE" next-task "$TF")"
case "$nt" in
  *T002*) ok "next-task: advances to T002" ;;
  *) bad "next-task: advances to T002 — got '$nt'" ;;
esac
sh "$STATE" task-check "$TF" T002 >/dev/null
set +e
sh "$STATE" next-task "$TF" >/dev/null 2>&1; rc=$?
set -e
assert_exit "next-task: exit 1 when all complete" 1 "$rc"
sh "$STATE" tasks-flip "$TF" completed >/dev/null
assert_file_grep "tasks-flip: in-progress->completed" "^status: *completed" "$TF"
set +e
sh "$STATE" tasks-flip "$TF" abandoned >/dev/null 2>&1; rc=$?
set -e
assert_exit "tasks-flip: completed->abandoned refused" 1 "$rc"

# --- feedback-mark / feedback-planned ---
FB="$WORK/p1/.project/feedback"; mkdir -p "$FB"
FF="$FB/feedback-x-cd34.md"
cat > "$FF" <<'EOF'
---
status: open      # open -> planned
created: 2026-07-06
plan: null        # set to the consuming plan's filename once planned
---
# Feedback
## Bugs
- [ ] F001 Thing is broken [artifacts: constitution]
## UX
- [ ] F002 Thing is confusing
EOF
sh "$STATE" feedback-mark "$FF" F001 x >/dev/null
assert_file_grep "feedback-mark: F001 -> [x]" "^- \[x\] F001 " "$FF"
sh "$STATE" feedback-mark "$FF" F002 - >/dev/null
assert_file_grep "feedback-mark: F002 -> [-]" "^- \[-\] F002 " "$FF"
set +e
sh "$STATE" feedback-mark "$FF" F002 x >/dev/null 2>&1; rc=$?
set -e
assert_exit "feedback-mark: re-marking a resolved item refused" 1 "$rc"
set +e
sh "$STATE" feedback-mark "$FF" F009 x >/dev/null 2>&1; rc=$?
set -e
assert_exit "feedback-mark: unknown item refused" 1 "$rc"

FF2="$FB/feedback-y-ef56.md"
sed 's/status: open/status: open/' "$FF" > "$FF2"   # copy, all items resolved
sh "$STATE" feedback-planned "$FF2" plan-x-2026-07-06.md >/dev/null
assert_file_grep "feedback-planned: status flipped" "^status: *planned" "$FF2"
assert_file_grep "feedback-planned: plan stamped" "^plan: plan-x-2026-07-06.md" "$FF2"
cat > "$FF" <<'EOF'
---
status: open
created: 2026-07-06
plan: null
---
- [ ] F001 Unresolved item
EOF
set +e
sh "$STATE" feedback-planned "$FF" plan-x-2026-07-06.md >/dev/null 2>&1; rc=$?
set -e
assert_exit "feedback-planned: refused while items unresolved" 1 "$rc"

exit "$fail"
