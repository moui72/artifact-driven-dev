---
plan: plan-docs-sweep-2026-07-18-b6ef.md
generated: 2026-07-18
status: in-progress
---

# Tasks

## Phase 1: `docs-sweep` skill file
- [x] T001 Create `.claude/skills/docs-sweep/SKILL.md` with frontmatter
  (`name: docs-sweep`, `description:` leading with "Source-side only
  (never installed to consumers)." plus a one-line summary of what it
  checks and its triage-to-feedback ending), mirroring
  `.claude/skills/prerelease-sweep/SKILL.md`'s frontmatter shape (read
  that file first).
- [x] T002 Write the scope-resolution step in the new SKILL.md: default =
  skills changed since the last stable release tag
  (`git log --oneline <last-stable-tag>..HEAD -- skills/`), with an
  explicit `--all` argument for a full sweep of every skill regardless of
  recent changes. Handle the no-stable-tag-yet case sensibly (fall back
  to full sweep, noting why) rather than erroring.
- [x] T003 Write the per-skill judgment procedure in the new SKILL.md:
  for each in-scope skill, read its `SKILL.md` in full; read its
  `docs/reference/skills/<name>.md` hand-written body (below
  `generated:end`) if that file exists (skip for local-only skills, which
  have none); judge whether the body accurately and completely describes
  the skill's current modes/flags/behavior, noting specific gaps with
  file:line citations rather than vague staleness claims. Also check
  `USAGE.md`'s command table/routing and `docs/concepts.md`'s narrative
  for whether the skill (and any new mode/flag) is represented,
  explicitly noting that both docs are deliberately selective — an
  absence isn't automatically a gap, it needs a user-visibility judgment
  call. Also spot-check `README.md` for staleness against the current
  skill list/workflow description.
- [x] T004 Write the triage/report step in the new SKILL.md: present
  findings as one table (skill/file, gap, suggested fix), same shape as
  `prerelease-sweep`'s scenario-report triage; accept/decline per item;
  accepted items get filed as `/ardd-feedback` entries. State explicitly
  that there is no durable per-run report file (unlike
  `prerelease-sweep`'s `dev-notes/prerelease-runs/`) — the only durable
  output is whatever `/ardd-feedback` items result from the triage.

## Phase 2: Cross-references
- [x] T005 [parallel] Add a one-line pointer in `CONTRIBUTING.md`'s
  "Releases" section naming `docs-sweep` as a companion manual check to
  run before a stable release. Read that section first — if it's silent
  on `prerelease-sweep` too, add pointers for both in one consistent
  style rather than introducing an asymmetry between the two local-only
  skills.
- [x] T006 [parallel] Add a one-line pointer at the end of
  `.claude/skills/prerelease-sweep/SKILL.md`'s triage-ending prose noting
  `docs-sweep` as a companion check for the human-facing doc surface.

## Phase 3: First real dogfood run
- [ ] T007 Manually invoke `/docs-sweep` (as built by T001–T004) against
  this repo's own current state and report its findings. Do not
  auto-apply fixes — confirm the new skill produces a coherent,
  correctly-scoped triage table (sanity-check its own output, don't
  independently re-derive the drift), not fix every finding. File
  genuinely accepted findings via `/ardd-feedback` per the skill's own
  triage step; record which findings were filed (if any) as this task's
  completion note. The research report
  (`research-docs-freshness-human-facing-2026-07-18.md`) already cites
  concrete candidates (epics undocumented in `/ardd-status`'s by-epic
  breakdown and `/ardd-tracker`'s milestone mapping; `/ardd-plan --slate`
  unrouted in `USAGE.md`/`core-loop.md`) — expect the sweep to surface at
  least these; treat their absence from the sweep's output as a signal
  the procedure itself needs another look, not that they were already
  fixed.
