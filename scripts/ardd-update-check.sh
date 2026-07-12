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
#   source-missing path=<p>              recorded path gone, or not an ARDD checkout
#   self-hosted commit=<x>              source IS the target repo (dogfood); comparison meaningless
#   up-to-date commit=<x>                installed at the latest release's commit
#   behind installed=<x> latest-release=<tag>
#   up-to-date commit=<x> note=no-releases        no tags yet: tip comparison
#   behind installed=<x> source-tip=<y> note=no-releases
#
# Usage: ardd-update-check.sh [target-dir]     (default: .)

set -e

TARGET="${1:-.}"
VF="$TARGET/.project/ardd-version.md"

[ -f "$VF" ] || { echo "no-version-file"; exit 0; }

src="$(sed -n 's/^Source-Path: //p' "$VF" | head -1)"
[ -n "$src" ] || { echo "no-source-path"; exit 0; }

# The recorded path must still be an ARDD source checkout (moved or
# deleted checkouts both land here, same reason format).
if [ ! -d "$src" ] || [ ! -f "$src/install.sh" ] || [ ! -d "$src/skills" ]; then
  echo "source-missing path=$src"
  exit 0
fi

installed="$(sed -n 's/.*_Source: artifact-driven-dev @ \([0-9a-f]*\).*/\1/p' "$VF" | head -1)"

# Self-hosted guard: when the source IS the target repo (this repo
# dogfooding itself), the version-bump commit always advances the tip
# past the recorded commit, so "behind" would be a perpetual false
# alarm. Compare resolved git toplevels, never string paths — a
# symlinked or relative Source-Path must still match.
src_top="$(git -C "$src" rev-parse --show-toplevel 2>/dev/null || true)"
tgt_top="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$src_top" ] && [ "$src_top" = "$tgt_top" ]; then
  echo "self-hosted commit=$installed"
  exit 0
fi

tip="$(git -C "$src" rev-parse --short HEAD 2>/dev/null || true)"

if [ -z "$tip" ]; then
  echo "source-missing path=$src"
  exit 0
fi

# Latest release = highest strict-semver tag (same selection rule as
# source-resolve.sh: v:refname ordering, vX.Y.Z only — pre-releases and
# decoy tags never count as releases).
latest="$(git -C "$src" tag --list 'v[0-9]*' --sort=v:refname 2>/dev/null \
  | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1 || true)"

if [ -n "$latest" ]; then
  release_commit="$(git -C "$src" rev-parse --short "$latest^{commit}" 2>/dev/null || true)"
  if [ "$installed" = "$release_commit" ]; then
    echo "up-to-date commit=$installed"
  else
    echo "behind installed=$installed latest-release=$latest"
  fi
elif [ "$installed" = "$tip" ]; then
  echo "up-to-date commit=$installed note=no-releases"
else
  echo "behind installed=$installed source-tip=$tip note=no-releases"
fi
