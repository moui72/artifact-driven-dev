#!/usr/bin/env sh
# Regression test for install.sh's third-tier Channel default (F001 fix,
# plan: prerelease-sweep-fixes): when neither $ARDD_CHANNEL nor a
# previously-recorded Channel: applies, the default is inferred from
# $SOURCE_REF's own shape (the -beta. suffix convention this repo already
# uses elsewhere) rather than a hardcoded "stable" — beta when the source
# checkout sits at a prerelease tag, stable otherwise. Explicit
# $ARDD_CHANNEL and a previously-recorded Channel: still win first,
# unaffected by this fix.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# A throwaway source checkout, tagged at a beta prerelease — mirrors this
# repo's own between-releases state (HEAD sitting past the last stable tag,
# at a -beta.N tag).
SRC="$WORK/src"
mkdir -p "$SRC"
cp -R "$REPO_ROOT/skills" "$REPO_ROOT/templates" "$REPO_ROOT/scripts" "$REPO_ROOT/migrations" "$SRC/"
cp "$REPO_ROOT/install.sh" "$SRC/"
( cd "$SRC" && git init -q -b main && git add -A && git commit -q -m one )
git -C "$SRC" tag v1.0.0-beta.1

new_target() { # $1=name
  t="$WORK/$1"
  mkdir -p "$t"
  git init -q "$t"
  git -C "$t" commit -q --allow-empty -m init
  echo "$t"
}

run_install() { # $1=target
  ( cd "$SRC" && sh "$SRC/install.sh" "$1" ) >/dev/null 2>&1
}

# --- Case 1: fresh target, no $ARDD_CHANNEL, no prior recorded channel,
# source sits at a beta tag -> Channel: beta inferred ---
target="$(new_target case1)"
run_install "$target"
vf="$target/.project/ardd-version.md"
if grep -q '^Channel: beta$' "$vf" 2>/dev/null; then
  ok "case1: beta-tag source with no prior/explicit channel infers Channel: beta"
else
  bad "case1: beta-tag source with no prior/explicit channel infers Channel: beta"
  cat "$vf" 2>/dev/null || echo "(no version file)"
fi

# --- Case 2: explicit $ARDD_CHANNEL=stable still wins over the beta-shaped
# Source-Ref ---
target="$(new_target case2)"
( cd "$SRC" && ARDD_CHANNEL=stable sh "$SRC/install.sh" "$target" ) >/dev/null 2>&1
if grep -q '^Channel: stable$' "$target/.project/ardd-version.md" 2>/dev/null; then
  ok "case2: explicit ARDD_CHANNEL=stable overrides beta-shaped Source-Ref"
else
  bad "case2: explicit ARDD_CHANNEL=stable overrides beta-shaped Source-Ref"
fi

# --- Case 3: a target with a previously-recorded Channel: beta preserves
# it on re-install even with $ARDD_CHANNEL unset ---
target="$(new_target case3)"
( cd "$SRC" && ARDD_CHANNEL=beta sh "$SRC/install.sh" "$target" ) >/dev/null 2>&1
run_install "$target"
if grep -q '^Channel: beta$' "$target/.project/ardd-version.md" 2>/dev/null; then
  ok "case3: previously-recorded Channel: beta preserved with ARDD_CHANNEL unset"
else
  bad "case3: previously-recorded Channel: beta preserved with ARDD_CHANNEL unset"
fi

# --- Case 4: source HEAD carries BOTH a stable and a beta tag (the state
# right after a stable cut, where HEAD still carries the beta it was
# promoted from) -> recorded Source-Ref: is the stable tag, never the beta
# (c7cb703 fix: git describe --exact-match picks non-deterministically) ---
git -C "$SRC" tag v1.0.0
target="$(new_target case4)"
run_install "$target"
vf="$target/.project/ardd-version.md"
if grep -q '^Source-Ref: v1.0.0$' "$vf" 2>/dev/null; then
  ok "case4: dual-tagged HEAD records the stable tag as Source-Ref"
else
  bad "case4: dual-tagged HEAD records the stable tag as Source-Ref"
  cat "$vf" 2>/dev/null || echo "(no version file)"
fi

exit "$fail"
