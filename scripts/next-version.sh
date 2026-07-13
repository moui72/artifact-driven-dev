#!/usr/bin/env sh
# next-version.sh — the single version-compute authority for the two
# release channels (constitution v1.8.0, two-channel standing decision).
# Source-side only: called by the release workflows and maintainers, and
# deliberately NOT shipped by install.sh — consumers never compute
# versions, they resolve tags.
#
# Usage: next-version.sh beta
#        next-version.sh stable [major|minor|patch]     (default: patch)
#
# Prints exactly one tag on stdout, computed from the tags of the repo at
# the current working directory:
#   beta    -> the next prerelease of the *upcoming patch version*:
#              latest stable vX.Y.Z gives vX.Y.(Z+1)-beta.N, where N is one
#              past the highest existing beta for that version (or 1).
#              After a stable vX.Y.(Z+1) ships, betas roll over to target
#              vX.Y.(Z+2). No stable tags at all -> v0.0.1-beta.N.
#   stable  -> the latest stable bumped per the argument (vX.Y.Z+1 /
#              vX.(Y+1).0 / v(X+1).0.0). No stable tags -> bump from 0.0.0.
#
# All tag ordering runs under `-c versionsort.suffix=-beta.`. That suffix
# is load-bearing: git's DEFAULT version sort orders `v0.9.1-beta.2`
# AFTER `v0.9.1`, so any "latest tag" pick without it prefers a stale beta
# over a newer stable. test-next-version.sh pins that trap empirically in
# both directions. Latest-*stable* selection is additionally immune by
# construction (strict ^vX.Y.Z$ filter), same rule as source-resolve.sh.
#
# Refusals: not a git repo -> exit 1; bad usage -> exit 2. Never writes.

set -e

usage() {
  echo "Usage: next-version.sh beta | next-version.sh stable [major|minor|patch]" >&2
  exit 2
}

mode="${1:-}"
case "$mode" in
  beta)
    [ $# -le 1 ] || usage
    ;;
  stable)
    [ $# -le 2 ] || usage
    bump="${2:-patch}"
    case "$bump" in major|minor|patch) ;; *) usage ;; esac
    ;;
  *) usage ;;
esac

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "next-version: not inside a git work tree" >&2
  exit 1
fi

vgit() { git -c versionsort.suffix=-beta. "$@"; }

# Latest stable release: strict vX.Y.Z only — prereleases and decoys
# (v1.10.1-rc1, v2, banana) never count.
latest_stable="$(vgit tag --list 'v[0-9]*' --sort=v:refname \
  | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1 || true)"

base="${latest_stable#v}"
[ -n "$base" ] || base="0.0.0"
major="${base%%.*}"
rest="${base#*.}"
minor="${rest%%.*}"
patch="${rest#*.}"

if [ "$mode" = "stable" ]; then
  case "$bump" in
    major) printf 'v%s.0.0\n' "$((major + 1))" ;;
    minor) printf 'v%s.%s.0\n' "$major" "$((minor + 1))" ;;
    patch) printf 'v%s.%s.%s\n' "$major" "$minor" "$((patch + 1))" ;;
  esac
  exit 0
fi

# --- beta: target the upcoming patch version, increment its beta N -------
target="$major.$minor.$((patch + 1))"

# Highest existing beta for the target version, under suffix-aware
# ordering (numeric: beta.10 > beta.9). Escape the dots for the grep pin.
target_re="$(printf '%s' "$target" | sed 's/\./\\./g')"
last_beta="$(vgit tag --list "v$target-beta.*" --sort=v:refname \
  | grep -E "^v$target_re-beta\.[0-9]+\$" | tail -n 1 || true)"

if [ -n "$last_beta" ]; then
  n="${last_beta##*-beta.}"
  n=$((n + 1))
else
  n=1
fi

printf 'v%s-beta.%s\n' "$target" "$n"
