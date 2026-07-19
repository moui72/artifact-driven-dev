#!/usr/bin/env sh
# Regression test for install.sh's opt-in ARDD_VERSION_BADGE handling
# (plan: dynamic-version-badge-sync): when set to "1", install.sh writes
# .github/workflows/ardd-badge.yml and .github/badges/ardd-version.json into
# the target (seeded with this run's actual version), and prints the
# two-badge snippet instead of the single static one — never overwriting a
# hand-customized version of either file on re-install. When unset (the
# default), behavior must be byte-for-byte unchanged from before this opt-in
# existed: neither file is written and the single-badge snippet is printed.

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

new_target() { # $1=name -> creates a git-init'd target with a README
  t="$WORK/$1"
  mkdir -p "$t"
  git init -q "$t"
  git -C "$t" commit -q --allow-empty -m init
  printf '# Test project\n' > "$t/README.md"
  echo "$t"
}

run_install() { # $1=target
  ( cd "$REPO_ROOT" && sh "$INSTALL_SH" "$1" )
}

# NOTE: `VAR=1 run_install ...` would look like it scopes VAR to that one
# call, but POSIX sh (dash) persists a variable assignment prefixed onto a
# *shell function* call after the call returns (unlike for an external
# command) — a real trap here. Use this wrapper instead, which always
# unsets the var again explicitly.
run_install_badge_on() { # $1=target
  ARDD_VERSION_BADGE=1
  export ARDD_VERSION_BADGE
  out="$(run_install "$1")"
  unset ARDD_VERSION_BADGE
  printf '%s' "$out"
}

WORKFLOW_REL=".github/workflows/ardd-badge.yml"
JSON_REL=".github/badges/ardd-version.json"

# --- Case 1: ARDD_VERSION_BADGE=1 creates both new files, JSON carries the
# fixture's actual recorded version ---
target="$(new_target case1)"
out="$(run_install_badge_on "$target")"

if [ -f "$target/$WORKFLOW_REL" ]; then
  ok "case1: workflow file created"
else
  bad "case1: workflow file created"
fi

if [ -f "$target/$JSON_REL" ]; then
  ok "case1: seed JSON created"
else
  bad "case1: seed JSON created"
fi

vf="$target/.project/ardd-version.md"
source_ref="$(sed -n 's/^Source-Ref: //p' "$vf" | head -1)"
source_commit="$(sed -n 's/^Source-Commit: //p' "$vf" | head -1)"
if [ -n "$source_ref" ]; then
  expected_message="$source_ref"
else
  expected_message="$(printf '%s' "$source_commit" | cut -c1-7)"
fi

if grep -qF "\"message\": \"$expected_message\"" "$target/$JSON_REL"; then
  ok "case1: seed JSON message matches recorded version ($expected_message)"
else
  bad "case1: seed JSON message matches recorded version ($expected_message)"
  cat "$target/$JSON_REL"
fi

case "$out" in
  *"two-badge"*)
    ok "case1: two-badge snippet printed" ;;
  *)
    bad "case1: two-badge snippet printed" ;;
esac

# --- Case 2: re-install with ARDD_VERSION_BADGE=1 leaves a hand-edited
# workflow/JSON untouched (idempotent, never clobbered) ---
target="$(new_target case2)"
run_install_badge_on "$target" >/dev/null

printf 'hand-edited workflow\n' > "$target/$WORKFLOW_REL"
printf '{"hand": "edited"}\n' > "$target/$JSON_REL"
before_workflow="$(cksum "$target/$WORKFLOW_REL")"
before_json="$(cksum "$target/$JSON_REL")"

run_install_badge_on "$target" >/dev/null

after_workflow="$(cksum "$target/$WORKFLOW_REL")"
after_json="$(cksum "$target/$JSON_REL")"

if [ "$before_workflow" = "$after_workflow" ]; then
  ok "case2: hand-edited workflow left untouched"
else
  bad "case2: hand-edited workflow left untouched"
fi

if [ "$before_json" = "$after_json" ]; then
  ok "case2: hand-edited seed JSON left untouched"
else
  bad "case2: hand-edited seed JSON left untouched"
fi

# --- Case 3: unset ARDD_VERSION_BADGE (default) writes neither file and
# prints the unchanged single-badge snippet ---
target="$(new_target case3)"
out="$(run_install "$target")"

if [ -e "$target/.github" ]; then
  bad "case3: no .github directory created when unset"
else
  ok "case3: no .github directory created when unset"
fi

case "$out" in
  *"two-badge"*)
    bad "case3: default path does not print the two-badge snippet" ;;
  *)
    ok "case3: default path does not print the two-badge snippet" ;;
esac

case "$out" in
  *'add a "built with ArDD" badge to your README'*)
    ok "case3: single-badge snippet still offered" ;;
  *)
    bad "case3: single-badge snippet still offered" ;;
esac

# --- Case 4: unset ARDD_VERSION_BADGE re-install stays silent about
# .github entirely (no regression from before this opt-in existed) ---
target="$(new_target case4)"
run_install "$target" >/dev/null
run_install "$target" >/dev/null
if [ -e "$target/.github" ]; then
  bad "case4: .github still absent after a second unset install"
else
  ok "case4: .github still absent after a second unset install"
fi

# --- Case 5: marker already present (a prior static-badge adopter) +
# ARDD_VERSION_BADGE=1 still writes both supporting files (F002 fix) —
# previously this was a silent no-op ---
target="$(new_target case5)"
printf '# Test project\n\n<!-- ardd-badge-start -->\nold static badge\n<!-- ardd-badge-end -->\n' > "$target/README.md"
run_install_badge_on "$target" >/dev/null

if [ -f "$target/$WORKFLOW_REL" ]; then
  ok "case5: marker-present + ARDD_VERSION_BADGE=1 writes workflow file"
else
  bad "case5: marker-present + ARDD_VERSION_BADGE=1 writes workflow file"
fi

if [ -f "$target/$JSON_REL" ]; then
  ok "case5: marker-present + ARDD_VERSION_BADGE=1 writes seed JSON"
else
  bad "case5: marker-present + ARDD_VERSION_BADGE=1 writes seed JSON"
fi

exit "$fail"
