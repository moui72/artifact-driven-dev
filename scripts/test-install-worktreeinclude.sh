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

# --- Case 1a1: gitignore suggestion — target has no .gitignore covering
# .claude/skills/ardd-*/, so install.sh must print the bounded, visually
# distinct ACTION NEEDED block (not just one line lost in general output) ---
gi_out="$(cd "$REPO_ROOT" && sh "$INSTALL_SH" "$target")"
case "$gi_out" in
  *"ACTION NEEDED: .claude/skills/ardd-*/ isn't gitignored"*)
    ok "gitignore: ACTION NEEDED marker printed when uncovered" ;;
  *)
    bad "gitignore: ACTION NEEDED marker printed when uncovered" ;;
esac

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
  *"built with-ArDD-blue"*|*"suggestion"*|*ardd-badge-start*)
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

# --- Case 1a4: Source-Ref recorded when the source HEAD is exactly at a
# semver tag, omitted otherwise (release-channel standing decision).
# Hermetic: a minimal fixture *source* checkout in temp, so tagging never
# touches the real repo.
FIXSRC="$WORK/fixture-source"
mkdir -p "$FIXSRC"
cp -R "$REPO_ROOT/skills" "$REPO_ROOT/templates" "$REPO_ROOT/scripts" "$REPO_ROOT/migrations" "$FIXSRC/"
cp "$REPO_ROOT/install.sh" "$FIXSRC/"
( cd "$FIXSRC" && git init -q -b main && git add -A && git commit -q -m fixture )
git -C "$FIXSRC" tag v9.9.9

t_at="$WORK/case1a4-at-tag"; mkdir -p "$t_at"; git init -q "$t_at"
( cd "$FIXSRC" && sh "$FIXSRC/install.sh" "$t_at" ) >/dev/null
ref_val="$(sed -n 's/^Source-Ref: //p' "$t_at/.project/ardd-version.md" | head -1)"
if [ "$ref_val" = "v9.9.9" ]; then
  ok "version file: Source-Ref recorded when source HEAD is at a tag"
else
  bad "version file: Source-Ref at tag (got '$ref_val')"
fi

# Move the fixture source past the tag: the line must be omitted, and a
# re-install over the at-tag record must drop it (the file is rewritten).
( cd "$FIXSRC" && printf 'drift\n' >> README.md 2>/dev/null || printf 'drift\n' > drift.txt; git add -A && git commit -q -m drift )
t_off="$WORK/case1a4-off-tag"; mkdir -p "$t_off"; git init -q "$t_off"
( cd "$FIXSRC" && sh "$FIXSRC/install.sh" "$t_off" ) >/dev/null
if grep -q '^Source-Ref: ' "$t_off/.project/ardd-version.md"; then
  bad "version file: Source-Ref wrongly recorded off-tag"
else
  ok "version file: Source-Ref omitted when source HEAD is not at a tag"
fi
( cd "$FIXSRC" && sh "$FIXSRC/install.sh" "$t_at" ) >/dev/null
if grep -q '^Source-Ref: ' "$t_at/.project/ardd-version.md"; then
  bad "version file: stale Source-Ref survives an off-tag re-install"
else
  ok "version file: off-tag re-install drops the stale Source-Ref"
fi

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
wr="$target/.claude/skills/ardd-scripts/worktree-reap.sh"
if [ -x "$wr" ]; then
  ok "case1b4: worktree-reap.sh installed and executable"
else
  bad "case1b4: worktree-reap.sh installed and executable"
fi
fl="$target/.claude/skills/ardd-scripts/feature-list.sh"
if [ -x "$fl" ]; then
  ok "case1b5: feature-list.sh installed and executable"
else
  bad "case1b5: feature-list.sh installed and executable"
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
