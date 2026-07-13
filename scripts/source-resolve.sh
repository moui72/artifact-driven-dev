#!/usr/bin/env sh
# source-resolve.sh — resolve an ARDD source checkout to the release
# channel (constitution, release-channel standing decision, 2026-07-12).
# Target-side: installed to .claude/skills/ardd-scripts/ and shelled out to
# by /ardd-update's source-standing step. The decision tree here is a pure
# function of disk/remote state (Principle II); the judgment — whether to
# accept a dev-mode source — stays in skill prose.
#
# Usage: source-resolve.sh [--channel stable|beta] [source-path]
#   With no source-path argument, reads the Source-Path: line from
#   ./.project/ardd-version.md (the file install.sh writes).
#   --channel (default stable) picks which tags count for the owned
#   checkout (two-channel decision, v1.8.0): stable = strict vX.Y.Z only
#   (today's behavior, unchanged); beta = the latest tag among
#   stable+prerelease under versionsort.suffix=-beta. ordering, where a
#   newer stable beats an older beta — the empirically-pinned trap: git's
#   DEFAULT version sort puts vX.Y.Z-beta.N *after* vX.Y.Z, so without
#   the suffix a stale beta would shadow a newer stable. Dev-mode paths
#   ignore the flag entirely (used exactly as given, never mutated).
#
# Outcomes (one machine-readable line; warnings appended as tokens):
#   resolved=<path> ref=<tag> channel=release            owned checkout, at latest release
#   resolved=<path> ref=<branch> channel=release warning=no-tags
#                                                        owned, no releases yet -> default branch
#   ... warning=offline                                  fetch failed; resolved from existing state
#   resolved=<path> channel=dev                          any other existing ARDD checkout (never mutated)
#   ... fallback=owned                                   recorded Source-Path was invalid; resolved the
#                                                        owned checkout instead (additive token; only a
#                                                        version-file path falls back, never an explicit
#                                                        argument — the user named that one deliberately)
#   resolved=false reason=missing|not-ardd|no-source-path  (exit 1)
#
# Only the tooling-owned checkout at $ARDD_HOME/source (~/.ardd/source) is
# ever mutated: fetched (`--tags`, offline-tolerant) and checked out at the
# latest semver release tag, detached — expected between updates. A user's
# checkout named any other way is read, never written (same ownership rule
# as new.sh). Latest-release selection is `git tag --sort=v:refname` over
# strict vX.Y.Z tags — fixture tests (test-source-resolve.sh) pin the
# v1.10.0 > v1.9.0 ordering and the pre-release/decoy exclusions, per the
# plan's Complexity Tracking; no hand-rolled compare needed while they hold.

set -e

CHANNEL="stable"
SRC=""
while [ $# -gt 0 ]; do
  case "$1" in
    --channel)   [ $# -ge 2 ] || { echo "resolved=false reason=usage detail=--channel-needs-a-value"; exit 2; }
                 CHANNEL="$2"; shift 2 ;;
    --channel=*) CHANNEL="${1#--channel=}"; shift ;;
    -*)          echo "resolved=false reason=usage detail=unknown-option:$1"; exit 2 ;;
    *)           [ -z "$SRC" ] || { echo "resolved=false reason=usage detail=unexpected-argument:$1"; exit 2; }
                 SRC="$1"; shift ;;
  esac
done
case "$CHANNEL" in
  stable|beta) ;;
  *) echo "resolved=false reason=usage detail=unknown-channel:$CHANNEL"; exit 2 ;;
esac

FROM_VF=""

if [ -z "$SRC" ]; then
  VF=".project/ardd-version.md"
  [ -f "$VF" ] && SRC="$(sed -n 's/^Source-Path: //p' "$VF" | head -1)"
  if [ -z "$SRC" ]; then
    echo "resolved=false reason=no-source-path"
    exit 1
  fi
  FROM_VF=1
fi

# A recorded (version-file) Source-Path that no longer exists on this
# machine — moved machine, re-cloned source — falls back to the owned
# checkout when that one qualifies, flagged with an additive fallback=owned
# token. An explicit argument never falls back: the user named it.
FALLBACK=""
if [ -n "$FROM_VF" ] && { [ ! -d "$SRC" ] || [ ! -f "$SRC/install.sh" ] || [ ! -d "$SRC/skills" ]; }; then
  owned_fb="${ARDD_HOME:-$HOME/.ardd}/source"
  if [ -d "$owned_fb" ] && [ -f "$owned_fb/install.sh" ] && [ -d "$owned_fb/skills" ]; then
    SRC="$owned_fb"
    FALLBACK=" fallback=owned"
  fi
fi

if [ ! -d "$SRC" ]; then
  echo "resolved=false reason=missing path=$SRC"
  exit 1
fi

# Must be an ARDD checkout at all — same shape check as ardd-update-check.sh.
if [ ! -f "$SRC/install.sh" ] || [ ! -d "$SRC/skills" ]; then
  echo "resolved=false reason=not-ardd path=$SRC"
  exit 1
fi

# Owned = the one checkout the tooling may mutate. Compare physical paths so
# a symlinked or relative spelling of the same directory still matches.
OWNED="${ARDD_HOME:-$HOME/.ardd}/source"
src_phys="$(cd "$SRC" && pwd -P)"
owned_phys="$( [ -d "$OWNED" ] && cd "$OWNED" && pwd -P || echo "$OWNED" )"

if [ "$src_phys" != "$owned_phys" ]; then
  echo "resolved=$SRC channel=dev$FALLBACK"
  exit 0
fi

# --- Owned checkout: fetch tags (offline-tolerant), move to latest release ---
warn=""
if ! git -C "$SRC" fetch --tags --quiet origin >/dev/null 2>&1; then
  warn=" warning=offline"
fi

# Channel filter. stable: strict vX.Y.Z only — the grep pins the exact
# shape (excludes pre-releases and decoys like v1.10.0-rc2). beta: also
# admits vX.Y.Z-beta.N, ordered under versionsort.suffix=-beta. so a
# newer stable still beats an older beta (the pinned trap).
if [ "$CHANNEL" = "beta" ]; then
  tag="$(git -C "$SRC" -c versionsort.suffix=-beta. tag --list 'v[0-9]*' --sort=v:refname \
    | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+(-beta\.[0-9]+)?$' | tail -n 1 || true)"
else
  tag="$(git -C "$SRC" tag --list 'v[0-9]*' --sort=v:refname \
    | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1 || true)"
fi

if [ -n "$tag" ]; then
  git -C "$SRC" checkout --quiet "$tag"
  echo "resolved=$SRC ref=$tag channel=release$warn$FALLBACK"
  exit 0
fi

# No releases yet: stay on (return to) the default branch, flagged.
default="$(git -C "$SRC" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's#^refs/remotes/origin/##')"
if [ -z "$default" ]; then
  if git -C "$SRC" show-ref --verify --quiet refs/heads/main; then
    default=main
  else
    default=master
  fi
fi
git -C "$SRC" checkout --quiet "$default"
echo "resolved=$SRC ref=$default channel=release warning=no-tags$warn$FALLBACK"
