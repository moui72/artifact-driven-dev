#!/usr/bin/env sh
# Migration 0003: split the legacy single-file feature register
# (.project/artifacts/features.md) into per-feature files at
# .project/features/<slug>.md — the register of record per the
# constitution's 2026-07-06 standing decision.
#
# Parses each entry's `_Slug: ... · Status: ... · Logged ...` metadata
# line one final time, carrying Plan:/Tasks:/GH: fields into frontmatter
# (plan:/tasks:/gh_issue:) and everything between the metadata line and
# the next `## ` heading into the body. The legacy file is REMOVED, not
# stubbed: lint-project.sh treats a features.md coexisting with
# .project/features/ as a violation, so a stub would fail every
# subsequent lint.
#
# Idempotent: if features.md is absent (already migrated, or the project
# never had a register), exits 0 silently.

TARGET="${1:-.}"
LEGACY="$TARGET/.project/artifacts/features.md"
OUTDIR="$TARGET/.project/features"

[ -f "$LEGACY" ] || exit 0

mkdir -p "$OUTDIR"

awk -v outdir="$OUTDIR" '
  function flush() {
    if (slug == "") return
    f = outdir "/" slug ".md"
    print "---" > f
    print "slug: " slug >> f
    print "status: " status >> f
    print "logged: " logged >> f
    if (plan != "")  print "plan: " plan >> f
    if (tasks != "") print "tasks: " tasks >> f
    if (gh != "")    print "gh_issue: " gh >> f
    print "---" >> f
    print "" >> f
    # trim trailing blank lines from the captured body
    while (nbody > 0 && body[nbody] == "") nbody--
    for (i = 1; i <= nbody; i++) print body[i] >> f
    close(f)
    printf "  - %s.md (%s)\n", slug, status
    slug = ""; status = ""; logged = ""; plan = ""; tasks = ""; gh = ""
    nbody = 0; inbody = 0
  }
  /^## / { flush(); next }
  /^_Slug: / {
    line = $0
    slug = line;   sub(/.*_Slug: `/, "", slug);   sub(/`.*/, "", slug)
    status = line; sub(/.*· Status: /, "", status); sub(/ ·.*/, "", status); sub(/_$/, "", status)
    logged = line; sub(/.*· Logged /, "", logged); sub(/ ·.*/, "", logged); sub(/_$/, "", logged)
    plan = ""; tasks = ""; gh = ""
    if (line ~ /· Plan: /)  { plan = line;  sub(/.*· Plan: /, "", plan);   sub(/ ·.*/, "", plan);  sub(/_$/, "", plan) }
    if (line ~ /· Tasks: /) { tasks = line; sub(/.*· Tasks: /, "", tasks); sub(/ ·.*/, "", tasks); sub(/_$/, "", tasks) }
    if (line ~ /· GH: /)    { gh = line;    sub(/.*· GH: #?/, "", gh);     sub(/ ·.*/, "", gh);    sub(/_$/, "", gh) }
    inbody = 1
    next
  }
  inbody { body[++nbody] = $0 }
  END { flush() }
' "$LEGACY"

rm -f "$LEGACY"
echo "  - removed legacy $LEGACY"
