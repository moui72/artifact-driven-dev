#!/usr/bin/env sh
# Regression test for next-version.sh — the single version-compute
# authority for the two release channels (constitution v1.8.0):
#
#   next-version.sh beta                     -> next vX.Y.Z-beta.N
#   next-version.sh stable [major|minor|patch] -> next vX.Y.Z (default patch)
#
# All ordering runs under `-c versionsort.suffix=-beta.` — and this test
# pins the empirical trap that makes the suffix load-bearing: under git's
# DEFAULT version sort, `v0.9.1-beta.2` orders AFTER `v0.9.1`, so a naive
# "latest tag" would prefer a stale beta over a newer stable. With the
# suffix configured, the beta correctly sorts BEFORE its stable. Both
# orderings are asserted directly (the trap case), alongside the mixed-tag
# scenarios the tasks file requires: no tags; only stable; only betas;
# beta-after-stable rollover; non-semver decoys ignored; numeric (not
# lexical) beta-N and version-component ordering.
#
# Hermetic: fixture repos under a temp dir; no network.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NEXTVER="$SCRIPT_DIR/next-version.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# run_nv <fixture-dir> [args...] — captures $out/$status
run_nv() {
  dir="$1"; shift
  set +e
  out="$( (cd "$dir" && sh "$NEXTVER" "$@") 2>&1 )"
  status=$?
  set -e
}

expect() { # expect <fixture> <want> <label> [args...]
  fix="$1"; want="$2"; label="$3"; shift 3
  run_nv "$fix" "$@"
  if [ "$status" -eq 0 ] && [ "$out" = "$want" ]; then
    ok "$label"
  else
    bad "$label — want '$want', got '$out' (rc=$status)"
  fi
}

mkrepo() { # mkrepo <dir> [tags...]
  mkdir -p "$1"
  ( cd "$1" && git init -q -b main \
    && printf 'x\n' > f && git add -A && git commit -q -m one )
  d="$1"; shift
  for t in "$@"; do git -C "$d" tag "$t"; done
}

# --- Scenario 1: no tags at all -----------------------------------------
R1="$WORK/r1"; mkrepo "$R1"
expect "$R1" "v0.0.1-beta.1" "s1: no tags -> beta targets v0.0.1" beta
expect "$R1" "v0.0.1"        "s1: no tags -> stable patch v0.0.1" stable
expect "$R1" "v0.0.1"        "s1: patch is the default bump" stable patch
expect "$R1" "v0.1.0"        "s1: no tags -> stable minor v0.1.0" stable minor
expect "$R1" "v1.0.0"        "s1: no tags -> stable major v1.0.0" stable major

# --- Scenario 2: only a stable tag ---------------------------------------
R2="$WORK/r2"; mkrepo "$R2" v0.9.0
expect "$R2" "v0.9.1-beta.1" "s2: only stable -> first beta of next patch" beta
expect "$R2" "v0.9.1"        "s2: stable patch" stable
expect "$R2" "v0.10.0"       "s2: stable minor (numeric: 10 follows 9)" stable minor
expect "$R2" "v1.0.0"        "s2: stable major" stable major

# --- Scenario 3: only betas (no stable yet) -------------------------------
R3="$WORK/r3"; mkrepo "$R3" v0.0.1-beta.1 v0.0.1-beta.2
expect "$R3" "v0.0.1-beta.3" "s3: only betas -> N increments" beta
expect "$R3" "v0.0.1"        "s3: only betas -> stable claims the previewed version" stable

# --- Scenario 4: stable + newer betas ------------------------------------
R4="$WORK/r4"; mkrepo "$R4" v0.9.0 v0.9.1-beta.1 v0.9.1-beta.2
expect "$R4" "v0.9.1-beta.3" "s4: betas continue for the upcoming patch" beta
expect "$R4" "v0.9.1"        "s4: stable patch is the previewed version" stable

# --- Scenario 5: THE ORDERING TRAP — beta-after-stable rollover ----------
# v0.9.1 now exists alongside its old betas. Under default version sort the
# stale v0.9.1-beta.2 orders AFTER v0.9.1 (pinned below), so a naive
# latest-tag pick would say the beta is newest; with versionsort.suffix
# the stable wins and betas roll over to target v0.9.2.
R5="$WORK/r5"; mkrepo "$R5" v0.9.0 v0.9.1-beta.1 v0.9.1-beta.2 v0.9.1
expect "$R5" "v0.9.2-beta.1" "s5: after stable v0.9.1, betas target v0.9.2" beta
expect "$R5" "v0.9.2"        "s5: stable patch moves past v0.9.1" stable

# Pin the trap empirically, in both directions:
default_last="$(git -C "$R5" tag --list 'v0.9.1*' --sort=v:refname | tail -1)"
[ "$default_last" = "v0.9.1-beta.2" ] \
  && ok "s5: trap pinned — DEFAULT sort puts v0.9.1-beta.2 after v0.9.1" \
  || bad "s5: default-sort trap changed? last='$default_last' (expected v0.9.1-beta.2)"
suffix_last="$(git -C "$R5" -c versionsort.suffix=-beta. tag --list 'v0.9.1*' --sort=v:refname | tail -1)"
[ "$suffix_last" = "v0.9.1" ] \
  && ok "s5: trap fixed — suffix sort puts v0.9.1 after its betas" \
  || bad "s5: suffix sort broken — last='$suffix_last' (expected v0.9.1)"

# --- Scenario 6: beta-N is numeric, not lexical ---------------------------
R6="$WORK/r6"; mkrepo "$R6" v1.2.0 \
  v1.2.1-beta.1 v1.2.1-beta.2 v1.2.1-beta.9 v1.2.1-beta.10
expect "$R6" "v1.2.1-beta.11" "s6: beta.10 > beta.9 numerically -> next is beta.11" beta

# --- Scenario 7: non-semver and decoy tags are ignored --------------------
R7="$WORK/r7"; mkrepo "$R7" v1.9.0 v1.10.0 v1.10.1-rc1 v2 banana v1.10.1-beta
expect "$R7" "v1.10.1-beta.1" "s7: decoys ignored; v1.10.0 > v1.9.0 numerically" beta
expect "$R7" "v1.10.1"        "s7: stable from v1.10.0, rc/bare decoys ignored" stable

# --- Usage / refusal cases -------------------------------------------------
run_nv "$R1"
[ "$status" -eq 2 ] && ok "usage: no mode exits 2" || bad "usage: no mode — rc=$status, out='$out'"
run_nv "$R1" flavor
[ "$status" -eq 2 ] && ok "usage: unknown mode exits 2" || bad "usage: unknown mode — rc=$status"
run_nv "$R1" stable gigantic
[ "$status" -eq 2 ] && ok "usage: unknown bump exits 2" || bad "usage: unknown bump — rc=$status"
run_nv "$R1" beta extra-arg
[ "$status" -eq 2 ] && ok "usage: beta takes no extra argument" || bad "usage: beta extra arg — rc=$status"
NOTREPO="$WORK/notrepo"; mkdir -p "$NOTREPO"
run_nv "$NOTREPO" beta
[ "$status" -eq 1 ] && ok "refusal: not a git repo exits 1" || bad "refusal: not a repo — rc=$status, out='$out'"

if [ "$fail" -eq 0 ]; then
  echo "test-next-version: all cases pass"
else
  echo "test-next-version: FAILURES above" >&2
  exit 1
fi
