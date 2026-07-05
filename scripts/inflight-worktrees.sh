#!/usr/bin/env sh
# Worktree-native state: solo mode's coarse-state visibility channel. In the
# old design, "is there other in-flight delegated work" was answered by
# reading committed state on the default branch. Under worktree-native
# state, a delegated run's coarse state rides entirely in its own worktree
# branch and never lands on the default branch until merge — so visibility
# instead comes from enumerating worktrees on disk and reading whatever
# ARDD tasks-file state happens to live in each one.
#
# Usage: ./scripts/inflight-worktrees.sh
# Works from the primary checkout or from inside any worktree — the
# worktree containing the current directory is always skipped, since it's
# "this" work, not "other" in-flight work.
#
# For every OTHER worktree of this repo, prints one line per ARDD tasks
# file (.project/tasks/tasks-*.md) whose frontmatter `status` is
# `in-progress` or `completed`:
#   worktree=<path>	branch=<name|detached>	tasks=<relative-path>	status=<status>	progress=<x/y>
# x = count of `- [x]` lines, y = x + count of `- [ ]` lines.
#
# Already-merged state is filtered out: a candidate tasks file that exists
# on the default branch (per branch-info.sh, resolved once at startup) with
# IDENTICAL content is not in-flight — it's history every worktree carries —
# and reporting it is pure noise (a fresh worktree would otherwise report
# every completed tasks file ever merged). A candidate is reported only if
# it differs from the default branch's version or doesn't exist there at
# all. If the default branch can't be resolved, no filtering happens
# (everything is reported).
#
# If a worktree has no such tasks files (no .project/, none in a reportable
# status, or all candidates filtered as already-merged), prints one line
# instead:
#   worktree=<path>	branch=<name|detached>	tasks=none	status=-	progress=-
#
# Prints nothing if there are no other worktrees. Exits 1 only if not
# inside a git repo; exits 0 otherwise, even with nothing to report.

set -e

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "error: not inside a git work tree" >&2
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

current_toplevel="$(cd "$(git rev-parse --show-toplevel)" && pwd -P)"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
default="$(sh "$SCRIPT_DIR/branch-info.sh" 2>/dev/null | sed -n 's/^default=//p')" || default=""

# True if the candidate file is identical to the default branch's version —
# already-merged state, not in-flight. If the default branch is unknown or
# doesn't resolve in that worktree, nothing is considered merged (report
# everything). `git diff` can't see untracked files, so the existence check
# (cat-file -e) must come first: a file absent from the default branch is
# always in-flight, tracked or not.
already_merged() {
  wt="$1"
  rel="$2"
  [ -n "$default" ] || return 1
  git -C "$wt" rev-parse --verify --quiet "$default" > /dev/null 2>&1 || return 1
  git -C "$wt" cat-file -e "$default:$rel" 2>/dev/null || return 1
  git -C "$wt" diff --quiet "$default" -- "$rel" 2>/dev/null
}

# Parse `git worktree list --porcelain` into one "path<TAB>branch" line per
# worktree. Each record is: "worktree <path>", "HEAD <sha>", then either
# "branch refs/heads/<name>", "bare", or "detached", separated by blank lines.
worktree_records="$(
  git worktree list --porcelain | awk '
    /^worktree / { if (path != "") print path "\t" branch; path=$0; sub(/^worktree /, "", path); branch="detached"; next }
    /^branch /   { b=$0; sub(/^branch refs\/heads\//, "", b); branch=b; next }
    /^bare$/     { branch="bare"; next }
    END { if (path != "") print path "\t" branch }
  '
)"

[ -n "$worktree_records" ] || exit 0

old_ifs="$IFS"
IFS='
'
for record in $worktree_records; do
  IFS="$old_ifs"
  wt_path="${record%%	*}"
  wt_branch="${record#*	}"

  wt_real="$(cd "$wt_path" 2>/dev/null && pwd -P)" || continue
  [ "$wt_real" = "$current_toplevel" ] && continue

  reported=0
  for tf in "$wt_path"/.project/tasks/tasks-*.md; do
    [ -f "$tf" ] || continue
    status="$(frontmatter_field "$tf" status)"
    case "$status" in
      in-progress|completed) ;;
      *) continue ;;
    esac
    rel="${tf#"$wt_path"/}"
    already_merged "$wt_path" "$rel" && continue
    x="$(grep -cE '^- \[x\]' "$tf" 2>/dev/null || true)"
    unchecked="$(grep -cE '^- \[ \]' "$tf" 2>/dev/null || true)"
    y=$((x + unchecked))
    printf 'worktree=%s\tbranch=%s\ttasks=%s\tstatus=%s\tprogress=%s/%s\n' \
      "$wt_path" "$wt_branch" "$rel" "$status" "$x" "$y"
    reported=1
  done

  if [ "$reported" -eq 0 ]; then
    printf 'worktree=%s\tbranch=%s\ttasks=none\tstatus=-\tprogress=-\n' "$wt_path" "$wt_branch"
  fi
  IFS='
'
done
IFS="$old_ifs"
