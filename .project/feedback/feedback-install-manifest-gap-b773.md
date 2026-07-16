---
status: open      # open -> planned
created: 2026-07-15
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Bugs
- [ ] F001 `scripts/feature-list.sh` ships in the repo but `install.sh`
  never copies it into a target's `.claude/skills/ardd-scripts/` —
  confirmed via `grep -n feature-list install.sh` (no matches) and by
  inspecting the explicit per-file `cp` manifest around
  `install.sh:169-184`, where every other `ardd-scripts` script has a
  line but `feature-list.sh` doesn't. Reported against v0.10.1-beta.9
  (`bdd553e`), where the script was added for
  `list-mode-for-plan-and-impleme` (beta.8) and extended for
  `epics-grouping-in-feature-regi` (beta.9). Impact: after a clean
  `install.sh` run, `.claude/skills/ardd-scripts/feature-list.sh` is
  absent, so `/ardd-plan --list`, `--epic` filtering, and any other
  consumer of `feature-list.sh` are dead in every installed project —
  the rest of epic grouping (the `epic:` frontmatter field,
  `lint-project.sh` validation, `/ardd-status`'s by-epic breakdown, and
  `/ardd-tracker`'s milestone assignment) is unaffected since those
  live in already-installed skill/script files.

## UX
- [ ] F002 No packaging-manifest test currently asserts that every
  `scripts/*.sh` referenced by a skill (or by CI) is also copied by
  `install.sh` — this exact class of gap (a new script added to a
  feature's implementation, but the explicit `cp` manifest not
  extended in the same commit) would be caught mechanically rather
  than discovered post-release.
