#!/usr/bin/env sh
# Install or upgrade artifact-driven-dev skills into a target project.
# Usage: ./install.sh [target-dir]
# Defaults to the current directory if no target is given.
# Safe to re-run — skills are overwritten, migrations are applied once.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-.}"
SKILLS_DIR="$SCRIPT_DIR/skills"
MIGRATIONS_DIR="$SCRIPT_DIR/migrations"
CLAUDE_SKILLS="$TARGET/.claude/skills"
APPLIED_FILE="$TARGET/.ardd-applied"
VERSION_FILE="$TARGET/.project/ardd-version.md"
CONSTITUTION_DATA_DIR="$CLAUDE_SKILLS/ardd-constitution-data"
ARTIFACT_TEMPLATES_DIR="$CLAUDE_SKILLS/ardd-artifact-templates"
ARDD_SCRIPTS_DIR="$CLAUDE_SKILLS/ardd-scripts"

if [ ! -d "$TARGET" ]; then
  echo "Error: target directory '$TARGET' does not exist." >&2
  exit 1
fi

# --- Skills ---
echo "Installing artifact-driven-dev skills into $TARGET ..."

installed_skill_names=""
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  dest="$CLAUDE_SKILLS/$skill_name"
  mkdir -p "$dest"
  cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
  echo "  ✓ $skill_name"
  installed_skill_names="$installed_skill_names $skill_name"
done

# --- Constitution suggestion catalog ---
# Not a skill (no SKILL.md, so it never registers as an invokable command) —
# reference data /ardd-bootstrap and /ardd-codify read at constitution-
# creation time. Lives under .claude/skills/ardd-* so it's covered by the
# same gitignore guidance already given for ardd-* skill directories below.
mkdir -p "$CONSTITUTION_DATA_DIR"
cp "$SCRIPT_DIR/templates/constitution-suggestions.md" "$CONSTITUTION_DATA_DIR/constitution-suggestions.md"
echo "  ✓ ardd-constitution-data/constitution-suggestions.md"

# --- Artifact templates ---
# Not skills either — structure skeletons /ardd-bootstrap, /ardd-refine, and
# /ardd-add-artifact fill in from context when creating/refining an artifact.
# These previously only existed in the ADD source repo, never in a target
# project, so the "look for templates/artifacts/<name>.md in the ADD
# installation" instruction those skills carried was a no-op outside this
# repo; falling back to generic.md silently absorbed the gap. Same fix as
# the constitution catalog above: copy them so the fixed path actually
# resolves in a target project.
mkdir -p "$ARTIFACT_TEMPLATES_DIR"
cp "$SCRIPT_DIR"/templates/artifacts/*.md "$ARTIFACT_TEMPLATES_DIR/"
echo "  ✓ ardd-artifact-templates/ ($(ls "$SCRIPT_DIR"/templates/artifacts/*.md | wc -l | tr -d ' ') templates)"

# --- Deterministic check/utility scripts ---
# Not skills — shelled out to by skill prose or run by hand/CI.
# lint-project.sh: invoked by /ardd-lint against this project's own
#   .project/ state. Schema-of-record for status enums and required
#   frontmatter fields lives in this script, not in prose; see its header.
# branch-info.sh: invoked by ardd-plan/ardd-implement/ardd-converge's "check
#   branch" step for the deterministic current/default-branch detection
#   those skills used to duplicate as prose.
# worktree-info.sh: invoked by ardd-implement/ardd-converge's "check
#   branch" step to create or locate a worktree branched from the default
#   branch's current tip, when that step's default-to-yes delegation is
#   accepted. ardd-plan never delegates — its draft plan file is itself the
#   state ardd-tasks needs to see promptly, so isolating it in a worktree
#   would defeat the point.
# sibling-tasks-complete.sh: invoked by ardd-implement/ardd-converge on a
#   tasks file's own completion, to check whether every tasks file bound to
#   the same plan is done before flipping that plan's features to
#   implemented — those two skills used to duplicate this check as prose.
# sync-slug-match.sh / sync-label-decision.sh / sync-divergence.sh: invoked
#   by ardd-sync's Push/Pull steps for the three pure decisions it makes
#   from gh-provided state (dedup match, label-swap action, divergence
#   detection) — extracted so they're testable without mocking gh itself.
# project-lock.sh: invoked by ardd-plan/ardd-tasks/ardd-implement/
#   ardd-converge around their multi-file bookkeeping writes — a warn-only
#   marker for two sessions/agents racing on the same .project/, not real
#   locking; a `check` never blocks a run, only surfaces a warning.
mkdir -p "$ARDD_SCRIPTS_DIR"
cp "$SCRIPT_DIR/scripts/lint-project.sh" "$ARDD_SCRIPTS_DIR/lint-project.sh"
cp "$SCRIPT_DIR/scripts/branch-info.sh" "$ARDD_SCRIPTS_DIR/branch-info.sh"
cp "$SCRIPT_DIR/scripts/worktree-info.sh" "$ARDD_SCRIPTS_DIR/worktree-info.sh"
cp "$SCRIPT_DIR/scripts/sibling-tasks-complete.sh" "$ARDD_SCRIPTS_DIR/sibling-tasks-complete.sh"
cp "$SCRIPT_DIR/scripts/sync-slug-match.sh" "$ARDD_SCRIPTS_DIR/sync-slug-match.sh"
cp "$SCRIPT_DIR/scripts/sync-label-decision.sh" "$ARDD_SCRIPTS_DIR/sync-label-decision.sh"
cp "$SCRIPT_DIR/scripts/sync-divergence.sh" "$ARDD_SCRIPTS_DIR/sync-divergence.sh"
cp "$SCRIPT_DIR/scripts/project-lock.sh" "$ARDD_SCRIPTS_DIR/project-lock.sh"
chmod +x "$ARDD_SCRIPTS_DIR/lint-project.sh" "$ARDD_SCRIPTS_DIR/branch-info.sh" \
  "$ARDD_SCRIPTS_DIR/worktree-info.sh" \
  "$ARDD_SCRIPTS_DIR/sibling-tasks-complete.sh" "$ARDD_SCRIPTS_DIR/sync-slug-match.sh" \
  "$ARDD_SCRIPTS_DIR/sync-label-decision.sh" "$ARDD_SCRIPTS_DIR/sync-divergence.sh" \
  "$ARDD_SCRIPTS_DIR/project-lock.sh"
echo "  ✓ ardd-scripts/lint-project.sh"
echo "  ✓ ardd-scripts/branch-info.sh"
echo "  ✓ ardd-scripts/worktree-info.sh"
echo "  ✓ ardd-scripts/sibling-tasks-complete.sh"
echo "  ✓ ardd-scripts/sync-slug-match.sh"
echo "  ✓ ardd-scripts/sync-label-decision.sh"
echo "  ✓ ardd-scripts/sync-divergence.sh"
echo "  ✓ ardd-scripts/project-lock.sh"

# --- Migrations ---
if [ -d "$MIGRATIONS_DIR" ]; then
  echo ""
  echo "Applying migrations ..."

  touch "$APPLIED_FILE"
  any_new=0

  for migration in "$MIGRATIONS_DIR"/*.sh; do
    [ -f "$migration" ] || continue
    migration_name="$(basename "$migration")"
    if grep -qxF "$migration_name" "$APPLIED_FILE"; then
      echo "  – $migration_name (already applied)"
    else
      sh "$migration" "$TARGET"
      echo "$migration_name" >> "$APPLIED_FILE"
      echo "  ✓ $migration_name"
      any_new=1
    fi
  done

  if [ "$any_new" -eq 0 ]; then
    echo "  (none pending)"
  fi
fi

# --- Version file ---
# .claude/skills/ is regenerated output (gitignore it); this file is the
# committed, human-readable record of which ARDD version produced it.
COMMIT="$(git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
DATE="$(date +%Y-%m-%d)"
mkdir -p "$(dirname "$VERSION_FILE")"
cat > "$VERSION_FILE" <<EOF
# ARDD Version

_Source: artifact-driven-dev @ $COMMIT · Installed/updated ${DATE}_

This file is committed so the project's history shows which ARDD skill
version was active at any point. \`.claude/skills/\` is regenerated by
\`install.sh\` from that source commit and should be gitignored, not
committed.
EOF
echo ""
echo "  ✓ .project/ardd-version.md ($COMMIT)"

# --- Gitignore check ---
# Ask git itself whether the skills would show up in `git status` (untracked
# or previously committed) rather than parsing .gitignore text — this is
# what actually determines whether they'd get committed.
#
# The only thing ARDD ever installs under .claude/skills/ is its own ardd-*
# directories (skills, plus the non-skill ardd-constitution-data,
# ardd-artifact-templates, ardd-scripts). Anything else under .claude/ or
# .claude/skills/ — settings.json, agents/, commands/, hooks, a hand-written
# custom skill — is real project content ARDD doesn't own. Never suggest
# ignoring more than ".claude/skills/ardd-*/": a broader pattern (blanket
# ".claude/", or blanket ".claude/skills/") silently blocks tracking that
# content forever, since git refuses to `add` an ignored path without -f —
# easy to not notice until you actually need to commit something there.
if git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  skills_ignored=0
  git -C "$TARGET" check-ignore -q ".claude/skills/ardd-plan/SKILL.md" 2>/dev/null && skills_ignored=1

  if [ "$skills_ignored" -eq 0 ]; then
    tracked_ardd=0   # our own ardd-* skills already committed

    tracked_files="$(git -C "$TARGET" ls-files -- .claude/skills)"
    if [ -n "$tracked_files" ]; then
      old_ifs="$IFS"
      IFS='
'
      for f in $tracked_files; do
        case "$f" in
          .claude/skills/*/*)
            rest="${f#.claude/skills/}"
            skill_name="${rest%%/*}"
            case " $installed_skill_names ardd-constitution-data ardd-artifact-templates ardd-scripts " in
              *" $skill_name "*) tracked_ardd=1 ;;
            esac
            ;;
        esac
      done
      IFS="$old_ifs"
    fi

    echo ""
    echo "Note: .claude/skills/ardd-*/ isn't gitignored in $TARGET — these"
    echo "files are regenerated by install.sh, not project source. Add this"
    echo "pattern to .gitignore (never blanket \".claude/\" or"
    echo "\".claude/skills/\" — both can hold real project content):"
    echo ""
    echo "  .claude/skills/ardd-*/"

    if [ "$tracked_ardd" -eq 1 ]; then
      echo ""
      echo "  ardd-* skill files are already committed here. After updating"
      echo "  .gitignore, untrack them with:"
      echo "    git rm -r --cached .claude/skills/ardd-*"
    fi

    echo ""
    echo "  Commit .project/ardd-version.md instead — it's the lightweight,"
    echo "  human-readable record of which ARDD version produced them."
    echo ""
    echo "  Also gitignore .project/.lock if it appears — it's project-"
    echo "  lock.sh's transient concurrency marker, not project history."
  else
    if git -C "$TARGET" check-ignore -q ".claude/settings.json" 2>/dev/null; then
      echo ""
      echo "Warning: $TARGET's .gitignore blocks .claude/skills/ardd-* but is"
      echo "broad enough to also block .claude/settings.json (and similarly"
      echo ".claude/agents/, .claude/commands/) — real, team-shared project"
      echo "config, not ARDD-regenerated output. If you (or a hook, like"
      echo "ARDD's own PostToolUse lint hook) ever need to commit one of"
      echo "those, git will silently refuse without -f. Narrow the pattern to:"
      echo ""
      echo "  .claude/skills/ardd-*/"
    fi
    if git -C "$TARGET" check-ignore -q ".claude/skills/my-custom-skill/SKILL.md" 2>/dev/null; then
      echo ""
      echo "Warning: $TARGET's .gitignore also blocks any future hand-written"
      echo "skill under .claude/skills/ — only the ardd-* directories there"
      echo "are ARDD-regenerated output. If you ever add your own skill"
      echo "alongside ARDD's, git will silently refuse to track it without"
      echo "-f. Narrow the pattern to:"
      echo ""
      echo "  .claude/skills/ardd-*/"
    fi
  fi
fi

echo ""
echo "Done. Next steps for a new project:"
echo "  1. Run /ardd-bootstrap in Claude Code to seed your project artifacts."
echo "  2. Run /ardd-analyze to check for cross-artifact issues."
echo "  3. Run /ardd-plan when artifacts are stable."
echo ""
echo "For an existing project, run /ardd-analyze to verify everything looks right."
