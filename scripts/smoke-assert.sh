#!/usr/bin/env sh
# smoke-assert.sh — deterministic post-run assertions for behavioral
# smoke scenarios (constitution Quality Standards, behavioral-test tier).
# Given a target project directory that a headless skill run just
# mutated, verify the file outcomes. Needs no API key — pure file checks.
#
# Always runs lint-project.sh against the target (statuses legal,
# cross-refs resolve). Additional assertions:
#   --exists <relpath>            file must exist
#   --absent <relpath>            file must not exist
#   --feature <slug> <status>     register entry must have that status
#
# Usage: smoke-assert.sh <target-dir> [assertions...]
# Exit 0 if every assertion holds, 1 otherwise.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-}"
[ -n "$TARGET" ] && [ -d "$TARGET" ] || { echo "usage: smoke-assert.sh <target-dir> [assertions...]" >&2; exit 1; }
shift

fail=0
report() { echo "smoke-assert: $1"; fail=1; }

if ! "$SCRIPT_DIR/lint-project.sh" "$TARGET" >/dev/null 2>&1; then
  report "lint-project.sh failed against $TARGET:"
  "$SCRIPT_DIR/lint-project.sh" "$TARGET" 2>&1 | sed 's/^/  /' || true
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --exists)
      [ -f "$TARGET/$2" ] || report "expected file missing: $2"
      shift 2 ;;
    --absent)
      [ ! -e "$TARGET/$2" ] || report "file should not exist: $2"
      shift 2 ;;
    --feature)
      f="$TARGET/.project/features/$2.md"
      if [ ! -f "$f" ]; then
        report "no register entry for feature '$2'"
      else
        actual="$(sed -n 's/^status:[[:space:]]*\([a-z-]*\).*/\1/p' "$f" | head -1)"
        [ "$actual" = "$3" ] || report "feature '$2' status '$actual', expected '$3'"
      fi
      shift 3 ;;
    *)
      echo "smoke-assert: unknown assertion '$1'" >&2; exit 1 ;;
  esac
done

[ "$fail" -eq 0 ] && echo "smoke-assert: all assertions hold for $TARGET"
exit "$fail"
