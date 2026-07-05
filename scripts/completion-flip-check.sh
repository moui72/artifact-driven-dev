#!/usr/bin/env sh
# Detects the orphaned-completion-flip failure mode: a tasks file whose
# frontmatter is `status: completed`, whose work happened on a branch that
# has already merged into the default branch, but whose bound features are
# still `Status: tasked` in features.md rather than `implemented`.
# /ardd-implement's and /ardd-converge's post-merge flip step assumes a
# live coordinating conversation checks back after the worktree branch
# merges — but merge is manual/async, so in the common case that
# conversation is gone before it happens and the flip never lands.
# /ardd-analyze wires this in as a read-only detector.
#
# Which branch actually had the work: the tasks file's own
# `worktree_branch:` frontmatter if present (written by /ardd-implement or
# /ardd-converge the moment a delegated subagent reports back — see
# CLAUDE.md's state-commit-before-branch note for why this must be read
# from disk, not just recalled from the plan). Falls back to the *plan's*
# `branch:` field only when `worktree_branch:` is absent — the
# non-delegated/inline case, where work happened directly on whatever
# branch the plan itself was drafted/approved on.
#
# Usage: ./scripts/completion-flip-check.sh <tasks-file>
# Prints one orphaned feature slug per line. Prints nothing (exit 0) if the
# tasks file isn't `completed`, the relevant branch isn't merged, or none of
# its bound features are still `tasked`. Exits 1 on missing/malformed input.

set -e

FILE="$1"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "error: usage: completion-flip-check.sh <tasks-file>" >&2
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

status="$(frontmatter_field "$FILE" status)"
[ "$status" = "completed" ] || exit 0

plan_name="$(frontmatter_field "$FILE" plan)"
[ -n "$plan_name" ] || { echo "error: $FILE has no 'plan:' frontmatter" >&2; exit 1; }

project_root="$(cd "$(dirname "$(dirname "$FILE")")" && pwd)"
plan_file="$project_root/plans/$plan_name"
[ -f "$plan_file" ] || { echo "error: plan '$plan_name' not found at $plan_file" >&2; exit 1; }

branch="$(frontmatter_field "$FILE" worktree_branch)"
[ -n "$branch" ] || branch="$(frontmatter_field "$plan_file" branch)"
[ -n "$branch" ] || exit 0

featval="$(frontmatter_field "$plan_file" features)"
inner="$(printf '%s' "$featval" | sed -E 's/^\[//; s/\]$//')"
[ -n "$inner" ] || exit 0

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
repo_root="$(cd "$project_root/.." && pwd)"
default="$(cd "$repo_root" && sh "$SCRIPT_DIR/branch-info.sh" | sed -n 's/^default=//p')"
[ -n "$default" ] || exit 0

if ! (cd "$repo_root" && git merge-base --is-ancestor "$branch" "$default" 2>/dev/null); then
  exit 0
fi

features_file="$project_root/artifacts/features.md"
[ -f "$features_file" ] || exit 0

old_ifs="$IFS"
IFS=','
for raw in $inner; do
  IFS="$old_ifs"
  slug="$(printf '%s' "$raw" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
  if [ -n "$slug" ]; then
    feature_status="$(grep -oE "_Slug: \`${slug}\` · Status: [a-z]+" "$features_file" | sed -E 's/.*Status: ([a-z]+)$/\1/')"
    [ "$feature_status" = "tasked" ] && echo "$slug"
  fi
  IFS=','
done
IFS="$old_ifs"
