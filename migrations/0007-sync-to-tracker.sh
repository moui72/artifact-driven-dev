#!/usr/bin/env sh
# Migration 0007: rename the legacy .project/SYNC.md to .project/TRACKER.md
# (the ardd-sync -> ardd-tracker skill rename at v1.0.0; the owned report
# file follows its owner). Idempotent: mv-if-exists; a target with no
# SYNC.md is a no-op. Never clobbers: if BOTH files exist, warn and skip —
# the ardd-tracker skill's legacy-adoption step will surface it on next run.

TARGET="${1:-.}"
OLD="$TARGET/.project/SYNC.md"
NEW="$TARGET/.project/TRACKER.md"

[ -f "$OLD" ] || exit 0

if [ -f "$NEW" ]; then
  echo "  ! 0007: both SYNC.md and TRACKER.md exist — skipping rename;"
  echo "    merge or remove $OLD by hand (TRACKER.md left untouched)."
  exit 0
fi

mv "$OLD" "$NEW"
echo "  ✓ renamed .project/SYNC.md -> .project/TRACKER.md"
