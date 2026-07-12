---
name: ardd-lint
tier: core
description: "Fast, deterministic check of .project/ frontmatter schemas and [artifacts: ...] references — no LLM judgment."
---

# /ardd-lint

Deterministic, non-LLM check of `.project/` state: frontmatter `status`
fields are valid values, required frontmatter fields are present, and
`[artifacts: ...]` tags on tasks/feedback lines reference artifact files that
actually exist. This is a fast structural check, not a substitute for
`/ardd-status` — it catches malformed bookkeeping (a typo'd status, a
missing field, a stale reference), not whether the decisions themselves are
consistent or good.

Usage: `/ardd-lint` — takes no arguments, always checks the current project's
`.project/` directory.

## Steps

1. **Run the bundled script**: `.claude/skills/ardd-scripts/lint-project.sh`
   (installed by `install.sh` — if missing, tell the user to re-run
   `install.sh` to pick it up).

2. **Report the result verbatim.** The script prints one line per violation
   (file, and what's wrong) and exits non-zero if anything failed, or a
   single clean-confirmation line and exit 0 otherwise. Don't reinterpret or
   summarize findings — surface them as-is so the file:line-style output stays
   directly actionable.

3. **If violations were found**, suggest `/ardd-refine <artifact>` for a bad
   artifact frontmatter field, or editing the specific tasks/feedback/plan
   file directly for the others — this skill only reports, it never writes.
