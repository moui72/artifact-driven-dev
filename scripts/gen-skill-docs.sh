#!/usr/bin/env sh
# gen-skill-docs.sh — single-source skill documentation (source-side).
# Reads each skills/*/SKILL.md's frontmatter (name/tier/description) and
# regenerates:
#   - README.md's "## Skills" section body (via scripts/upsert-section.sh —
#     that section is OWNED by this generator; edit a skill's frontmatter,
#     not the README table)
#   - docs/reference/skills/<name>.md's generated header — everything up to
#     and including the "generated:end" marker line; the hand-written body
#     below the marker is preserved verbatim (a missing page is scaffolded
#     with an empty body)
#   - docs/reference/skills/README.md — the reference index (full overwrite)
#   - templates/WORKFLOW.md — the static per-target workflow reference
#     install.sh ships
#
# --check regenerates into a temp area and diffs, exiting 1 on drift —
# wired into lint-docs.sh so a description edit that skips regeneration
# fails CI and the pre-commit hook.
#
# Usage: gen-skill-docs.sh [--check]     (run from the repo root)

set -e

MODE="${1:-generate}"

REF_DIR="docs/reference/skills"
MARKER_TAG="generated:end"

fm() { # fm <file> <field> — strips optional surrounding double quotes
  # (descriptions containing colons must be quoted for strict-YAML parsers)
  awk '/^---$/{n++; next} n==1' "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -1 \
    | sed -E 's/^"(.*)"$/\1/'
}

# Editorial workflow order per tier — skills not listed here append after
# the ordered ones, alphabetically, so a new skill can't silently vanish
# from the generated tables.
ORDER_setup="ardd-init"
ORDER_core="ardd-backlog ardd-feedback ardd-refine ardd-plan ardd-implement ardd-status ardd-lint"
ORDER_extension="ardd-defects ardd-audit ardd-research ardd-diagram ardd-tracker ardd-update"

row_for() { # row_for <skill-name> <link-prefix — "" for plain, path for linked>
  f="skills/$1/SKILL.md"
  [ -f "$f" ] || return 0
  n="$(fm "$f" name)"
  if [ -n "$2" ]; then
    printf '| [`/%s`](%s%s.md) | %s |\n' "$n" "$2" "$n" "$(fm "$f" description)"
  else
    printf '| `/%s` | %s |\n' "$n" "$(fm "$f" description)"
  fi
}

table_rows() { # table_rows <tier> <link-prefix>
  case "$1" in
    setup)     ordered="$ORDER_setup" ;;
    core)      ordered="$ORDER_core" ;;
    extension) ordered="$ORDER_extension" ;;
    *)         ordered="" ;;
  esac
  emitted=" "
  for name in $ordered; do
    f="skills/$name/SKILL.md"
    [ -f "$f" ] || continue
    [ "$(fm "$f" tier)" = "$1" ] || continue
    row_for "$name" "$2"
    emitted="$emitted$name "
  done
  for f in skills/*/SKILL.md; do
    name="$(fm "$f" name)"
    case "$emitted" in *" $name "*) continue ;; esac
    [ "$(fm "$f" tier)" = "$1" ] || continue
    row_for "$name" "$2"
  done
}

all_rows() { # all_rows <link-prefix> — every skill, tier order
  table_rows setup "$1"
  table_rows core "$1"
  table_rows extension "$1"
}

skills_body() { # README's "## Skills" section body
  cat <<'EOF'
Every command at a glance — each links to its full reference page under
[docs/reference/skills/](docs/reference/skills/). (This table is generated
from each skill's frontmatter by `scripts/gen-skill-docs.sh` — edit the
`description:` there, then re-run it.)

| Command | What it does |
|---|---|
EOF
  all_rows "docs/reference/skills/"
}

index_body() { # docs/reference/skills/README.md — full file
  cat <<'EOF'
# Skill reference

One page per installed skill: usage, what it reads and writes, behavior
notes, and routing to neighboring skills. Each page's header block is
generated from the skill's frontmatter by `scripts/gen-skill-docs.sh`;
the table below is generated too — edit a skill's `description:` there,
then re-run it.

| Command | What it does |
|---|---|
EOF
  all_rows ""
}

page_header() { # page_header <skill-name> — the generated block incl. marker
  f="skills/$1/SKILL.md"
  printf '# /%s\n\n_Tier: %s_\n\n> %s\n\n' \
    "$(fm "$f" name)" "$(fm "$f" tier)" "$(fm "$f" description)"
  printf '<!-- %s — the header above is generated from skills/%s/SKILL.md frontmatter by scripts/gen-skill-docs.sh; edit the body below by hand -->\n' \
    "$MARKER_TAG" "$1"
}

page_for() { # page_for <skill-name> <existing-page-or-empty> — full page to stdout
  page_header "$1"
  if [ -n "$2" ] && [ -f "$2" ] && grep -q "$MARKER_TAG" "$2"; then
    awk -v tag="$MARKER_TAG" 'found{print} index($0, tag){found=1}' "$2"
  else
    printf '\n_(Hand-written body not yet added.)_\n'
  fi
}

workflow_body() {
  cat <<'EOF'
# Project Workflow Guide

This project uses [artifact-driven-dev (ArDD)](https://github.com/moui72/artifact-driven-dev).
This file is a static reference generated from the installed skill set —
regenerate by re-running install.sh after an ArDD upgrade.

## Skills

| Command | What it does |
|---|---|
EOF
  all_rows ""
  cat <<'EOF'

## Operating mode

`workflow_mode` in `constitution.md`'s frontmatter (one of `solo` |
`collaborative`; absent means `solo`) governs where in-progress work lives.
**Solo**: committing to your local default branch is fine for inline runs;
delegated runs use an isolated worktree and merge back on completion. **Collaborative**: nothing lands on the local default branch — work moves to
a branch and, after the first commit, the skill offers to push and open a
draft PR titled with the feature slug, which is the shared in-flight signal.

See `STATUS.md` for current artifact statuses, open questions, and the
recommended next step. Artifacts live in `.project/artifacts/`; the
feature register in `.project/features/`.
EOF
}

skill_names() { # every skill name, in tier order
  for tier in setup core extension; do
    table_rows "$tier" "" | sed -E 's/^\| \[?`\/([a-z0-9-]+)`.*/\1/'
  done
}

gen_readme() { # gen_readme <file>
  skills_body | sh scripts/upsert-section.sh "$1" "Skills" 2>/dev/null
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
  gen_readme "$TMP/README.md"
  if ! diff -q "$TMP/README.md" README.md >/dev/null 2>&1; then
    echo "gen-skill-docs: README.md Skills table drifted from SKILL.md frontmatter — run scripts/gen-skill-docs.sh" >&2
    rc=1
  fi
  index_body > "$TMP/index.md"
  if ! diff -q "$TMP/index.md" "$REF_DIR/README.md" >/dev/null 2>&1; then
    echo "gen-skill-docs: $REF_DIR/README.md drifted from SKILL.md frontmatter — run scripts/gen-skill-docs.sh" >&2
    rc=1
  fi
  for name in $(skill_names); do
    page_for "$name" "$REF_DIR/$name.md" > "$TMP/page.md"
    if ! diff -q "$TMP/page.md" "$REF_DIR/$name.md" >/dev/null 2>&1; then
      echo "gen-skill-docs: $REF_DIR/$name.md header drifted from SKILL.md frontmatter (or the page is missing) — run scripts/gen-skill-docs.sh" >&2
      rc=1
    fi
  done
  exit "$rc"
fi

# Apply twice: the first pass may APPEND a missing section (which adds a
# separating blank line the REPLACE path doesn't reproduce); the second
# pass runs in replace mode and normalizes spacing, so --check (which
# always replaces) diffs cleanly against the committed file.
gen_readme README.md
gen_readme README.md
mkdir -p templates "$REF_DIR"
workflow_body > templates/WORKFLOW.md
index_body > "$REF_DIR/README.md"
for name in $(skill_names); do
  page_for "$name" "$REF_DIR/$name.md" > "$REF_DIR/.$name.md.tmp"
  mv "$REF_DIR/.$name.md.tmp" "$REF_DIR/$name.md"
done
echo "gen-skill-docs: README.md Skills table, $REF_DIR/, and templates/WORKFLOW.md regenerated"
