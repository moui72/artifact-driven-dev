#!/usr/bin/env sh
# Fold the current feature branch into the local default branch (fast-forward
# only) and check out the default branch. This is the deterministic half of
# the eager-background delegation gate (/ardd-implement step 3,
# reconcile mode): to background a run that is already on a feature
# branch, the run's state must reach the local default branch so a delegated
# worktree — which branches from <default> and is fast-forwarded by
# worktree-align.sh — can see it, while the focused session is left clean on
# <default>.
#
# Refuses (never resolves) on a dirty tree, a detached HEAD, or a
# non-fast-forward divergence — matching worktree-align.sh's
# refuse-don't-resolve discipline. Does NOT delete the folded branch: after an
# FF fold it is identical to <default>, and cleanup is the caller's choice.
#
# Usage: ./scripts/fold-to-main.sh [<default-branch>]
#   <default-branch> defaults to the `default=` branch reported by
#   branch-info.sh (found alongside this script).
#
# Prints, one per line, then exits:
#   folded=true  head=<sha>                  (exit 0; HEAD now on <default>)
#   folded=false reason=not-a-repo           (exit 1)
#   folded=false reason=dirty                (exit 1)
#   folded=false reason=detached             (exit 1)
#   folded=false reason=no-default           (exit 1)
#   folded=false reason=diverged head=<sha>  (exit 1; unchanged, still on branch)
#   folded=false reason=checkout-failed      (exit 1)

set -e

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "folded=false"
  echo "reason=not-a-repo"
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "folded=false"
  echo "reason=dirty"
  exit 1
fi

current="$(git branch --show-current)"
if [ -z "$current" ]; then
  echo "folded=false"
  echo "reason=detached"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

default="$1"
if [ -z "$default" ]; then
  default="$(sh "$SCRIPT_DIR/branch-info.sh" | sed -n 's/^default=//p')"
fi
if [ -z "$default" ] || ! git show-ref --verify --quiet "refs/heads/$default"; then
  echo "folded=false"
  echo "reason=no-default"
  exit 1
fi

# Already on the default branch: nothing to fold (no-op success).
if [ "$current" = "$default" ]; then
  echo "folded=true"
  echo "head=$(git rev-parse HEAD)"
  exit 0
fi

# A fast-forward of <default> up to the current branch is only possible if
# <default> is an ancestor of the current branch. Otherwise the histories
# diverged — report, never resolve, and leave HEAD untouched.
if ! git merge-base --is-ancestor "$default" "$current" 2>/dev/null; then
  echo "folded=false"
  echo "reason=diverged"
  echo "head=$(git rev-parse HEAD)"
  exit 1
fi

if ! git checkout "$default" > /dev/null 2>&1; then
  # <default> is likely checked out in another worktree, so it can't be
  # checked out here. Don't force anything.
  echo "folded=false"
  echo "reason=checkout-failed"
  exit 1
fi

if git merge --ff-only "$current" > /dev/null 2>&1; then
  echo "folded=true"
  echo "head=$(git rev-parse HEAD)"
  exit 0
else
  # Ancestry was checked above, so this is not expected; never resolve.
  echo "folded=false"
  echo "reason=diverged"
  echo "head=$(git rev-parse HEAD)"
  exit 1
fi
