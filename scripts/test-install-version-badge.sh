#!/usr/bin/env sh
# Regression test for install.sh's opt-in ARDD_VERSION_BADGE handling
# (plan: dynamic-version-badge-sync): when set to "1", install.sh writes
# .github/workflows/ardd-badge.yml and .github/badges/ardd-version.json into
# the target (seeded with this run's actual version), and prints the
# split-badge snippet instead of the single static one — never overwriting a
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
  *"split"*)
    ok "case1: split-badge snippet printed" ;;
  *)
    bad "case1: split-badge snippet printed" ;;
esac

case "$out" in
  *"img.shields.io/endpoint"*)
    ok "case1: snippet carries the endpoint badge URL" ;;
  *)
    bad "case1: snippet carries the endpoint badge URL" ;;
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
  *"img.shields.io/endpoint"*)
    bad "case3: default path does not print the split-badge snippet" ;;
  *)
    ok "case3: default path does not print the split-badge snippet" ;;
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

# --- Case 6: GitHub https origin remote → printed snippet carries the
# target's own coordinates (owner/repo + current branch), no placeholders ---
target="$(new_target case6)"
git -C "$target" remote add origin https://github.com/acme/widget.git
branch="$(git -C "$target" symbolic-ref --short HEAD)"
out="$(run_install_badge_on "$target")"

case "$out" in
  *"acme/widget/$branch"*)
    ok "case6: snippet filled with acme/widget/$branch" ;;
  *)
    bad "case6: snippet filled with acme/widget/$branch" ;;
esac

case "$out" in
  *"OWNER/REPO/BRANCH"*)
    bad "case6: no literal OWNER/REPO/BRANCH placeholder remains" ;;
  *)
    ok "case6: no literal OWNER/REPO/BRANCH placeholder remains" ;;
esac

# --- Case 7: SSH-form remote git@github.com:acme/widget.git parses to
# acme/widget too ---
target="$(new_target case7)"
git -C "$target" remote add origin git@github.com:acme/widget.git
branch="$(git -C "$target" symbolic-ref --short HEAD)"
out="$(run_install_badge_on "$target")"

case "$out" in
  *"acme/widget/$branch"*)
    ok "case7: SSH remote parsed to acme/widget/$branch" ;;
  *)
    bad "case7: SSH remote parsed to acme/widget/$branch" ;;
esac

# --- Case 8: no remote → placeholders stay AND the replace-these
# instruction is printed (not buried in an unprinted template comment) ---
target="$(new_target case8)"
out="$(run_install_badge_on "$target")"

case "$out" in
  *"OWNER/REPO/BRANCH"*)
    ok "case8: placeholders remain with no remote" ;;
  *)
    bad "case8: placeholders remain with no remote" ;;
esac

case "$out" in
  *"replace OWNER/REPO/BRANCH with your repo's coordinates"*)
    ok "case8: replace-these instruction printed" ;;
  *)
    bad "case8: replace-these instruction printed" ;;
esac

# --- Case 9: README already contains ardd-badge-version-start → snippet
# not reprinted; supporting files still written ---
target="$(new_target case9)"
printf '# Test project\n\n<!-- ardd-badge-version-start -->\nadopted\n<!-- ardd-badge-version-end -->\n' > "$target/README.md"
out="$(run_install_badge_on "$target")"

case "$out" in
  *"img.shields.io/endpoint"*)
    bad "case9: split-badge snippet not reprinted when marker present" ;;
  *)
    ok "case9: split-badge snippet not reprinted when marker present" ;;
esac

if [ -f "$target/$WORKFLOW_REL" ] && [ -f "$target/$JSON_REL" ]; then
  ok "case9: supporting files still written when marker present"
else
  bad "case9: supporting files still written when marker present"
fi

# --- Case 10: README with a latest-release ArDD badge → advisory printed
# in BOTH the default (unset) path and the ARDD_VERSION_BADGE=1 path ---
release_badge_readme() { # $1=target
  printf '# Test project\n\n[![v](https://img.shields.io/github/v/release/moui72/artifact-driven-dev)](x)\n' > "$1/README.md"
}

target="$(new_target case10a)"
release_badge_readme "$target"
out="$(run_install "$target")"
case "$out" in
  *"latest release"*)
    ok "case10: advisory fires in default (unset) path" ;;
  *)
    bad "case10: advisory fires in default (unset) path" ;;
esac

target="$(new_target case10b)"
release_badge_readme "$target"
out="$(run_install_badge_on "$target")"
case "$out" in
  *"latest release"*)
    ok "case10: advisory fires in ARDD_VERSION_BADGE=1 path" ;;
  *)
    bad "case10: advisory fires in ARDD_VERSION_BADGE=1 path" ;;
esac

# --- Case 11: snippet output includes the private-repo caveat line ---
target="$(new_target case11)"
out="$(run_install_badge_on "$target")"
case "$out" in
  *"public repos"*)
    ok "case11: private-repo caveat printed with snippet" ;;
  *)
    bad "case11: private-repo caveat printed with snippet" ;;
esac

# --- Case 12: default (unset) path's static-badge suggestion mentions the
# ARDD_VERSION_BADGE=1 dynamic upgrade ---
target="$(new_target case12)"
out="$(run_install "$target")"
case "$out" in
  *"ARDD_VERSION_BADGE=1"*)
    ok "case12: default path mentions ARDD_VERSION_BADGE=1 upgrade" ;;
  *)
    bad "case12: default path mentions ARDD_VERSION_BADGE=1 upgrade" ;;
esac

# --- Case 13: target with NO README, env unset → output carries a one-line
# ARDD_VERSION_BADGE=1 opt-in pointer (a pointer, not a snippet) ---
target="$WORK/case13"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init
out="$(run_install "$target")"

case "$out" in
  *"ARDD_VERSION_BADGE=1"*)
    ok "case13: no-README default path prints the opt-in pointer" ;;
  *)
    bad "case13: no-README default path prints the opt-in pointer" ;;
esac

case "$out" in
  *"img.shields.io/endpoint"*|*"ardd-badge-version-start"*)
    bad "case13: no-README path does not print any badge snippet" ;;
  *)
    ok "case13: no-README path does not print any badge snippet" ;;
esac

# --- Case 14: misdirected latest-release badge sitting INSIDE the
# ardd-badge-version markers + ARDD_VERSION_BADGE=1 → the advisory's remedy
# must be self-sufficient (replace the badge inside the markers), not a
# bare re-run the reprint guard would silence ---
target="$(new_target case14)"
printf '# Test project\n\n<!-- ardd-badge-version-start -->\n[![v](https://img.shields.io/github/v/release/moui72/artifact-driven-dev)](x)\n<!-- ardd-badge-version-end -->\n' > "$target/README.md"
out="$(run_install_badge_on "$target")"

case "$out" in
  *"replace the badge inside the markers"*)
    ok "case14: advisory names the replace-inside-markers remedy" ;;
  *)
    bad "case14: advisory names the replace-inside-markers remedy" ;;
esac

case "$out" in
  *"run install.sh with ARDD_VERSION_BADGE=1 to print it"*)
    bad "case14: advisory does not offer a bare re-run as the sole remedy" ;;
  *)
    ok "case14: advisory does not offer a bare re-run as the sole remedy" ;;
esac

# --- Case 15: opted-in install ships the badge icon at the path the sync
# workflow reads (.github/badges/ardd-icon.svg) ---
ICON_REL=".github/badges/ardd-icon.svg"
target="$(new_target case15)"
run_install_badge_on "$target" >/dev/null

if [ -f "$target/$ICON_REL" ]; then
  ok "case15: badge icon shipped to $ICON_REL"
else
  bad "case15: badge icon shipped to $ICON_REL"
fi

if grep -q "ardd-icon.svg" "$REPO_ROOT/templates/ardd-badge-workflow.yml" \
   && grep -q ".github/badges/ardd-icon.svg" "$REPO_ROOT/templates/ardd-badge-workflow.yml"; then
  ok "case15: workflow template reads the same icon path"
else
  bad "case15: workflow template reads the same icon path"
fi

# --- Case 16: seed JSON carries the brand labelColor and an inline logoSvg ---
target="$(new_target case16)"
run_install_badge_on "$target" >/dev/null

if grep -qF '"labelColor": "#7C3AED"' "$target/$JSON_REL"; then
  ok "case16: seed JSON carries labelColor #7C3AED"
else
  bad "case16: seed JSON carries labelColor #7C3AED"
  cat "$target/$JSON_REL"
fi

if grep -qF '"logoSvg": "<svg' "$target/$JSON_REL"; then
  ok "case16: seed JSON carries an inline logoSvg"
else
  bad "case16: seed JSON carries an inline logoSvg"
  cat "$target/$JSON_REL"
fi

if grep -qF '__ARDD_BADGE_LOGO__' "$target/$JSON_REL"; then
  bad "case16: no logo placeholder left in seed JSON"
else
  ok "case16: no logo placeholder left in seed JSON"
fi

# Seed must stay parseable JSON after the logoSvg embed (quote/newline
# escaping is exactly what the awk escaper exists for). Skipped without
# python3 — the grep assertions above still ran.
if command -v python3 >/dev/null 2>&1; then
  if python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$target/$JSON_REL" 2>/dev/null; then
    ok "case16: seed JSON parses as JSON with logoSvg embedded"
  else
    bad "case16: seed JSON parses as JSON with logoSvg embedded"
  fi
fi

# --- Case 17: re-install never clobbers a hand-edited icon ---
target="$(new_target case17)"
run_install_badge_on "$target" >/dev/null
printf 'hand-edited icon\n' > "$target/$ICON_REL"
before_icon="$(cksum "$target/$ICON_REL")"
run_install_badge_on "$target" >/dev/null
after_icon="$(cksum "$target/$ICON_REL")"
if [ "$before_icon" = "$after_icon" ]; then
  ok "case17: hand-edited icon left untouched"
else
  bad "case17: hand-edited icon left untouched"
fi

# --- Case 18: env unset, README already carries ardd-badge-version markers
# (S9 F001, feedback b8b6) → the static-badge suggestion must NOT print;
# instead a one-line acknowledgment naming the found form ---
target="$(new_target case18)"
printf '# Test project\n\n<!-- ardd-badge-version-start -->\nadopted\n<!-- ardd-badge-version-end -->\n' > "$target/README.md"
out="$(run_install "$target")"

case "$out" in
  *'add a "built with ArDD" badge to your README'*)
    bad "case18: static suggestion suppressed when version markers present" ;;
  *)
    ok "case18: static suggestion suppressed when version markers present" ;;
esac

case "$out" in
  *"already badged via version markers"*)
    ok "case18: acknowledgment names the found form (version)" ;;
  *)
    bad "case18: acknowledgment names the found form (version)" ;;
esac

# --- Case 19: ARDD_VERSION_BADGE=1, README carries ardd-badge-pair markers
# (S9 F002) → no full paste-snippet block; a short "already badged via pair
# markers" note pointing at templates/badge.md; supporting files still
# written as usual ---
target="$(new_target case19)"
printf '# Test project\n\n<!-- ardd-badge-pair-start -->\nadopted pair\n<!-- ardd-badge-pair-end -->\n' > "$target/README.md"
out="$(run_install_badge_on "$target")"

case "$out" in
  *"img.shields.io/endpoint"*)
    bad "case19: full paste-snippet block not printed when pair markers present" ;;
  *)
    ok "case19: full paste-snippet block not printed when pair markers present" ;;
esac

case "$out" in
  *"already badged via pair markers"*)
    ok "case19: note names the found form (pair)" ;;
  *)
    bad "case19: note names the found form (pair)" ;;
esac

case "$out" in
  *"templates/badge.md"*)
    ok "case19: note points at templates/badge.md" ;;
  *)
    bad "case19: note points at templates/badge.md" ;;
esac

if [ -f "$target/$WORKFLOW_REL" ] && [ -f "$target/$JSON_REL" ]; then
  ok "case19: supporting files still written when pair markers present"
else
  bad "case19: supporting files still written when pair markers present"
fi

# --- Case 20: ARDD_VERSION_BADGE=1 into a README-less repo (S9 F003) →
# pointer must acknowledge the flag is already set ("create a README and
# re-run"), not tell the user to re-run with a flag they already set ---
target="$WORK/case20"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init
out="$(run_install_badge_on "$target")"

case "$out" in
  *"ARDD_VERSION_BADGE=1 is set"*)
    ok "case20: no-README pointer acknowledges the flag is set" ;;
  *)
    bad "case20: no-README pointer acknowledges the flag is set" ;;
esac

case "$out" in
  *"re-run install with ARDD_VERSION_BADGE=1"*)
    bad "case20: no-README pointer does not re-suggest setting the flag" ;;
  *)
    ok "case20: no-README pointer does not re-suggest setting the flag" ;;
esac

# --- Case 21: fixture repo whose default branch is `master` (plan
# badge-workflow-branch, S9 finding 7b1a / feedback 8110 F001) → the
# WRITTEN workflow's on.push.branches: filter must carry the real branch
# (`master`), not the template's hardcoded `main` — otherwise the badge
# sync never fires on non-main-default repos. Alongside (already-passing
# context assertion): the printed snippet's endpoint URL carries master. ---
target="$WORK/case21"
mkdir -p "$target"
git init -q -b master "$target"
git -C "$target" commit -q --allow-empty -m init
printf '# Test project\n' > "$target/README.md"
git -C "$target" remote add origin https://github.com/example-owner/example-repo.git
out="$(run_install_badge_on "$target")"

if grep -qE '^[[:space:]]*branches:[[:space:]]*\[master\]' "$target/$WORKFLOW_REL"; then
  ok "case21: written workflow branches filter carries master"
else
  bad "case21: written workflow branches filter carries master"
  grep -n "branches" "$target/$WORKFLOW_REL" || true
fi

case "$out" in
  *"example-owner/example-repo/master"*)
    ok "case21: snippet endpoint URL carries example-owner/example-repo/master" ;;
  *)
    bad "case21: snippet endpoint URL carries example-owner/example-repo/master" ;;
esac

# --- Case 22: scp-style ssh-config ALIAS remote (feedback ea66 F001) —
# `github-ardd:example-owner/example-repo.git` has no `://` and a host
# token that isn't `git@github.com`, but the path part alone yields the
# coordinates. The printed snippet's endpoint URL and the written workflow
# must carry example-owner/example-repo and the real branch, with zero
# placeholder residue. ---
target="$(new_target case22)"
git -C "$target" remote add origin github-ardd:example-owner/example-repo.git
branch="$(git -C "$target" symbolic-ref --short HEAD)"
out="$(run_install_badge_on "$target")"

case "$out" in
  *"example-owner/example-repo/$branch"*)
    ok "case22: alias remote parsed to example-owner/example-repo/$branch" ;;
  *)
    bad "case22: alias remote parsed to example-owner/example-repo/$branch" ;;
esac

case "$out" in
  *"OWNER/REPO/BRANCH"*)
    bad "case22: no literal OWNER/REPO/BRANCH placeholder remains" ;;
  *)
    ok "case22: no literal OWNER/REPO/BRANCH placeholder remains" ;;
esac

if grep -qE "^[[:space:]]*branches:[[:space:]]*\[$branch\]" "$target/$WORKFLOW_REL"; then
  ok "case22: written workflow branches filter carries $branch"
else
  bad "case22: written workflow branches filter carries $branch"
  grep -n "branches" "$target/$WORKFLOW_REL" || true
fi

exit "$fail"
