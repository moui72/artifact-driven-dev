---
name: ardd-setup
tier: setup
description: Complete an npx-acquired install — locate or clone the ARDD source checkout and run install.sh from it.
---

# /ardd-setup

Turn a skills-only acquisition into a real ARDD install. `npx skills add`
(the vercel-labs skills CLI) copies only the `SKILL.md` directories into
`.claude/skills/` — it cannot run migrations, create the non-skill
reference directories (`ardd-scripts`, `ardd-artifact-templates`,
`ardd-constitution-data`), record `.project/ardd-version.md`, or maintain
`.worktreeinclude`. Until `install.sh` runs, most skills break on their
first `ardd-scripts` call. This skill bridges that gap once; `install.sh`
remains the only real install/upgrade entry point (constitution standing
decision, 2026-07-09) — `/ardd-setup` never reimplements any part of it.

Not to be confused with `/ardd-update` — that updates an already-complete
install from its recorded source path. `/ardd-setup` is for the first run,
before any source path has been recorded.

## Steps

1. **Detect install completeness.** The install is complete when both
   `.claude/skills/ardd-scripts/` and `.project/ardd-version.md` exist in
   the current project. If both exist, report that the install is already
   complete and point the user at `/ardd-update` for updates — stop here.

2. **Locate the ARDD source.** Ask the user whether they already have an
   ARDD source checkout (a clone of
   `https://github.com/moui72/artifact-driven-dev`):
   - If yes, take the path they give. Verify it looks like an ARDD
     checkout — `install.sh` and `skills/` exist at its top level. If it
     doesn't, stop and ask rather than guessing at a different directory.
   - If no, offer to clone to `~/.ardd/source` (a suggestion, not a hard
     convention — any path they prefer works). **Never clone or overwrite
     anything without explicit confirmation.** If the target directory
     already exists, inspect it: an existing ARDD checkout gets reused (offer
     a `git pull` first); anything else stops with a report — pick another
     path rather than writing into a directory this skill doesn't own.

   Plain `git clone` / `git pull` — no custom script wraps this.

3. **Run the installer.** From the source checkout, run
   `./install.sh <absolute path to the current project>` and relay its
   output **verbatim** — including migration lines, the `.gitignore`
   suggestion, badge suggestion, and any warnings. That output is the
   user's only view of what install-time housekeeping happened; don't
   summarize it away. This records the source path in
   `.project/ardd-version.md`, so `/ardd-update` handles everything from
   now on — after this run, an npx-acquired install and a clone-first
   install are indistinguishable.

4. **Point at the next step** (plain text, user's call — not a skill
   invocation): a project with no `.project/` directory starts with
   `/ardd-bootstrap` (or `/ardd-codify` for an existing codebase); a
   project that already has `.project/` runs `/ardd-analyze` to verify
   everything looks right.
