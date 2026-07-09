---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: npx-skills-install
created: 2026-07-09
features: [npx-skills-install]
surfaced-defects: []
---

# Plan: npx-skills-install

## Goal

Make ARDD acquirable via `npx skills add <owner>/artifact-driven-dev`
(vercel-labs skills CLI), with that path converging onto `install.sh`
through a new `/ardd-setup` skill — per the constitution's standing
decision (v1.2.2): install.sh stays the only real install/upgrade entry
point.

## Scope

**In:** SKILL.md frontmatter compatibility with the CLI's discovery
(`name` + `description`); the new `/ardd-setup` skill; an install.sh
symlink-detection warning; docs (npx quick start, copy-mode
recommendation); live verification of the npx path.

**Out:** reimplementing any install.sh behavior in the npx channel
(constitution standing decision); publishing to npm (the CLI pulls
straight from GitHub — nothing to publish); supporting the CLI's
symlink mode (docs steer to copy mode; install.sh warns if it finds
symlinks).

## Technical Approach

- **CLI behavior (researched 2026-07-09):** `npx skills add <owner>/<repo>`
  discovers `SKILL.md` files under `skills/` (frontmatter `name` +
  `description` required) and copies or symlinks each skill dir into
  `.claude/skills/` — project scope by default. No install scripts, no
  migrations, no post-install steps. So the npx channel delivers the 20
  skill files and nothing else install.sh does (non-skill reference
  dirs, migrations + `.ardd-applied`, `.project/ardd-version.md`,
  `.worktreeinclude`, gitignore checks) — an npx-only install breaks on
  the first `ardd-scripts` call.
- **Convergence design:** `/ardd-setup` is the bridge. It ships as a
  normal skill (so the npx channel delivers it too), detects an
  incomplete install (no `.claude/skills/ardd-scripts/` or no
  `.project/ardd-version.md`), locates or clones the ARDD source
  checkout, runs `./install.sh <project>` from it, and relays the
  output. After it runs once, `install.sh` has recorded the source path
  in `ardd-version.md` and `/ardd-update` handles everything
  thereafter — the two channels are indistinguishable from that point.
  `/ardd-setup` on an already-complete install reports that and defers
  to `/ardd-update` (no overlap between the two skills' jobs).
- **Source checkout location:** suggest `~/.ardd/source` as the default
  clone destination, but always ask the user (they may already have a
  checkout — offer to use an existing path instead of cloning).
  Judgment stays prose; the clone/pull commands are plain git, no
  custom script (Principle VIII).
- **Symlink guard:** docs recommend the CLI's copy mode; belt-and-braces,
  `install.sh` gains a check that warns (not fails) when an existing
  `.claude/skills/ardd-*` entry is a symlink — regenerating through a
  symlink would write into the CLI's cache instead of the project.

## Phase Breakdown

### Phase 1 — CLI compatibility (test-first)

- [ ] T001 Verify every `skills/*/SKILL.md` has frontmatter `name` and
  `description` matching what the skills CLI requires; add any missing
  `name:` fields. Extend `scripts/lint-docs.sh` to enforce
  name+description frontmatter on every skill file (source-side check,
  Principle IV) with a red-first fixture/regression case per Principle V.

### Phase 2 — /ardd-setup skill [feature: npx-skills-install]

- [ ] T002 Write `skills/ardd-setup/SKILL.md`: detect incomplete install
  (missing `.claude/skills/ardd-scripts/` or `.project/ardd-version.md`);
  if complete, report and defer to `/ardd-update`; otherwise ask the user
  for an existing source checkout or offer to clone to `~/.ardd/source`
  (never clone without confirmation), run `./install.sh <project>`, relay
  output verbatim (including gitignore suggestions), and end with the
  standard `/ardd-analyze` handoff only if a `.project/` exists.
- [ ] T003 Register `ardd-setup` in `scripts/gen-skill-docs.sh` (README's
  skill sections are generated — hand-edits fail lint-docs drift check)
  and regenerate README/WORKFLOW.md.
- [ ] T004 `install.sh`: warn (never fail) when an existing
  `.claude/skills/ardd-*` entry is a symlink, naming the CLI's copy mode
  as the fix. Test-first: fixture case in the install.sh regression test
  with a symlinked skill dir, red before implementation.

### Phase 3 — docs + live verification

- [ ] T005 README.md + USAGE.md: npx quick start (`npx skills add` →
  `/ardd-setup`), copy-mode-not-symlink note, and the standing decision
  (npx = acquisition only; install.sh = the installer). `lint-docs.sh`
  must pass.
- [ ] T006 Live verification (manual, network-dependent): in a throwaway
  target project, run `npx skills add <this repo>` (copy mode), confirm
  the skills land in `.claude/skills/`, then run `/ardd-setup` and
  confirm it completes the install (reference dirs present,
  `ardd-version.md` recorded, `.worktreeinclude` updated) and that
  `/ardd-update` works thereafter. Record findings in the tasks file
  notes; no CI job (network + interactive — same reasoning as the
  smoke-test tier's gating).

## Complexity Tracking

None — one new skill, one lint extension, one install.sh warning; no new
abstractions or state.

## Open Questions

None blocking. (The default clone path `~/.ardd/source` is a suggestion
surfaced to the user at setup time, not a hard convention — revisit only
if it proves confusing in T006.)

## Production Annotation Summary

None.
