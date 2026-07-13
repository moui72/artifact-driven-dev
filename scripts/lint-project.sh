#!/usr/bin/env sh
# Validate a target project's .project/ state against the ADD schema:
#   - frontmatter `status` fields are one of the values that field's skill
#     actually accepts
#   - required frontmatter fields are present
#   - [artifacts: ...] tags on tasks/feedback lines reference artifact files
#     that actually exist
#   - cross-file pointers resolve: a tasks file's `plan:` names an existing
#     plan file; a plan's `features:` slugs exist in features.md; a
#     features.md entry's `Plan:`/`Tasks:` metadata fields name existing files
#   - a tasks file stuck at `status: generating` (a crashed /ardd-plan tasking run)
#     is flagged rather than silently accepted as a valid enum value
#   - an approved/superseded plan whose `features:` slugs are still
#     `backlogged` in features.md — the fingerprint an approval sequence
#     interrupted between the plan-status flip and the feature-status flip
#     would leave (see /ardd-plan step 11)
#   - the same feature slug listed in the `features:` of two non-superseded
#     (draft/approved) plans — the file-based fingerprint of two live plans
#     independently targeting the same feature (see /ardd-plan step 7)
#
# Deliberately NOT validated: audit.md, DEFECTS.md, TRACKER.md, and STATUS.md.
# These are single-writer report files with looser, informal schemas by
# design — their content is prose a human reads, not machine-checkable state —
# so their absence from the checks above is intentional, not an oversight.
#
# THIS SCRIPT IS THE SCHEMA-OF-RECORD for status enums and required fields.
# The enums below are hardcoded because they can't be derived from the
# filesystem the way skill names can (see scripts/lint-docs.sh) — they only
# exist as prose inside each SKILL.md today. If you change what values a
# skill writes to a status field, or add/remove a required frontmatter
# field, update the matching block below IN THE SAME COMMIT. The prose in
# SKILL.md should describe behavior; this script is what actually enforces
# the shape, so treat a mismatch between them as a bug in this script, not
# license to skip updating it.
#
# Usage: ./scripts/lint-project.sh [target-dir]
# Exit 0 if clean, 1 if any violation found.

set -e

TARGET="${1:-.}"

# Findings reported inside piped-while subshells can't set the parent's
# fail flag; they mark this mktemp sentinel instead. It never lives in the
# target root (an interrupted run must not leave litter there — a stale
# pre-1.0 root sentinel is simply ignored) and the trap cleans it up on any
# exit, including interruption.
SENTINEL="$(mktemp)"
trap 'rm -f "$SENTINEL"' EXIT INT TERM
PROJECT_DIR="$TARGET/.project"
FEATURES_FILE="$PROJECT_DIR/artifacts/features.md"   # legacy pre-0003 register
FEATURES_DIR="$PROJECT_DIR/features"                 # register of record

fail=0
report() {
  echo "$1"
  fail=1
}

# Appended to every unknown-enum finding: an unrecognized status may be a
# typo, or a file written by a newer ARDD whose widened enum this install's
# validator predates (the 1.0-compatible version-skew mechanism — a real
# Schema-Version marker is explicitly deferred post-1.0).
SKEW_HINT=" (or written by a newer ARDD than this install — run /ardd-update)"

# --- Schema of record -------------------------------------------------
ARTIFACT_STATUS_ENUM="draft stable"
DIAGRAM_STATUS_ENUM="unrendered stale current"
PLAN_STATUS_ENUM="draft approved superseded"
TASKS_STATUS_ENUM="generating ready in-progress completed abandoned"
FEEDBACK_STATUS_ENUM="open planned"
FEATURE_STATUS_ENUM="backlogged planned tasked implemented retired"  # retired = shipped, then deliberately removed; only from implemented; terminal; manual via ardd-state.sh feature-flip (no skill automates removal)
WORKFLOW_MODE_ENUM="solo collaborative"
NEXT_STEP_PROMPT_ENUM="true false"
DELEGATION_ENUM="eager ask inline"
MERGE_POLICY_ENUM="auto ask"
# -----------------------------------------------------------------------

in_enum() {
  needle="$1"
  shift
  for candidate in "$@"; do
    [ "$candidate" = "$needle" ] && return 0
  done
  return 1
}

# Extracts a frontmatter field's value: the token right after "field:",
# stopping at whitespace/comment, from the first `---`...`---` block only.
frontmatter_field() {
  file="$1"
  field="$2"
  awk '/^---$/{n++; next} n==1' "$file" \
    | grep -E "^${field}:" \
    | head -1 \
    | sed -E "s/^${field}:[[:space:]]*//; s/[[:space:]]*(#.*)?\$//"
}

frontmatter_has() {
  file="$1"
  field="$2"
  awk '/^---$/{n++; next} n==1' "$file" | grep -qE "^${field}:"
}

# Register lookups, mode-agnostic: per-feature files if the register dir
# exists, else the legacy single-file format.
feature_exists() {
  if [ -d "$FEATURES_DIR" ]; then
    [ -f "$FEATURES_DIR/$1.md" ]
  else
    [ -f "$FEATURES_FILE" ] && grep -qE "_Slug: \`$1\`" "$FEATURES_FILE"
  fi
}

feature_status_of() {
  if [ -d "$FEATURES_DIR" ]; then
    [ -f "$FEATURES_DIR/$1.md" ] && frontmatter_field "$FEATURES_DIR/$1.md" status
  else
    grep -oE "_Slug: \`$1\` · Status: [a-z]+" "$FEATURES_FILE" | sed -E 's/.*Status: ([a-z]+)$/\1/'
  fi
}

# --- artifacts/*.md (excluding features.md — different schema) --------
if [ -d "$PROJECT_DIR/artifacts" ]; then
  for f in "$PROJECT_DIR"/artifacts/*.md; do
    [ -f "$f" ] || continue
    name="$(basename "$f" .md)"
    [ "$name" = "features" ] && continue

    if ! frontmatter_has "$f" status; then
      report "$f: missing required frontmatter field 'status'"
    else
      val="$(frontmatter_field "$f" status)"
      if ! in_enum "$val" $ARTIFACT_STATUS_ENUM; then
        report "$f: status '$val' not in {$ARTIFACT_STATUS_ENUM}$SKEW_HINT"
      fi
    fi

    if ! frontmatter_has "$f" last_updated; then
      report "$f: missing required frontmatter field 'last_updated'"
    fi

    if [ "$name" = "constitution" ] && frontmatter_has "$f" workflow_mode; then
      val="$(frontmatter_field "$f" workflow_mode)"
      if ! in_enum "$val" $WORKFLOW_MODE_ENUM; then
        report "$f: workflow_mode '$val' not in {$WORKFLOW_MODE_ENUM}$SKEW_HINT"
      fi
    fi

    # next_step_prompt is optional (absent = false); when present it must
    # be exactly true or false.
    if [ "$name" = "constitution" ] && frontmatter_has "$f" next_step_prompt; then
      val="$(frontmatter_field "$f" next_step_prompt)"
      if ! in_enum "$val" $NEXT_STEP_PROMPT_ENUM; then
        report "$f: next_step_prompt '$val' not in {$NEXT_STEP_PROMPT_ENUM}$SKEW_HINT"
      fi
    fi

    # delegation / merge_policy are optional workflow fields (absent = ask
    # for both — today's prompting behavior); when present they must be in
    # their enums.
    if [ "$name" = "constitution" ] && frontmatter_has "$f" delegation; then
      val="$(frontmatter_field "$f" delegation)"
      if ! in_enum "$val" $DELEGATION_ENUM; then
        report "$f: delegation '$val' not in {$DELEGATION_ENUM}$SKEW_HINT"
      fi
    fi
    if [ "$name" = "constitution" ] && frontmatter_has "$f" merge_policy; then
      val="$(frontmatter_field "$f" merge_policy)"
      if ! in_enum "$val" $MERGE_POLICY_ENUM; then
        report "$f: merge_policy '$val' not in {$MERGE_POLICY_ENUM}$SKEW_HINT"
      fi
    fi

    # update_check_max_age_days is optional (absent = the update check never
    # fetches); when present it must be a positive integer.
    if [ "$name" = "constitution" ] && frontmatter_has "$f" update_check_max_age_days; then
      val="$(frontmatter_field "$f" update_check_max_age_days)"
      case "$val" in
        0*|*[!0-9]*|'')
          report "$f: update_check_max_age_days '$val' is not a positive integer (1, 2, ...)$SKEW_HINT" ;;
      esac
    fi

    # --- constitution governance bookkeeping consistency ---
    # The exact drift /ardd-defects caught once (v1.1.0 defects): footer
    # Version/Last Amended vs frontmatter last_updated vs the Sync Impact
    # Report's target version. Checked only when the markers exist — a
    # minimal constitution without a footer/SIR is fine.
    if [ "$name" = "constitution" ]; then
      footer="$(grep -E '^\*\*Version\*\*:' "$f" | head -1 || true)"
      if [ -n "$footer" ]; then
        footer_ver="$(printf '%s' "$footer" | sed -E 's/^\*\*Version\*\*:[[:space:]]*([0-9.]+).*/\1/')"
        footer_amended="$(printf '%s' "$footer" | sed -E 's/.*\*\*Last Amended\*\*:[[:space:]]*([0-9-]+).*/\1/')"
        fm_updated="$(frontmatter_field "$f" last_updated)"
        if [ -n "$footer_amended" ] && [ -n "$fm_updated" ] && [ "$footer_amended" != "$fm_updated" ]; then
          report "$f: footer Last Amended '$footer_amended' != frontmatter last_updated '$fm_updated' — governance bookkeeping drift"
        fi
        sir_ver="$(grep -E '^Version change:' "$f" | head -1 | sed -E 's/.*→[[:space:]]*([0-9.]+).*/\1/' || true)"
        if [ -n "$sir_ver" ] && [ "$sir_ver" != "$footer_ver" ]; then
          report "$f: Sync Impact Report targets version '$sir_ver' but footer says '$footer_ver' — governance bookkeeping drift"
        fi
      fi
    fi

    # An artifact is renderable when it declares diagram_type (the literal
    # Mermaid diagram-type declaration — /ardd-diagram). Renderability is a
    # property, not a fixed name-list: there is no RENDERABLE_ARTIFACTS set and
    # no enum of diagram types (an invalid type surfaces at render, not here).
    # diagram_status is required once diagram_type is present, and enum-checked
    # whenever present.
    if frontmatter_has "$f" diagram_type && ! frontmatter_has "$f" diagram_status; then
      report "$f: missing required frontmatter field 'diagram_status' (required when diagram_type is present)"
    fi
    if frontmatter_has "$f" diagram_status; then
      val="$(frontmatter_field "$f" diagram_status)"
      if ! in_enum "$val" $DIAGRAM_STATUS_ENUM; then
        report "$f: diagram_status '$val' not in {$DIAGRAM_STATUS_ENUM}$SKEW_HINT"
      fi
    fi

    # diagram_type / render_hint / render_target / render_section are the
    # optional per-artifact render fields for /ardd-diagram. All are free-form
    # strings, so there's no enum to check — only that a present field isn't
    # empty (an empty value would silently fall back to a default or make a
    # non-renderable artifact look renderable, masking a typo). Validated on
    # any artifact that carries them.
    for rfield in diagram_type render_hint render_target render_section; do
      if frontmatter_has "$f" "$rfield"; then
        val="$(frontmatter_field "$f" "$rfield")"
        if [ -z "$val" ]; then
          report "$f: $rfield is present but empty — give it a value or remove the field"
        fi
      fi
    done
  done

  # --- feature register ---------------------------------------------
  # Per-feature files (.project/features/<slug>.md) are the register of
  # record (constitution standing decision, 2026-07-06). The single-file
  # artifacts/features.md branch below is retained ONLY for projects that
  # predate migration 0003-per-feature-files — install.sh applies the
  # migration on upgrade, so any project with a features/ dir is
  # post-migration and a lingering features.md there is a violation.
  if [ -d "$FEATURES_DIR" ]; then
    if [ -f "$FEATURES_FILE" ]; then
      report "$FEATURES_FILE: legacy single-file register coexists with $FEATURES_DIR/ — run migration 0003-per-feature-files (re-run install.sh) and remove features.md"
    fi
    for f in "$FEATURES_DIR"/*.md; do
      [ -f "$f" ] || continue
      fslug="$(basename "$f" .md)"
      if ! frontmatter_has "$f" slug; then
        report "$f: missing required frontmatter field 'slug'"
      else
        val="$(frontmatter_field "$f" slug)"
        if [ "$val" != "$fslug" ]; then
          report "$f: frontmatter slug '$val' does not match filename '$fslug'"
        fi
      fi
      if ! frontmatter_has "$f" status; then
        report "$f: missing required frontmatter field 'status'"
      else
        val="$(frontmatter_field "$f" status)"
        if ! in_enum "$val" $FEATURE_STATUS_ENUM; then
          report "$f: status '$val' not in {$FEATURE_STATUS_ENUM}$SKEW_HINT"
        fi
      fi
      if ! frontmatter_has "$f" logged; then
        report "$f: missing required frontmatter field 'logged'"
      fi
      if frontmatter_has "$f" plan; then
        ref="$(frontmatter_field "$f" plan)"
        if [ -n "$ref" ] && [ ! -f "$PROJECT_DIR/plans/$ref" ]; then
          report "$f: plan reference '$ref' — no $PROJECT_DIR/plans/$ref"
        fi
      fi
      if frontmatter_has "$f" tasks; then
        ref="$(frontmatter_field "$f" tasks)"
        if [ -n "$ref" ] && [ ! -f "$PROJECT_DIR/tasks/$ref" ]; then
          report "$f: tasks reference '$ref' — no $PROJECT_DIR/tasks/$ref"
        fi
      fi
      if frontmatter_has "$f" gh_issue; then
        val="$(frontmatter_field "$f" gh_issue)"
        case "$val" in
          ''|*[!0-9]*) report "$f: gh_issue '$val' is not a number" ;;
        esac
      fi
    done
  elif [ -f "$FEATURES_FILE" ]; then
    # Legacy pre-0003 single-file register.
    features_file="$FEATURES_FILE"
    if ! frontmatter_has "$features_file" last_updated; then
      report "$features_file: missing required frontmatter field 'last_updated'"
    fi
    grep -oE '_Slug: `[^`]+` · Status: [a-z]+' "$features_file" | while IFS= read -r line; do
      slug="$(printf '%s' "$line" | sed -E 's/_Slug: `([^`]+)`.*/\1/')"
      val="$(printf '%s' "$line" | sed -E 's/.*Status: ([a-z]+)$/\1/')"
      if ! in_enum "$val" $FEATURE_STATUS_ENUM; then
        echo "$features_file: feature '$slug' status '$val' not in {$FEATURE_STATUS_ENUM}$SKEW_HINT"
        echo 1 > "$SENTINEL"
      fi
    done
    grep -E '_Slug: `' "$features_file" | while IFS= read -r line; do
      slug="$(printf '%s' "$line" | sed -E 's/.*_Slug: `([^`]+)`.*/\1/')"
      planref="$(printf '%s' "$line" | grep -oE 'Plan: [^·_]+' | sed -E 's/^Plan:[[:space:]]*//; s/[[:space:]]+$//')"
      tasksref="$(printf '%s' "$line" | grep -oE 'Tasks: [^·_]+' | sed -E 's/^Tasks:[[:space:]]*//; s/[[:space:]]+$//')"
      if [ -n "$planref" ] && [ ! -f "$PROJECT_DIR/plans/$planref" ]; then
        echo "$features_file: feature '$slug' Plan reference '$planref' — no $PROJECT_DIR/plans/$planref"
        echo 1 > "$SENTINEL"
      fi
      if [ -n "$tasksref" ] && [ ! -f "$PROJECT_DIR/tasks/$tasksref" ]; then
        echo "$features_file: feature '$slug' Tasks reference '$tasksref' — no $PROJECT_DIR/tasks/$tasksref"
        echo 1 > "$SENTINEL"
      fi
    done
  fi
fi

# --- plans/plan-*.md ----------------------------------------------------
if [ -d "$PROJECT_DIR/plans" ]; then
  # Accumulates every slug listed in a non-superseded plan's `features:`, to
  # catch the same slug claimed by two live plans (checked after the loop).
  live_plan_slugs=""
  for f in "$PROJECT_DIR"/plans/plan-*.md; do
    [ -f "$f" ] || continue
    for field in status branch created; do
      if ! frontmatter_has "$f" "$field"; then
        report "$f: missing required frontmatter field '$field'"
      fi
    done
    plan_status=""
    if frontmatter_has "$f" status; then
      val="$(frontmatter_field "$f" status)"
      plan_status="$val"
      if ! in_enum "$val" $PLAN_STATUS_ENUM; then
        report "$f: status '$val' not in {$PLAN_STATUS_ENUM}$SKEW_HINT"
      fi
    fi

    # --- features: [...] slugs must exist in features.md ---
    if frontmatter_has "$f" features; then
      featval="$(frontmatter_field "$f" features)"
      inner="$(printf '%s' "$featval" | sed -E 's/^\[//; s/\]$//')"
      if [ -n "$inner" ]; then
        old_ifs="$IFS"
        IFS=','
        for raw in $inner; do
          IFS="$old_ifs"
          slug="$(printf '%s' "$raw" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
          if [ -n "$slug" ]; then
            if [ "$plan_status" != "superseded" ]; then
              live_plan_slugs="$live_plan_slugs $slug"
            fi
            if ! feature_exists "$slug"; then
              echo "$f: features slug '$slug' not found in the feature register"
              echo 1 > "$SENTINEL"
            elif [ "$plan_status" = "approved" ] || [ "$plan_status" = "superseded" ]; then
              # --- an approved/superseded plan's feature must have moved past backlogged ---
              feature_status="$(feature_status_of "$slug")"
              if [ "$feature_status" = "backlogged" ]; then
                echo "$f: plan is '$plan_status' but features slug '$slug' is still 'backlogged' in the register — a bookkeeping sequence was likely interrupted (see /ardd-plan step 11)"
                echo 1 > "$SENTINEL"
              fi
            fi
          fi
          IFS=','
        done
        IFS="$old_ifs"
      fi
    fi
  done

  # --- same slug listed in two non-superseded (draft/approved) plans ---
  # Two live plans independently targeting the same feature — the pure
  # file-based fingerprint of two branches that each planned it. A superseded
  # plan is excluded above, so sharing a slug with one is fine.
  for slug in $(printf '%s\n' $live_plan_slugs | sort | uniq -d); do
    report "duplicate feature slug '$slug' — listed in the features: of more than one non-superseded plan; two live plans target the same feature (supersede one, see /ardd-plan step 7)"
  done
fi

# --- tasks/tasks-*.md -----------------------------------------------
if [ -d "$PROJECT_DIR/tasks" ]; then
  for f in "$PROJECT_DIR"/tasks/tasks-*.md; do
    [ -f "$f" ] || continue
    for field in status plan generated; do
      if ! frontmatter_has "$f" "$field"; then
        report "$f: missing required frontmatter field '$field'"
      fi
    done
    if frontmatter_has "$f" status; then
      val="$(frontmatter_field "$f" status)"
      if ! in_enum "$val" $TASKS_STATUS_ENUM; then
        # Pointed messages for invented statuses seen in the wild — each
        # replaces the generic report (one finding, not two). Prefix match
        # on 'reopened': the observed value carried an inline annotation.
        case "$val" in
          reopened*)
            report "$f: status '$val' — completed is terminal; capture post-completion failures with /ardd-feedback and plan them as new work" ;;
          superseded)
            report "$f: status 'superseded' — did you mean 'abandoned'? superseded is a plan status" ;;
          *)
            report "$f: status '$val' not in {$TASKS_STATUS_ENUM}$SKEW_HINT" ;;
        esac
      elif [ "$val" = "generating" ]; then
        report "$f: status is 'generating' — a previous /ardd-plan tasking run likely crashed mid-generation; regenerate or fix manually"
      fi
    fi

    # --- plan: must reference an existing plan file ---
    if frontmatter_has "$f" plan; then
      planref="$(frontmatter_field "$f" plan)"
      if [ -n "$planref" ] && [ ! -f "$PROJECT_DIR/plans/$planref" ]; then
        report "$f: plan '$planref' — no $PROJECT_DIR/plans/$planref"
      fi
    fi
  done
fi

# --- feedback/feedback-*.md ------------------------------------------
if [ -d "$PROJECT_DIR/feedback" ]; then
  for f in "$PROJECT_DIR"/feedback/feedback-*.md; do
    [ -f "$f" ] || continue
    for field in status created plan; do
      if ! frontmatter_has "$f" "$field"; then
        report "$f: missing required frontmatter field '$field'"
      fi
    done
    if frontmatter_has "$f" status; then
      val="$(frontmatter_field "$f" status)"
      if ! in_enum "$val" $FEEDBACK_STATUS_ENUM; then
        if [ "$val" = "split" ]; then
          # Invented status seen in the wild — pointed message replaces
          # the generic report (one finding, not two).
          report "$f: status 'split' — not a status; mark items individually, the file flips to planned when every item is resolved"
        else
          report "$f: status '$val' not in {$FEEDBACK_STATUS_ENUM}$SKEW_HINT"
        fi
      fi
    fi
  done
fi

# --- [artifacts: ...] tags -> artifact file must exist -----------------
if [ -d "$PROJECT_DIR/artifacts" ]; then
  for f in "$PROJECT_DIR"/tasks/tasks-*.md "$PROJECT_DIR"/feedback/feedback-*.md; do
    [ -f "$f" ] || continue
    grep -noE '\[artifacts: [^]]+\]' "$f" | while IFS=: read -r lineno rest; do
      # Both bracket-tag checks (artifact-reference and placeholder-name)
      # apply to checklist item lines only — `- [ ]` / `- [x]` / `- [-]`.
      # A tag mentioned in body prose is prose, not a reference.
      sed -n "${lineno}p" "$f" | grep -qE '^[[:space:]]*- \[[ x-]\]' || continue
      names="$(printf '%s' "$rest" | sed -E 's/^\[artifacts: //; s/\]$//')"
      old_ifs="$IFS"
      IFS=','
      for raw in $names; do
        IFS="$old_ifs"
        n="$(printf '%s' "$raw" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
        if [ "$n" = "none" ] || [ "$n" = "n/a" ]; then
          echo "$f:$lineno: placeholder artifact name '$n' — omit the artifacts bracket-tag entirely when no artifact applies"
          echo 1 > "$SENTINEL"
        elif [ -n "$n" ] && [ ! -f "$PROJECT_DIR/artifacts/$n.md" ]; then
          echo "$f:$lineno: [artifacts: ...] references '$n' — no $PROJECT_DIR/artifacts/$n.md"
          echo 1 > "$SENTINEL"
        fi
        IFS=','
      done
      IFS="$old_ifs"
    done
  done
fi

if [ -s "$SENTINEL" ]; then
  fail=1
fi

if [ "$fail" -eq 1 ]; then
  exit 1
fi

echo "lint-project: clean — frontmatter schemas and [artifacts: ...] references are valid."
exit 0
