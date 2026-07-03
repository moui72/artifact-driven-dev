#!/usr/bin/env sh
# Regression test for hook-lint-on-write.sh: silent on non-.project writes,
# silent on clean .project writes, emits valid JSON with additionalContext
# on a violating .project write.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
HOOK="$SCRIPT_DIR/hook-lint-on-write.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0

# --- Case 1: file outside .project/ — must be silent ---
out="$(printf '{"tool_input":{"file_path":"%s/README.md"},"cwd":"%s"}' "$WORK" "$WORK" | sh "$HOOK")"
if [ -n "$out" ]; then
  echo "FAIL: non-.project write should be silent, got: $out"
  fail=1
else
  echo "ok: non-.project write is silent"
fi

# --- Case 2: clean .project/ (good fixture) — must be silent ---
mkdir -p "$WORK/good/scripts"
cp "$SCRIPT_DIR/lint-project.sh" "$WORK/good/scripts/"
cp -r "$REPO_DIR/tests/fixtures/good-project/.project" "$WORK/good/.project"
out="$(printf '{"tool_input":{"file_path":"%s/good/.project/artifacts/constitution.md"},"cwd":"%s/good"}' "$WORK" "$WORK" | sh "$HOOK")"
if [ -n "$out" ]; then
  echo "FAIL: clean .project write should be silent, got: $out"
  fail=1
else
  echo "ok: clean .project write is silent"
fi

# --- Case 3: violating .project/ (bad fixture) — must emit valid JSON with additionalContext ---
mkdir -p "$WORK/bad/scripts"
cp "$SCRIPT_DIR/lint-project.sh" "$WORK/bad/scripts/"
cp -r "$REPO_DIR/tests/fixtures/bad-project/.project" "$WORK/bad/.project"
out="$(printf '{"tool_input":{"file_path":"%s/bad/.project/artifacts/constitution.md"},"cwd":"%s/bad"}' "$WORK" "$WORK" | sh "$HOOK")"
if [ -z "$out" ]; then
  echo "FAIL: violating .project write should emit context, got nothing"
  fail=1
elif ! printf '%s' "$out" | jq -e '.hookSpecificOutput.additionalContext' > /dev/null 2>&1; then
  echo "FAIL: output is not valid JSON with additionalContext: $out"
  fail=1
else
  echo "ok: violating .project write emits valid JSON with findings"
fi

exit "$fail"
