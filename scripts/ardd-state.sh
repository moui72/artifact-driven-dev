#!/usr/bin/env sh
# ardd-state.sh — deterministic state mutations for a target project's
# .project/ files (constitution Principle II: skill prose decides *when*
# a transition happens; this script does the *writing*, validating file
# state first and refusing illegal transitions with a nonzero exit).
#
# Installed target-side into .claude/skills/ardd-scripts/ by install.sh.
# POSIX sh only. Every subcommand is idempotent-safe to re-run: a
# transition to the state a file is already in is reported, not applied.
#
# Subcommands (added incrementally; see usage()):
#   (none yet — dispatcher scaffold)
#
# Exit codes: 0 success, 1 validation/transition refusal, 2 usage error.

set -e

usage() {
  cat <<'EOF'
usage: ardd-state.sh <subcommand> [args...]

Deterministic state mutations for .project/ files. Subcommands:
  (none implemented yet)
EOF
}

cmd="${1:-}"
[ -n "$cmd" ] || { usage >&2; exit 2; }
shift

case "$cmd" in
  *)
    echo "ardd-state: unknown subcommand '$cmd'" >&2
    usage >&2
    exit 2
    ;;
esac
