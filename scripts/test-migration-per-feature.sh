#!/usr/bin/env sh
# Regression test for migrations/0003-per-feature-files.sh: splits a
# legacy single-file features.md register into .project/features/<slug>.md
# files (per the constitution's 2026-07-06 standing decision), removes the
# legacy file (a stub would trip lint-project's both-registers violation),
# and is idempotent.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MIG="$(dirname "$SCRIPT_DIR")/migrations/0003-per-feature-files.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }
assert_grep() { if grep -q "$2" "$3"; then ok "$1"; else bad "$1 — pattern '$2' not in $3"; fi }

mkdir -p "$WORK/t/.project/artifacts"
cat > "$WORK/t/.project/artifacts/features.md" <<'EOF'
---
last_updated: 2026-07-03
---

# Features

## Pre-commit lint enforcement

_Slug: `pre-commit-lint-hook` · Status: implemented · Logged 2026-07-03 · Plan: plan-pre-commit-lint-hook-2026-07-03.md · Tasks: tasks-pre-commit-lint-hook-afed.md_
A local git pre-commit hook runs the lint scripts.
Why: the standard is stated but not implemented.

## Widget export

_Slug: `widget-export` · Status: backlogged · Logged 2026-07-01 · GH: #42_
Export widgets to CSV.
EOF

sh "$MIG" "$WORK/t" > "$WORK/out1.txt"

F1="$WORK/t/.project/features/pre-commit-lint-hook.md"
F2="$WORK/t/.project/features/widget-export.md"
[ -f "$F1" ] && ok "entry 1 file created" || bad "entry 1 file created — missing $F1"
[ -f "$F2" ] && ok "entry 2 file created" || bad "entry 2 file created — missing $F2"
assert_grep "entry 1: slug" "^slug: pre-commit-lint-hook" "$F1"
assert_grep "entry 1: status" "^status: implemented" "$F1"
assert_grep "entry 1: logged" "^logged: 2026-07-03" "$F1"
assert_grep "entry 1: plan carried" "^plan: plan-pre-commit-lint-hook-2026-07-03.md" "$F1"
assert_grep "entry 1: tasks carried" "^tasks: tasks-pre-commit-lint-hook-afed.md" "$F1"
assert_grep "entry 1: body carried" "pre-commit hook runs the lint scripts" "$F1"
assert_grep "entry 1: why carried" "^Why: the standard is stated" "$F1"
assert_grep "entry 2: gh_issue carried (number only)" "^gh_issue: 42" "$F2"
[ ! -f "$WORK/t/.project/artifacts/features.md" ] && ok "legacy features.md removed" || bad "legacy features.md removed — still present"

# idempotent: second run with nothing to do succeeds silently
sh "$MIG" "$WORK/t" > "$WORK/out2.txt"
[ -s "$WORK/out2.txt" ] && bad "re-run is silent — got output: $(cat "$WORK/out2.txt")" || ok "re-run is silent"

# a project with neither register: no-op success
mkdir -p "$WORK/empty/.project/artifacts"
sh "$MIG" "$WORK/empty" >/dev/null && ok "no register: no-op success" || bad "no register: no-op success"

exit "$fail"
