#!/usr/bin/env sh
# Regression test for install.sh's Source-Path portability: the
# `Source-Path:` line written into the target's .project/ardd-version.md
# must be home-relative (`~/<rest>`) whenever the source checkout sits
# under $HOME, and stay absolute otherwise — a committed absolute path is
# a machine-specific leak in the consumer repo (feedback 19ce F001).
# Also covers the legacy repair: re-installing over a target whose
# existing ardd-version.md records an absolute under-$HOME Source-Path
# rewrites it portably and prints a history-leak notice (19ce F002).

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SH="$REPO_ROOT/install.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

recorded_path() { # $1=target
  sed -n 's/^Source-Path: //p' "$1/.project/ardd-version.md" | head -1
}

mk_target() { # $1=dir
  mkdir -p "$1"
  git init -q "$1"
  git -C "$1" commit -q --allow-empty -m init
}

# --- Case 1: source under $HOME -> home-relative ~/<rest> recorded ---
# Fake HOME as the source repo's parent so the real checkout "sits under
# $HOME" regardless of where CI put it.
target="$WORK/case1"
mk_target "$target"
FAKE_HOME="$(dirname "$REPO_ROOT")"
( cd "$REPO_ROOT" && HOME="$FAKE_HOME" sh "$INSTALL_SH" "$target" ) >/dev/null

rec="$(recorded_path "$target")"
case "$rec" in
  "~/"*) ok "case1: Source-Path recorded home-relative ($rec)" ;;
  *)     bad "case1: Source-Path recorded home-relative (got: $rec)" ;;
esac
expected="~/$(basename "$REPO_ROOT")"
if [ "$rec" = "$expected" ]; then
  ok "case1: recorded path expands back to the source checkout"
else
  bad "case1: recorded path expands back to the source checkout (got $rec, want $expected)"
fi

# --- Case 2: source NOT under $HOME -> absolute path kept ---
target="$WORK/case2"
mk_target "$target"
( cd "$REPO_ROOT" && HOME="$WORK/not-a-parent" sh "$INSTALL_SH" "$target" ) >/dev/null

rec="$(recorded_path "$target")"
if [ "$rec" = "$REPO_ROOT" ]; then
  ok "case2: Source-Path stays absolute when source is outside \$HOME"
else
  bad "case2: Source-Path stays absolute when source is outside \$HOME (got: $rec)"
fi

# --- Case 3 (legacy repair): existing version file records an absolute
# under-$HOME path -> re-install rewrites portably + prints the
# history-leak notice; the change is left uncommitted in the target ---
target="$WORK/case3"
mk_target "$target"
mkdir -p "$target/.project"
cat > "$target/.project/ardd-version.md" <<EOF
# ArDD Version

_Source: artifact-driven-dev @ deadbee · Installed/updated 2026-01-01_

Source-Path: $REPO_ROOT
EOF
git -C "$target" add .project/ardd-version.md
git -C "$target" commit -q -m "record ardd version"

out="$( cd "$REPO_ROOT" && HOME="$FAKE_HOME" sh "$INSTALL_SH" "$target" )"

rec="$(recorded_path "$target")"
case "$rec" in
  "~/"*) ok "case3: legacy absolute Source-Path rewritten to ~/ form" ;;
  *)     bad "case3: legacy absolute Source-Path rewritten to ~/ form (got: $rec)" ;;
esac
case "$out" in
  *"git history"*) ok "case3: history-leak notice printed" ;;
  *)               bad "case3: history-leak notice printed" ;;
esac
# The rewrite must be left uncommitted (user's call how to handle history).
if git -C "$target" diff --quiet -- .project/ardd-version.md; then
  bad "case3: rewrite left uncommitted in the target"
else
  ok "case3: rewrite left uncommitted in the target"
fi

# --- Case 4: fresh install (no prior version file) must NOT print the
# legacy notice ---
target="$WORK/case4"
mk_target "$target"
out="$( cd "$REPO_ROOT" && HOME="$FAKE_HOME" sh "$INSTALL_SH" "$target" )"
case "$out" in
  *"git history"*) bad "case4: no legacy notice on a fresh install" ;;
  *)               ok "case4: no legacy notice on a fresh install" ;;
esac

if [ "$fail" = "0" ]; then
  echo "test-install-source-path: all cases passed"
else
  echo "test-install-source-path: FAILURES"
  exit 1
fi
