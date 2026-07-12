#!/usr/bin/env sh
# Shared "are all sibling tasks files for this plan done?" check, used by
# /ardd-implement (on a tasks file's own completion, and in reconcile mode on
# reconciling a tasks file to completed) to decide whether to flip that
# plan's bound features from tasked -> implemented. A plan can have more
# than one tasks file (see /ardd-plan step 11's "deliberate fork" case for a
# plan that already has one in flight), so completing one doesn't mean the
# plan's feature work is actually done. This logic used to be duplicated
# near-verbatim as prose in both skills.
#
# A sibling at status: abandoned (superseded by a later tasks file for the
# same plan) doesn't block completion — but at least one sibling must be
# `completed` for the plan to count as done; a plan whose every tasks file
# was abandoned has no finished work to flip features on.
#
# Usage: ./scripts/sibling-tasks-complete.sh <path-to-a-tasks-file>
# Prints, one per line:
#   plan=<plan filename from the given file's own `plan:` frontmatter>
#   siblings=<space-separated tasks-*.md filenames bound to that plan>
#   all_complete=true|false
# Exits 1 if the given file doesn't exist or has no `plan:` frontmatter.

set -e

FILE="$1"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "error: usage: sibling-tasks-complete.sh <path-to-a-tasks-file>" >&2
  exit 1
fi

frontmatter_field() {
  file="$1"
  field="$2"
  awk '/^---$/{n++; next} n==1' "$file" \
    | grep -E "^${field}:" \
    | head -1 \
    | sed -E "s/^${field}:[[:space:]]*//; s/[[:space:]]*(#.*)?\$//"
}

plan="$(frontmatter_field "$FILE" plan)"
if [ -z "$plan" ]; then
  echo "error: $FILE has no 'plan:' frontmatter" >&2
  exit 1
fi

dir="$(dirname "$FILE")"
siblings=""
any_completed=false
all_complete=true

for f in "$dir"/tasks-*.md; do
  [ -f "$f" ] || continue
  f_plan="$(frontmatter_field "$f" plan)"
  [ "$f_plan" = "$plan" ] || continue
  siblings="$siblings $(basename "$f")"
  status="$(frontmatter_field "$f" status)"
  case "$status" in
    completed) any_completed=true ;;
    abandoned) ;;
    *) all_complete=false ;;
  esac
done

[ "$any_completed" = "true" ] || all_complete=false

echo "plan=$plan"
echo "siblings=${siblings# }"
echo "all_complete=$all_complete"
