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

# Release channel this install records (two-channel decision, v1.8.0).
# $ARDD_CHANNEL (set by new.sh --beta, or a deliberate channel switch)
# wins; otherwise the target's previously recorded channel is preserved;
# otherwise stable. Validated before anything is written — an unknown
# channel is a refusal, not a guess.
case "${ARDD_CHANNEL:-}" in
  ""|stable|beta) ;;
  *) echo "Error: ARDD_CHANNEL must be 'stable' or 'beta' (got '$ARDD_CHANNEL')." >&2
     exit 1 ;;
esac

# --- Skills ---
echo "Installing artifact-driven-dev skills into $TARGET ..."

# --- Symlink guard ---
# The skills CLI's symlink mode (`npx skills add`) leaves .claude/skills/
# entries pointing into its cache; copying "into" those would write through
# the link into the cache instead of the project. Replace any symlinked
# ardd-* entry with a real directory — warn, never fail.
for entry in "$CLAUDE_SKILLS"/ardd-*; do
  [ -L "$entry" ] || continue
  echo "  ! $(basename "$entry") is a symlink (skills-CLI symlink mode?) — replacing with a real copy."
  echo "    Regenerating through a symlink would write into the CLI cache, not this project;"
  echo "    prefer the CLI's copy mode if you re-add skills with it."
  rm "$entry"
done

installed_skill_names=""
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  dest="$CLAUDE_SKILLS/$skill_name"
  mkdir -p "$dest"
  cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
  echo "  ✓ $skill_name"
  installed_skill_names="$installed_skill_names $skill_name"
done

# --- Prune ardd-* skills removed from source (Principle VII) ---
# Removing a slash command is a breaking change to existing installs, so an
# upgrade past a skill merge (e.g. bootstrap+codify merged into /ardd-init)
# must delete the dead command's directory — otherwise the retired command
# lingers in the target's palette. Enumerate the target's own ardd-* dirs and
# remove any with no counterpart under source `skills/`. Only ardd-owned dirs
# are ever touched: a hand-written non-ardd skill never matches `ardd-*`, and
# the three non-skill reference dirs below (this script's own output, with no
# source `skills/` entry) are explicitly preserved.
for existing in "$CLAUDE_SKILLS"/ardd-*/; do
  [ -d "$existing" ] || continue   # no matches -> literal glob, skip
  existing_name="$(basename "$existing")"
  case " $installed_skill_names ardd-constitution-data ardd-artifact-templates ardd-scripts " in
    *" $existing_name "*) continue ;;   # a real source skill or a reference dir
  esac
  rm -rf "$existing"
  # v1.0.0 transition map: renamed skills point at the new command, folded
  # skills at their destination; anything else keeps the generic message.
  case "$existing_name" in
    ardd-analyze)      echo "  ✗ ardd-analyze (renamed — now /ardd-status)" ;;
    ardd-critique)     echo "  ✗ ardd-critique (renamed — now /ardd-audit)" ;;
    ardd-verify)       echo "  ✗ ardd-verify (renamed — now /ardd-defects)" ;;
    ardd-sync)         echo "  ✗ ardd-sync (renamed — now /ardd-tracker)" ;;
    ardd-feature)      echo "  ✗ ardd-feature (renamed — now /ardd-backlog)" ;;
    ardd-render)       echo "  ✗ ardd-render (renamed — now /ardd-diagram)" ;;
    ardd-converge)     echo "  ✗ ardd-converge (folded into /ardd-implement)" ;;
    ardd-add-artifact) echo "  ✗ ardd-add-artifact (folded into /ardd-refine)" ;;
    ardd-bootstrap)    echo "  ✗ ardd-bootstrap (folded into /ardd-init)" ;;
    ardd-codify)       echo "  ✗ ardd-codify (folded into /ardd-init)" ;;
    *)                 echo "  ✗ $existing_name (removed — no longer in ArDD source)" ;;
  esac
done

# --- Constitution suggestion catalog ---
# Not a skill (no SKILL.md, so it never registers as an invokable command) —
# reference data /ardd-init reads at constitution-
# creation time. Lives under .claude/skills/ardd-* so it's covered by the
# same gitignore guidance already given for ardd-* skill directories below.
mkdir -p "$CONSTITUTION_DATA_DIR"
cp "$SCRIPT_DIR/templates/constitution-suggestions.md" "$CONSTITUTION_DATA_DIR/constitution-suggestions.md"
echo "  ✓ ardd-constitution-data/constitution-suggestions.md"

# --- Artifact templates ---
# Not skills either — structure skeletons /ardd-init and /ardd-refine's
# create path fill in from context when creating/refining an artifact.
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
# branch-info.sh: invoked by ardd-plan/ardd-implement's "check
#   branch" step for the deterministic current/default-branch detection
#   those skills used to duplicate as prose. ardd-implement's
#   worktree isolation (when their branch-gate step delegates) is the
#   Agent tool's own `isolation: "worktree"` — no custom script for that
#   part; a hand-built one (worktree-info.sh) was tried and removed after
#   turning out to duplicate what the tool already does, incompatibly.
# completion-flip-check.sh: invoked by ardd-status against every
#   status: completed tasks file, to detect a plan whose branch already
#   merged into the default branch but whose bound features are still
#   Status: tasked — the orphaned-completion-flip case that arises because
#   ardd-implement's post-merge flip assumes a live
#   conversation checks back after merge, which in practice often doesn't
#   happen.
# sibling-tasks-complete.sh: invoked by ardd-implement on a
#   tasks file's own completion, to check whether every tasks file bound to
#   the same plan is done before flipping that plan's features to
#   implemented — those two skills used to duplicate this check as prose.
# sync-slug-match.sh / sync-label-decision.sh / sync-divergence.sh: invoked
#   by ardd-tracker's Push/Pull steps for the three pure decisions it makes
#   from gh-provided state (dedup match, label-swap action, divergence
#   detection) — extracted so they're testable without mocking gh itself.
# project-lock.sh: invoked by ardd-plan/ardd-implement/
#   around their multi-file bookkeeping writes — a warn-only
#   marker for two sessions/agents racing on the same .project/, not real
#   locking; a `check` never blocks a run, only surfaces a warning.
# worktree-align.sh: run as the first step inside a freshly created
#   delegated worktree, to fast-forward it onto whatever local commits
#   already landed on the default branch before delegation started — a
#   delegated worktree branches from origin/<default> by default and so can
#   start behind the local default branch.
# inflight-worktrees.sh: enumerates other worktrees of the repo and reports
#   any in-progress/completed ArDD tasks-file state found in them — the
#   worktree-native replacement for reading coarse state off the default
#   branch to see what other delegated work is in flight.
# fold-to-main.sh: the deterministic half of the eager-background delegation
#   gate — fast-forward-folds the current feature branch into the local
#   default branch and checks it out, so a run already on a branch can be
#   backgrounded (its state reaches local <default> for worktree-align.sh to
#   carry into the subagent's worktree). Refuses on dirty/detached/diverged.
# worktree-reap.sh: removes merged, clean worktrees (and deletes their
#   branches with `branch -d`, never forced) after a delegated run's branch
#   lands — run by ardd-implement's post-merge coordinator step; ardd-status
#   runs it with --dry-run for visibility only. Refuse-never-resolve:
#   unmerged/dirty/detached worktrees are reported and skipped; the primary
#   and current worktrees are never candidates.
mkdir -p "$ARDD_SCRIPTS_DIR"
cp "$SCRIPT_DIR/scripts/lint-project.sh" "$ARDD_SCRIPTS_DIR/lint-project.sh"
cp "$SCRIPT_DIR/scripts/branch-info.sh" "$ARDD_SCRIPTS_DIR/branch-info.sh"
cp "$SCRIPT_DIR/scripts/completion-flip-check.sh" "$ARDD_SCRIPTS_DIR/completion-flip-check.sh"
cp "$SCRIPT_DIR/scripts/sibling-tasks-complete.sh" "$ARDD_SCRIPTS_DIR/sibling-tasks-complete.sh"
cp "$SCRIPT_DIR/scripts/sync-slug-match.sh" "$ARDD_SCRIPTS_DIR/sync-slug-match.sh"
cp "$SCRIPT_DIR/scripts/sync-label-decision.sh" "$ARDD_SCRIPTS_DIR/sync-label-decision.sh"
cp "$SCRIPT_DIR/scripts/sync-divergence.sh" "$ARDD_SCRIPTS_DIR/sync-divergence.sh"
cp "$SCRIPT_DIR/scripts/project-lock.sh" "$ARDD_SCRIPTS_DIR/project-lock.sh"
cp "$SCRIPT_DIR/scripts/worktree-align.sh" "$ARDD_SCRIPTS_DIR/worktree-align.sh"
cp "$SCRIPT_DIR/scripts/fold-to-main.sh" "$ARDD_SCRIPTS_DIR/fold-to-main.sh"
cp "$SCRIPT_DIR/scripts/worktree-reap.sh" "$ARDD_SCRIPTS_DIR/worktree-reap.sh"
cp "$SCRIPT_DIR/scripts/inflight-worktrees.sh" "$ARDD_SCRIPTS_DIR/inflight-worktrees.sh"
cp "$SCRIPT_DIR/scripts/ardd-state.sh" "$ARDD_SCRIPTS_DIR/ardd-state.sh"
cp "$SCRIPT_DIR/scripts/defects-unsurfaced.sh" "$ARDD_SCRIPTS_DIR/defects-unsurfaced.sh"
cp "$SCRIPT_DIR/scripts/tasks-list.sh" "$ARDD_SCRIPTS_DIR/tasks-list.sh"
cp "$SCRIPT_DIR/scripts/upsert-section.sh" "$ARDD_SCRIPTS_DIR/upsert-section.sh"
cp "$SCRIPT_DIR/scripts/ardd-update-check.sh" "$ARDD_SCRIPTS_DIR/ardd-update-check.sh"
cp "$SCRIPT_DIR/scripts/source-resolve.sh" "$ARDD_SCRIPTS_DIR/source-resolve.sh"
cp "$SCRIPT_DIR/templates/WORKFLOW.md" "$ARTIFACT_TEMPLATES_DIR/WORKFLOW.md"
echo "  ✓ ardd-artifact-templates/WORKFLOW.md"
chmod +x "$ARDD_SCRIPTS_DIR/lint-project.sh" "$ARDD_SCRIPTS_DIR/branch-info.sh" \
  "$ARDD_SCRIPTS_DIR/completion-flip-check.sh" \
  "$ARDD_SCRIPTS_DIR/sibling-tasks-complete.sh" "$ARDD_SCRIPTS_DIR/sync-slug-match.sh" \
  "$ARDD_SCRIPTS_DIR/sync-label-decision.sh" "$ARDD_SCRIPTS_DIR/sync-divergence.sh" \
  "$ARDD_SCRIPTS_DIR/project-lock.sh" "$ARDD_SCRIPTS_DIR/worktree-align.sh" \
  "$ARDD_SCRIPTS_DIR/fold-to-main.sh" "$ARDD_SCRIPTS_DIR/worktree-reap.sh" \
  "$ARDD_SCRIPTS_DIR/inflight-worktrees.sh" "$ARDD_SCRIPTS_DIR/ardd-state.sh" \
  "$ARDD_SCRIPTS_DIR/defects-unsurfaced.sh" "$ARDD_SCRIPTS_DIR/tasks-list.sh" \
  "$ARDD_SCRIPTS_DIR/upsert-section.sh" "$ARDD_SCRIPTS_DIR/ardd-update-check.sh" \
  "$ARDD_SCRIPTS_DIR/source-resolve.sh"
echo "  ✓ ardd-scripts/lint-project.sh"
echo "  ✓ ardd-scripts/branch-info.sh"
echo "  ✓ ardd-scripts/completion-flip-check.sh"
echo "  ✓ ardd-scripts/sibling-tasks-complete.sh"
echo "  ✓ ardd-scripts/sync-slug-match.sh"
echo "  ✓ ardd-scripts/sync-label-decision.sh"
echo "  ✓ ardd-scripts/sync-divergence.sh"
echo "  ✓ ardd-scripts/project-lock.sh"
echo "  ✓ ardd-scripts/worktree-align.sh"
echo "  ✓ ardd-scripts/fold-to-main.sh"
echo "  ✓ ardd-scripts/worktree-reap.sh"
echo "  ✓ ardd-scripts/inflight-worktrees.sh"
echo "  ✓ ardd-scripts/ardd-state.sh"
echo "  ✓ ardd-scripts/defects-unsurfaced.sh"
echo "  ✓ ardd-scripts/tasks-list.sh"
echo "  ✓ ardd-scripts/upsert-section.sh"
echo "  ✓ ardd-scripts/ardd-update-check.sh"
echo "  ✓ ardd-scripts/source-resolve.sh"

# --- Worktree include ---
# Claude Code copies gitignored files into a freshly created worktree
# (including an Agent-tool subagent's own `isolation: "worktree"`) when they
# match a pattern in a `.worktreeinclude` file at the project root (gitignore
# syntax; only files that both match AND are gitignored are copied). Since
# .claude/skills/ardd-*/ is the gitignore pattern this script itself
# recommends below, a fresh delegated worktree would otherwise start with
# none of the installed ardd scripts. Never write anything broader than
# .claude/skills/ardd-*/ here — same ceiling as the gitignore suggestion.
WORKTREEINCLUDE="$TARGET/.worktreeinclude"
WORKTREEINCLUDE_COMMENT="# ArDD: copy installed skills/scripts into new worktrees (added by install.sh)"
WORKTREEINCLUDE_PATTERN=".claude/skills/ardd-*/"

if [ ! -f "$WORKTREEINCLUDE" ]; then
  printf '%s\n%s\n' "$WORKTREEINCLUDE_COMMENT" "$WORKTREEINCLUDE_PATTERN" > "$WORKTREEINCLUDE"
  echo "  ✓ .worktreeinclude created ($WORKTREEINCLUDE_PATTERN)"
elif grep -qxF "$WORKTREEINCLUDE_PATTERN" "$WORKTREEINCLUDE"; then
  echo "  – .worktreeinclude already contains $WORKTREEINCLUDE_PATTERN"
else
  # Guard against a missing trailing newline in the existing file gluing our
  # appended line onto its last line.
  if [ -s "$WORKTREEINCLUDE" ] && [ -n "$(tail -c1 "$WORKTREEINCLUDE")" ]; then
    printf '\n' >> "$WORKTREEINCLUDE"
  fi
  printf '%s\n%s\n' "$WORKTREEINCLUDE_COMMENT" "$WORKTREEINCLUDE_PATTERN" >> "$WORKTREEINCLUDE"
  echo "  ✓ .worktreeinclude appended ($WORKTREEINCLUDE_PATTERN)"
fi

# --- Merge attributes for single-writer report files ---
# The four generated report files (STATUS.md, DEFECTS.md, TRACKER.md,
# audit.md) are disposable at merge: take either side without deliberation
# and let the owning skill regenerate from disk. `merge=ours` makes that
# rule git mechanism instead of prose — with the driver configured, parallel
# branches never conflict on them. The attributes file lives inside
# .project/ (the directory ArDD owns — never the target's root
# .gitattributes, same ceiling discipline as the gitignore suggestion).
# Idempotent create-or-append: missing entries are added, existing entries
# never duplicated, user-added lines preserved.
#
# Git deliberately ignores repo-committed merge-driver *definitions*
# (arbitrary command execution), so the driver itself is a per-clone opt-in
# — checked and suggested below, hooksPath-style, never set by this script.
GITATTRIBUTES="$TARGET/.project/.gitattributes"
GITATTRIBUTES_COMMENT="# ArDD: generated single-writer reports — keep current side on merge (added by install.sh)"
MERGE_OURS_ENTRIES="STATUS.md
DEFECTS.md
TRACKER.md
audit.md"

mkdir -p "$TARGET/.project"
ga_missing=""
for report in $MERGE_OURS_ENTRIES; do
  if [ ! -f "$GITATTRIBUTES" ] || ! grep -qxF "$report merge=ours" "$GITATTRIBUTES"; then
    ga_missing="$ga_missing $report"
  fi
done

if [ -z "$ga_missing" ]; then
  echo "  – .project/.gitattributes already has all merge=ours entries"
else
  if [ ! -f "$GITATTRIBUTES" ]; then
    printf '%s\n' "$GITATTRIBUTES_COMMENT" > "$GITATTRIBUTES"
    ga_verb="created"
  else
    # Guard against a missing trailing newline in the existing file gluing
    # our appended lines onto its last line.
    if [ -s "$GITATTRIBUTES" ] && [ -n "$(tail -c1 "$GITATTRIBUTES")" ]; then
      printf '\n' >> "$GITATTRIBUTES"
    fi
    printf '%s\n' "$GITATTRIBUTES_COMMENT" >> "$GITATTRIBUTES"
    ga_verb="appended"
  fi
  for report in $ga_missing; do
    printf '%s merge=ours\n' "$report" >> "$GITATTRIBUTES"
  done
  echo "  ✓ .project/.gitattributes $ga_verb (merge=ours:$ga_missing)"
fi

# Suggest-and-check for the driver definition (never mutate the user's
# config): with the attributes present but the driver unconfigured, git
# falls back to its normal text merge — a conflict, handled by the
# interactive take-either-side rule, so nothing gets worse; configuring the
# driver is what makes report merges conflict-free.
if git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  && grep -q 'merge=ours' "$GITATTRIBUTES" 2>/dev/null \
  && ! git -C "$TARGET" config --get merge.ours.driver >/dev/null 2>&1; then
  echo ""
  echo "Note: .project/.gitattributes marks the generated report files"
  echo "merge=ours, but this clone has no 'ours' merge driver configured, so"
  echo "git falls back to a normal text merge (a conflict you resolve by"
  echo "taking either side). To make those merges automatic, opt in once per"
  echo "clone:"
  echo ""
  echo "  git config merge.ours.driver true"
fi

# --- Migrations ---
if [ -d "$MIGRATIONS_DIR" ]; then
  echo ""
  # --- "built with ArDD" badge: suggestion only, never an edit -----------
# Mirrors the gitignore-suggestion posture: install.sh never modifies a
# target's README. Offered only when a README exists and lacks the marker.
if [ -f "$TARGET/README.md" ] && ! grep -q 'ardd-badge-start' "$TARGET/README.md"; then
  echo ""
  echo "Optional: add a \"built with ArDD\" badge to your README — paste this snippet:"
  echo ""
  cat "$SCRIPT_DIR/templates/badge.md" | sed 's/^/  /'
  echo ""
fi

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
# committed, human-readable record of which ArDD version produced it.
COMMIT="$(git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
DATE="$(date +%Y-%m-%d)"
# Structured, machine-read record of the installed commit (full sha — the
# prose _Source: line above it stays for humans, now decorative; consumers
# prefer this line and compare by prefix). Omitted when git is unavailable.
FULL_COMMIT="$(git -C "$SCRIPT_DIR" rev-parse HEAD 2>/dev/null || true)"
SOURCE_COMMIT_LINE=""
[ -n "$FULL_COMMIT" ] && SOURCE_COMMIT_LINE="Source-Commit: $FULL_COMMIT
"
# When the source checkout sits exactly at a semver release tag (the normal
# release-channel state after source-resolve.sh), record which release this
# install came from; omit the line for any other commit (dev-mode installs
# have no release identity to claim).
SOURCE_REF="$(git -C "$SCRIPT_DIR" describe --exact-match --tags --match 'v[0-9]*' 2>/dev/null || true)"
SOURCE_REF_LINE=""
[ -n "$SOURCE_REF" ] && SOURCE_REF_LINE="Source-Ref: $SOURCE_REF
"
# Channel precedence: $ARDD_CHANNEL (validated above) > the channel the
# target already records (a re-install must not silently flip a beta
# consumer back to stable) > stable. Absent-in-old-files = stable is the
# consumers' parse rule; going forward the line is always written.
PREV_CHANNEL=""
[ -f "$VERSION_FILE" ] && PREV_CHANNEL="$(sed -n 's/^Channel: //p' "$VERSION_FILE" | head -1)"
CHANNEL="${ARDD_CHANNEL:-$PREV_CHANNEL}"
case "$CHANNEL" in stable|beta) ;; *) CHANNEL=stable ;; esac
mkdir -p "$(dirname "$VERSION_FILE")"
cat > "$VERSION_FILE" <<EOF
# ArDD Version

_Source: artifact-driven-dev @ $COMMIT · Installed/updated ${DATE}_

Source-Path: $SCRIPT_DIR
$SOURCE_COMMIT_LINE${SOURCE_REF_LINE}Channel: $CHANNEL

This file is committed so the project's history shows which ArDD skill
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
# The only thing ArDD ever installs under .claude/skills/ is its own ardd-*
# directories (skills, plus the non-skill ardd-constitution-data,
# ardd-artifact-templates, ardd-scripts). Anything else under .claude/ or
# .claude/skills/ — settings.json, agents/, commands/, hooks, a hand-written
# custom skill — is real project content ArDD doesn't own. Never suggest
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
    echo "  human-readable record of which ArDD version produced them."
    echo ""
    echo "  Commit .ardd-applied too — it records which migrations have run;"
    echo "  left uncommitted, every teammate re-runs every migration."
    echo ""
    echo "  Also gitignore .project/.lock if it appears — it's project-"
    echo "  lock.sh's transient concurrency marker, not project history."
  else
    if git -C "$TARGET" check-ignore -q ".claude/settings.json" 2>/dev/null; then
      echo ""
      echo "Warning: $TARGET's .gitignore blocks .claude/skills/ardd-* but is"
      echo "broad enough to also block .claude/settings.json (and similarly"
      echo ".claude/agents/, .claude/commands/) — real, team-shared project"
      echo "config, not ArDD-regenerated output. If you (or a hook, like"
      echo "ArDD's own PostToolUse lint hook) ever need to commit one of"
      echo "those, git will silently refuse without -f. Narrow the pattern to:"
      echo ""
      echo "  .claude/skills/ardd-*/"
    fi
    if git -C "$TARGET" check-ignore -q ".claude/skills/my-custom-skill/SKILL.md" 2>/dev/null; then
      echo ""
      echo "Warning: $TARGET's .gitignore also blocks any future hand-written"
      echo "skill under .claude/skills/ — only the ardd-* directories there"
      echo "are ArDD-regenerated output. If you ever add your own skill"
      echo "alongside ArDD's, git will silently refuse to track it without"
      echo "-f. Narrow the pattern to:"
      echo ""
      echo "  .claude/skills/ardd-*/"
    fi
  fi
fi

echo ""
echo "Done. Next steps for a new project:"
echo "  1. Run /ardd-init in Claude Code — it detects greenfield vs existing"
echo "     code, then seeds your artifacts from the conversation (interviewing"
echo "     you first on a cold start) or reverse-engineers them from the code."
echo "  2. Run /ardd-status to check for cross-artifact issues."
echo "  3. Run /ardd-plan when artifacts are stable."
echo ""
echo "For an existing project, run /ardd-status to verify everything looks right."
