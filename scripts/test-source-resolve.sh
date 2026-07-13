#!/usr/bin/env sh
# Regression test for source-resolve.sh — the release-channel resolution
# layer (constitution, release-channel standing decision, 2026-07-12).
#
# Contract: given a recorded Source-Path (argument, or read from
# .project/ardd-version.md in the cwd), the tooling-owned checkout at
# $ARDD_HOME/source (~/.ardd/source) is fetched (offline-tolerant) and moved
# to the latest semver release tag; any other existing path is dev-mode and
# is never mutated; a missing path is resolved=false, exit 1.
#
# Hermetic: fixture "remotes" are local repos in temp dirs; $ARDD_HOME is
# pinned into the temp dir; no case ever reaches the network. These fixtures
# are also where `git tag --sort=v:refname` earns its keep (plan Complexity
# Tracking): the v1.10.0 > v1.9.0 case fails under lexical ordering.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESOLVE="$SCRIPT_DIR/source-resolve.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# Fixture "origin": looks like an ARDD checkout, carries semver tags whose
# correct ordering is non-lexical, plus decoys a strict filter must ignore.
ORIGIN="$WORK/origin"
mkdir -p "$ORIGIN/skills/ardd-x"
printf 'placeholder\n' > "$ORIGIN/skills/ardd-x/SKILL.md"   # git keeps no empty dirs across clones
printf '#!/usr/bin/env sh\n' > "$ORIGIN/install.sh"
( cd "$ORIGIN" \
  && git init -q -b main \
  && git add -A && git commit -q -m one \
  && git tag v1.2.0 \
  && printf 'x\n' >> install.sh && git add -A && git commit -q -m two \
  && git tag v1.9.0 \
  && printf 'y\n' >> install.sh && git add -A && git commit -q -m three \
  && git tag v1.10.0 \
  && git tag v1.10.0-rc2 \
  && git tag banana )

# The owned checkout lives under a pinned $ARDD_HOME, cloned from the local
# fixture origin — no network.
export ARDD_HOME="$WORK/ardd-home"
OWNED="$ARDD_HOME/source"
mkdir -p "$ARDD_HOME"
git clone -q "$ORIGIN" "$OWNED"

run_resolve() { # run_resolve [args...]
  set +e
  out="$(sh "$RESOLVE" "$@" 2>&1)"
  status=$?
  set -e
}

# --- Case 1: owned path resolves the latest semver tag (v1.10.0 > v1.9.0) ---
# Also proves the strict filter: v1.10.0-rc2 and banana must lose.
run_resolve "$OWNED"
[ "$status" -eq 0 ] \
  && ok "case1: exit 0" \
  || { bad "case1: expected exit 0, got $status"; printf '%s\n' "$out" | sed 's/^/    /'; }
[ "$out" = "resolved=$OWNED ref=v1.10.0 channel=release" ] \
  && ok "case1: latest semver tag wins (v1.10.0 > v1.9.0, rc/decoy ignored)" \
  || bad "case1: got '$out'"
[ "$(git -C "$OWNED" rev-parse HEAD)" = "$(git -C "$OWNED" rev-parse 'v1.10.0^{commit}')" ] \
  && ok "case1: owned checkout moved to the tag" \
  || bad "case1: owned checkout not at v1.10.0"

# --- Case 2: detached-at-tag re-resolve picks up a newer release ---
( cd "$ORIGIN" && printf 'z\n' >> install.sh && git add -A && git commit -q -m four && git tag v1.11.0 )
run_resolve "$OWNED"
[ "$out" = "resolved=$OWNED ref=v1.11.0 channel=release" ] \
  && ok "case2: re-resolve from detached HEAD fetches and moves to v1.11.0" \
  || bad "case2: got '$out'"
[ "$(git -C "$OWNED" rev-parse HEAD)" = "$(git -C "$OWNED" rev-parse 'v1.11.0^{commit}')" ] \
  && ok "case2: owned checkout at the new tag" \
  || bad "case2: owned checkout not at v1.11.0"

# --- Case 3: offline fetch failure warns and continues with existing state ---
git -C "$OWNED" remote set-url origin "$WORK/nonexistent-remote"
run_resolve "$OWNED"
[ "$status" -eq 0 ] \
  && ok "case3: offline exit 0" \
  || bad "case3: expected exit 0, got $status"
[ "$out" = "resolved=$OWNED ref=v1.11.0 channel=release warning=offline" ] \
  && ok "case3: warning=offline, resolves from existing tags" \
  || bad "case3: got '$out'"
git -C "$OWNED" remote set-url origin "$ORIGIN"

# --- Case 4: a non-owned path is dev-mode and is never mutated ---
DEV="$WORK/dev-checkout"
git clone -q "$ORIGIN" "$DEV"
dev_head="$(git -C "$DEV" rev-parse HEAD)"
run_resolve "$DEV"
[ "$status" -eq 0 ] \
  && ok "case4: exit 0" \
  || bad "case4: expected exit 0, got $status"
[ "$out" = "resolved=$DEV channel=dev" ] \
  && ok "case4: channel=dev, no ref claimed" \
  || bad "case4: got '$out'"
[ "$(git -C "$DEV" rev-parse HEAD)" = "$dev_head" ] \
  && ok "case4: dev checkout not mutated (HEAD unchanged, no tag checkout)" \
  || bad "case4: dev checkout HEAD moved"

# --- Case 5: owned checkout with no release tags -> default branch + warning ---
ORIGIN2="$WORK/origin-notags"
mkdir -p "$ORIGIN2/skills/ardd-x"
printf 'placeholder\n' > "$ORIGIN2/skills/ardd-x/SKILL.md"
printf '#!/usr/bin/env sh\n' > "$ORIGIN2/install.sh"
( cd "$ORIGIN2" && git init -q -b main && git add -A && git commit -q -m one )
export ARDD_HOME="$WORK/ardd-home2"
mkdir -p "$ARDD_HOME"
git clone -q "$ORIGIN2" "$ARDD_HOME/source"
run_resolve "$ARDD_HOME/source"
[ "$status" -eq 0 ] \
  && ok "case5: exit 0" \
  || bad "case5: expected exit 0, got $status"
[ "$out" = "resolved=$ARDD_HOME/source ref=main channel=release warning=no-tags" ] \
  && ok "case5: no tags -> ref=main with warning=no-tags" \
  || bad "case5: got '$out'"
export ARDD_HOME="$WORK/ardd-home"

# --- Case 6: missing path -> resolved=false, exit 1 ---
run_resolve "$WORK/nowhere"
[ "$status" -eq 1 ] \
  && ok "case6: exit 1" \
  || bad "case6: expected exit 1, got $status"
case "$out" in
  "resolved=false reason=missing"*) ok "case6: resolved=false reason=missing" ;;
  *) bad "case6: got '$out'" ;;
esac

# --- Case 7: existing path that isn't an ARDD checkout -> resolved=false ---
NOTARDD="$WORK/not-ardd"; mkdir -p "$NOTARDD"
run_resolve "$NOTARDD"
[ "$status" -eq 1 ] \
  && ok "case7: exit 1" \
  || bad "case7: expected exit 1, got $status"
case "$out" in
  "resolved=false reason=not-ardd"*) ok "case7: resolved=false reason=not-ardd" ;;
  *) bad "case7: got '$out'" ;;
esac

# --- Case 8: no argument -> Source-Path read from .project/ardd-version.md ---
TGT="$WORK/target"; mkdir -p "$TGT/.project"
printf '# ARDD Version\n\n_Source: artifact-driven-dev @ abc1234 · Installed/updated 2026-07-12_\n\nSource-Path: %s\n' "$DEV" \
  > "$TGT/.project/ardd-version.md"
set +e
out="$( (cd "$TGT" && sh "$RESOLVE") 2>&1 )"
status=$?
set -e
[ "$status" -eq 0 ] && [ "$out" = "resolved=$DEV channel=dev" ] \
  && ok "case8: Source-Path read from ardd-version.md" \
  || bad "case8: got '$out' (rc=$status)"

# --- Case 9: no argument, no version file -> resolved=false ---
EMPTY="$WORK/empty-target"; mkdir -p "$EMPTY"
set +e
out="$( (cd "$EMPTY" && sh "$RESOLVE") 2>&1 )"
status=$?
set -e
[ "$status" -eq 1 ] \
  && ok "case9: exit 1" \
  || bad "case9: expected exit 1, got $status"
case "$out" in
  "resolved=false reason=no-source-path"*) ok "case9: reason=no-source-path" ;;
  *) bad "case9: got '$out'" ;;
esac

# --- Case 10: recorded Source-Path gone -> fall back to the owned checkout.
# Only a version-file path falls back (a moved machine); an explicit
# argument never does (case 6 is the guard). ---
TGT2="$WORK/target-moved"; mkdir -p "$TGT2/.project"
printf '# ARDD Version\n\n_Source: artifact-driven-dev @ abc1234 · Installed/updated 2026-07-12_\n\nSource-Path: %s\n' "$WORK/vanished" \
  > "$TGT2/.project/ardd-version.md"
set +e
out="$( (cd "$TGT2" && sh "$RESOLVE") 2>&1 )"
status=$?
set -e
[ "$status" -eq 0 ] && [ "$out" = "resolved=$OWNED ref=v1.11.0 channel=release fallback=owned" ] \
  && ok "case10: moved Source-Path -> owned fallback" \
  || bad "case10: got '$out' (rc=$status)"

# --- Case 11: recorded Source-Path gone AND no owned checkout -> missing ---
set +e
out="$( (cd "$TGT2" && ARDD_HOME="$WORK/absent-home" sh "$RESOLVE") 2>&1 )"
status=$?
set -e
[ "$status" -eq 1 ] \
  && ok "case11: exit 1" \
  || bad "case11: expected exit 1, got $status"
case "$out" in
  "resolved=false reason=missing path=$WORK/vanished"*) ok "case11: reason=missing, original path reported" ;;
  *) bad "case11: got '$out'" ;;
esac

# --- Cases 12–16: --channel stable|beta (two-channel decision, v1.8.0) ---
# stable (the default) keeps the strict ^vX.Y.Z$ filter; beta selects the
# latest tag among stable+prerelease under versionsort.suffix=-beta. —
# where a NEWER STABLE BEATS AN OLDER BETA (the empirically-pinned
# ordering trap: default version sort puts v1.11.1-beta.2 after v1.11.1).

# --- Case 12: --channel beta resolves the latest prerelease ---
( cd "$ORIGIN" && printf 'b1\n' >> install.sh && git add -A && git commit -q -m five )
git -C "$ORIGIN" tag v1.11.1-beta.1
( cd "$ORIGIN" && printf 'b2\n' >> install.sh && git add -A && git commit -q -m six )
git -C "$ORIGIN" tag v1.11.1-beta.2
run_resolve --channel beta "$OWNED"
[ "$status" -eq 0 ] && [ "$out" = "resolved=$OWNED ref=v1.11.1-beta.2 channel=release" ] \
  && ok "case12: --channel beta picks the newest prerelease" \
  || bad "case12: got '$out' (rc=$status)"
[ "$(git -C "$OWNED" rev-parse HEAD)" = "$(git -C "$OWNED" rev-parse 'v1.11.1-beta.2^{commit}')" ] \
  && ok "case12: owned checkout moved to the beta tag" \
  || bad "case12: owned checkout not at v1.11.1-beta.2"

# --- Case 13: stable stays the default; betas are invisible to it ---
run_resolve "$OWNED"
[ "$out" = "resolved=$OWNED ref=v1.11.0 channel=release" ] \
  && ok "case13: bare invocation stays stable (betas invisible)" \
  || bad "case13: got '$out'"
run_resolve --channel stable "$OWNED"
[ "$out" = "resolved=$OWNED ref=v1.11.0 channel=release" ] \
  && ok "case13: explicit --channel stable identical" \
  || bad "case13: explicit stable got '$out'"

# --- Case 14: the ordering trap — a newer stable beats an older beta ---
( cd "$ORIGIN" && printf 's\n' >> install.sh && git add -A && git commit -q -m seven )
git -C "$ORIGIN" tag v1.11.1
run_resolve --channel beta "$OWNED"
[ "$out" = "resolved=$OWNED ref=v1.11.1 channel=release" ] \
  && ok "case14: beta channel resolves the newer stable v1.11.1" \
  || bad "case14: got '$out'"
# Pin the trap itself: without the suffix, the stale beta would have won.
default_last="$(git -C "$OWNED" tag --list 'v1.11.1*' --sort=v:refname | tail -1)"
[ "$default_last" = "v1.11.1-beta.2" ] \
  && ok "case14: trap pinned — default sort prefers the stale beta" \
  || bad "case14: default-sort trap changed? last='$default_last'"

# --- Case 15: --channel beta on a dev checkout — still dev, never mutated ---
dev_head="$(git -C "$DEV" rev-parse HEAD)"
run_resolve --channel beta "$DEV"
[ "$status" -eq 0 ] && [ "$out" = "resolved=$DEV channel=dev" ] \
  && ok "case15: dev checkout stays channel=dev under --channel beta" \
  || bad "case15: got '$out' (rc=$status)"
[ "$(git -C "$DEV" rev-parse HEAD)" = "$dev_head" ] \
  && ok "case15: dev checkout not mutated" \
  || bad "case15: dev checkout HEAD moved"

# --- Case 16: an unknown --channel is a usage refusal, exit 2 ---
run_resolve --channel nightly "$OWNED"
[ "$status" -eq 2 ] \
  && ok "case16: unknown channel exits 2" \
  || bad "case16: expected exit 2, got $status"
case "$out" in
  "resolved=false reason=usage"*) ok "case16: resolved=false reason=usage" ;;
  *) bad "case16: got '$out'" ;;
esac
# --channel=<value> form works too
run_resolve --channel=beta "$OWNED"
[ "$out" = "resolved=$OWNED ref=v1.11.1 channel=release" ] \
  && ok "case16: --channel=beta form accepted" \
  || bad "case16: --channel= form got '$out'"

if [ "$fail" -eq 0 ]; then
  echo "test-source-resolve: all cases pass"
else
  echo "test-source-resolve: FAILURES above" >&2
  exit 1
fi
