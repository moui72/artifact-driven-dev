#!/usr/bin/env sh
# release.sh — cut an ARDD release. Source-side only, run by a human,
# deliberately: cutting a release (tag + `gh release`) is the act that
# publishes skill changes to consumers (constitution, release-channel
# standing decision, 2026-07-12) — merging to main alone no longer does.
#
# Usage: ./scripts/release.sh [--dry-run] <vX.Y.Z>
#
# Validates, in order, refusing (exit 1) on the first failure:
#   - version argument matches vX.Y.Z exactly (missing arg = usage, exit 2)
#   - working tree is clean
#   - HEAD is on the default branch (branch-info.sh, cwd repo)
#   - the tag does not already exist
#   - the repo's full pre-commit suite (hooks/pre-commit) passes; a missing
#     suite is a refusal, never a silent skip
#
# --dry-run stops after validation. Otherwise: create an annotated,
# SSH-signed tag (signed with the on-disk Claude signing key — decided at
# T001's checkpoint), push it, and publish the GitHub release. Those three
# steps are thin and untested by design (test-release.sh pins the refusals
# and, statically, the signed-tag line).
#
# Operates on the repository at the current working directory, like the
# pre-commit hook it runs.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

dry_run=0
tag=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    -*) echo "release: unknown option '$arg'" >&2
        echo "Usage: release.sh [--dry-run] <vX.Y.Z>" >&2; exit 2 ;;
    *)  [ -z "$tag" ] || { echo "release: unexpected argument '$arg'" >&2; exit 2; }
        tag="$arg" ;;
  esac
done

if [ -z "$tag" ]; then
  echo "Usage: release.sh [--dry-run] <vX.Y.Z>" >&2
  exit 2
fi

# Version format first — a typo'd tag must cost nothing.
case "$tag" in
  v[0-9]*.[0-9]*.[0-9]*) ;;
  *) echo "release: refused — '$tag' is not a vX.Y.Z version" >&2; exit 1 ;;
esac
if ! printf '%s\n' "$tag" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "release: refused — '$tag' is not a vX.Y.Z version" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "release: refused — not inside a git work tree" >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "release: refused — working tree is not clean; commit or stash first" >&2
  exit 1
fi

# A release is always cut from the default branch — a feature branch's tip
# is unmerged, possibly-broken state.
if ! sh "$SCRIPT_DIR/branch-info.sh" | grep -qx 'on_default=true'; then
  echo "release: refused — not on the default branch" >&2
  exit 1
fi

if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  echo "release: refused — tag '$tag' already exists" >&2
  exit 1
fi

# The full pre-commit suite must pass at the exact commit being released.
# Missing suite = refusal: releasing unverified state is worse than a
# papercut, and this repo always carries hooks/pre-commit.
if [ ! -f "hooks/pre-commit" ]; then
  echo "release: refused — hooks/pre-commit not found; refusing to release unverified state" >&2
  exit 1
fi
if ! sh "hooks/pre-commit"; then
  echo "release: refused — pre-commit suite failed" >&2
  exit 1
fi

if [ "$dry_run" -eq 1 ]; then
  echo "release: dry-run — all validations passed for $tag; stopping before tag/push/gh."
  exit 0
fi

# --- The deliberate, irreversible part: tag, push, publish ---------------
# SSH-signed with the on-disk Claude signing key (never the 1Password-backed
# key, which can't sign from a locked remote session).
git -c gpg.format=ssh \
    -c gpg.ssh.program=ssh-keygen \
    -c user.signingkey="$HOME/.ssh/id_claude_signing.pub" \
    tag -s "$tag" -m "ARDD release $tag"
echo "release: tagged $tag (annotated, SSH-signed)"

git push origin "$tag"
echo "release: pushed $tag"

gh release create "$tag" --generate-notes
echo "release: published $tag"
