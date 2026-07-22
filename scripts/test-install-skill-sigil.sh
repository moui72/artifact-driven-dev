#!/usr/bin/env sh
# Regression test for install.sh's codex-only `/ardd-<name>` -> `$ardd-<name>`
# invocation-syntax rewrite. Claude installs must stay byte-identical to the
# canonical source; codex installs must rewrite genuine invocation references
# while leaving path prose, script filenames, and adjacent-name collisions
# (ardd-update vs ardd-update-check) untouched.

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

# --- Install fixtures: claude and codex, both from this same source tree ---
claude_target="$WORK/claude"
mkdir -p "$claude_target"
git init -q "$claude_target"
git -C "$claude_target" commit -q --allow-empty -m init
run_install "$claude_target" >/dev/null

codex_target="$WORK/codex"
mkdir -p "$codex_target"
git init -q "$codex_target"
git -C "$codex_target" commit -q --allow-empty -m init
run_install "$codex_target" --harness codex >/dev/null

# --- Codex assertions ---

plan_codex="$codex_target/.agents/skills/ardd-plan/SKILL.md"
update_codex="$codex_target/.agents/skills/ardd-update/SKILL.md"

grep -qxF '# $ardd-plan' "$plan_codex" \
  && ok "codex: ardd-plan H1 heading rewritten to \$ardd-plan" \
  || bad "codex: ardd-plan H1 heading rewritten to \$ardd-plan"

grep -qF '(`$ardd-backlog`)' "$plan_codex" \
  && ok "codex: body cross-reference /ardd-backlog rewritten to \$ardd-backlog" \
  || bad "codex: body cross-reference /ardd-backlog rewritten to \$ardd-backlog"

grep -qF '.agents/skills/ardd-scripts/ardd-state.sh' "$update_codex" \
  && ok "codex: path reference to ardd-state.sh stays a path (unrewritten)" \
  || bad "codex: path reference to ardd-state.sh stays a path (unrewritten)"

if grep -q '\$ardd-state' "$update_codex"; then
  bad "codex: ardd-state.sh must never become \$ardd-state"
else
  ok "codex: ardd-state.sh must never become \$ardd-state"
fi

grep -qF '.agents/skills/ardd-scripts/ardd-update-check.sh' "$update_codex" \
  && ok "codex: ardd-update-check.sh reference stays untouched (path-rewritten only)" \
  || bad "codex: ardd-update-check.sh reference stays untouched (path-rewritten only)"

if grep -q '\$ardd-update-check' "$update_codex"; then
  bad "codex: ardd-update-check must never be rewritten"
else
  ok "codex: ardd-update-check must never be rewritten"
fi

if grep -q '\$ardd-update\.sh' "$update_codex"; then
  bad "codex: /ardd-update must not over-match into ardd-update-check"
else
  ok "codex: /ardd-update must not over-match into ardd-update-check"
fi

# --- Claude assertions: every installed SKILL.md byte-identical to source ---
claude_mismatch=0
for src in "$REPO_ROOT"/skills/*/SKILL.md; do
  skill_name="$(basename "$(dirname "$src")")"
  installed="$claude_target/.claude/skills/$skill_name/SKILL.md"
  if [ ! -f "$installed" ]; then
    bad "claude: $skill_name/SKILL.md installed"
    claude_mismatch=1
    continue
  fi
  if ! cmp -s "$src" "$installed"; then
    bad "claude: $skill_name/SKILL.md byte-identical to source"
    claude_mismatch=1
  fi
done
[ "$claude_mismatch" -eq 0 ] \
  && ok "claude: all installed SKILL.md files byte-identical to source"

if [ "$fail" -ne 0 ]; then
  echo "test-install-skill-sigil: FAILED" >&2
  exit 1
fi

echo "test-install-skill-sigil: ok"
