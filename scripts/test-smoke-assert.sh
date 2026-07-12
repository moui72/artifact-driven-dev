#!/usr/bin/env sh
# Regression test for smoke-assert.sh — the deterministic post-run checker
# for behavioral smoke scenarios (runs without any API key; pure file
# checks against a target project directory).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ASSERT="$SCRIPT_DIR/smoke-assert.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

T="$WORK/t"
mkdir -p "$T/.project/artifacts" "$T/.project/features"
cat > "$T/.project/artifacts/constitution.md" <<'EOF'
---
name: constitution
status: stable
last_updated: 2026-07-06
---
# C
EOF
cat > "$T/.project/features/dark-mode.md" <<'EOF'
---
slug: dark-mode
status: backlogged
logged: 2026-07-06
---
Dark mode.
EOF

# --- passing run: lint clean + exists + feature status ---
sh "$ASSERT" "$T" --exists .project/features/dark-mode.md --feature dark-mode backlogged \
  && ok "passing assertions exit 0" || bad "passing assertions exit 0"

# --- failing: expected file absent ---
set +e
sh "$ASSERT" "$T" --exists .project/plans/plan-x.md >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && ok "missing --exists fails" || bad "missing --exists fails"

# --- failing: wrong feature status ---
set +e
sh "$ASSERT" "$T" --feature dark-mode implemented >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && ok "wrong feature status fails" || bad "wrong feature status fails"

# --- failing: --absent present ---
set +e
sh "$ASSERT" "$T" --absent .project/features/dark-mode.md >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && ok "--absent violated fails" || bad "--absent violated fails"

# --- failing: lint violation in target (bad feature status enum) ---
sed -i.bak 's/^status: backlogged/status: shipped/' "$T/.project/features/dark-mode.md" && rm -f "$T/.project/features/dark-mode.md.bak"
set +e
sh "$ASSERT" "$T" >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && ok "lint violation fails the run" || bad "lint violation fails the run"

# --- scenario-2 assertion set: plan/tasks status flags (simulated
# post-/ardd-implement state; runs with no API key) ---
mkdir -p "$T/.project/plans" "$T/.project/tasks"
sed -i.bak 's/^status: shipped/status: implemented/' "$T/.project/features/dark-mode.md" && rm -f "$T/.project/features/dark-mode.md.bak"
cat > "$T/.project/plans/plan-dm-2026-07-06.md" <<'EOF'
---
status: approved
branch: dm
created: 2026-07-06
features: [dark-mode]
---
# P
EOF
cat > "$T/.project/tasks/tasks-dm-aaaa.md" <<'EOF'
---
plan: plan-dm-2026-07-06.md
generated: 2026-07-06
status: completed
---
# Tasks
- [x] T001 done
EOF
sh "$ASSERT" "$T" \
  --plan-status .project/plans/plan-dm-2026-07-06.md approved \
  --tasks-status .project/tasks/tasks-dm-aaaa.md completed \
  --feature dark-mode implemented \
  && ok "scenario-2 set passes" || bad "scenario-2 set passes"
set +e
sh "$ASSERT" "$T" --plan-status .project/plans/plan-dm-2026-07-06.md draft >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && ok "--plan-status wrong value fails" || bad "--plan-status wrong value fails"
set +e
sh "$ASSERT" "$T" --tasks-status .project/tasks/tasks-dm-aaaa.md in-progress >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && ok "--tasks-status wrong value fails" || bad "--tasks-status wrong value fails"

# --- --task-checked: checked passes; unchecked and missing ids fail ---
cat > "$T/.project/tasks/tasks-dm-bbbb.md" <<'EOF'
---
plan: plan-dm-2026-07-06.md
generated: 2026-07-06
status: in-progress
---
# Tasks
- [x] T001 already reconciled
- [ ] T002 still open
EOF
sh "$ASSERT" "$T" --task-checked .project/tasks/tasks-dm-bbbb.md T001 \
  && ok "--task-checked passes on a checked task" || bad "--task-checked passes on a checked task"
set +e
sh "$ASSERT" "$T" --task-checked .project/tasks/tasks-dm-bbbb.md T002 >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && ok "--task-checked fails on an unchecked task" || bad "--task-checked fails on an unchecked task"
set +e
sh "$ASSERT" "$T" --task-checked .project/tasks/tasks-dm-bbbb.md T099 >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && ok "--task-checked fails on a missing task id" || bad "--task-checked fails on a missing task id"
# T001 must not match T0011 (id is a whole token)
cat >> "$T/.project/tasks/tasks-dm-bbbb.md" <<'EOF'
- [x] T0011 lookalike id
EOF
set +e
sh "$ASSERT" "$T" --task-checked .project/tasks/tasks-dm-bbbb.md T0012 >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && ok "--task-checked does not prefix-match lookalike ids" || bad "--task-checked does not prefix-match lookalike ids"

exit "$fail"
