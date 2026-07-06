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
# Usage: defects-unsurfaced.sh [target-dir]     (default: .)
# Exit 0 always unless inputs are malformed; silent when nothing is
# unsurfaced (or DEFECTS.md is absent/all-clear).

set -e

TARGET="${1:-.}"
DEFECTS="$TARGET/.project/DEFECTS.md"
PLANS_DIR="$TARGET/.project/plans"

[ -f "$DEFECTS" ] || exit 0

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

grep '^- \*\*Claim:\*\* ' "$DEFECTS" | sed 's/^- \*\*Claim:\*\* //' \
| while IFS= read -r claim; do
  id="$(printf '%s' "$claim" | shasum | cut -c1-8)"
  case " $surfaced " in
    *" $id "*) ;;
    *) printf '%s\t%s\n' "$id" "$claim" ;;
  esac
done
