#!/usr/bin/env sh
# Decides the ardd:* label-swap or close action /ardd-tracker's Push step 3
# needs to take for one already-linked features.md entry.
#
# Usage: ./scripts/sync-label-decision.sh <status> <current-label> <issue-state>
#   status:        backlogged | planned | tasked | implemented
#   current-label: the issue's current ardd:* label, or the literal "none"
#   issue-state:   open | closed
#
# Prints one of:
#   (nothing)              — already correct, no action needed
#   add ardd:<status>       — issue has no ardd:* label yet
#   swap <old-label> ardd:<status> — label is behind status
#   close                   — status is implemented and the issue is still open

set -e

STATUS="$1"
CURRENT_LABEL="$2"
ISSUE_STATE="$3"

if [ "$STATUS" = "implemented" ]; then
  if [ "$ISSUE_STATE" = "open" ]; then
    echo "close"
  fi
  exit 0
fi

DESIRED="ardd:${STATUS}"

if [ "$CURRENT_LABEL" = "$DESIRED" ]; then
  exit 0
elif [ "$CURRENT_LABEL" = "none" ]; then
  echo "add $DESIRED"
else
  echo "swap $CURRENT_LABEL $DESIRED"
fi
