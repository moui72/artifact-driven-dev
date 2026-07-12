#!/usr/bin/env sh
# Regression test for migrations/0007-sync-to-tracker.sh: renames a
# target's legacy .project/SYNC.md to .project/TRACKER.md (the
# ardd-sync -> ardd-tracker skill rename's owned-file migration).
# Semantics pinned here: mv-if-exists, idempotent, and NEVER clobber an
# existing TRACKER.md (warn + skip when both files exist).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MIG="$(dirname "$SCRIPT_DIR")/migrations/0007-sync-to-tracker.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# case 1: SYNC.md present, TRACKER.md absent -> renamed, content intact
mkdir -p "$WORK/a/.project"
printf '# Sync\n\n- [ ] **[S]** open item one\n' > "$WORK/a/.project/SYNC.md"
sh "$MIG" "$WORK/a" >/dev/null 2>&1 || bad "case1: migration exited non-zero"
[ -f "$WORK/a/.project/TRACKER.md" ] && ok "case1: TRACKER.md created" || bad "case1: TRACKER.md missing"
[ ! -f "$WORK/a/.project/SYNC.md" ] && ok "case1: SYNC.md gone" || bad "case1: SYNC.md still present"
grep -q 'open item one' "$WORK/a/.project/TRACKER.md" 2>/dev/null \
  && ok "case1: content intact" || bad "case1: content lost"

# case 2: idempotent — second run is a silent no-op
sh "$MIG" "$WORK/a" >/dev/null 2>&1 || bad "case2: second run exited non-zero"
[ -f "$WORK/a/.project/TRACKER.md" ] && ok "case2: idempotent" || bad "case2: TRACKER.md gone after rerun"

# case 3: neither file exists -> no-op, exit 0
mkdir -p "$WORK/b/.project"
sh "$MIG" "$WORK/b" >/dev/null 2>&1 && ok "case3: no-op on absent files" || bad "case3: should exit 0 when nothing to do"
[ ! -f "$WORK/b/.project/TRACKER.md" ] && ok "case3: nothing created" || bad "case3: created a file from nothing"

# case 4: BOTH files exist -> warn + skip, never clobber the destination
mkdir -p "$WORK/c/.project"
printf 'old SYNC content\n' > "$WORK/c/.project/SYNC.md"
printf 'existing TRACKER content\n' > "$WORK/c/.project/TRACKER.md"
out="$(sh "$MIG" "$WORK/c" 2>&1)" || bad "case4: both-exist should not be fatal"
grep -q 'existing TRACKER content' "$WORK/c/.project/TRACKER.md" \
  && ok "case4: TRACKER.md not clobbered" || bad "case4: TRACKER.md clobbered"
[ -f "$WORK/c/.project/SYNC.md" ] && ok "case4: SYNC.md left in place" || bad "case4: SYNC.md removed despite skip"
printf '%s' "$out" | grep -qi 'skip' && ok "case4: warns and names the skip" || bad "case4: no skip warning ($out)"

[ "$fail" -eq 0 ] || { echo "test-migration-sync-to-tracker: FAILURES"; exit 1; }
echo "test-migration-sync-to-tracker: all cases pass"
