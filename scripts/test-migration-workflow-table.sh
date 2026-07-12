#!/usr/bin/env sh
# Regression test for migrations/0008-workflow-table.sh: a target carrying
# .project/WORKFLOW.md gets its "## Skills" section upserted from the
# shipped template (so consumers don't keep a table of dead pre-v1.0.0
# commands); a target without WORKFLOW.md is a strict no-op; idempotent.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
MIG="$REPO_ROOT/migrations/0008-workflow-table.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# case 1: WORKFLOW.md with a stale skills table -> table replaced, other
# sections untouched
mkdir -p "$WORK/a/.project"
cat > "$WORK/a/.project/WORKFLOW.md" <<'EOF'
# Project Workflow Guide

Intro prose the migration must not touch.

## Skills

| Command | What it does |
|---|---|
| `/ardd-bootstrap` | dead command from an old install |
| `/ardd-converge` | another dead command |

## Operating mode

Custom operating-mode prose that must survive.
EOF
sh "$MIG" "$WORK/a" >/dev/null 2>&1 || bad "case1: migration exited non-zero"
grep -q '/ardd-bootstrap' "$WORK/a/.project/WORKFLOW.md" \
  && bad "case1: dead command still in table" || ok "case1: dead commands gone"
grep -q '/ardd-init' "$WORK/a/.project/WORKFLOW.md" \
  && ok "case1: current commands present" || bad "case1: current commands missing"
grep -q 'Intro prose the migration must not touch.' "$WORK/a/.project/WORKFLOW.md" \
  && ok "case1: intro prose untouched" || bad "case1: intro prose lost"
grep -q 'Custom operating-mode prose that must survive.' "$WORK/a/.project/WORKFLOW.md" \
  && ok "case1: later section untouched" || bad "case1: later section lost"

# case 2: idempotent — second run produces the identical file
cp "$WORK/a/.project/WORKFLOW.md" "$WORK/first-pass"
sh "$MIG" "$WORK/a" >/dev/null 2>&1 || bad "case2: second run exited non-zero"
if diff -q "$WORK/first-pass" "$WORK/a/.project/WORKFLOW.md" >/dev/null; then
  ok "case2: idempotent"
else
  bad "case2: second run changed the file"
fi

# case 3: no WORKFLOW.md -> strict no-op, exit 0, nothing created
mkdir -p "$WORK/b/.project"
sh "$MIG" "$WORK/b" >/dev/null 2>&1 && ok "case3: no-op exit 0" || bad "case3: should exit 0"
[ ! -f "$WORK/b/.project/WORKFLOW.md" ] \
  && ok "case3: nothing created" || bad "case3: created WORKFLOW.md from nothing"

[ "$fail" -eq 0 ] || { echo "test-migration-workflow-table: FAILURES"; exit 1; }
echo "test-migration-workflow-table: all cases pass"
