#!/usr/bin/env sh
# tasks-list.sh — deterministic tasks-file pick list. One line per
# .project/tasks/tasks-*.md:
#
#   <filename>\t<status>\t<checked>/<total>\t<plan-filename>
#
# Files at status: abandoned are excluded unless --all is given (they're
# superseded forks with nothing to execute against). Replaces the
# pick-list prose previously duplicated across /ardd-implement,
# /ardd-plan step 11 (constitution Principle II).
#
# Usage: tasks-list.sh [--all] [target-dir]     (default: .)

set -e

ALL=0
[ "${1:-}" = "--all" ] && { ALL=1; shift; }
TARGET="${1:-.}"
TASKS_DIR="$TARGET/.project/tasks"

[ -d "$TASKS_DIR" ] || exit 0

fm_field() {
  awk '/^---$/{n++; next} n==1' "$1" \
    | grep -E "^$2:" | head -1 \
    | sed -E "s/^$2:[[:space:]]*//; s/[[:space:]]*(#.*)?\$//"
}

for f in "$TASKS_DIR"/tasks-*.md; do
  [ -f "$f" ] || continue
  status="$(fm_field "$f" status)"
  [ "$status" = "abandoned" ] && [ "$ALL" -eq 0 ] && continue
  plan="$(fm_field "$f" plan)"
  checked="$(grep -c '^- \[x\] ' "$f" || true)"
  unchecked="$(grep -c '^- \[ \] ' "$f" || true)"
  total=$((checked + unchecked))
  printf '%s\t%s\t%s/%s\t%s\n' "$(basename "$f")" "$status" "$checked" "$total" "$plan"
done
