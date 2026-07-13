#!/usr/bin/env sh
# Worktree-native state: merge is the single atomic event that lands a
# delegated run's code and state together — after which the worktree that
# carried them is dead weight, and leaving it on disk keeps
# inflight-worktrees.sh (and /ardd-status's In Flight section) reporting
# work that already landed. Reap-candidacy is a pure function of git state,
# so this is a script, not prose: a worktree is reaped iff its branch is
# fully merged into the local default branch AND its tree is clean. The
# primary worktree and the worktree containing the current directory are
# never candidates, and a worktree holding the default branch itself is
# refused (deleting its branch would delete the default branch).
#
# Refuse-never-resolve: anything dirty, unmerged, or detached is reported
# and skipped — never forced. `git branch -d` (never -D) is the second
# safety net: it refuses unmerged branches on its own.
#
# Usage: ./scripts/worktree-reap.sh [--dry-run]
#
# Prints one line per non-primary, non-current worktree:
#   reaped=true path=<p> branch=<b>
#   reaped=false path=<p> branch=<b> reason=unmerged|dirty|detached|default-branch|remove-failed
# With --dry-run, prints instead (and mutates nothing):
#   candidate=<p> branch=<b>
# one line per worktree that a real run would reap; non-candidates are
# silent.
#
# Exit 0 when everything eligible was reaped (or nothing existed);
# exit 1 only on a reap attempt that failed (reason=remove-failed) or a
# usage/environment error.

set -e

dry_run=false
if [ "$1" = "--dry-run" ]; then
  dry_run=true
elif [ -n "$1" ]; then
  echo "usage: $0 [--dry-run]" >&2
  exit 2
fi

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "error: not inside a git work tree" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
default="$(sh "$SCRIPT_DIR/branch-info.sh" | sed -n 's/^default=//p')"
if [ -z "$default" ]; then
  echo "error: cannot determine the default branch" >&2
  exit 1
fi

current_toplevel="$(cd "$(git rev-parse --show-toplevel)" && pwd -P)"

# Parse `git worktree list --porcelain` into one "path<TAB>branch" line per
# worktree. Each record is: "worktree <path>", "HEAD <sha>", then either
# "branch refs/heads/<name>", "bare", or "detached", separated by blank
# lines. The main (primary) worktree is always listed first.
worktree_records="$(
  git worktree list --porcelain | awk '
    /^worktree / { if (path != "") print path "\t" branch; path=$0; sub(/^worktree /, "", path); branch="detached"; next }
    /^branch /   { b=$0; sub(/^branch refs\/heads\//, "", b); branch=b; next }
    /^bare$/     { branch="bare"; next }
    END { if (path != "") print path "\t" branch }
  '
)"

[ -n "$worktree_records" ] || exit 0

fail=0
first=1
old_ifs="$IFS"
IFS='
'
for record in $worktree_records; do
  IFS="$old_ifs"

  # The primary (main) worktree is the first record — never a candidate.
  if [ "$first" -eq 1 ]; then
    first=0
    IFS='
'
    continue
  fi

  wt_path="${record%%	*}"
  wt_branch="${record#*	}"

  # The worktree containing the current directory is never a candidate.
  wt_real="$(cd "$wt_path" 2>/dev/null && pwd -P)" || { IFS='
'; continue; }
  if [ "$wt_real" = "$current_toplevel" ]; then
    IFS='
'
    continue
  fi

  reason=""
  if [ "$wt_branch" = "detached" ] || [ "$wt_branch" = "bare" ]; then
    reason="detached"
  elif [ "$wt_branch" = "$default" ]; then
    # Trivially "merged", but reaping would delete the default branch.
    reason="default-branch"
  elif ! git merge-base --is-ancestor "$wt_branch" "$default" 2>/dev/null; then
    reason="unmerged"
  elif [ -n "$(git -C "$wt_path" status --porcelain)" ]; then
    reason="dirty"
  fi

  if [ -n "$reason" ]; then
    if [ "$dry_run" = "false" ]; then
      echo "reaped=false path=$wt_path branch=$wt_branch reason=$reason"
    fi
    IFS='
'
    continue
  fi

  if [ "$dry_run" = "true" ]; then
    echo "candidate=$wt_path branch=$wt_branch"
    IFS='
'
    continue
  fi

  if git worktree remove "$wt_path" > /dev/null 2>&1 \
     && git branch -d "$wt_branch" > /dev/null 2>&1; then
    echo "reaped=true path=$wt_path branch=$wt_branch"
  else
    echo "reaped=false path=$wt_path branch=$wt_branch reason=remove-failed"
    fail=1
  fi

  IFS='
'
done
IFS="$old_ifs"

exit "$fail"
