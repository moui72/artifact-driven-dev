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
#   - a tasks file stuck at `status: generating` (a crashed /ardd-tasks run)
#     is flagged rather than silently accepted as a valid enum value
#   - an approved/superseded plan whose `features:` slugs are still
#     `backlogged` in features.md — the fingerprint an approval sequence
#     interrupted between the plan-status flip and the feature-status flip
#     would leave (see /ardd-tasks step 2)
#
# Deliberately NOT validated: critique.md, DEFECTS.md, SYNC.md, and STATUS.md.
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
PROJECT_DIR="$TARGET/.project"
FEATURES_FILE="$PROJECT_DIR/artifacts/features.md"

fail=0
report() {
  echo "$1"
  fail=1
}

# --- Schema of record -------------------------------------------------
ARTIFACT_STATUS_ENUM="draft stable"
DIAGRAM_STATUS_ENUM="unrendered stale current"
RENDERABLE_ARTIFACTS="datamodel infrastructure ui"
PLAN_STATUS_ENUM="draft approved superseded"
TASKS_STATUS_ENUM="generating ready in-progress completed abandoned"
FEEDBACK_STATUS_ENUM="open planned"
FEATURE_STATUS_ENUM="backlogged planned tasked implemented"
WORKFLOW_MODE_ENUM="solo collaborative"
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
        report "$f: status '$val' not in {$ARTIFACT_STATUS_ENUM}"
      fi
    fi

    if ! frontmatter_has "$f" last_updated; then
      report "$f: missing required frontmatter field 'last_updated'"
    fi

    if [ "$name" = "constitution" ] && frontmatter_has "$f" workflow_mode; then
      val="$(frontmatter_field "$f" workflow_mode)"
      if ! in_enum "$val" $WORKFLOW_MODE_ENUM; then
        report "$f: workflow_mode '$val' not in {$WORKFLOW_MODE_ENUM}"
      fi
    fi

    if in_enum "$name" $RENDERABLE_ARTIFACTS; then
      if ! frontmatter_has "$f" diagram_status; then
        report "$f: missing required frontmatter field 'diagram_status'"
      else
        val="$(frontmatter_field "$f" diagram_status)"
        if ! in_enum "$val" $DIAGRAM_STATUS_ENUM; then
          report "$f: diagram_status '$val' not in {$DIAGRAM_STATUS_ENUM}"
        fi
      fi
    fi
  done

  # --- features.md: last_updated in frontmatter, Status: per entry ---
  features_file="$FEATURES_FILE"
  if [ -f "$features_file" ]; then
    if ! frontmatter_has "$features_file" last_updated; then
      report "$features_file: missing required frontmatter field 'last_updated'"
    fi
    grep -oE '_Slug: `[^`]+` · Status: [a-z]+' "$features_file" | while IFS= read -r line; do
      slug="$(printf '%s' "$line" | sed -E 's/_Slug: `([^`]+)`.*/\1/')"
      val="$(printf '%s' "$line" | sed -E 's/.*Status: ([a-z]+)$/\1/')"
      if ! in_enum "$val" $FEATURE_STATUS_ENUM; then
        echo "$features_file: feature '$slug' status '$val' not in {$FEATURE_STATUS_ENUM}"
        echo 1 > "$TARGET/.lint-project-failed"
      fi
    done

    # --- Plan:/Tasks: metadata fields must reference existing files ---
    grep -E '_Slug: `' "$features_file" | while IFS= read -r line; do
      slug="$(printf '%s' "$line" | sed -E 's/.*_Slug: `([^`]+)`.*/\1/')"
      planref="$(printf '%s' "$line" | grep -oE 'Plan: [^·_]+' | sed -E 's/^Plan:[[:space:]]*//; s/[[:space:]]+$//')"
      tasksref="$(printf '%s' "$line" | grep -oE 'Tasks: [^·_]+' | sed -E 's/^Tasks:[[:space:]]*//; s/[[:space:]]+$//')"
      if [ -n "$planref" ] && [ ! -f "$PROJECT_DIR/plans/$planref" ]; then
        echo "$features_file: feature '$slug' Plan reference '$planref' — no $PROJECT_DIR/plans/$planref"
        echo 1 > "$TARGET/.lint-project-failed"
      fi
      if [ -n "$tasksref" ] && [ ! -f "$PROJECT_DIR/tasks/$tasksref" ]; then
        echo "$features_file: feature '$slug' Tasks reference '$tasksref' — no $PROJECT_DIR/tasks/$tasksref"
        echo 1 > "$TARGET/.lint-project-failed"
      fi
    done
  fi
fi

# --- plans/plan-*.md ----------------------------------------------------
if [ -d "$PROJECT_DIR/plans" ]; then
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
        report "$f: status '$val' not in {$PLAN_STATUS_ENUM}"
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
            if [ ! -f "$FEATURES_FILE" ] || ! grep -qE "_Slug: \`${slug}\`" "$FEATURES_FILE"; then
              echo "$f: features slug '$slug' not found in $FEATURES_FILE"
              echo 1 > "$TARGET/.lint-project-failed"
            elif [ "$plan_status" = "approved" ] || [ "$plan_status" = "superseded" ]; then
              # --- an approved/superseded plan's feature must have moved past backlogged ---
              feature_status="$(grep -oE "_Slug: \`${slug}\` · Status: [a-z]+" "$FEATURES_FILE" | sed -E 's/.*Status: ([a-z]+)$/\1/')"
              if [ "$feature_status" = "backlogged" ]; then
                echo "$f: plan is '$plan_status' but features slug '$slug' is still 'backlogged' in $FEATURES_FILE — a bookkeeping sequence was likely interrupted (see /ardd-tasks step 2)"
                echo 1 > "$TARGET/.lint-project-failed"
              fi
            fi
          fi
          IFS=','
        done
        IFS="$old_ifs"
      fi
    fi
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
        report "$f: status '$val' not in {$TASKS_STATUS_ENUM}"
      elif [ "$val" = "generating" ]; then
        report "$f: status is 'generating' — a previous /ardd-tasks run likely crashed mid-generation; regenerate or fix manually"
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
        report "$f: status '$val' not in {$FEEDBACK_STATUS_ENUM}"
      fi
    fi
  done
fi

# --- [artifacts: ...] tags -> artifact file must exist -----------------
if [ -d "$PROJECT_DIR/artifacts" ]; then
  for f in "$PROJECT_DIR"/tasks/tasks-*.md "$PROJECT_DIR"/feedback/feedback-*.md; do
    [ -f "$f" ] || continue
    grep -noE '\[artifacts: [^]]+\]' "$f" | while IFS=: read -r lineno rest; do
      names="$(printf '%s' "$rest" | sed -E 's/^\[artifacts: //; s/\]$//')"
      old_ifs="$IFS"
      IFS=','
      for raw in $names; do
        IFS="$old_ifs"
        n="$(printf '%s' "$raw" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
        if [ -n "$n" ] && [ ! -f "$PROJECT_DIR/artifacts/$n.md" ]; then
          echo "$f:$lineno: [artifacts: ...] references '$n' — no $PROJECT_DIR/artifacts/$n.md"
          echo 1 > "$TARGET/.lint-project-failed"
        fi
        IFS=','
      done
      IFS="$old_ifs"
    done
  done
fi

if [ -f "$TARGET/.lint-project-failed" ]; then
  rm -f "$TARGET/.lint-project-failed"
  fail=1
fi

if [ "$fail" -eq 1 ]; then
  exit 1
fi

echo "lint-project: clean — frontmatter schemas and [artifacts: ...] references are valid."
exit 0
