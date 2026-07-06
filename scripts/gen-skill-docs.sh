#!/usr/bin/env sh
# gen-skill-docs.sh — single-source skill documentation (source-side).
# Reads each skills/*/SKILL.md's frontmatter (name/tier/description) and
# regenerates:
#   - README.md's "## The core loop" and "## Extensions" section bodies
#     (via scripts/upsert-section.sh — those two sections are OWNED by
#     this generator; edit a skill's frontmatter, not the README table)
#   - templates/WORKFLOW.md — the static per-target workflow reference
#     install.sh ships (bootstrap/codify cp it; they no longer embed it)
#
# --check regenerates into a temp area and diffs, exiting 1 on drift —
# wired into lint-docs.sh so a description edit that skips regeneration
# fails CI and the pre-commit hook.
#
# Usage: gen-skill-docs.sh [--check]     (run from the repo root)

set -e

MODE="${1:-generate}"

fm() { # fm <file> <field>
  awk '/^---$/{n++; next} n==1' "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -1
}

table_rows() { # table_rows <tier>
  for f in skills/*/SKILL.md; do
    name="$(fm "$f" name)"
    tier="$(fm "$f" tier)"
    desc="$(fm "$f" description)"
    [ "$tier" = "$1" ] || continue
    printf '| `/%s` | %s |\n' "$name" "$desc"
  done
}

core_body() {
  cat <<'EOF'
The skills that carry a project from decisions to shipped code — this is
the workflow; everything else is opt-in. (This table is generated from
each skill's frontmatter by `scripts/gen-skill-docs.sh` — edit the
`description:` there, then re-run it.)

| Command | What it does |
|---|---|
EOF
  table_rows core
  cat <<'EOF'

`/ardd-analyze` (cross-artifact consistency) runs automatically as the
final step of most state-changing skills, so it isn't a step you have to
remember — run it by hand anytime for a fresh check.
EOF
}

ext_body() {
  cat <<'EOF'
Opt-in skills for concerns the core loop doesn't force on you.
(Generated — see note under The core loop.)

| Command | What it does |
|---|---|
EOF
  table_rows extension
}

workflow_body() {
  cat <<'EOF'
# Project Workflow Guide

This project uses [artifact-driven-dev (ARDD)](https://github.com/moui72/artifact-driven-dev).
This file is a static reference generated from the installed skill set —
regenerate by re-running install.sh after an ARDD upgrade.

## Skills

| Command | What it does |
|---|---|
EOF
  table_rows core
  table_rows extension
  cat <<'EOF'

See `STATUS.md` for current artifact statuses, open questions, and the
recommended next step. Artifacts live in `.project/artifacts/`; the
feature register in `.project/features/`.
EOF
}

if [ "$MODE" = "--check" ]; then
  rc=0
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  workflow_body > "$TMP/WORKFLOW.md"
  if ! diff -q "$TMP/WORKFLOW.md" templates/WORKFLOW.md >/dev/null 2>&1; then
    echo "gen-skill-docs: templates/WORKFLOW.md drifted from SKILL.md frontmatter — run scripts/gen-skill-docs.sh" >&2
    rc=1
  fi
  cp README.md "$TMP/README.md"
  core_body | sh scripts/upsert-section.sh "$TMP/README.md" "The core loop" 2>/dev/null
  ext_body  | sh scripts/upsert-section.sh "$TMP/README.md" "Extensions" 2>/dev/null
  if ! diff -q "$TMP/README.md" README.md >/dev/null 2>&1; then
    echo "gen-skill-docs: README.md skill tables drifted from SKILL.md frontmatter — run scripts/gen-skill-docs.sh" >&2
    rc=1
  fi
  exit "$rc"
fi

# Apply twice: the first pass may APPEND a missing section (which adds a
# separating blank line the REPLACE path doesn't reproduce); the second
# pass runs in replace mode and normalizes spacing, so --check (which
# always replaces) diffs cleanly against the committed file.
core_body | sh scripts/upsert-section.sh README.md "The core loop" 2>/dev/null
ext_body  | sh scripts/upsert-section.sh README.md "Extensions" 2>/dev/null
core_body | sh scripts/upsert-section.sh README.md "The core loop" 2>/dev/null
ext_body  | sh scripts/upsert-section.sh README.md "Extensions" 2>/dev/null
mkdir -p templates
workflow_body > templates/WORKFLOW.md
echo "gen-skill-docs: README.md sections + templates/WORKFLOW.md regenerated"
