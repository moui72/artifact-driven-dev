#!/usr/bin/env sh
# Decides whether a linked issue's state has diverged from features.md, per
# /ardd-tracker's Pull step 2: closed-but-not-implemented, or
# reopened-but-implemented. Report-only — /ardd-tracker never applies this,
# only records it in TRACKER.md.
#
# Usage: ./scripts/sync-divergence.sh <slug> <issue-number> <status> <issue-state>
#   status:      backlogged | planned | tasked | implemented
#   issue-state: open | closed
#
# Prints the TRACKER.md "## Diverged" line if diverged, nothing otherwise.

set -e

SLUG="$1"
ISSUE_NUMBER="$2"
STATUS="$3"
ISSUE_STATE="$4"

diverged=false
if [ "$ISSUE_STATE" = "closed" ] && [ "$STATUS" != "implemented" ]; then
  diverged=true
elif [ "$ISSUE_STATE" = "open" ] && [ "$STATUS" = "implemented" ]; then
  diverged=true
fi

if [ "$diverged" = "true" ]; then
  echo "- **Slug:** $SLUG — issue #$ISSUE_NUMBER is $ISSUE_STATE, features.md says \`Status: $STATUS\`"
fi
