#!/usr/bin/env sh
# Regression test for install.sh's .project/.gitattributes setup step: it
# must ensure the four single-writer report files (STATUS.md, DEFECTS.md,
# TRACKER.md, audit.md) carry `merge=ours` in the target's
# .project/.gitattributes — creating the file if absent, appending only the
# missing entries (never duplicating, never gluing onto a final line that
# lacks a trailing newline), preserving user-added lines, and leaving the
# file untouched (idempotent) on re-install. It must also print the one-time
# `git config merge.ours.driver true` opt-in suggestion when the driver is
# unconfigured in the target repo, and stay silent about it when configured
# (suggest-and-check, hooksPath-style — install.sh never mutates the user's
# git config).

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SH="$REPO_ROOT/install.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Throwaway fixture repos under $WORK — no signing, no user hooks.
git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

ENTRIES="STATUS.md
DEFECTS.md
TRACKER.md
audit.md"

entry_count() { # $1=file $2=report-name
  grep -cxF "$2 merge=ours" "$1" 2>/dev/null || true
}

all_entries_once() { # $1=file $2=case-label
  for e in $ENTRIES; do
    c="$(entry_count "$1" "$e")"
    if [ "$c" = "1" ]; then
      ok "$2: '$e merge=ours' present exactly once"
    else
      bad "$2: '$e merge=ours' present exactly once (got count=$c)"
    fi
  done
}

run_install() { # $1=target -> prints install output
  ( cd "$REPO_ROOT" && sh "$INSTALL_SH" "$1" )
}

# --- Case 1: fresh target, no .project/.gitattributes -> created, all four
# entries, and the driver-unconfigured suggestion printed ---
target="$WORK/case1"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

out="$(run_install "$target")"

ga="$target/.project/.gitattributes"
if [ -f "$ga" ]; then
  ok "case1: .project/.gitattributes created"
else
  bad "case1: .project/.gitattributes created"
fi
all_entries_once "$ga" "case1"

case "$out" in
  *"git config merge.ours.driver true"*)
    ok "case1: driver opt-in suggestion printed when unconfigured" ;;
  *)
    bad "case1: driver opt-in suggestion printed when unconfigured" ;;
esac

# install.sh must suggest, never mutate the user's config.
if git -C "$target" config --get merge.ours.driver >/dev/null 2>&1; then
  bad "case1: install.sh must not set merge.ours.driver itself"
else
  ok "case1: install.sh did not touch the target's git config"
fi

# --- Case 2: existing .gitattributes with a user line and NO trailing
# newline -> user line intact, no glued line, entries appended once ---
target="$WORK/case2"
mkdir -p "$target/.project"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init
ga="$target/.project/.gitattributes"
printf '*.snap merge=union' > "$ga"   # deliberately no trailing newline

run_install "$target" >/dev/null

if grep -qxF "*.snap merge=union" "$ga"; then
  ok "case2: user line intact"
else
  bad "case2: user line intact"
fi
if grep -q 'unionSTATUS\|union#' "$ga"; then
  bad "case2: no glued line"
else
  ok "case2: no glued line"
fi
all_entries_once "$ga" "case2"

# --- Case 3: some entries already present -> only the missing ones
# appended, nothing duplicated ---
target="$WORK/case3"
mkdir -p "$target/.project"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init
ga="$target/.project/.gitattributes"
printf 'STATUS.md merge=ours\naudit.md merge=ours\n' > "$ga"

run_install "$target" >/dev/null
all_entries_once "$ga" "case3"

# --- Case 4: idempotent re-run -> file byte-identical across installs ---
target="$WORK/case4"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

run_install "$target" >/dev/null
ga="$target/.project/.gitattributes"
before_sum="$(cksum "$ga")"

run_install "$target" >/dev/null
after_sum="$(cksum "$ga")"

if [ "$before_sum" = "$after_sum" ]; then
  ok "case4: file unchanged across re-install"
else
  bad "case4: file unchanged across re-install"
fi
all_entries_once "$ga" "case4"

# --- Case 5: driver already configured in the target repo -> no suggestion ---
target="$WORK/case5"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init
git -C "$target" config merge.ours.driver true

out="$(run_install "$target")"
case "$out" in
  *"git config merge.ours.driver true"*)
    bad "case5: silent when driver already configured" ;;
  *)
    ok "case5: silent when driver already configured" ;;
esac

# --- Case 6: non-git target -> attributes still written, no driver
# suggestion (there is no repo config to check), no failure ---
target="$WORK/case6"
mkdir -p "$target"

out="$(run_install "$target")"
ga="$target/.project/.gitattributes"
all_entries_once "$ga" "case6"
case "$out" in
  *"git config merge.ours.driver true"*)
    bad "case6: no driver suggestion outside a git repo" ;;
  *)
    ok "case6: no driver suggestion outside a git repo" ;;
esac

exit "$fail"
