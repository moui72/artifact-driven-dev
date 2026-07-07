#!/usr/bin/env sh
# Regression test for ardd-update-check.sh: compares a target's installed
# ARDD commit (from .project/ardd-version.md) against the recorded source
# checkout's tip. Local git only. Four outcomes, one line each.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CHECK="$SCRIPT_DIR/ardd-update-check.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# Fake source checkout: a git repo that looks like ARDD (install.sh + skills/)
SRC="$WORK/ardd-src"
mkdir -p "$SRC/skills"
printf '#!/usr/bin/env sh\n' > "$SRC/install.sh"
( cd "$SRC" && git init -q -b main && git add -A && git commit -q -m one )
TIP1="$(git -C "$SRC" rev-parse --short HEAD)"

mkver() { # mkver <target> <commit> <source-path>
  mkdir -p "$1/.project"
  printf '# ARDD Version\n\n_Source: artifact-driven-dev @ %s · Installed/updated 2026-07-07_\n\nSource-Path: %s\n' "$2" "$3" > "$1/.project/ardd-version.md"
}

# --- up-to-date ---
T1="$WORK/t1"; mkver "$T1" "$TIP1" "$SRC"
out="$(sh "$CHECK" "$T1")"
[ "$out" = "up-to-date commit=$TIP1" ] && ok "up-to-date" || bad "up-to-date — got '$out'"

# --- behind (source advances) ---
( cd "$SRC" && printf 'x\n' >> install.sh && git add -A && git commit -q -m two )
TIP2="$(git -C "$SRC" rev-parse --short HEAD)"
out="$(sh "$CHECK" "$T1")"
[ "$out" = "behind installed=$TIP1 source-tip=$TIP2" ] && ok "behind" || bad "behind — got '$out'"

# --- source-missing: recorded path gone ---
T2="$WORK/t2"; mkver "$T2" "$TIP1" "$WORK/nowhere"
out="$(sh "$CHECK" "$T2")"
[ "$out" = "source-missing path=$WORK/nowhere" ] && ok "source-missing (gone)" || bad "source-missing (gone) — got '$out'"

# --- source-missing: path exists but is not an ARDD checkout ---
NOTSRC="$WORK/not-ardd"; mkdir -p "$NOTSRC"
T3="$WORK/t3"; mkver "$T3" "$TIP1" "$NOTSRC"
out="$(sh "$CHECK" "$T3")"
[ "$out" = "source-missing path=$NOTSRC" ] && ok "source-missing (moved/not-ardd)" || bad "source-missing (moved) — got '$out'"

# --- no version file ---
T4="$WORK/t4"; mkdir -p "$T4/.project"
out="$(sh "$CHECK" "$T4")"; rc=$?
[ "$out" = "no-version-file" ] && [ "$rc" -eq 0 ] && ok "no-version-file, exit 0" || bad "no-version-file — got '$out' rc=$rc"

# --- version file predates Source-Path (pre-T001 install) -> no-source-path ---
T5="$WORK/t5"; mkdir -p "$T5/.project"
printf '# ARDD Version\n\n_Source: artifact-driven-dev @ %s · Installed/updated 2026-07-06_\n' "$TIP1" > "$T5/.project/ardd-version.md"
out="$(sh "$CHECK" "$T5")"
[ "$out" = "no-source-path" ] && ok "pre-T001 file -> no-source-path" || bad "no-source-path — got '$out'"

exit "$fail"
