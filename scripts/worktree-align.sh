#!/usr/bin/env sh
# Worktree-native state: a delegated run's `isolation: "worktree"` branches
# from origin/<default> by default (see CLAUDE.md's worktree-native state
# note, bug #3) — so a freshly created delegated worktree can lack
# commits that already landed locally on the default branch before
# delegation started. Git worktrees share one repository object store and
# one set of local branch refs, so the fix is just a fast-forward merge of
# the local default branch into the worktree's HEAD — no fetch, no network,
# no special worktree-aware plumbing required.
#
# Run this as the FIRST step inside a freshly created delegated worktree,
# before doing anything else there.
#
# Usage: ./scripts/worktree-align.sh [<ref>]
#   <ref> defaults to the `default=` branch reported by branch-info.sh
#   (found alongside this script).
#
# Prints, one per line, then exits:
#   aligned=true  head=<full sha of HEAD>                     (exit 0)
#   aligned=false reason=not-a-repo                            (exit 1)
#   aligned=false reason=dirty                                 (exit 1)
#   aligned=false reason=no-such-ref                            (exit 1)
#   aligned=false reason=diverged head=<sha before attempt>     (exit 1)
#
# Never attempts a non-fast-forward merge — a diverged history is reported,
# not resolved, since resolving it requires judgment this script doesn't have.

set -e

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "aligned=false"
  echo "reason=not-a-repo"
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "aligned=false"
  echo "reason=dirty"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

ref="$1"
if [ -z "$ref" ]; then
  ref="$(sh "$SCRIPT_DIR/branch-info.sh" | sed -n 's/^default=//p')"
fi

if ! git rev-parse --verify --quiet "$ref" > /dev/null 2>&1; then
  echo "aligned=false"
  echo "reason=no-such-ref"
  exit 1
fi

if git merge-base --is-ancestor "$ref" HEAD 2>/dev/null; then
  echo "aligned=true"
  echo "head=$(git rev-parse HEAD)"
  exit 0
fi

if git merge --ff-only "$ref" > /dev/null 2>&1; then
  echo "aligned=true"
  echo "head=$(git rev-parse HEAD)"
  exit 0
else
  echo "aligned=false"
  echo "reason=diverged"
  echo "head=$(git rev-parse HEAD)"
  exit 1
fi
