#!/usr/bin/env sh
# Install or upgrade artifact-driven-dev skills into a target project.
# Usage: ./install.sh [--harness claude|codex] [target-dir]
# Defaults to the current directory if no target is given.
# Safe to re-run — skills are overwritten, migrations are applied once.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HARNESS="claude"
TARGET=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --harness)
      [ "$#" -ge 2 ] || { echo "Error: --harness requires claude or codex." >&2; exit 1; }
      HARNESS="$2"
      shift 2
      ;;
    --harness=*)
      HARNESS="${1#--harness=}"
      shift
      ;;
    --*)
      echo "Error: unknown option '$1'." >&2
      exit 1
      ;;
    *)
      if [ -n "$TARGET" ]; then
        echo "Error: expected at most one target directory." >&2
        exit 1
      fi
      TARGET="$1"
      shift
      ;;
  esac
done

TARGET="${TARGET:-.}"

case "$HARNESS" in
  claude)
    SKILLS_REL=".claude/skills"
    COMMAND_SIGIL="/"
    ;;
  codex)
    SKILLS_REL=".agents/skills"
    COMMAND_SIGIL="$"
    ;;
  *)
    echo "Error: --harness must be 'claude' or 'codex' (got '$HARNESS')." >&2
    exit 1
    ;;
esac

SKILLS_DIR="$SCRIPT_DIR/skills"
MIGRATIONS_DIR="$SCRIPT_DIR/migrations"
INSTALL_SKILLS="$TARGET/$SKILLS_REL"
APPLIED_FILE="$TARGET/.ardd-applied"
VERSION_FILE="$TARGET/.project/ardd-version.md"
CONSTITUTION_DATA_DIR="$INSTALL_SKILLS/ardd-constitution-data"
ARTIFACT_TEMPLATES_DIR="$INSTALL_SKILLS/ardd-artifact-templates"
ARDD_SCRIPTS_DIR="$INSTALL_SKILLS/ardd-scripts"

if [ ! -d "$TARGET" ]; then
  echo "Error: target directory '$TARGET' does not exist." >&2
  exit 1
fi

# Installed harness *set* (multi-harness-install-metadata): union the
# invoking harness into any previously recorded Harnesses: line —
# preserve-on-reinstall, never last-writer-wins. Absent line in an
# existing file parses as claude (old files predate the field); the set
# is order-normalized (sorted, comma-separated) so both install orders
# converge on the same record. Computed up front because the
# .worktreeinclude, reviewer-guide, and gitignore-suggestion steps below
# all speak for every installed harness, not just the invoking one.
PREV_HARNESSES=""
if [ -f "$VERSION_FILE" ]; then
  PREV_HARNESSES="$(sed -n 's/^Harnesses: //p' "$VERSION_FILE" | head -1)"
  [ -n "$PREV_HARNESSES" ] || PREV_HARNESSES="claude"
fi
HARNESSES="$(printf '%s,%s' "$PREV_HARNESSES" "$HARNESS" \
  | tr ',' '\n' | grep -v '^$' | sort -u | paste -sd, -)"

# Per-harness bounded skill roots for the installed set (Principle III:
# these ardd-*/ patterns are the permanent ceiling — never a broader
# parent).
harness_root() { # $1=harness -> its skills dir, empty for unknown
  case "$1" in
    claude) echo ".claude/skills" ;;
    codex)  echo ".agents/skills" ;;
  esac
}

# Release channel this install records (two-channel decision, v1.8.0).
# $ARDD_CHANNEL (set by new.sh --beta, a deliberate channel switch, or
# /ardd-update passing through source-resolve.sh's channel=dev verdict)
# wins; otherwise the target's previously recorded channel is preserved;
# otherwise stable. Validated before anything is written — an unknown
# channel is a refusal, not a guess. `dev` marks a live-checkout install:
# it records Channel: dev and drops any stale Source-Ref (878c F002) —
# a dev install has no release identity to claim.
case "${ARDD_CHANNEL:-}" in
  ""|stable|beta|dev) ;;
  *) echo "Error: ARDD_CHANNEL must be 'stable', 'beta', or 'dev' (got '$ARDD_CHANNEL')." >&2
     exit 1 ;;
esac

# Opt-in dynamic version badge (plan: dynamic-version-badge-sync). Mirrors
# the ARDD_CHANNEL validation above: unset/0/1 only — an unrecognized value
# is a refusal, not a silent guess. When "1", install.sh writes the badge
# workflow + seed JSON + badge icon into the target and prints the
# split-badge snippet
# instead of the single static one; unset (the default) leaves behavior
# byte-for-byte unchanged.
case "${ARDD_VERSION_BADGE:-}" in
  ""|0|1) ;;
  *) echo "Error: ARDD_VERSION_BADGE must be '0' or '1' (got '$ARDD_VERSION_BADGE')." >&2
     exit 1 ;;
esac

# --- Skills ---
echo "Installing artifact-driven-dev skills into $TARGET ($HARNESS harness) ..."

install_skill_file() {
  src="$1"
  dest="$2"
  # One canonical source: harness installs may choose their target directory,
  # so installed SKILL.md path prose must name the installed harness root.
  # The `.claude/skills` -> $SKILLS_REL path substitution below runs for
  # every harness and never touches command invocations such as /ardd-plan.
  #
  # Codex installs additionally rewrite genuine `/ardd-<name>` invocation
  # references to `$ardd-<name>` (Codex's own command syntax), so a
  # Codex session doesn't see Claude Code's slash-command form quoted back
  # at it. This second pass is codex-only — the claude branch's output
  # stays byte-identical to the plain path substitution above. It matches
  # only when: (a) `/ardd-<name>` is immediately preceded by a
  # command-context boundary (backtick, space, `(`, `"`, or start of
  # line) — this alone excludes every path-embedded occurrence, since a
  # path always has a directory-name character immediately before that
  # slash (e.g. the `s` in `.../skills/ardd-plan`); (b) `<name>` is
  # exactly one of the 14 real skill names, via explicit alternation, not
  # a wildcard — so non-invocation `ardd-*` entities (script filenames
  # like `ardd-state.sh`, reference dirs like `ardd-scripts`) are never
  # touched; (c) immediately followed by a non-identifier character (not
  # a lowercase letter or hyphen) — so `/ardd-update` cannot match inside
  # `/ardd-update-check`.
  case "$HARNESS" in
    codex)
      names="audit|backlog|defects|diagram|feedback|implement|init|lint|plan|refine|research|status|tracker|update"
      sed -E \
        -e "s|\\.claude/skills|$SKILLS_REL|g" \
        -e "s#([\`\" (])/ardd-($names)([^a-z-]|\$)#\\1\$ardd-\\2\\3#g" \
        -e "s#^/ardd-($names)([^a-z-]|\$)#\$ardd-\\1\\2#g" \
        "$src" > "$dest"
      ;;
    *)
      sed "s|\\.claude/skills|$SKILLS_REL|g" "$src" > "$dest"
      ;;
  esac
}

# --- Symlink guard ---
# The skills CLI's symlink mode (`npx skills add`) leaves skill install
# entries pointing into its cache; copying "into" those would write through
# the link into the cache instead of the project. Replace any symlinked
# ardd-* entry with a real directory — warn, never fail.
for entry in "$INSTALL_SKILLS"/ardd-*; do
  [ -L "$entry" ] || continue
  echo "  ! $(basename "$entry") is a symlink (skills-CLI symlink mode?) — replacing with a real copy."
  echo "    Regenerating through a symlink would write into the CLI cache, not this project;"
  echo "    prefer the CLI's copy mode if you re-add skills with it."
  rm "$entry"
done

installed_skill_names=""
for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  dest="$INSTALL_SKILLS/$skill_name"
  mkdir -p "$dest"
  install_skill_file "$skill_dir/SKILL.md" "$dest/SKILL.md"
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
for existing in "$INSTALL_SKILLS"/ardd-*/; do
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
# parallel-matrix.sh: pairwise overlap verdicts (shared feature slugs via
#   the tasks->plan chain, shared [artifacts: ...] tags) among ready tasks
#   files and in-flight worktree claims — read by ardd-status's Work Queue
#   section and ardd-implement's pick-list annotations. `independent` means
#   no declared overlap only; merge_policy still governs at merge time.
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
cp "$SCRIPT_DIR/scripts/parallel-matrix.sh" "$ARDD_SCRIPTS_DIR/parallel-matrix.sh"
cp "$SCRIPT_DIR/scripts/ardd-state.sh" "$ARDD_SCRIPTS_DIR/ardd-state.sh"
cp "$SCRIPT_DIR/scripts/defects-unsurfaced.sh" "$ARDD_SCRIPTS_DIR/defects-unsurfaced.sh"
cp "$SCRIPT_DIR/scripts/tasks-list.sh" "$ARDD_SCRIPTS_DIR/tasks-list.sh"
cp "$SCRIPT_DIR/scripts/upsert-section.sh" "$ARDD_SCRIPTS_DIR/upsert-section.sh"
cp "$SCRIPT_DIR/scripts/ardd-update-check.sh" "$ARDD_SCRIPTS_DIR/ardd-update-check.sh"
cp "$SCRIPT_DIR/scripts/source-resolve.sh" "$ARDD_SCRIPTS_DIR/source-resolve.sh"
cp "$SCRIPT_DIR/scripts/feature-list.sh" "$ARDD_SCRIPTS_DIR/feature-list.sh"
cp "$SCRIPT_DIR/templates/WORKFLOW.md" "$ARTIFACT_TEMPLATES_DIR/WORKFLOW.md"
echo "  ✓ ardd-artifact-templates/WORKFLOW.md"
chmod +x "$ARDD_SCRIPTS_DIR/lint-project.sh" "$ARDD_SCRIPTS_DIR/branch-info.sh" \
  "$ARDD_SCRIPTS_DIR/completion-flip-check.sh" \
  "$ARDD_SCRIPTS_DIR/sibling-tasks-complete.sh" "$ARDD_SCRIPTS_DIR/sync-slug-match.sh" \
  "$ARDD_SCRIPTS_DIR/sync-label-decision.sh" "$ARDD_SCRIPTS_DIR/sync-divergence.sh" \
  "$ARDD_SCRIPTS_DIR/project-lock.sh" "$ARDD_SCRIPTS_DIR/worktree-align.sh" \
  "$ARDD_SCRIPTS_DIR/fold-to-main.sh" "$ARDD_SCRIPTS_DIR/worktree-reap.sh" \
  "$ARDD_SCRIPTS_DIR/inflight-worktrees.sh" "$ARDD_SCRIPTS_DIR/parallel-matrix.sh" \
  "$ARDD_SCRIPTS_DIR/ardd-state.sh" \
  "$ARDD_SCRIPTS_DIR/defects-unsurfaced.sh" "$ARDD_SCRIPTS_DIR/tasks-list.sh" \
  "$ARDD_SCRIPTS_DIR/upsert-section.sh" "$ARDD_SCRIPTS_DIR/ardd-update-check.sh" \
  "$ARDD_SCRIPTS_DIR/source-resolve.sh" "$ARDD_SCRIPTS_DIR/feature-list.sh"
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
echo "  ✓ ardd-scripts/parallel-matrix.sh"
echo "  ✓ ardd-scripts/ardd-state.sh"
echo "  ✓ ardd-scripts/defects-unsurfaced.sh"
echo "  ✓ ardd-scripts/tasks-list.sh"
echo "  ✓ ardd-scripts/upsert-section.sh"
echo "  ✓ ardd-scripts/ardd-update-check.sh"
echo "  ✓ ardd-scripts/source-resolve.sh"
echo "  ✓ ardd-scripts/feature-list.sh"

# Live capability matrix for the installed harness. Skills can read this
# instead of inferring capabilities from stale prose or from the harness name.
CAPABILITIES_FILE="$ARDD_SCRIPTS_DIR/harness-capabilities.env"
CODEX_CLI_STATUS="not-applicable"
CODEX_VERSION="not-applicable"
CODEX_FEATURES_STATUS="not-applicable"
HOOKS_STATUS="unknown"
SUBAGENTS_STATUS="unknown"
if [ "$HARNESS" = "codex" ]; then
  if command -v codex >/dev/null 2>&1; then
    CODEX_CLI_STATUS="available"
    CODEX_VERSION="$(codex --version 2>/dev/null | head -1 | tr ' ' '_' || true)"
    [ -n "$CODEX_VERSION" ] || CODEX_VERSION="unavailable"
    CODEX_FEATURES="$(codex features list 2>/dev/null || true)"
    if [ -n "$CODEX_FEATURES" ]; then
      CODEX_FEATURES_STATUS="available"
      case "$(printf '%s\n' "$CODEX_FEATURES" | awk '$1 == "hooks" { print $3; exit }')" in
        true) HOOKS_STATUS="available" ;;
        false) HOOKS_STATUS="disabled" ;;
      esac
      case "$(printf '%s\n' "$CODEX_FEATURES" | awk '$1 == "multi_agent" { print $3; exit }')" in
        true) SUBAGENTS_STATUS="available" ;;
        false) SUBAGENTS_STATUS="disabled" ;;
      esac
    else
      CODEX_FEATURES_STATUS="unavailable"
    fi
  else
    CODEX_CLI_STATUS="unavailable"
    CODEX_VERSION="unavailable"
    CODEX_FEATURES_STATUS="unavailable"
  fi
fi
cat > "$CAPABILITIES_FILE" <<EOF
# Generated by install.sh. Read as advisory capability evidence, not policy.
HARNESS=$HARNESS
SKILLS_DIR=$SKILLS_REL
COMMAND_SIGIL=$COMMAND_SIGIL
CANONICAL_SKILL_SOURCE=skills
DETERMINISTIC_SCRIPTS=present
WORKTREEINCLUDE=present
WORKTREEINCLUDE_PATTERN=$SKILLS_REL/ardd-*/
STRUCTURED_USER_QUESTIONS=unknown
SUBAGENTS=$SUBAGENTS_STATUS
HOOKS=$HOOKS_STATUS
SKILL_CHAINING=optional
NEXT_SKILL_FALLBACK=explicit
CODEX_CLI=$CODEX_CLI_STATUS
CODEX_CLI_VERSION=$CODEX_VERSION
CODEX_FEATURES_STATUS=$CODEX_FEATURES_STATUS
EOF
echo "  ✓ ardd-scripts/harness-capabilities.env"

# --- Worktree include ---
# Preserve ArDD's worktree-copy contract for the installed harness. The
# harness-specific ardd skills pattern is also the gitignore pattern this
# script recommends below, so a fresh delegated worktree needs the same
# bounded include to receive the installed scripts. Never write anything
# broader than the ardd skill pattern here — same ceiling as the gitignore
# suggestion.
WORKTREEINCLUDE="$TARGET/.worktreeinclude"
WORKTREEINCLUDE_COMMENT="# ArDD: copy installed skills/scripts into new worktrees (added by install.sh)"

# One bounded pattern per *installed* harness (the Harnesses: union set) —
# dual installs keep both; a pattern is pruned only when its harness is
# absent from the set (a stale line from before the set existed).
wti_keep_claude=0
wti_keep_codex=0
case ",$HARNESSES," in *,claude,*) wti_keep_claude=1 ;; esac
case ",$HARNESSES," in *,codex,*)  wti_keep_codex=1 ;; esac

if [ -f "$WORKTREEINCLUDE" ]; then
  tmp_worktreeinclude="$WORKTREEINCLUDE.tmp.$$"
  awk -v keepc="$wti_keep_claude" -v keepx="$wti_keep_codex" '
    $0 == ".claude/skills/ardd-*/" && keepc != 1 { next }
    $0 == ".agents/skills/ardd-*/" && keepx != 1 { next }
    { print }
  ' "$WORKTREEINCLUDE" > "$tmp_worktreeinclude"
  mv "$tmp_worktreeinclude" "$WORKTREEINCLUDE"
fi

for wti_harness in $(printf '%s' "$HARNESSES" | tr ',' ' '); do
  wti_root="$(harness_root "$wti_harness")"
  [ -n "$wti_root" ] || continue
  WORKTREEINCLUDE_PATTERN="$wti_root/ardd-*/"
  if [ ! -f "$WORKTREEINCLUDE" ]; then
    printf '%s\n%s\n' "$WORKTREEINCLUDE_COMMENT" "$WORKTREEINCLUDE_PATTERN" > "$WORKTREEINCLUDE"
    echo "  ✓ .worktreeinclude created ($WORKTREEINCLUDE_PATTERN)"
  elif grep -qxF "$WORKTREEINCLUDE_PATTERN" "$WORKTREEINCLUDE"; then
    echo "  – .worktreeinclude already contains $WORKTREEINCLUDE_PATTERN"
  else
    # Guard against a missing trailing newline in the existing file gluing
    # our appended line onto its last line.
    if [ -s "$WORKTREEINCLUDE" ] && [ -n "$(tail -c1 "$WORKTREEINCLUDE")" ]; then
      printf '\n' >> "$WORKTREEINCLUDE"
    fi
    if ! grep -qxF "$WORKTREEINCLUDE_COMMENT" "$WORKTREEINCLUDE"; then
      printf '%s\n' "$WORKTREEINCLUDE_COMMENT" >> "$WORKTREEINCLUDE"
    fi
    printf '%s\n' "$WORKTREEINCLUDE_PATTERN" >> "$WORKTREEINCLUDE"
    echo "  ✓ .worktreeinclude appended ($WORKTREEINCLUDE_PATTERN)"
  fi
done

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
# The harness skill directory is regenerated output (gitignore it); this file is the
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
# have no release identity to claim). A commit can carry more than one
# matching tag at once (e.g. right at a stable cut, which also still
# carries the beta tag it was promoted from) — `git describe --exact-match`
# picks one non-deterministically in that case, so list every tag at HEAD
# explicitly and prefer a strict stable tag over a `-beta.` one, matching
# the "newer stable beats older beta" ordering convention used elsewhere
# (next-version.sh, source-resolve.sh).
ALL_REFS_AT_HEAD="$(git -C "$SCRIPT_DIR" tag --points-at HEAD --list 'v[0-9]*' 2>/dev/null || true)"
SOURCE_REF="$(printf '%s\n' "$ALL_REFS_AT_HEAD" | grep -v -- '-beta\.' | sort -V | tail -1)"
[ -z "$SOURCE_REF" ] && SOURCE_REF="$(printf '%s\n' "$ALL_REFS_AT_HEAD" | sort -V | tail -1)"
SOURCE_REF_LINE=""
[ -n "$SOURCE_REF" ] && SOURCE_REF_LINE="Source-Ref: $SOURCE_REF
"
# Channel precedence: $ARDD_CHANNEL (validated above) > the channel the
# target already records (a re-install must not silently flip a beta
# consumer back to stable) > inferred from $SOURCE_REF's own shape (this
# repo's existing -beta. suffix convention, per next-version.sh /
# source-resolve.sh) — beta if SOURCE_REF contains -beta., stable
# otherwise (covers both a plain stable tag and the no-tag/dev-mode
# case). Absent-in-old-files = stable is the consumers' parse rule;
# going forward the line is always written.
PREV_CHANNEL=""
[ -f "$VERSION_FILE" ] && PREV_CHANNEL="$(sed -n 's/^Channel: //p' "$VERSION_FILE" | head -1)"
CHANNEL="${ARDD_CHANNEL:-$PREV_CHANNEL}"
case "$CHANNEL" in
  stable|beta|dev) ;;
  *)
    case "$SOURCE_REF" in
      *-beta.*) CHANNEL=beta ;;
      *) CHANNEL=stable ;;
    esac
    ;;
esac
# Dev-mode installs have no release identity: never record a Source-Ref
# (even when the checkout incidentally sits at a tag), and never leave a
# stale one from a previous stable/beta install (878c F002).
if [ "$CHANNEL" = "dev" ]; then
  SOURCE_REF=""
  SOURCE_REF_LINE=""
fi
# (Harnesses: union set computed up front, right after the harness case —
# the .worktreeinclude/guide/gitignore steps above already used it.)
# Record Source-Path portably: when the source checkout sits under $HOME,
# write it home-relative (~/<rest>) so the committed file carries no
# machine-specific absolute path (readers — source-resolve.sh,
# ardd-update-check.sh — expand the leading ~). Outside $HOME the absolute
# path is kept: there is nothing portable to relativize against.
case "$SCRIPT_DIR" in
  "$HOME"/*) SOURCE_PATH_RECORD="~${SCRIPT_DIR#"$HOME"}" ;;
  *)         SOURCE_PATH_RECORD="$SCRIPT_DIR" ;;
esac
# Legacy repair: a pre-portability install recorded an absolute Source-Path.
# When the existing file's path sits under the current $HOME, this write
# rewrites it to the ~/ form — but the old absolute path is already in the
# consumer's git history. Repairing history (rewrite/squash before sharing,
# or accepting the leak) is the user's call; the rewrite itself is left
# uncommitted here, like every other install.sh write.
PREV_SOURCE_PATH=""
[ -f "$VERSION_FILE" ] && PREV_SOURCE_PATH="$(sed -n 's/^Source-Path: //p' "$VERSION_FILE" | head -1)"
case "$PREV_SOURCE_PATH" in
  "$HOME"/*)
    echo ""
    echo "  ⚠ This target's .project/ardd-version.md recorded a machine-specific"
    echo "    absolute Source-Path ($PREV_SOURCE_PATH)."
    echo "    It is being rewritten to the portable ~/ form, but the old absolute"
    echo "    path remains in this repo's git history. Repairing history is your"
    echo "    call — rewrite/squash before sharing the repo, or accept the leak."
    echo "    Recommendation: if the history is already public, just accept it."
    ;;
esac
mkdir -p "$(dirname "$VERSION_FILE")"
cat > "$VERSION_FILE" <<EOF
# ArDD Version

_Source: artifact-driven-dev @ $COMMIT · Installed/updated ${DATE}_

Source-Path: $SOURCE_PATH_RECORD
$SOURCE_COMMIT_LINE${SOURCE_REF_LINE}Channel: $CHANNEL
Harness: $HARNESS
Harnesses: $HARNESSES

This file is committed so the project's history shows which ArDD skill
version was active at any point. \`$SKILLS_REL/\` is regenerated by
\`install.sh\` from that source commit and should be gitignored, not
committed.

See \`.project/README.md\` for how to read this directory's files.
EOF
echo ""
echo "  ✓ .project/ardd-version.md ($COMMIT)"

# --- .project/README.md reviewer guide: install.sh-owned, overwritten on
# every install (like ardd-version.md) — how to read .project/ for
# downstream reviewers. Source of truth: templates/dot-project-readme.md.
# The guide speaks for every installed harness root (the Harnesses: set),
# not just the invoking one: the template's __ARDD_SKILL_ROOTS__ /
# __ARDD_SKILL_PATTERNS__ tokens are filled with the full set. The path
# rewrite for any remaining literal .claude/skills prose runs first, so
# the substituted set text is never itself rewritten.
GUIDE_ROOTS=""
GUIDE_PATTERNS=""
for guide_harness in $(printf '%s' "$HARNESSES" | tr ',' ' '); do
  guide_root="$(harness_root "$guide_harness")"
  [ -n "$guide_root" ] || continue
  [ -n "$GUIDE_ROOTS" ] && GUIDE_ROOTS="$GUIDE_ROOTS and "
  GUIDE_ROOTS="$GUIDE_ROOTS\`$guide_root/\`"
  [ -n "$GUIDE_PATTERNS" ] && GUIDE_PATTERNS="$GUIDE_PATTERNS, "
  GUIDE_PATTERNS="$GUIDE_PATTERNS\`$guide_root/ardd-*/\`"
done
sed -e "s|\\.claude/skills|$SKILLS_REL|g" \
    -e "s|__ARDD_SKILL_ROOTS__|$GUIDE_ROOTS|g" \
    -e "s|__ARDD_SKILL_PATTERNS__|$GUIDE_PATTERNS|g" \
  "$SCRIPT_DIR/templates/dot-project-readme.md" > "$TARGET/.project/README.md"
echo "  ✓ .project/README.md (reviewer guide)"

# --- "built with ArDD" badge: suggestion only, never a README edit --------
# Mirrors the gitignore-suggestion posture: install.sh never modifies a
# target's README. The static-suggestion print (for a first-time adopter)
# is offered only when a README exists and lacks the marker. The
# ARDD_VERSION_BADGE=1 supporting-file writes (workflow + seed JSON) fire
# whenever a README exists, independent of whether the marker is already
# present — a project that already adopted the static badge is exactly
# the kind of consumer who'd want the dynamic upgrade, and shouldn't need
# to strip the marker first (never overwriting a target's hand-customized
# version on a re-run). Unset (the default): behavior is byte-for-byte
# unchanged from before this opt-in existed (modulo the wrong-badge
# advisory and the one-line dynamic-upgrade mention below).

# Advisory (both paths, F004): a hand-rolled ArDD badge of the
# latest-release shape tracks ArDD's newest release, not the version this
# project actually has installed. Advisory only — never a README edit.
if [ -f "$TARGET/README.md" ] \
   && grep -q 'img.shields.io/github/v/release/.*artifact-driven-dev' "$TARGET/README.md"; then
  echo ""
  echo "  ⚠ Your README has an ArDD badge that tracks ArDD's latest release, not the"
  echo "    version installed here. To fix it, replace the badge inside the markers"
  echo "    (ardd-badge-version-start/-end, or wherever it sits) with the shields.io"
  echo "    endpoint form pointing at this repo's own .github/badges/ardd-version.json"
  echo "    (re-running with ARDD_VERSION_BADGE=1 writes that file; see"
  echo "    templates/badge.md in the ArDD source for the endpoint snippet shape)."
fi

# Marker-family detection: which badge form (if any) the README already
# carries. Word-exact matches on the full marker tokens — the three tokens
# share the `ardd-badge-` prefix, so a naive substring grep for one can
# be shadowed by another; check the two longer tokens first and bound
# every match so e.g. `ardd-badge-start` never matches inside a longer
# token or a hyphenated neighbor.
BADGE_FAMILY=""
if [ -f "$TARGET/README.md" ]; then
  if grep -qE '(^|[^[:alnum:]_-])ardd-badge-version-start([^[:alnum:]_-]|$)' "$TARGET/README.md"; then
    BADGE_FAMILY="version"
  elif grep -qE '(^|[^[:alnum:]_-])ardd-badge-pair-start([^[:alnum:]_-]|$)' "$TARGET/README.md"; then
    BADGE_FAMILY="pair"
  elif grep -qE '(^|[^[:alnum:]_-])ardd-badge-start([^[:alnum:]_-]|$)' "$TARGET/README.md"; then
    BADGE_FAMILY="static"
  fi
fi

# EXISTING_SHIELDS_IO detection (T003): does the target README already carry
# a pre-existing, non-ArDD img.shields.io badge? Strip every ArDD marker
# block first (start/end pairs across all three families) so ArDD's own
# shields.io-rendered badge never counts as "existing" — only a badge the
# target authored independently of ArDD should flip this to true.
EXISTING_SHIELDS_IO=false
if [ -f "$TARGET/README.md" ]; then
  if sed -E '/<!-- ardd-badge(-version|-pair)?-start -->/,/<!-- ardd-badge(-version|-pair)?-end -->/d' "$TARGET/README.md" \
     | grep -q 'img\.shields\.io'; then
    EXISTING_SHIELDS_IO=true
  fi
fi

if [ -f "$TARGET/README.md" ] && [ "${ARDD_VERSION_BADGE:-}" = "1" ]; then
    echo ""
    BADGE_WORKFLOW="$TARGET/.github/workflows/ardd-badge.yml"
    BADGE_JSON="$TARGET/.github/badges/ardd-version.json"
    BADGE_ICON="$TARGET/.github/badges/ardd-icon.svg"

    # The target's real default branch — used both for the workflow's
    # on.push.branches: filter (filled at write time below) and, further
    # down, the printed snippet's endpoint URL. Empty = undeterminable
    # (detached HEAD): the template's [main] placeholder is left as-is and
    # a replace-it instruction printed, mirroring the snippet's own
    # placeholder fallback.
    BADGE_BRANCH="$(git -C "$TARGET" symbolic-ref --short HEAD 2>/dev/null || true)"

    if [ ! -f "$BADGE_WORKFLOW" ]; then
      mkdir -p "$(dirname "$BADGE_WORKFLOW")"
      if [ -n "$BADGE_BRANCH" ]; then
        # Fresh write only — never-clobber above is unchanged. The template
        # keeps `branches: [main]` as its placeholder form; substitute the
        # real branch here so the badge sync fires on repos whose default
        # branch isn't main.
        sed "s|^\([[:space:]]*branches:[[:space:]]*\)\[main\]|\1[$BADGE_BRANCH]|" \
          "$SCRIPT_DIR/templates/ardd-badge-workflow.yml" > "$BADGE_WORKFLOW"
        echo "  ✓ .github/workflows/ardd-badge.yml (branches: [$BADGE_BRANCH])"
      else
        cp "$SCRIPT_DIR/templates/ardd-badge-workflow.yml" "$BADGE_WORKFLOW"
        echo "  ✓ .github/workflows/ardd-badge.yml"
        echo "    (Could not determine this repo's default branch — the workflow's"
        echo "    'branches: [main]' filter is a placeholder; replace 'main' with your"
        echo "    default branch if it differs.)"
      fi
    else
      echo "  – .github/workflows/ardd-badge.yml (already exists, left untouched)"
    fi

    # The badge mark the workflow inlines as logoSvg — shipped to the path
    # the workflow reads, same never-clobber posture as the other two files.
    if [ ! -f "$BADGE_ICON" ]; then
      mkdir -p "$(dirname "$BADGE_ICON")"
      cp "$SCRIPT_DIR/templates/ardd-icon.svg" "$BADGE_ICON"
      echo "  ✓ .github/badges/ardd-icon.svg"
    else
      echo "  – .github/badges/ardd-icon.svg (already exists, left untouched)"
    fi

    if [ ! -f "$BADGE_JSON" ]; then
      # Fill the seed JSON with this run's actual version, same
      # Source-Ref-preferred/Source-Commit-fallback precedence and
      # channel->color mapping as the sync workflow (T001) uses.
      if [ -n "$SOURCE_REF" ]; then
        BADGE_MESSAGE="$SOURCE_REF"
      elif [ -n "$FULL_COMMIT" ]; then
        BADGE_MESSAGE="$(printf '%s' "$FULL_COMMIT" | cut -c1-7)"
      else
        BADGE_MESSAGE="dev"
      fi
      case "$CHANNEL" in
        beta) BADGE_COLOR="yellow" ;;
        *) BADGE_COLOR="blue" ;;
      esac
      mkdir -p "$(dirname "$BADGE_JSON")"
      # Inline the icon file as the seed's logoSvg — JSON-escaped with awk
      # (backslash, quote, newline), passed via ENVIRON so no shell/awk
      # escape reprocessing touches it. POSIX-safe: no jq dependency here
      # (the sync workflow, which always runs on a runner with jq, uses
      # jq --rawfile for the same embed).
      ARDD_BADGE_LOGO="$(awk 'BEGIN{ORS=""} {gsub(/\\/,"\\\\"); gsub(/"/,"\\\""); print $0 "\\n"}' "$SCRIPT_DIR/templates/ardd-icon.svg")" \
        awk '
          /__ARDD_BADGE_LOGO__/ { printf "  \"logoSvg\": \"%s\"\n", ENVIRON["ARDD_BADGE_LOGO"]; next }
          { print }
        ' "$SCRIPT_DIR/templates/ardd-badge.json" \
        | sed -e "s/__ARDD_BADGE_MESSAGE__/$BADGE_MESSAGE/" \
              -e "s/__ARDD_BADGE_COLOR__/$BADGE_COLOR/" > "$BADGE_JSON"
      echo "  ✓ .github/badges/ardd-version.json ($BADGE_MESSAGE)"
    else
      echo "  – .github/badges/ardd-version.json (already exists, left untouched)"
    fi

    # Snippet print, guarded on the detected marker family (F003 + S9
    # F002): version markers → already adopted this exact shape, stay
    # silent about the snippet; pair/static markers → already badged in
    # another shape, print a short switch-shapes note instead of the
    # duplication-inviting full paste block. Supporting-file writes above
    # still ran in every case.
    if [ "$BADGE_FAMILY" = "pair" ] || [ "$BADGE_FAMILY" = "static" ]; then
      echo ""
      echo "  README is already badged via $BADGE_FAMILY markers — see templates/badge.md"
      echo "  in the ArDD source if you want to switch to the dynamic version-badge shape."
      echo ""
    elif [ -z "$BADGE_FAMILY" ]; then
      # Coordinate fill (F002): derive OWNER/REPO from the target's own
      # origin remote (https and scp-style SSH shapes) and BRANCH from HEAD
      # (fallback main); on any parse failure keep the placeholders and
      # print the replace-these instruction instead. Any `<token>:<path>`
      # remote with no `://` is scp-style — the host token (git@github.com,
      # an ssh-config alias like github-ardd, ...) is irrelevant to the
      # coordinates; take <path>, strip a trailing .git, and read
      # owner/repo from its last two segments.
      BADGE_COORDS=""
      BADGE_ORIGIN="$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)"
      case "$BADGE_ORIGIN" in
        https://github.com/*/*) BADGE_COORDS="${BADGE_ORIGIN#https://github.com/}" ;;
        *://*) ;;  # other URL schemes — keep placeholders
        *:*/*)
          badge_path="${BADGE_ORIGIN#*:}"
          badge_path="${badge_path%.git}"
          badge_repo="${badge_path##*/}"
          badge_owner_path="${badge_path%/*}"
          badge_owner="${badge_owner_path##*/}"
          if [ -n "$badge_owner" ] && [ -n "$badge_repo" ]; then
            BADGE_COORDS="$badge_owner/$badge_repo"
          fi
          ;;
      esac
      BADGE_COORDS="${BADGE_COORDS%.git}"
      case "$BADGE_COORDS" in
        */*/*) BADGE_COORDS="" ;;  # unexpected shape — keep placeholders
      esac
      BADGE_BRANCH="$(git -C "$TARGET" symbolic-ref --short HEAD 2>/dev/null || echo main)"

      # T004: shieldcn.dev is the default offer; fall back to the shields.io
      # form only when the target README already carries a pre-existing,
      # non-ArDD shields.io badge (EXISTING_SHIELDS_IO, detected above) —
      # matching the target's own existing visual language.
      if [ "$EXISTING_SHIELDS_IO" = "true" ]; then
        BADGE_TEMPLATE_SRC="$SCRIPT_DIR/templates/badge.md"
        BADGE_STYLE_NOTE="offering the shields.io style: your README already has a shields.io badge, so this matches it"
      else
        BADGE_TEMPLATE_SRC="$SCRIPT_DIR/templates/badge-shieldcn.md"
        BADGE_STYLE_NOTE="offering the shieldcn.dev style (ArDD's own default — see templates/badge-shieldcn.md in the ArDD source)"
      fi

      echo ""
      echo "Optional: add the split \"built with ArDD │ version\" badge to your README — paste this snippet:"
      echo "($BADGE_STYLE_NOTE. One endpoint badge; both halves, brand colour, and mark all come"
      echo "from .github/badges/ardd-version.json — a two-badge pair variant lives alongside this"
      echo "template if you prefer separated marks)"
      echo ""
      if [ -n "$BADGE_COORDS" ]; then
        sed -n '/<!-- ardd-badge-version-start -->/,/<!-- ardd-badge-version-end -->/p' "$BADGE_TEMPLATE_SRC" \
          | sed "s|OWNER/REPO/BRANCH|$BADGE_COORDS/$BADGE_BRANCH|" | sed 's/^/  /'
      else
        sed -n '/<!-- ardd-badge-version-start -->/,/<!-- ardd-badge-version-end -->/p' "$BADGE_TEMPLATE_SRC" | sed 's/^/  /'
        echo ""
        echo "  (No GitHub origin remote found — replace OWNER/REPO/BRANCH with your repo's coordinates before pasting.)"
      fi
      echo ""
      echo "  Note: the version badge renders only for public repos — the endpoint fetches"
      echo "  raw.githubusercontent.com unauthenticated."
      echo ""
      echo "  Before pasting: adapt the snippet's variant/theme (or shields.io colour) query"
      echo "  params to match whatever badge styling is already visible in your README (e.g."
      echo "  variant=secondary&theme=pink) rather than pasting the shipped defaults unexamined."
      echo ""
      echo "  Suggestion only — this script never edits your README. An agent relaying"
      echo "  this should offer the edit: show the exact diff and ask before writing."
      echo ""
    fi
elif [ -f "$TARGET/README.md" ] && [ -n "$BADGE_FAMILY" ]; then
    # S9 F001: any marker family present → the project is already badged;
    # suppress the static suggestion, acknowledge the found form instead
    # (matters doubly because /ardd-update runs install.sh env-unset and
    # relays this output verbatim).
    echo ""
    echo "  README is already badged via $BADGE_FAMILY markers — nothing to add."
elif [ -f "$TARGET/README.md" ]; then
    # T005: same EXISTING_SHIELDS_IO selection rule as the version-badge
    # print site above — shieldcn.dev by default, shields.io fallback when
    # the target README already carries a pre-existing, non-ArDD
    # shields.io badge.
    if [ "$EXISTING_SHIELDS_IO" = "true" ]; then
      BADGE_TEMPLATE_SRC="$SCRIPT_DIR/templates/badge.md"
      BADGE_STYLE_NOTE="offering the shields.io style: your README already has a shields.io badge, so this matches it"
    else
      BADGE_TEMPLATE_SRC="$SCRIPT_DIR/templates/badge-shieldcn.md"
      BADGE_STYLE_NOTE="offering the shieldcn.dev style (ArDD's own default — see templates/badge-shieldcn.md in the ArDD source)"
    fi
    echo ""
    echo "Optional: add a \"built with ArDD\" badge to your README — paste this snippet:"
    echo "($BADGE_STYLE_NOTE)"
    echo ""
    sed -n '/<!-- ardd-badge-start -->/,/<!-- ardd-badge-end -->/p' "$BADGE_TEMPLATE_SRC" | sed 's/^/  /'
    echo ""
    echo "  Prefer a badge showing the installed ArDD version? Re-run with ARDD_VERSION_BADGE=1 ./install.sh to get the dynamic split version badge."
    echo ""
    echo "  Before pasting: adapt the snippet's variant/theme (or shields.io colour) query"
    echo "  params to match whatever badge styling is already visible in your README rather"
    echo "  than pasting the shipped defaults unexamined."
    echo ""
    echo "  Suggestion only — this script never edits your README. An agent relaying"
    echo "  this should offer the edit: show the exact diff and ask before writing."
    echo ""
    echo "  Using a different badge system than shields.io/shieldcn? Submit a new template"
    echo "  design upstream to the ArDD repo (templates/) rather than hand-rolling one here."
    echo ""
else
    # F001: no README yet (a fresh new.sh project) — the opt-in would
    # otherwise never be mentioned. Pointer only, never the snippet:
    # there's no README to paste it into yet. S9 F003: if the flag is
    # already set, acknowledge it instead of re-suggesting it.
    echo ""
    if [ "${ARDD_VERSION_BADGE:-}" = "1" ]; then
      echo "  ARDD_VERSION_BADGE=1 is set, but this project has no README.md yet — create a README and re-run install to add the dynamic version badge."
    else
      echo "  Once this project has a README.md, re-run install with ARDD_VERSION_BADGE=1 to add a dynamic version badge."
    fi
fi

# --- .project/.lock gitignore entry ---
# project-lock.sh's transient concurrency marker — never project history.
# Written unconditionally (like .worktreeinclude above), not left to a
# conditional printed reminder inside the gitignore-diagnostic block below,
# which only fires when the ardd-*/ skills pattern itself is missing.
TARGET_GITIGNORE="$TARGET/.gitignore"
LOCK_PATTERN=".project/.lock"

if [ ! -f "$TARGET_GITIGNORE" ]; then
  printf '%s\n' "$LOCK_PATTERN" > "$TARGET_GITIGNORE"
  echo "  ✓ .gitignore created ($LOCK_PATTERN)"
elif grep -qxF "$LOCK_PATTERN" "$TARGET_GITIGNORE"; then
  : # already present, nothing to do
else
  if [ -s "$TARGET_GITIGNORE" ] && [ -n "$(tail -c1 "$TARGET_GITIGNORE")" ]; then
    printf '\n' >> "$TARGET_GITIGNORE"
  fi
  printf '%s\n' "$LOCK_PATTERN" >> "$TARGET_GITIGNORE"
  echo "  ✓ .gitignore appended ($LOCK_PATTERN)"
fi

# --- Gitignore check ---
# Ask git itself whether the skills would show up in `git status` (untracked
# or previously committed) rather than parsing .gitignore text — this is
# what actually determines whether they'd get committed.
#
# The only thing ArDD ever installs under the harness skill directory is its own ardd-*
# directories (skills, plus the non-skill ardd-constitution-data,
# ardd-artifact-templates, ardd-scripts). Anything else under the harness
# root or skill directory — settings, commands, hooks, a hand-written
# custom skill — is real project content ArDD doesn't own. Never suggest
# ignoring more than the ardd skill pattern: a broader pattern silently blocks tracking that
# content forever, since git refuses to `add` an ignored path without -f —
# easy to not notice until you actually need to commit something there.
# `--is-inside-work-tree` is true for any directory nested under an
# enclosing .git, not just $TARGET being a repo root itself (same trap
# new.sh:242 had) — so confirm $TARGET is its own repo top-level before
# trusting `check-ignore` results below, or a residually-broken install
# (e.g. one that predates new.sh's own fix) could misattribute an outer
# repo's unrelated ignore rule to ArDD's own pattern.
target_abs="$(cd "$TARGET" && pwd -P)"
target_toplevel="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -n "$target_toplevel" ] && [ "$target_toplevel" = "$target_abs" ]; then
  skills_ignored=0
  git -C "$TARGET" check-ignore -q "$SKILLS_REL/ardd-plan/SKILL.md" 2>/dev/null && skills_ignored=1

  if [ "$skills_ignored" -eq 0 ]; then
    tracked_ardd=0   # our own ardd-* skills already committed

    tracked_files="$(git -C "$TARGET" ls-files -- "$SKILLS_REL")"
    if [ -n "$tracked_files" ]; then
      old_ifs="$IFS"
      IFS='
'
      for f in $tracked_files; do
        case "$f" in
          "$SKILLS_REL"/*/*)
            rest="${f#"$SKILLS_REL"/}"
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
    echo "======================================================================"
    echo "ACTION NEEDED: $SKILLS_REL/ardd-*/ isn't gitignored in $TARGET"
    echo "======================================================================"
    echo "These files are regenerated by install.sh, not project source. Add"
    echo "this pattern to .gitignore (never blanket the whole harness directory"
    echo "or its skills directory — both can hold real project content):"
    echo ""
    # One bounded pattern per installed harness (the Harnesses: set) —
    # a dual install suggests both ardd-*/ patterns, never a broader
    # parent (Principle III ceiling).
    for gi_harness in $(printf '%s' "$HARNESSES" | tr ',' ' '); do
      gi_root="$(harness_root "$gi_harness")"
      [ -n "$gi_root" ] || continue
      echo "  $gi_root/ardd-*/"
    done

    if [ "$tracked_ardd" -eq 1 ]; then
      echo ""
      echo "  ardd-* skill files are already committed here. After updating"
      echo "  .gitignore, untrack them with:"
      echo "    git rm -r --cached $SKILLS_REL/ardd-*"
    fi

    echo ""
    echo "  Commit .project/ardd-version.md instead — it's the lightweight,"
    echo "  human-readable record of which ArDD version produced them."
    echo ""
    echo "  Commit .ardd-applied too — it records which migrations have run;"
    echo "  left uncommitted, every teammate re-runs every migration."
    echo "======================================================================"
  else
    if git -C "$TARGET" check-ignore -q "${SKILLS_REL%/skills}/settings.json" 2>/dev/null; then
      echo ""
      echo "Warning: $TARGET's .gitignore blocks $SKILLS_REL/ardd-* but is"
      echo "broad enough to also block files at ${SKILLS_REL%/skills}/ — real, team-shared project"
      echo "config, not ArDD-regenerated output. If you (or a hook, like"
      echo "ArDD's own PostToolUse lint hook) ever need to commit one of"
      echo "those, git will silently refuse without -f. Narrow the pattern to:"
      echo ""
      echo "  $SKILLS_REL/ardd-*/"
    fi
    if git -C "$TARGET" check-ignore -q "$SKILLS_REL/my-custom-skill/SKILL.md" 2>/dev/null; then
      echo ""
      echo "Warning: $TARGET's .gitignore also blocks any future hand-written"
      echo "skill under $SKILLS_REL/ — only the ardd-* directories there"
      echo "are ArDD-regenerated output. If you ever add your own skill"
      echo "alongside ArDD's, git will silently refuse to track it without"
      echo "-f. Narrow the pattern to:"
      echo ""
      echo "  $SKILLS_REL/ardd-*/"
    fi
  fi
fi

echo ""
echo "Done. Next steps for a new project:"
if [ "$HARNESS" = "codex" ]; then
  echo "  1. Run \$ardd-init in Codex — it detects greenfield vs existing"
else
  echo "  1. Run /ardd-init in Claude Code — it detects greenfield vs existing"
fi
echo "     code, then seeds your artifacts from the conversation (interviewing"
echo "     you first on a cold start) or reverse-engineers them from the code."
echo "  2. Run ${COMMAND_SIGIL}ardd-status to check for cross-artifact issues."
echo "  3. Run ${COMMAND_SIGIL}ardd-plan when artifacts are stable."
echo ""
echo "For an existing project, run ${COMMAND_SIGIL}ardd-status to verify everything looks right."
