#!/usr/bin/env sh
# Check that every /ardd-* (or bare-name) command referenced in this repo's
# docs actually corresponds to a skill directory under skills/.
# Usage: ./scripts/lint-docs.sh
# Exit 0 if clean, 1 if any doc references a command with no matching skill.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$REPO_DIR/skills"

DOCS="$REPO_DIR/README.md $REPO_DIR/USAGE.md"
for g in "$REPO_DIR"/guides/*.md; do
  [ -f "$g" ] && DOCS="$DOCS $g"
done
# Skill bodies and templates are scanned for command tokens too (markdown
# only — never .sh files, whose comments false-positive): a rename that
# misses a terminal-handoff reference inside another skill, or a template
# naming a dead command, must fail here.
for g in "$SKILLS_DIR"/*/SKILL.md "$REPO_DIR"/templates/*.md "$REPO_DIR"/templates/artifacts/*.md; do
  [ -f "$g" ] && DOCS="$DOCS $g"
done

skill_names="$(ls "$SKILLS_DIR")"

fail=0

for doc in $DOCS; do
  [ -f "$doc" ] || continue

  # Candidate command tokens: a "/" preceded by start-of-line, whitespace,
  # backtick, or "(", followed by a lowercase word, with no further "/"
  # immediately after the word (which would make it a file path instead).
  matches="$(grep -noE '(^|[[:space:]`(])/[a-z][a-z0-9-]*([[:space:]`)]|$)' "$doc" || true)"

  [ -z "$matches" ] && continue

  echo "$matches" | while IFS=: read -r lineno rest; do
    # Strip the leading separator char and trailing boundary char to isolate the word.
    word="$(printf '%s' "$rest" | sed -E 's/^[[:space:]`(]*\///; s/[[:space:]`)]*$//')"

    case "$word" in
      ardd-*)
        found=0
        for s in $skill_names; do
          [ "$s" = "$word" ] && found=1 && break
        done
        if [ "$found" -eq 0 ]; then
          echo "$doc:$lineno: unknown command '/$word' — no matching skill directory"
          echo 1 > "$SCRIPT_DIR/.lint-docs-failed"
        fi
        ;;
      init)
        # Claude Code's own built-in /init (generates CLAUDE.md) is a real
        # command outside skills/ — ardd-init's docs reference it in their
        # redirect clause, so it must not trip the bare-suffix check below.
        ;;
      *)
        # Bare name (no ardd- prefix) — flag if it matches a skill's
        # unprefixed suffix, since that's the missing-prefix bug class.
        for s in $skill_names; do
          suffix="${s#ardd-}"
          if [ "$suffix" = "$word" ]; then
            echo "$doc:$lineno: bare command '/$word' — did you mean '/$s'?"
            echo 1 > "$SCRIPT_DIR/.lint-docs-failed"
          fi
        done
        ;;
    esac
  done
done

if [ -f "$SCRIPT_DIR/.lint-docs-failed" ]; then
  rm -f "$SCRIPT_DIR/.lint-docs-failed"
  exit 1
fi

# --- skills-CLI compatibility: every SKILL.md needs name + description ---
# The vercel-labs skills CLI (npx acquisition channel) discovers skills by
# frontmatter `name:` and `description:`; a missing field silently drops
# that skill from `npx skills add`. Empty values count as missing.
fm_fail=0
for sk in "$SKILLS_DIR"/*/SKILL.md; do
  [ -f "$sk" ] || continue
  fm="$(awk '/^---[[:space:]]*$/{c++; next} c==1{print} c>=2{exit}' "$sk")"
  if ! printf '%s\n' "$fm" | grep -q '^name:[[:space:]]*[^[:space:]]'; then
    echo "$sk: frontmatter missing 'name:' — required for skills-CLI discovery"
    fm_fail=1
  fi
  # Frontmatter name must equal the directory name — a rename that moves
  # the directory but forgets `name:` (or vice versa) registers the skill
  # under the wrong command.
  dir_name="$(basename "$(dirname "$sk")")"
  fm_name="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
  if [ -n "$fm_name" ] && [ "$fm_name" != "$dir_name" ]; then
    echo "$sk: frontmatter name '$fm_name' != directory name '$dir_name'"
    fm_fail=1
  fi
  if ! printf '%s\n' "$fm" | grep -q '^description:[[:space:]]*[^[:space:]]'; then
    echo "$sk: frontmatter missing 'description:' — required for skills-CLI discovery"
    fm_fail=1
  fi
  # Unquoted colon-space in the value is invalid strict YAML — the skills
  # CLI silently drops such a skill (live-verified 2026-07-09). Quote it.
  if printf '%s\n' "$fm" | grep -q '^description:[[:space:]]*[^"'"'"'[:space:]].*:[[:space:]]'; then
    echo "$sk: description contains an unquoted colon — strict-YAML parsers drop this skill; wrap the value in quotes"
    fm_fail=1
  fi
done
[ "$fm_fail" -eq 1 ] && exit 1

# --- owned-report-filename gate (v1.0.0 transition guard) ----------------
# lint-docs checks command tokens only, so a renamed skill's OLD owned-file
# name (critique.md, SYNC.md) would otherwise linger silently in live
# source. Once the renamed skill directory exists, the legacy literal must
# not appear in skills/, scripts/, install.sh, new.sh, README, USAGE, or
# templates. Exempt: lines mentioning "legacy" (the adoption steps and the
# migrations must name the old file), test fixtures (scripts/test-*.sh),
# migrations/ (they perform the rename), and this script itself.
gate_fail=0
gate_scan() { # gate_scan <escaped-literal> <display-name>
  for f in "$SKILLS_DIR"/*/SKILL.md "$REPO_DIR"/scripts/*.sh \
           "$REPO_DIR/install.sh" "$REPO_DIR/new.sh" \
           "$REPO_DIR/README.md" "$REPO_DIR/USAGE.md" \
           "$REPO_DIR"/templates/*.md "$REPO_DIR"/templates/artifacts/*.md; do
    [ -f "$f" ] || continue
    case "$f" in
      */scripts/lint-docs.sh|*/scripts/test-*.sh) continue ;;
    esac
    hits="$(grep -n "$1" "$f" 2>/dev/null | grep -iv 'legacy' || true)"
    if [ -n "$hits" ]; then
      echo "$f: legacy owned-file name '$2' still referenced (renamed at v1.0.0):"
      printf '%s\n' "$hits" | sed 's/^/  /'
      gate_fail=1
    fi
  done
}
[ -d "$SKILLS_DIR/ardd-audit" ]   && gate_scan 'critique\.md' 'critique.md'
[ -d "$SKILLS_DIR/ardd-tracker" ] && gate_scan 'SYNC\.md' 'SYNC.md'
[ "$gate_fail" -eq 1 ] && exit 1

# --- generated skill docs must match SKILL.md frontmatter ---------------
if ! sh "$(dirname "$SCRIPT_DIR")/scripts/gen-skill-docs.sh" --check 2>&1; then
  exit 1
fi

echo "lint-docs: clean — every /ardd-* reference in README.md, USAGE.md, guides/*.md matches a skill."
exit 0
