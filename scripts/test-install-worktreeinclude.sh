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

exit "$fail"
