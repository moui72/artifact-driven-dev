#!/usr/bin/env sh
# ardd-update-check.sh — is this target's ARDD install behind its source's
# latest release? Reads .project/ardd-version.md (installed commit +
# Source-Path recorded by install.sh) and compares against the source
# checkout's latest semver release tag (constitution, release-channel
# standing decision, 2026-07-12): "behind" means "the installed commit is
# not the latest release's commit" — the tip of the source no longer
# matters when releases exist. A source with no release tags yet falls
# back to the original tip comparison, noted. LOCAL git only — no fetch,
# no network (v1 scope decision, plan-self-update-from-consumer;
# source-resolve.sh owns fetching). Prints exactly one machine-readable
# line; always exits 0 unless inputs are unreadable.
#
#   no-version-file                      never installed / file absent
#   no-source-path                       pre-Source-Path install; re-run install.sh
#   source-missing path=<p>              recorded path gone/not-ardd, and no owned checkout to fall back to
#   self-hosted commit=<x>              source IS the target repo (dogfood); comparison meaningless
#   up-to-date commit=<x>                installed at the latest release's commit
#   behind installed=<x> latest-release=<tag>
#   up-to-date commit=<x> note=no-releases        no tags yet: tip comparison
#   behind installed=<x> source-tip=<y> note=no-releases
#
# Additive tokens (appended, never changing an existing key's meaning):
#   fallback=owned    the recorded Source-Path was invalid and the check ran
#                     against ${ARDD_HOME:-$HOME/.ardd}/source instead (a
#                     moved machine / re-cloned source)
#   channel=beta      the version file records `Channel: beta` (two-channel
#                     decision, v1.8.0), so "latest release" was computed
#                     among stable+prerelease tags under
#                     versionsort.suffix=-beta. ordering — a newer stable
#                     still beats an older beta (the pinned trap). Absent
#                     or `Channel: stable` = today's strict-vX.Y.Z behavior
#                     with no token, so pre-channel files keep parsing.
#
# The installed commit is read from the structured `Source-Commit:` line
# (full sha, written by install.sh since the pre-1.0 hardening) and compared
# by prefix — short-vs-full and future abbreviation-width changes both keep
# matching. Files predating that line fall back to the prose `_Source: ... @
# <short>` parse, which stays decorative in new files.
#
# Usage: ardd-update-check.sh [target-dir]     (default: .)

set -e

TARGET="${1:-.}"
VF="$TARGET/.project/ardd-version.md"

[ -f "$VF" ] || { echo "no-version-file"; exit 0; }

src="$(sed -n 's/^Source-Path: //p' "$VF" | head -1)"
[ -n "$src" ] || { echo "no-source-path"; exit 0; }

# The recorded path must still be an ARDD source checkout. When it isn't
# (moved machine, re-cloned source), fall back to the tooling-owned checkout
# at ${ARDD_HOME:-$HOME/.ardd}/source if that one qualifies — flagged with
# an additive fallback=owned token; only with no usable fallback is the
# original source-missing outcome reported (its meaning is unchanged).
fallback=""
if [ ! -d "$src" ] || [ ! -f "$src/install.sh" ] || [ ! -d "$src/skills" ]; then
  owned="${ARDD_HOME:-$HOME/.ardd}/source"
  if [ -d "$owned" ] && [ -f "$owned/install.sh" ] && [ -d "$owned/skills" ]; then
    src="$owned"
    fallback=" fallback=owned"
  else
    echo "source-missing path=$src"
    exit 0
  fi
fi

# Prefer the structured Source-Commit line; fall back to the prose parse for
# pre-1.0 files that only carry `_Source: artifact-driven-dev @ <short>`.
installed="$(sed -n 's/^Source-Commit: //p' "$VF" | head -1)"
[ -n "$installed" ] || installed="$(sed -n 's/.*_Source: artifact-driven-dev @ \([0-9a-f]*\).*/\1/p' "$VF" | head -1)"

# Prefix match in either direction: recorded and resolved commits may be
# short or full, at any abbreviation width.
same_commit() {
  [ -n "$1" ] && [ -n "$2" ] || return 1
  case "$1" in "$2"*) return 0 ;; esac
  case "$2" in "$1"*) return 0 ;; esac
  return 1
}

# Self-hosted guard: when the source IS the target repo (this repo
# dogfooding itself), the version-bump commit always advances the tip
# past the recorded commit, so "behind" would be a perpetual false
# alarm. Compare resolved git toplevels, never string paths — a
# symlinked or relative Source-Path must still match.
src_top="$(git -C "$src" rev-parse --show-toplevel 2>/dev/null || true)"
tgt_top="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$src_top" ] && [ "$src_top" = "$tgt_top" ]; then
  echo "self-hosted commit=$installed$fallback"
  exit 0
fi

tip="$(git -C "$src" rev-parse --short HEAD 2>/dev/null || true)"

if [ -z "$tip" ]; then
  echo "source-missing path=$src"
  exit 0
fi

# Compare within the recorded channel (absent or unrecognized = stable —
# old files keep parsing). Latest release = highest tag admitted by the
# channel's filter, same selection rules as source-resolve.sh --channel:
# stable = strict vX.Y.Z only; beta = stable+prerelease under
# versionsort.suffix=-beta. (newer stable beats older beta).
channel="$(sed -n 's/^Channel: //p' "$VF" | head -1)"
chtoken=""
if [ "$channel" = "beta" ]; then
  chtoken=" channel=beta"
  latest="$(git -C "$src" -c versionsort.suffix=-beta. tag --list 'v[0-9]*' --sort=v:refname 2>/dev/null \
    | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+(-beta\.[0-9]+)?$' | tail -n 1 || true)"
else
  latest="$(git -C "$src" tag --list 'v[0-9]*' --sort=v:refname 2>/dev/null \
    | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1 || true)"
fi

if [ -n "$latest" ]; then
  release_commit="$(git -C "$src" rev-parse --short "$latest^{commit}" 2>/dev/null || true)"
  if same_commit "$installed" "$release_commit"; then
    echo "up-to-date commit=$installed$fallback$chtoken"
  else
    echo "behind installed=$installed latest-release=$latest$fallback$chtoken"
  fi
elif same_commit "$installed" "$tip"; then
  echo "up-to-date commit=$installed note=no-releases$fallback$chtoken"
else
  echo "behind installed=$installed source-tip=$tip note=no-releases$fallback$chtoken"
fi
