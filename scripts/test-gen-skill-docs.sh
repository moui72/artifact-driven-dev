#!/usr/bin/env sh
# Regression test for gen-skill-docs.sh: generates the README core-loop/
# extensions tables and templates/WORKFLOW.md from SKILL.md frontmatter,
# and --check fails when either drifts from the frontmatter.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$SCRIPT_DIR")"
GEN="$SCRIPT_DIR/gen-skill-docs.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail=0
ok()  { echo "ok: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# Fixture repo: two fake skills + minimal README + the real helper scripts.
F="$WORK/repo"
mkdir -p "$F/skills/ardd-alpha" "$F/skills/ardd-beta" "$F/scripts" "$F/templates"
cp "$SCRIPT_DIR/upsert-section.sh" "$F/scripts/"
cat > "$F/skills/ardd-alpha/SKILL.md" <<'EOF'
---
name: ardd-alpha
tier: core
description: Does the alpha thing.
---
# /ardd-alpha
EOF
cat > "$F/skills/ardd-beta/SKILL.md" <<'EOF'
---
name: ardd-beta
tier: extension
description: Does the beta thing.
---
# /ardd-beta
EOF
mkdir -p "$F/skills/ardd-gamma"
cat > "$F/skills/ardd-gamma/SKILL.md" <<'EOF'
---
name: ardd-gamma
tier: setup
description: Does the gamma setup thing.
---
# /ardd-gamma
EOF
printf '# Fixture\n\nIntro.\n' > "$F/README.md"

# --- generate ---
( cd "$F" && sh "$GEN" ) >/dev/null
grep -q '`/ardd-alpha`' "$F/README.md" && ok "core skill in README" || bad "core skill in README"
grep -q 'Does the beta thing.' "$F/README.md" && ok "extension description in README" || bad "extension description in README"
grep -q 'Does the gamma setup thing.' "$F/README.md" && ok "setup tier in README" || bad "setup tier in README"
grep -q '/ardd-gamma' "$F/templates/WORKFLOW.md" && ok "setup tier in WORKFLOW.md" || bad "setup tier in WORKFLOW.md"
grep -q '/ardd-alpha' "$F/templates/WORKFLOW.md" && ok "WORKFLOW.md generated" || bad "WORKFLOW.md generated"
grep -q 'Does the alpha thing.' "$F/templates/WORKFLOW.md" && ok "WORKFLOW.md carries description" || bad "WORKFLOW.md carries description"

# --- check passes when in sync ---
( cd "$F" && sh "$GEN" --check ) >/dev/null 2>&1 && ok "--check passes in sync" || bad "--check passes in sync"

# --- check fails on drift ---
sed -i.bak 's/Does the beta thing./Does the OTHER thing./' "$F/skills/ardd-beta/SKILL.md" && rm -f "$F/skills/ardd-beta/SKILL.md.bak"
set +e
( cd "$F" && sh "$GEN" --check ) >/dev/null 2>&1; rc=$?
set -e
[ "$rc" -ne 0 ] && ok "--check fails on drift" || bad "--check fails on drift"

# --- workflow ordering: in the real repo's generated WORKFLOW.md, the
# core loop must read in execution order (plan before implement) — not
# glob/alphabetical order. (Tasking folded into /ardd-plan, so there's no
# longer a /ardd-tasks row between them.) ---
WF="$REPO/templates/WORKFLOW.md"
lp="$(grep -n '| `/ardd-plan`' "$WF" | cut -d: -f1 | head -1)"
li="$(grep -n '| `/ardd-implement`' "$WF" | cut -d: -f1 | head -1)"
if [ -n "$lp" ] && [ -n "$li" ] && [ "$lp" -lt "$li" ]; then
  ok "workflow order: plan < implement"
else
  bad "workflow order: plan < implement (lines: plan=$lp implement=$li)"
fi

# --- real repo must currently be in sync (or the commit adding this is wrong) ---
( cd "$REPO" && sh "$GEN" --check ) >/dev/null 2>&1 && ok "real repo in sync" || bad "real repo in sync"

exit "$fail"
