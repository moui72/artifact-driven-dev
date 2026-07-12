#!/usr/bin/env sh
# Migration 0006: rename the legacy .project/critique.md to .project/audit.md
# (the ardd-critique -> ardd-audit skill rename at v1.0.0; the owned report
# file follows its owner). Idempotent: mv-if-exists; a target with no
# critique.md is a no-op. Never clobbers: if BOTH files exist, warn and
# skip — resolving which content wins needs human judgment (the ardd-audit
# skill's legacy-adoption step will surface it on next run).

TARGET="${1:-.}"
OLD="$TARGET/.project/critique.md"
NEW="$TARGET/.project/audit.md"

[ -f "$OLD" ] || exit 0

if [ -f "$NEW" ]; then
  echo "  ! 0006: both critique.md and audit.md exist — skipping rename;"
  echo "    merge or remove $OLD by hand (audit.md left untouched)."
  exit 0
fi

mv "$OLD" "$NEW"
echo "  ✓ renamed .project/critique.md -> .project/audit.md"
