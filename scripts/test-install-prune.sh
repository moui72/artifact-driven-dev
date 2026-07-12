#!/usr/bin/env sh
# Regression test for install.sh's ardd-skill pruning step (Principle VII —
# no dead architecture in a target install). On re-run, install.sh must
# remove any .claude/skills/ardd-*/ directory in the target that no longer
# has a counterpart under the source `skills/` — so an upgrade past a skill
# merge (e.g. bootstrap+codify merged into /ardd-init) doesn't leave the
# removed command installed. It must NOT touch:
#   - the non-skill reference dirs (ardd-scripts, ardd-artifact-templates,
#     ardd-constitution-data), which have no source skills/ counterpart but
#     are install.sh's own output;
#   - a hand-written non-ardd skill (my-custom/), which ARDD doesn't own;
#   - real ardd-* skills that DO exist in source.
# The prune must be idempotent.

set -e

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX GIT_OBJECT_DIRECTORY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SH="$REPO_ROOT/install.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Throwaway fixture repos — no signing, no inherited hooks.
git() { command git -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"; }

fail=0
ok() { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

run_install() {
  ( cd "$REPO_ROOT" && sh "$INSTALL_SH" "$1" ) >/dev/null
}

# --- Fixture: fresh install, then plant stale + custom dirs, then re-run ---
target="$WORK/t"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

run_install "$target"   # first install populates .claude/skills/ardd-*

skills_dir="$target/.claude/skills"

# A stale ardd skill that no longer exists in source (simulates a removed/
# merged command left behind by an older install).
mkdir -p "$skills_dir/ardd-ghost"
printf -- '---\nname: ardd-ghost\n---\n' > "$skills_dir/ardd-ghost/SKILL.md"

# A v1.0.0-renamed skill dir (old name) and a folded skill dir — pruned
# like any stale dir, but the output must say what replaced each.
mkdir -p "$skills_dir/ardd-analyze"
printf -- '---\nname: ardd-analyze\n---\n' > "$skills_dir/ardd-analyze/SKILL.md"
mkdir -p "$skills_dir/ardd-converge"
printf -- '---\nname: ardd-converge\n---\n' > "$skills_dir/ardd-converge/SKILL.md"

# A hand-written, non-ardd skill ARDD must never touch.
mkdir -p "$skills_dir/my-custom"
printf -- '---\nname: my-custom\n---\n# mine\n' > "$skills_dir/my-custom/SKILL.md"

# re-run: prune should remove ardd-ghost, ardd-analyze, ardd-converge only
prune_out="$( cd "$REPO_ROOT" && sh "$INSTALL_SH" "$target" )"

# --- Assertions ---
if [ -d "$skills_dir/ardd-ghost" ]; then
  bad "stale ardd-ghost/ removed on re-run"
else
  ok "stale ardd-ghost/ removed on re-run"
fi

if [ -d "$skills_dir/my-custom" ] && [ -f "$skills_dir/my-custom/SKILL.md" ]; then
  ok "hand-written my-custom/ survives"
else
  bad "hand-written my-custom/ survives"
fi

# Rename-aware prune output: a renamed dir names its new command, a folded
# dir names its destination, an unknown stale dir keeps the generic message.
[ ! -d "$skills_dir/ardd-analyze" ] \
  && ok "renamed-dir ardd-analyze removed" || bad "renamed-dir ardd-analyze removed"
[ ! -d "$skills_dir/ardd-converge" ] \
  && ok "folded-dir ardd-converge removed" || bad "folded-dir ardd-converge removed"
printf '%s' "$prune_out" | grep -q 'ardd-analyze (renamed — now /ardd-status)' \
  && ok "renamed-dir message names /ardd-status" \
  || bad "renamed-dir message names /ardd-status"
printf '%s' "$prune_out" | grep -q 'ardd-converge (folded into /ardd-implement)' \
  && ok "folded-dir message names /ardd-implement" \
  || bad "folded-dir message names /ardd-implement"
printf '%s' "$prune_out" | grep -q 'ardd-ghost (removed — no longer in ARDD source)' \
  && ok "unknown stale dir keeps the generic message" \
  || bad "unknown stale dir keeps the generic message"

for ref in ardd-scripts ardd-artifact-templates ardd-constitution-data; do
  if [ -d "$skills_dir/$ref" ]; then
    ok "reference dir $ref survives"
  else
    bad "reference dir $ref survives"
  fi
done

# A real ardd skill present in source must remain installed.
if [ -d "$skills_dir/ardd-plan" ] && [ -f "$skills_dir/ardd-plan/SKILL.md" ]; then
  ok "real source skill ardd-plan survives"
else
  bad "real source skill ardd-plan survives"
fi

# --- Idempotence: a third run with no stale dirs changes nothing ---
before="$(ls "$skills_dir" | sort)"
run_install "$target"
after="$(ls "$skills_dir" | sort)"
if [ "$before" = "$after" ]; then
  ok "prune idempotent (no-op when nothing stale)"
else
  bad "prune idempotent (no-op when nothing stale)"
fi

exit "$fail"
