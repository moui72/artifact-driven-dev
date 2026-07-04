#!/usr/bin/env sh
# Deterministic half of "create or locate a worktree for a slug, branched
# from the default branch's current tip" — sibling to branch-info.sh. The
# judgment half (whether to use a worktree at all, whether to delegate the
# work to a subagent) stays in each skill's prose, per this repo's existing
# branch-info.sh convention: a script can't decide that, only detect state.
#
# Usage: ./scripts/worktree-info.sh create <slug> [project-dir]
# Prints the worktree's absolute path on success. Idempotent: if a worktree
# for <slug> already exists, prints its existing path instead of erroring or
# duplicating it. Branches from the *default* branch's current tip (reusing
# branch-info.sh's detection), not from whatever branch is checked out when
# this runs — callers are expected to have already committed any state flip
# to the default branch before calling this, so the new worktree starts
# strictly ahead of it.
#
# Exits 1 if not inside a git work tree or on bad usage.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

CMD="$1"
SLUG="$2"
TARGET="${3:-.}"

if [ "$CMD" != "create" ] || [ -z "$SLUG" ]; then
  echo "error: usage: worktree-info.sh create <slug> [project-dir]" >&2
  exit 1
fi

cd "$TARGET"

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "error: not inside a git work tree" >&2
  exit 1
fi

DEFAULT="$(sh "$SCRIPT_DIR/branch-info.sh" | sed -n 's/^default=//p')"
REPO_ROOT="$(git rev-parse --show-toplevel)"
REPO_BASE="$(basename "$REPO_ROOT")"
WT_PATH="$(dirname "$REPO_ROOT")/${REPO_BASE}-wt-${SLUG}"

# Idempotent: a worktree already registered at this path -> just print it.
if git worktree list --porcelain | grep -qxF "worktree $WT_PATH"; then
  echo "$WT_PATH"
  exit 0
fi

if git show-ref --verify --quiet "refs/heads/$SLUG"; then
  git worktree add "$WT_PATH" "$SLUG" > /dev/null
else
  git worktree add "$WT_PATH" -b "$SLUG" "$DEFAULT" > /dev/null
fi

echo "$WT_PATH"
