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

exit "$fail"
