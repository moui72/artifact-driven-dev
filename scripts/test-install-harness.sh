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
out="$(run_install "$target" --harness codex)"

[ -f "$target/.claude/skills/ardd-init/SKILL.md" ] \
  && [ -f "$target/.agents/skills/ardd-init/SKILL.md" ] \
  && ok "switch claude->codex: both generated skill trees can coexist" \
  || bad "switch claude->codex: both generated skill trees can coexist"

# Bounded gitignore guidance covers each installed harness root — both
# ardd-* patterns, never a broader parent (Principle III ceiling).
case "$out" in
  *".agents/skills/ardd-*/"*)
    case "$out" in
      *".claude/skills/ardd-*/"*)
        ok "dual claude->codex: gitignore suggestion names both bounded patterns" ;;
      *)
        bad "dual claude->codex: gitignore suggestion names both bounded patterns" ;;
    esac ;;
  *) bad "dual claude->codex: gitignore suggestion names both bounded patterns" ;;
esac

grep -qxF '.agents/skills/ardd-*/' "$target/.worktreeinclude" \
  && ok "switch claude->codex: .worktreeinclude keeps Codex pattern" \
  || bad "switch claude->codex: .worktreeinclude keeps Codex pattern"

# Dual installs are first-class (constitution, 2026-07-21): both trees
# coexist, so the sibling harness's bounded pattern stays — never pruned.
if grep -qxF '.claude/skills/ardd-*/' "$target/.worktreeinclude"; then
  ok "dual claude->codex: .worktreeinclude keeps installed Claude pattern"
else
  bad "dual claude->codex: .worktreeinclude keeps installed Claude pattern"
fi

# Reviewer guide lists every installed harness root, never just the
# invoking harness's.
if grep -q '\.agents/skills' "$target/.project/README.md" \
   && grep -q '\.claude/skills' "$target/.project/README.md"; then
  ok "dual claude->codex: reviewer guide lists both harness roots"
else
  bad "dual claude->codex: reviewer guide lists both harness roots"
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
  ok "dual codex->claude: .worktreeinclude keeps installed Codex pattern"
else
  bad "dual codex->claude: .worktreeinclude keeps installed Codex pattern"
fi

if grep -q '\.agents/skills' "$target/.project/README.md" \
   && grep -q '\.claude/skills' "$target/.project/README.md"; then
  ok "dual codex->claude: reviewer guide lists both harness roots"
else
  bad "dual codex->claude: reviewer guide lists both harness roots"
fi

# --- Case 5: Harnesses: union metadata (multi-harness-install-metadata) ---
# The shared .project/ardd-version.md must represent the full installed
# harness *set* via a comma-separated, order-normalized `Harnesses:` line —
# preserve-on-reinstall union semantics, never last-writer-wins. Absent
# line = claude (old files keep parsing); asserted here as the written
# contract for every new install.

target="$WORK/meta-claude"
mkdir -p "$target"; git init -q "$target"; git -C "$target" commit -q --allow-empty -m init
run_install "$target" >/dev/null
grep -qxF 'Harnesses: claude' "$target/.project/ardd-version.md" \
  && ok "meta: claude-only install records Harnesses: claude" \
  || bad "meta: claude-only install records Harnesses: claude"

target="$WORK/meta-codex"
mkdir -p "$target"; git init -q "$target"; git -C "$target" commit -q --allow-empty -m init
run_install "$target" --harness codex >/dev/null
grep -qxF 'Harnesses: codex' "$target/.project/ardd-version.md" \
  && ok "meta: codex-only install records Harnesses: codex" \
  || bad "meta: codex-only install records Harnesses: codex"

target="$WORK/meta-dual-cc"
mkdir -p "$target"; git init -q "$target"; git -C "$target" commit -q --allow-empty -m init
run_install "$target" >/dev/null
run_install "$target" --harness codex >/dev/null
grep -qxF 'Harnesses: claude,codex' "$target/.project/ardd-version.md" \
  && ok "meta: claude-then-codex records Harnesses: claude,codex" \
  || bad "meta: claude-then-codex records Harnesses: claude,codex"
[ -f "$target/.claude/skills/ardd-init/SKILL.md" ] \
  && [ -f "$target/.agents/skills/ardd-init/SKILL.md" ] \
  && ok "meta: claude-then-codex keeps both skill trees intact" \
  || bad "meta: claude-then-codex keeps both skill trees intact"

target="$WORK/meta-dual-xc"
mkdir -p "$target"; git init -q "$target"; git -C "$target" commit -q --allow-empty -m init
run_install "$target" --harness codex >/dev/null
run_install "$target" >/dev/null
grep -qxF 'Harnesses: claude,codex' "$target/.project/ardd-version.md" \
  && ok "meta: codex-then-claude records order-normalized Harnesses: claude,codex" \
  || bad "meta: codex-then-claude records order-normalized Harnesses: claude,codex"
[ -f "$target/.claude/skills/ardd-init/SKILL.md" ] \
  && [ -f "$target/.agents/skills/ardd-init/SKILL.md" ] \
  && ok "meta: codex-then-claude keeps both skill trees intact" \
  || bad "meta: codex-then-claude keeps both skill trees intact"

# Reinstall of one harness preserves the sibling's membership.
run_install "$target" --harness codex >/dev/null
grep -qxF 'Harnesses: claude,codex' "$target/.project/ardd-version.md" \
  && ok "meta: codex reinstall preserves claude membership in Harnesses:" \
  || bad "meta: codex reinstall preserves claude membership in Harnesses:"

# --- Case 6: dev-mode reinstall records Channel: dev, drops Source-Ref ---
# (878c F002.) A reinstall whose source resolved channel=dev (the caller —
# /ardd-update — passes ARDD_CHANNEL=dev) must record `Channel: dev` and
# drop any stale Source-Ref, never leave a stale beta/stable + tag pair.
# Fixture source sits at a release tag so the first install records a
# Source-Ref to go stale.
SRC="$WORK/devsrc"
mkdir -p "$SRC"
cp -R "$REPO_ROOT/skills" "$REPO_ROOT/templates" "$REPO_ROOT/scripts" "$REPO_ROOT/migrations" "$SRC/"
cp "$REPO_ROOT/install.sh" "$SRC/"
( cd "$SRC" && git init -q -b main && git add -A && git commit -q -m one )
git -C "$SRC" tag v9.9.9

target="$WORK/meta-dev"
mkdir -p "$target"; git init -q "$target"; git -C "$target" commit -q --allow-empty -m init
( cd "$SRC" && sh "$SRC/install.sh" "$target" ) >/dev/null 2>&1
grep -q '^Source-Ref: v9.9.9$' "$target/.project/ardd-version.md" \
  && ok "devmode: tagged-source install records Source-Ref (precondition)" \
  || bad "devmode: tagged-source install records Source-Ref (precondition)"

( cd "$SRC" && ARDD_CHANNEL=dev sh "$SRC/install.sh" "$target" ) >/dev/null 2>&1 || true
grep -qxF 'Channel: dev' "$target/.project/ardd-version.md" \
  && ok "devmode: ARDD_CHANNEL=dev reinstall records Channel: dev" \
  || bad "devmode: ARDD_CHANNEL=dev reinstall records Channel: dev"
if grep -q '^Source-Ref:' "$target/.project/ardd-version.md"; then
  bad "devmode: dev reinstall drops stale Source-Ref"
else
  ok "devmode: dev reinstall drops stale Source-Ref"
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
