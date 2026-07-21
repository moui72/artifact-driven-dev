#!/usr/bin/env sh
# Regression test for install.sh's harness selection. Claude remains the
# default install target; Codex installs the same canonical skills under
# .agents/skills and records live, advisory capability evidence.

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

# --- Case 0: source-side scenario sweep has a local Codex entrypoint, not a copy ---
codex_sweep="$REPO_ROOT/.agents/skills/scenario-sweep/SKILL.md"
claude_sweep="$REPO_ROOT/.claude/skills/scenario-sweep/SKILL.md"

[ -f "$codex_sweep" ] \
  && ok "source-side: local Codex scenario-sweep entrypoint exists" \
  || bad "source-side: local Codex scenario-sweep entrypoint exists"
[ -f "$claude_sweep" ] \
  && ok "source-side: canonical Claude scenario-sweep exists" \
  || bad "source-side: canonical Claude scenario-sweep exists"
grep -qxF 'name: scenario-sweep' "$codex_sweep" \
  && ok "source-side: Codex entrypoint has scenario-sweep frontmatter" \
  || bad "source-side: Codex entrypoint has scenario-sweep frontmatter"
grep -q '\.claude/skills/scenario-sweep/SKILL.md' "$codex_sweep" \
  && ok "source-side: Codex entrypoint points at canonical dispatcher" \
  || bad "source-side: Codex entrypoint points at canonical dispatcher"
grep -q '\$scenario-sweep smoke' "$codex_sweep" \
  && ok 'source-side: Codex entrypoint documents $scenario-sweep invocation' \
  || bad 'source-side: Codex entrypoint documents $scenario-sweep invocation'
if grep -q '^## 1\. Resolve the tier' "$codex_sweep"; then
  bad "source-side: Codex entrypoint duplicates dispatcher body"
else
  ok "source-side: Codex entrypoint does not duplicate dispatcher body"
fi

# --- Case 1: default harness stays Claude-compatible ---
target="$WORK/claude"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

out="$(run_install "$target")"

[ -f "$target/.claude/skills/ardd-init/SKILL.md" ] \
  && ok "default: installs to .claude/skills" \
  || bad "default: installs to .claude/skills"

[ ! -e "$target/.claude/skills/scenario-sweep" ] \
  && ok "default: does not install source-side scenario-sweep" \
  || bad "default: does not install source-side scenario-sweep"

cmp -s "$REPO_ROOT/skills/ardd-init/SKILL.md" "$target/.claude/skills/ardd-init/SKILL.md" \
  && ok "default: installed SKILL.md matches canonical source" \
  || bad "default: installed SKILL.md matches canonical source"

grep -qxF '.claude/skills/ardd-*/' "$target/.worktreeinclude" \
  && ok "default: .worktreeinclude uses Claude skill pattern" \
  || bad "default: .worktreeinclude uses Claude skill pattern"

grep -qxF 'Harness: claude' "$target/.project/ardd-version.md" \
  && ok "default: ardd-version records Claude harness" \
  || bad "default: ardd-version records Claude harness"

case "$out" in
  *"Run /ardd-init in Claude Code"*) ok "default: next step uses /ardd-init" ;;
  *) bad "default: next step uses /ardd-init" ;;
esac

# --- Case 2: Codex harness installs canonical skills under .agents/skills ---
target="$WORK/codex"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

out="$(run_install "$target" --harness codex)"

[ -f "$target/.agents/skills/ardd-init/SKILL.md" ] \
  && ok "codex: installs to .agents/skills" \
  || bad "codex: installs to .agents/skills"

[ ! -e "$target/.agents/skills/scenario-sweep" ] \
  && ok "codex: does not install source-side scenario-sweep" \
  || bad "codex: does not install source-side scenario-sweep"

grep -qxF 'name: ardd-init' "$target/.agents/skills/ardd-init/SKILL.md" \
  && ok "codex: installed SKILL.md keeps canonical skill identity" \
  || bad "codex: installed SKILL.md keeps canonical skill identity"

if grep -R '\.claude/skills' "$target/.agents/skills"/ardd-*/SKILL.md >/dev/null 2>&1; then
  bad "codex: installed skill prose still hard-codes .claude/skills"
else
  ok "codex: installed skill prose uses installed harness paths"
fi

if grep -R '\.claude/skills' "$target/.agents/skills/ardd-scripts" >/dev/null 2>&1; then
  bad "codex: installed deterministic scripts still hard-code .claude/skills"
else
  ok "codex: installed deterministic scripts use harness-neutral path prose"
fi

if grep -q -- '--harness <harness>' "$target/.agents/skills/ardd-update/SKILL.md" \
   && grep -q 'HARNESS=<claude|codex>' "$target/.agents/skills/ardd-update/SKILL.md" \
   && grep -q '\.agents/skills/ardd-scripts/harness-capabilities.env' "$target/.agents/skills/ardd-update/SKILL.md"; then
  ok "codex: ardd-update preserves installed harness on reinstall"
else
  bad "codex: ardd-update preserves installed harness on reinstall"
fi

if grep -q 'selected ArDD source predates Codex-harness support' "$target/.agents/skills/ardd-update/SKILL.md" \
   && grep -q 'Do not run the old installer as a fallback' "$target/.agents/skills/ardd-update/SKILL.md"; then
  ok "codex: ardd-update guards pre-harness release installers"
else
  bad "codex: ardd-update guards pre-harness release installers"
fi

[ ! -d "$target/.claude/skills" ] \
  && ok "codex: does not create parallel Claude skill tree" \
  || bad "codex: does not create parallel Claude skill tree"

grep -qxF '.agents/skills/ardd-*/' "$target/.worktreeinclude" \
  && ok "codex: .worktreeinclude uses Codex skill pattern" \
  || bad "codex: .worktreeinclude uses Codex skill pattern"

grep -qxF 'Harness: codex' "$target/.project/ardd-version.md" \
  && ok "codex: ardd-version records Codex harness" \
  || bad "codex: ardd-version records Codex harness"

if grep -q '\.claude/skills' "$target/.project/README.md"; then
  bad "codex: reviewer guide still hard-codes .claude/skills"
elif grep -q '\.agents/skills' "$target/.project/README.md"; then
  ok "codex: reviewer guide uses Codex harness path"
else
  bad "codex: reviewer guide mentions installed harness path"
fi

cap="$target/.agents/skills/ardd-scripts/harness-capabilities.env"
[ -f "$cap" ] \
  && ok "codex: writes harness capability matrix" \
  || bad "codex: writes harness capability matrix"

grep -qxF 'HARNESS=codex' "$cap" \
  && ok "codex: matrix records harness" \
  || bad "codex: matrix records harness"
grep -qxF 'SKILLS_DIR=.agents/skills' "$cap" \
  && ok "codex: matrix records skill directory" \
  || bad "codex: matrix records skill directory"
grep -qxF 'CANONICAL_SKILL_SOURCE=skills' "$cap" \
  && ok "codex: matrix records canonical source" \
  || bad "codex: matrix records canonical source"
grep -qxF 'WORKTREEINCLUDE_PATTERN=.agents/skills/ardd-*/' "$cap" \
  && ok "codex: matrix records worktreeinclude pattern" \
  || bad "codex: matrix records worktreeinclude pattern"
if grep -q '^HOOKS=missing$' "$cap"; then
  bad "codex: matrix does not assume hooks missing"
elif grep -q '^HOOKS=' "$cap"; then
  ok "codex: matrix does not assume hooks missing"
else
  bad "codex: matrix records hooks capability"
fi
if grep -q '^SUBAGENTS=missing$' "$cap"; then
  bad "codex: matrix does not assume subagents missing"
elif grep -q '^SUBAGENTS=' "$cap"; then
  ok "codex: matrix does not assume subagents missing"
else
  bad "codex: matrix records subagents capability"
fi

case "$out" in
  *"Run \$ardd-init in Codex"*) ok 'codex: next step uses explicit $ardd-init fallback' ;;
  *) bad 'codex: next step uses explicit $ardd-init fallback' ;;
esac

case "$out" in
  *"/ardd-init in Codex"*) bad "codex: next step must not use slash command" ;;
  *) ok "codex: next step avoids slash command" ;;
esac

# --- Case 3: harness-switch worktreeinclude pruning ---
target="$WORK/switch-claude-codex"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

run_install "$target" >/dev/null
run_install "$target" --harness codex >/dev/null

[ -f "$target/.claude/skills/ardd-init/SKILL.md" ] \
  && [ -f "$target/.agents/skills/ardd-init/SKILL.md" ] \
  && ok "switch claude->codex: both generated skill trees can coexist" \
  || bad "switch claude->codex: both generated skill trees can coexist"

grep -qxF '.agents/skills/ardd-*/' "$target/.worktreeinclude" \
  && ok "switch claude->codex: .worktreeinclude keeps Codex pattern" \
  || bad "switch claude->codex: .worktreeinclude keeps Codex pattern"

if grep -qxF '.claude/skills/ardd-*/' "$target/.worktreeinclude"; then
  bad "switch claude->codex: .worktreeinclude prunes stale Claude pattern"
else
  ok "switch claude->codex: .worktreeinclude prunes stale Claude pattern"
fi

target="$WORK/switch-codex-claude"
mkdir -p "$target"
git init -q "$target"
git -C "$target" commit -q --allow-empty -m init

run_install "$target" --harness codex >/dev/null
run_install "$target" >/dev/null

[ -f "$target/.agents/skills/ardd-init/SKILL.md" ] \
  && [ -f "$target/.claude/skills/ardd-init/SKILL.md" ] \
  && ok "switch codex->claude: both generated skill trees can coexist" \
  || bad "switch codex->claude: both generated skill trees can coexist"

grep -qxF '.claude/skills/ardd-*/' "$target/.worktreeinclude" \
  && ok "switch codex->claude: .worktreeinclude keeps Claude pattern" \
  || bad "switch codex->claude: .worktreeinclude keeps Claude pattern"

if grep -qxF '.agents/skills/ardd-*/' "$target/.worktreeinclude"; then
  bad "switch codex->claude: .worktreeinclude prunes stale Codex pattern"
else
  ok "switch codex->claude: .worktreeinclude prunes stale Codex pattern"
fi

# --- Case 4: option validation ---
if ( cd "$REPO_ROOT" && sh "$INSTALL_SH" --harness nope "$WORK/invalid" ) >/dev/null 2>&1; then
  bad "invalid: unknown harness is rejected"
else
  ok "invalid: unknown harness is rejected"
fi

if [ "$fail" -ne 0 ]; then
  echo "test-install-harness: FAILED" >&2
  exit 1
fi

echo "test-install-harness: ok"
