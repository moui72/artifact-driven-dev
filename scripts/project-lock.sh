#!/usr/bin/env sh
# Warn-only concurrency marker for skills that write multi-file state
# (plan approval + feature flips, tasks generation) — not real locking, just
# cheap insurance against two sessions/agents racing on the same .project/.
# A `check` never blocks a run; it only prints a warning for the user to
# judge, then the caller proceeds regardless.
#
# Usage:
#   ./scripts/project-lock.sh touch <label> [project-dir]
#   ./scripts/project-lock.sh check <label> [project-dir]
#
# `project-dir` defaults to `.` (same convention as lint-project.sh's
# optional target-dir argument). The lock file is
# `<project-dir>/.project/.lock`, containing "<epoch-seconds> <label>".
#
# `touch` records the current time and label. `check` prints a one-line
# warning if a lock exists, is less than 5 minutes old, and was written by a
# *different* label than the one given — otherwise it's silent.
#
# No protection across `git worktree` checkouts: the lock file lives inside
# each worktree's own `.project/`, so two worktrees of the same repo never see
# each other's lock. This guards concurrent runs sharing one `.project/`, not
# runs isolated in separate worktrees.
#
# Callers pass their own skill name as <label> (e.g. `ardd-plan`,
# `ardd-implement`), which is what lets `check`
# name the other writer — a future caller adding lock support should follow
# the same convention rather than reverse-engineer it from the existing ones.

set -e

CMD="$1"
LABEL="$2"
TARGET="${3:-.}"
LOCK_FILE="$TARGET/.project/.lock"
STALE_AFTER=300

case "$CMD" in
  touch)
    mkdir -p "$(dirname "$LOCK_FILE")"
    echo "$(date +%s) $LABEL" > "$LOCK_FILE"
    ;;
  check)
    [ -f "$LOCK_FILE" ] || exit 0
    read -r recorded_ts recorded_label < "$LOCK_FILE"
    now="$(date +%s)"
    age=$((now - recorded_ts))
    if [ "$age" -lt "$STALE_AFTER" ] && [ "$recorded_label" != "$LABEL" ]; then
      echo "warning: .project/ was written by '$recorded_label' ${age}s ago — check for a concurrent run before proceeding"
    fi
    ;;
  *)
    echo "error: usage: project-lock.sh <touch|check> <label> [project-dir]" >&2
    exit 1
    ;;
esac
