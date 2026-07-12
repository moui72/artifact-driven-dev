#!/usr/bin/env sh
# Regression test for install.sh's .worktreeinclude setup step: it must
# ensure the exact pattern ".claude/skills/ardd-*/" is present in the
# target's .worktreeinclude, creating the file if absent, appending to it
# without gluing lines together if a trailing newline is missing, and
# leaving it untouched (idempotent) if the pattern is already there.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SH="$REPO_ROOT/install.sh"
PATTERN=".claude/skills/ardd-*/"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Throwaway fixture repos under $WORK — no signing needed or wanted, and no
# hooks from the invoking user's global core.hooksPath should run against
# these disposable repos.
git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

pattern_count() {
  grep -cxF "$PATTERN" "$1" 2>/dev/null || true
}

run_install() {
  # Silence install.sh's own stdout — we only assert on the resulting file.
  ( cd "$REPO_ROOT" && sh "$INSTALL_SH" "$1" ) >/dev/null
}

# --- Case 1: no .worktreeinclude exists ---
target="$WORK/case1"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

run_install "$target"

wti="$target/.worktreeinclude"
if [ ! -f "$wti" ]; then
  bad "case1: .worktreeinclude created"
else
  ok "case1: .worktreeinclude created"
fi

count="$(pattern_count "$wti")"
if [ "$count" = "1" ]; then
  ok "case1: pattern present exactly once"
else
  bad "case1: pattern present exactly once (got count=$count)"
fi

# --- Case 1a2: badge suggestion — README without marker gets a printed
# suggestion and is NEVER edited by install.sh itself ---
printf '# Case1 Project\n' > "$target/README.md"
before="$(cat "$target/README.md")"
out="$(cd "$REPO_ROOT" && sh "$INSTALL_SH" "$target")"
after="$(cat "$target/README.md")"
if [ "$before" = "$after" ]; then
  ok "badge: README untouched by install"
else
  bad "badge: README untouched by install"
fi
case "$out" in
  *ardd-badge-start*) ok "badge: suggestion printed when marker absent" ;;
  *) bad "badge: suggestion printed when marker absent" ;;
esac

# marker present -> silent
cat "$REPO_ROOT/templates/badge.md" >> "$target/README.md"
out="$(cd "$REPO_ROOT" && sh "$INSTALL_SH" "$target")"
case "$out" in
  *"built with-ARDD-blue"*|*"suggestion"*|*ardd-badge-start*)
    # tolerate the word suggestion elsewhere; assert the badge block is not re-suggested
    case "$out" in
      *"img.shields.io/badge/built"*) bad "badge: silent when marker present" ;;
      *) ok "badge: silent when marker present" ;;
    esac ;;
  *) ok "badge: silent when marker present" ;;
esac

# no README -> silent (case2 target below has no README; checked here on a fresh dir)
nb="$WORK/nobadge"; mkdir -p "$nb"; git init -q "$nb"; git -C "$nb" commit -q --allow-empty -m init
out="$(cd "$REPO_ROOT" && sh "$INSTALL_SH" "$nb")"
case "$out" in
  *"img.shields.io"*) bad "badge: silent when README missing" ;;
  *) ok "badge: silent when README missing" ;;
esac

# --- Case 1a3: Source-Path recorded in ardd-version.md, absolute, once
# (and still exactly once after the second install in case 1a2) ---
vf="$target/.project/ardd-version.md"
sp_count="$(grep -c '^Source-Path: ' "$vf" 2>/dev/null || true)"
if [ "$sp_count" = "1" ]; then
  ok "version file: Source-Path present exactly once after two installs"
else
  bad "version file: Source-Path present exactly once (count=$sp_count)"
fi
sp_val="$(sed -n 's/^Source-Path: //p' "$vf" | head -1)"
case "$sp_val" in
  /*) [ -d "$sp_val" ] && ok "version file: Source-Path absolute and exists" || bad "version file: Source-Path dir missing: $sp_val" ;;
  *) bad "version file: Source-Path not absolute: '$sp_val'" ;;
esac

# --- Case 1b: ardd-state.sh ships into ardd-scripts and is executable ---
state="$target/.claude/skills/ardd-scripts/ardd-state.sh"
if [ -x "$state" ]; then
  ok "case1b: ardd-state.sh installed and executable"
else
  bad "case1b: ardd-state.sh installed and executable (missing or not +x)"
fi
uc="$target/.claude/skills/ardd-scripts/ardd-update-check.sh"
if [ -x "$uc" ]; then
  ok "case1b2: ardd-update-check.sh installed and executable"
else
  bad "case1b2: ardd-update-check.sh installed and executable"
fi
sr="$target/.claude/skills/ardd-scripts/source-resolve.sh"
if [ -x "$sr" ]; then
  ok "case1b3: source-resolve.sh installed and executable"
else
  bad "case1b3: source-resolve.sh installed and executable"
fi

# --- Case 2: existing .worktreeinclude, unrelated content, NO trailing newline ---
target="$WORK/case2"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

wti="$target/.worktreeinclude"
printf '.env' > "$wti"   # deliberately no trailing newline

run_install "$target"

if grep -qxF ".env" "$wti"; then
  ok "case2: original .env line intact"
else
  bad "case2: original .env line intact"
fi

if grep -q '\.env\.claude' "$wti"; then
  bad "case2: no glued line (.env + pattern must not merge)"
else
  ok "case2: no glued line"
fi

count="$(pattern_count "$wti")"
if [ "$count" = "1" ]; then
  ok "case2: pattern appended exactly once"
else
  bad "case2: pattern appended exactly once (got count=$count)"
fi

# --- Case 3: pattern already present -> file unchanged, idempotent re-run ---
target="$WORK/case3"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

run_install "$target"   # first install creates it with the pattern

wti="$target/.worktreeinclude"
before_sum="$(cksum "$wti")"

run_install "$target"   # second install should be a no-op for this file

after_sum="$(cksum "$wti")"

if [ "$before_sum" = "$after_sum" ]; then
  ok "case3: file unchanged across re-install"
else
  bad "case3: file unchanged across re-install"
fi

count="$(pattern_count "$wti")"
if [ "$count" = "1" ]; then
  ok "case3: exactly one pattern line after two installs"
else
  bad "case3: exactly one pattern line after two installs (got count=$count)"
fi

# --- Case 4: pre-existing symlinked ardd-* skill dir (skills-CLI symlink
# mode) -> warned, replaced with a real directory, cache dir untouched ---
target="$WORK/case4"
cache="$WORK/case4-cli-cache/ardd-plan"
mkdir -p "$target" "$cache"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init
mkdir -p "$target/.claude/skills"
ln -s "$cache" "$target/.claude/skills/ardd-plan"

out4="$WORK/case4-out"
( cd "$REPO_ROOT" && sh "$INSTALL_SH" "$target" ) > "$out4" 2>&1

if grep -qi "symlink" "$out4"; then
  ok "case4: symlink warning printed"
else
  bad "case4: symlink warning printed"
fi

dest="$target/.claude/skills/ardd-plan"
if [ ! -L "$dest" ] && [ -d "$dest" ] && [ -f "$dest/SKILL.md" ]; then
  ok "case4: symlink replaced with real directory"
else
  bad "case4: symlink replaced with real directory"
fi

if [ -z "$(ls -A "$cache" 2>/dev/null)" ]; then
  ok "case4: CLI cache dir not written through"
else
  bad "case4: CLI cache dir not written through"
fi

exit "$fail"
