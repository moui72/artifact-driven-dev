#!/usr/bin/env sh
# defects-unsurfaced.sh — print the DEFECTS.md entries that no plan has
# surfaced to the user yet, as "<id>\t<claim text>" lines.
#
# An entry's stable identifier is the first 8 chars of the shasum of its
# **Claim:** text — the same recipe /ardd-plan's prose used to describe.
# Every plan's `surfaced-defects:` frontmatter list is unioned into the
# already-surfaced set; membership there (whether the user accepted or
# declined the fix) suppresses re-prompting forever. Pure set arithmetic
# on file state — previously LLM-performed, now scripted (constitution
# Principle II).
#
# Two explicit-selection modes BYPASS the surfaced-union filter (used by
# /ardd-plan's defect:<id> / defects arguments, which deliberately re-offer
# entries the user already saw):
#   --id <id>   print the named entry; repeatable; an id with no matching
#               DEFECTS.md entry is an error (exit 1)
#   --all       print every current entry
#
# Usage: defects-unsurfaced.sh [--all | --id <id> ...] [target-dir]
# (default target: .)
# Exit 0 always unless inputs are malformed or a --id misses; silent when
# nothing is unsurfaced (or DEFECTS.md is absent/all-clear).

set -e

MODE="default"
IDS=""
TARGET="."
while [ $# -gt 0 ]; do
  case "$1" in
    --all)
      MODE="all"
      shift
      ;;
    --id)
      if [ $# -lt 2 ] || [ -z "$2" ]; then
        echo "defects-unsurfaced: --id requires an identifier" >&2
        exit 2
      fi
      [ "$MODE" = "all" ] || MODE="ids"
      IDS="$IDS $2"
      shift 2
      ;;
    *)
      TARGET="$1"
      shift
      ;;
  esac
done

DEFECTS="$TARGET/.project/DEFECTS.md"
PLANS_DIR="$TARGET/.project/plans"

if [ ! -f "$DEFECTS" ]; then
  # In --id mode a missing file means the named entry can't exist -> error;
  # the other modes stay silent success (nothing to print).
  if [ "$MODE" = "ids" ]; then
    echo "defects-unsurfaced: no DEFECTS.md at $DEFECTS" >&2
    exit 1
  fi
  exit 0
fi

# Every current entry as "<id>\t<claim>" lines (the separator below is a
# literal tab).
entries="$(grep '^- \*\*Claim:\*\* ' "$DEFECTS" | sed 's/^- \*\*Claim:\*\* //' \
| while IFS= read -r claim; do
  printf '%s\t%s\n' "$(printf '%s' "$claim" | shasum | cut -c1-8)" "$claim"
done)"

case "$MODE" in
  all)
    [ -n "$entries" ] && printf '%s\n' "$entries"
    exit 0
    ;;
  ids)
    for id in $IDS; do
      line="$(printf '%s\n' "$entries" | grep "^$id	" | head -1)" || true
      if [ -z "$line" ]; then
        echo "defects-unsurfaced: no DEFECTS.md entry with id '$id'" >&2
        exit 1
      fi
      printf '%s\n' "$line"
    done
    exit 0
    ;;
esac

# --- default mode: filter by the surfaced union -----------------------

# Union of every plan's surfaced-defects: [...] list.
surfaced=""
if [ -d "$PLANS_DIR" ]; then
  for f in "$PLANS_DIR"/plan-*.md; do
    [ -f "$f" ] || continue
    inner="$(awk '/^---$/{n++; next} n==1' "$f" \
      | sed -n 's/^surfaced-defects:[[:space:]]*\[\(.*\)\].*/\1/p' | head -1)"
    [ -n "$inner" ] || continue
    old_ifs="$IFS"; IFS=','
    for raw in $inner; do
      IFS="$old_ifs"
      id="$(printf '%s' "$raw" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
      [ -n "$id" ] && surfaced="$surfaced $id"
      IFS=','
    done
    IFS="$old_ifs"
  done
fi

[ -n "$entries" ] && printf '%s\n' "$entries" \
| while IFS= read -r line; do
  id="${line%%	*}"
  case " $surfaced " in
    *" $id "*) ;;
    *) printf '%s\n' "$line" ;;
  esac
done

exit 0
