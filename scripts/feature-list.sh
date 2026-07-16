#!/usr/bin/env sh
# feature-list.sh — deterministic feature-register pick list. One line per
# .project/features/*.md:
#
#   <slug>\t<status>\t<logged>\t<description>\t<epic>
#
# <description> is the body's first non-blank line (a "Why:" line, if
# present, is never the first non-blank line by convention and is never
# included). <epic> is the frontmatter `epic` value, empty string when
# unset. Default filter is status=backlogged (what's actionable for
# planning at a glance); --status <s1,s2,...> widens the filter to exactly
# those statuses; --all includes every status. --epic <slug> further
# restricts output to features whose `epic` exactly matches, and composes
# with --status/--all (which control the status filter only). Mirrors
# tasks-list.sh's structure (constitution Principle II — register-wide
# views come from enumeration, never a second hand-maintained index).
#
# Usage: feature-list.sh [--status <s1,s2,...> | --all] [--epic <slug>] [target-dir]  (default: .)

set -e

STATUSES="backlogged"
ALL=0
EPIC=""

while :; do
  case "${1:-}" in
    --all)
      ALL=1
      shift
      ;;
    --status)
      STATUSES="$2"
      shift 2
      ;;
    --epic)
      EPIC="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

TARGET="${1:-.}"
FEATURES_DIR="$TARGET/.project/features"

[ -d "$FEATURES_DIR" ] || exit 0

fm_field() {
  awk '/^---$/{n++; next} n==1' "$1" \
    | grep -E "^$2:" | head -1 \
    | sed -E "s/^$2:[[:space:]]*//; s/[[:space:]]*(#.*)?\$//"
}

first_body_line() {
  awk '/^---$/{n++; next} n>=2 && NF>0 {print; exit}' "$1"
}

status_matches() {
  status="$1"
  [ "$ALL" -eq 1 ] && return 0
  case ",$STATUSES," in
    *",$status,"*) return 0 ;;
    *) return 1 ;;
  esac
}

for f in "$FEATURES_DIR"/*.md; do
  [ -f "$f" ] || continue
  status="$(fm_field "$f" status)"
  status_matches "$status" || continue
  epic="$(fm_field "$f" epic)"
  if [ -n "$EPIC" ] && [ "$epic" != "$EPIC" ]; then
    continue
  fi
  slug="$(fm_field "$f" slug)"
  logged="$(fm_field "$f" logged)"
  description="$(first_body_line "$f")"
  printf '%s\t%s\t%s\t%s\t%s\n' "$slug" "$status" "$logged" "$description" "$epic"
done
