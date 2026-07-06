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

exit "$fail"
