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

# Hermetic: the script under test falls back to ${ARDD_HOME:-$HOME/.ardd}/source
# when the recorded Source-Path is invalid — pin ARDD_HOME to a nonexistent
# dir so the machine's real ~/.ardd never leaks into these cases.
export ARDD_HOME="$WORK/no-ardd-home"

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

# --- up-to-date (source has no releases yet -> tip comparison, noted) ---
T1="$WORK/t1"; mkver "$T1" "$TIP1" "$SRC"
out="$(sh "$CHECK" "$T1")"
[ "$out" = "up-to-date commit=$TIP1 note=no-releases" ] && ok "up-to-date (no releases)" || bad "up-to-date (no releases) — got '$out'"

# --- behind (source advances, still no releases -> tip comparison, noted) ---
( cd "$SRC" && printf 'x\n' >> install.sh && git add -A && git commit -q -m two )
TIP2="$(git -C "$SRC" rev-parse --short HEAD)"
out="$(sh "$CHECK" "$T1")"
[ "$out" = "behind installed=$TIP1 source-tip=$TIP2 note=no-releases" ] && ok "behind (no releases)" || bad "behind (no releases) — got '$out'"

# --- behind-release: a release exists and the install predates it ---
# behind now means "not the latest release's commit", not "not the tip".
git -C "$SRC" tag v1.0.0
out="$(sh "$CHECK" "$T1")"
[ "$out" = "behind installed=$TIP1 latest-release=v1.0.0" ] && ok "behind-release" || bad "behind-release — got '$out'"

# --- at-release: installed at the latest release's commit ---
T1R="$WORK/t1r"; mkver "$T1R" "$TIP2" "$SRC"
out="$(sh "$CHECK" "$T1R")"
[ "$out" = "up-to-date commit=$TIP2" ] && ok "at-release" || bad "at-release — got '$out'"

# --- at-release even when the source tip has moved past the release ---
( cd "$SRC" && printf 'y\n' >> install.sh && git add -A && git commit -q -m three )
out="$(sh "$CHECK" "$T1R")"
[ "$out" = "up-to-date commit=$TIP2" ] && ok "at-release, tip ahead of release" || bad "at-release, tip ahead — got '$out'"

# --- latest release ordering: v1.10.0 > v1.9.0, decoys ignored ---
git -C "$SRC" tag v1.9.0
TIP3="$(git -C "$SRC" rev-parse --short HEAD)"
( cd "$SRC" && printf 'z\n' >> install.sh && git add -A && git commit -q -m four )
git -C "$SRC" tag v1.10.0
git -C "$SRC" tag v1.10.1-rc1
TIP4="$(git -C "$SRC" rev-parse --short HEAD)"
T1S="$WORK/t1s"; mkver "$T1S" "$TIP3" "$SRC"
out="$(sh "$CHECK" "$T1S")"
[ "$out" = "behind installed=$TIP3 latest-release=v1.10.0" ] && ok "release ordering (v1.10.0 > v1.9.0, rc ignored)" || bad "release ordering — got '$out'"
T1T="$WORK/t1t"; mkver "$T1T" "$TIP4" "$SRC"
out="$(sh "$CHECK" "$T1T")"
[ "$out" = "up-to-date commit=$TIP4" ] && ok "at latest release v1.10.0" || bad "at latest release — got '$out'"

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

# --- self-hosted: recorded Source-Path IS the target repo -> distinct outcome ---
SH="$WORK/selfhosted"
mkdir -p "$SH/skills"
printf '#!/usr/bin/env sh\n' > "$SH/install.sh"
( cd "$SH" && git init -q -b main && git add -A && git commit -q -m one )
SHTIP="$(git -C "$SH" rev-parse --short HEAD)"
mkver "$SH" "$SHTIP" "$SH"
# advance the tip past the recorded commit (the version-bump chase)
( cd "$SH" && printf 'y\n' >> install.sh && git add -A && git commit -q -m two )
out="$(sh "$CHECK" "$SH")"
[ "$out" = "self-hosted commit=$SHTIP" ] && ok "self-hosted -> distinct outcome, not behind" || bad "self-hosted — got '$out'"

# --- self-hosted via symlink: string compare would miss this ---
ln -s "$SH" "$WORK/selfhosted-link"
mkver "$SH" "$SHTIP" "$WORK/selfhosted-link"
out="$(sh "$CHECK" "$SH")"
[ "$out" = "self-hosted commit=$SHTIP" ] && ok "self-hosted via symlink (toplevel compare)" || bad "self-hosted symlink — got '$out'"

# --- Source-Commit (new format): preferred over the prose line, compared by
# --- prefix so short-vs-full and future width changes never break it. The
# --- prose line carries a deliberate decoy commit to prove preference.
mkver2() { # mkver2 <target> <commit> <source-path>
  mkdir -p "$1/.project"
  printf '# ARDD Version\n\n_Source: artifact-driven-dev @ 0000000 · Installed/updated 2026-07-12_\n\nSource-Path: %s\nSource-Commit: %s\n' "$3" "$2" > "$1/.project/ardd-version.md"
}
FULL4="$(git -C "$SRC" rev-parse HEAD)"          # commit of v1.10.0
FULL3="$(git -C "$SRC" rev-parse "$TIP3")"       # commit of v1.9.0

T6="$WORK/t6"; mkver2 "$T6" "$FULL4" "$SRC"
out="$(sh "$CHECK" "$T6")"
[ "$out" = "up-to-date commit=$FULL4" ] && ok "Source-Commit preferred, full-vs-short prefix match" || bad "Source-Commit full sha — got '$out'"

T7="$WORK/t7"; mkver2 "$T7" "$FULL3" "$SRC"
out="$(sh "$CHECK" "$T7")"
[ "$out" = "behind installed=$FULL3 latest-release=v1.10.0" ] && ok "Source-Commit behind release" || bad "Source-Commit behind — got '$out'"

# width variance: a 12-char recorded commit still prefix-matches
INST12="$(printf '%s' "$FULL4" | cut -c1-12)"
T8="$WORK/t8"; mkver2 "$T8" "$INST12" "$SRC"
out="$(sh "$CHECK" "$T8")"
[ "$out" = "up-to-date commit=$INST12" ] && ok "prefix match across widths (12-char)" || bad "prefix width — got '$out'"

# --- moved Source-Path: fall back to the owned checkout when it exists ---
FBHOME="$WORK/ardd-home"; mkdir -p "$FBHOME"
git clone -q "$SRC" "$FBHOME/source"
mkdir -p "$FBHOME/source/skills"   # SRC's skills/ is empty; clones drop empty dirs
T9="$WORK/t9"; mkver2 "$T9" "$FULL4" "$WORK/nowhere"
out="$(ARDD_HOME="$FBHOME" sh "$CHECK" "$T9")"
[ "$out" = "up-to-date commit=$FULL4 fallback=owned" ] && ok "moved Source-Path -> owned fallback" || bad "owned fallback — got '$out'"

# without an owned checkout the moved path stays source-missing (asserted
# above with the pinned nonexistent ARDD_HOME; re-check with new format)
out="$(sh "$CHECK" "$T9")"
[ "$out" = "source-missing path=$WORK/nowhere" ] && ok "moved Source-Path, no owned -> source-missing" || bad "moved, no owned — got '$out'"

# --- producer contract: install.sh writes Source-Commit as the full sha ---
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TP="$WORK/producer"; mkdir -p "$TP"
( cd "$REPO_ROOT" && sh ./install.sh "$TP" ) >/dev/null 2>&1
want="$(command git -C "$REPO_ROOT" rev-parse HEAD)"
got="$(sed -n 's/^Source-Commit: //p' "$TP/.project/ardd-version.md" | head -1)"
[ "$got" = "$want" ] && ok "install.sh writes Source-Commit (full sha)" || bad "install.sh Source-Commit — got '$got', want '$want'"

exit "$fail"
