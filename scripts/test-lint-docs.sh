#!/usr/bin/env sh
# Regression test for lint-docs.sh, focused on its skill-frontmatter check:
# every skills/*/SKILL.md must carry frontmatter `name:` and `description:`
# (the vercel-labs skills CLI discovers skills by those fields, so a missing
# one silently drops that skill from the npx acquisition channel).
# Runs lint-docs.sh against temp repo skeletons with a stubbed
# gen-skill-docs.sh so the generated-docs drift check stays inert here
# (test-gen-skill-docs.sh owns that behavior).

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() { echo "FAIL: $1"; exit 1; }
ok() { echo "ok: $1"; }

mk_skeleton() { # $1 = root
  mkdir -p "$1/scripts" "$1/skills"
  cp "$SCRIPT_DIR/lint-docs.sh" "$1/scripts/lint-docs.sh"
  printf '#!/usr/bin/env sh\nexit 0\n' > "$1/scripts/gen-skill-docs.sh"
  chmod +x "$1/scripts/lint-docs.sh" "$1/scripts/gen-skill-docs.sh"
  : > "$1/README.md"
  : > "$1/USAGE.md"
}

mk_skill() { # $1 = root, $2 = skill name, $3 = frontmatter body
  mkdir -p "$1/skills/$2"
  {
    printf -- '---\n'
    printf '%s\n' "$3"
    printf -- '---\n\n# %s\n\nSteps.\n' "$2"
  } > "$1/skills/$2/SKILL.md"
}

# case 1: complete frontmatter -> clean
R="$TMP/good"; mk_skeleton "$R"
mk_skill "$R" ardd-alpha 'name: ardd-alpha
description: Does alpha things.'
sh "$R/scripts/lint-docs.sh" > "$TMP/out1" 2>&1 || fail "case1: complete frontmatter should pass ($(cat "$TMP/out1"))"
ok "case1: name+description present -> clean"

# case 2: missing description -> fail, message names the field
R="$TMP/nodesc"; mk_skeleton "$R"
mk_skill "$R" ardd-beta 'name: ardd-beta'
if sh "$R/scripts/lint-docs.sh" > "$TMP/out2" 2>&1; then
  fail "case2: missing description should fail"
fi
ok "case2: missing description -> exit 1"
grep -q "description" "$TMP/out2" || fail "case2: error should name 'description' ($(cat "$TMP/out2"))"
grep -q "ardd-beta" "$TMP/out2" || fail "case2: error should name the skill ($(cat "$TMP/out2"))"
ok "case2: error names field and skill"

# case 3: missing name -> fail, message names the field
R="$TMP/noname"; mk_skeleton "$R"
mk_skill "$R" ardd-gamma 'description: Does gamma things.'
if sh "$R/scripts/lint-docs.sh" > "$TMP/out3" 2>&1; then
  fail "case3: missing name should fail"
fi
grep -q "name" "$TMP/out3" || fail "case3: error should name 'name' ($(cat "$TMP/out3"))"
ok "case3: missing name -> exit 1, field named"

# case 4: no frontmatter block at all -> fail
R="$TMP/nofm"; mk_skeleton "$R"
mkdir -p "$R/skills/ardd-delta"
printf '# ardd-delta\n\nNo frontmatter here.\n' > "$R/skills/ardd-delta/SKILL.md"
if sh "$R/scripts/lint-docs.sh" > "$TMP/out4" 2>&1; then
  fail "case4: missing frontmatter block should fail"
fi
ok "case4: no frontmatter -> exit 1"

# case 5: empty-valued field counts as missing
R="$TMP/emptyval"; mk_skeleton "$R"
mk_skill "$R" ardd-epsilon 'name: ardd-epsilon
description:'
if sh "$R/scripts/lint-docs.sh" > "$TMP/out5" 2>&1; then
  fail "case5: empty description value should fail"
fi
ok "case5: empty description value -> exit 1"

# case 7: unquoted colon-space in description -> fail (strict-YAML parsers,
# e.g. the skills CLI's, silently drop the skill — live-verified 2026-07-09)
R="$TMP/colon"; mk_skeleton "$R"
mk_skill "$R" ardd-zeta 'name: ardd-zeta
description: One-time: does zeta things.'
if sh "$R/scripts/lint-docs.sh" > "$TMP/out7" 2>&1; then
  fail "case7: unquoted colon in description should fail"
fi
grep -qi "colon" "$TMP/out7" || fail "case7: error should mention the colon ($(cat "$TMP/out7"))"
ok "case7: unquoted colon-space in description -> exit 1"

# case 8: quoted description containing a colon -> clean
R="$TMP/quoted"; mk_skeleton "$R"
mk_skill "$R" ardd-eta 'name: ardd-eta
description: "One-time: does eta things."'
sh "$R/scripts/lint-docs.sh" > "$TMP/out8" 2>&1 || fail "case8: quoted colon description should pass ($(cat "$TMP/out8"))"
ok "case8: quoted colon description -> clean"

# case 6: the real repo passes (all shipped skills are CLI-discoverable)
sh "$SCRIPT_DIR/lint-docs.sh" > "$TMP/out6" 2>&1 || fail "case6: real repo should pass ($(cat "$TMP/out6"))"
ok "case6: real repo clean"

echo "test-lint-docs: all cases pass"
