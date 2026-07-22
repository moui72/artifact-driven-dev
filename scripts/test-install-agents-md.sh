#!/usr/bin/env sh
# Regression test for install.sh's Codex AGENTS.md wiring. A Codex install
# writes a never-clobber AGENTS.md pointer file at the target root; a
# Claude install never touches it.

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

run_install() {
  target="$1"
  shift
  ( cd "$REPO_ROOT" && sh "$INSTALL_SH" "$@" "$target" )
}

# --- Case 1: fresh Codex target gets AGENTS.md matching the template ---
target="$WORK/codex-fresh"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

run_install "$target" --harness codex >/dev/null

if [ -f "$target/AGENTS.md" ] \
   && cmp -s "$REPO_ROOT/templates/AGENTS.md" "$target/AGENTS.md"; then
  ok "codex fresh: AGENTS.md written and matches template byte-for-byte"
else
  bad "codex fresh: AGENTS.md written and matches template byte-for-byte"
fi

# --- Case 2: existing AGENTS.md is never clobbered, advisory line printed ---
target="$WORK/codex-existing"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init
printf 'custom agents content\n' > "$target/AGENTS.md"

out="$(run_install "$target" --harness codex)"

if [ -f "$target/AGENTS.md" ] \
   && [ "$(cat "$target/AGENTS.md")" = "custom agents content" ]; then
  ok "codex existing: AGENTS.md left byte-identical to pre-install content"
else
  bad "codex existing: AGENTS.md left byte-identical to pre-install content"
fi

case "$out" in
  *"AGENTS.md"*"already exists, left untouched"*)
    ok "codex existing: install output names AGENTS.md as already-existing" ;;
  *)
    bad "codex existing: install output names AGENTS.md as already-existing" ;;
esac

# --- Case 3: Claude installs never write or mention AGENTS.md ---
target="$WORK/claude-fresh"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

out="$(run_install "$target")"

[ ! -e "$target/AGENTS.md" ] \
  && ok "claude fresh: does not write AGENTS.md" \
  || bad "claude fresh: does not write AGENTS.md"

case "$out" in
  *AGENTS.md*) bad "claude fresh: install output does not mention AGENTS.md" ;;
  *) ok "claude fresh: install output does not mention AGENTS.md" ;;
esac

if [ "$fail" -ne 0 ]; then
  echo "test-install-agents-md: FAILED" >&2
  exit 1
fi

echo "test-install-agents-md: ok"
