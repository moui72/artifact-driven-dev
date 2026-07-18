---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: docs-sweep
created: 2026-07-18
features: [docs-sweep]
surfaced-defects: []
---

# Plan: docs-sweep

## Goal

Add a new local-only `docs-sweep` skill (never installed to consumers,
same placement as `prerelease-sweep`) that judges whether this repo's
human-facing documentation — `README.md`, `USAGE.md`,
`docs/concepts.md`, `docs/guides/*`, and `docs/reference/skills/*.md`
hand-written bodies — stays current and complete against each skill's
actual current behavior, triaging findings to `/ardd-feedback`.

## Scope

**In scope:**
- New skill file at `.claude/skills/docs-sweep/SKILL.md` — the
  `prerelease-sweep` precedent for a source-side-only skill's placement
  (outside `skills/`, so `install.sh` structurally cannot ship it),
  naming (bare name, no `ardd-` prefix), and description convention
  (leads with "Source-side only (never installed to consumers)").
- The sweep's actual judgment procedure: enumerate skills changed since
  the last stable release tag (or all skills, on request), read each
  changed skill's `SKILL.md` in full, compare against its
  `docs/reference/skills/<name>.md` hand-written body (below
  `generated:end`), `USAGE.md`'s routing table, and `docs/concepts.md`'s
  mental-model narrative; also spot-check `README.md` for staleness
  against the current skill set/workflow. Produce a triage table of
  findings (drift found / already current), ending in the same
  triage-to-`/ardd-feedback` pattern `prerelease-sweep` already uses.
- A one-line pointer in `CONTRIBUTING.md`'s Releases section, and one
  in `prerelease-sweep`'s own triage-ending prose, naming `docs-sweep`
  as a companion manual check before a stable release — mirroring how
  the docs-freshness research report recommended reinforcing the
  release-cadence trigger without new hook/reminder machinery.

**Out of scope:**
- Any deterministic script or CI job — per the research report, the
  mechanizable slice here (do referenced command names exist? are
  generated headers in sync?) is already covered by `lint-docs.sh` +
  `gen-skill-docs.sh --check`. What's left is judgment (does the prose
  accurately and adequately describe current behavior?), which has no
  script oracle — this plan does not attempt to mechanize any part of
  it.
- CI/test-wiring coverage and prerelease-sweep scenario coverage — a
  different concern (deterministic test/CI hygiene), already handled by
  `feedback-ci-migration-tests-unwired-37ee.md` (fixed) and
  `feedback-prerelease-sweep-scenario-gaps-95f6.md` (fixed, via
  `status-view-mode`). An earlier research pass drifted onto this
  tangent before being corrected; this plan does not revisit it.
- A mode of `/ardd-status` or `/ardd-audit` — both are installed,
  target-project-facing skills operating on a *consumer's*
  `.project/artifacts/`; this skill's subject (this source repo's own
  `docs/`) is categorically source-side and has no equivalent surface
  in a target project.
- Actually fixing every drift item this plan's first real dogfood run
  finds (e.g. the epics/`--slate` gaps the research report already
  cites) — those become `/ardd-feedback` items from running the new
  skill, consumed by a later plan, not pre-baked into this one.

## Technical Approach

`docs-sweep` follows `prerelease-sweep`'s established shape for a
local-only skill as a structural template (manual invocation, no
installed footprint, ends in a triage table), but its subject matter is
unrelated (content-accuracy judgment over prose, not dry-run scenario
dispatch) — so its procedure is original, not copied.

Procedure:
1. Resolve scope: default = skills changed since the last stable release
   tag (`git log --oneline <last-stable-tag>..HEAD -- skills/`, or the
   full skill set on the first-ever run / explicit `--all`).
2. For each in-scope skill: read its `SKILL.md` in full. Read its
   `docs/reference/skills/<name>.md` hand-written body (below
   `generated:end`) if that file exists (a local-only skill has none —
   skip). Judge: does the body accurately and completely describe the
   skill's current modes/flags/behavior? Note specific gaps (missing
   mode, stale description, inaccurate claim) with file:line citations,
   never a vague "seems stale."
3. Check `USAGE.md`'s command table/routing and `docs/concepts.md`'s
   narrative for whether the skill (and any new mode/flag) is
   represented there, applying judgment about whether the capability is
   user-visible enough to warrant inclusion (both docs are deliberately
   selective, not exhaustive enumerations — per the research report's
   explicit finding that not every omission is a bug).
4. Spot-check `README.md` for staleness against the current skill
   list/workflow description.
5. Present findings as one triage table (skill/file, gap, suggested
   fix), same shape as `prerelease-sweep`'s scenario-report triage —
   accept/decline per item, accepted items become `/ardd-feedback`
   entries (this repo dogfoods its own `.project/`).
6. No durable per-run report file (unlike `prerelease-sweep`'s
   `dev-notes/prerelease-runs/`) — a docs-sweep run is lighter-weight;
   its only durable output is whatever `/ardd-feedback` items get
   created from the triage.

## Phase Breakdown

### Phase 1: `docs-sweep` skill file
Depends on: —
- T001: Create `.claude/skills/docs-sweep/SKILL.md` with frontmatter
  (`name: docs-sweep`, `description:` leading with "Source-side only
  (never installed to consumers)." plus a one-line summary of what it
  checks and its triage-to-feedback ending), mirroring
  `.claude/skills/prerelease-sweep/SKILL.md`'s frontmatter shape.
- T002: Write the scope-resolution step (default: skills changed since
  the last stable tag via `git log`; explicit `--all` argument for a
  full sweep) per the Technical Approach step 1.
- T003: Write the per-skill judgment procedure (compare `SKILL.md`
  against its reference-page body, `USAGE.md`, `docs/concepts.md`;
  spot-check `README.md`) per Technical Approach steps 2–4, including
  the explicit judgment note that `USAGE.md`/`docs/concepts.md` are
  selective by design — an absence there isn't automatically a gap,
  it needs a user-visibility judgment call.
- T004: Write the triage/report step (one findings table,
  accept/decline per item, accepted items filed via `/ardd-feedback`) per
  Technical Approach steps 5–6.

### Phase 2: Cross-references
Depends on: Phase 1
[parallel] with each other (different files)
- T005 [parallel] Add a one-line pointer in `CONTRIBUTING.md`'s
  "Releases" section naming `docs-sweep` as a companion manual check to
  run before a stable release, alongside whatever `prerelease-sweep`
  guidance already lives there (read that section first — if it's
  silent on `prerelease-sweep` too, add both in one consistent style
  rather than introducing an asymmetry).
- T006 [parallel] Add a one-line pointer at the end of
  `.claude/skills/prerelease-sweep/SKILL.md`'s triage-ending prose
  noting `docs-sweep` as a companion check for the human-facing doc
  surface, so a user finishing a prerelease sweep sees the pointer to
  the sibling check.

### Phase 3: First real dogfood run
Depends on: Phase 2
- T007: Manually invoke `/docs-sweep` (as specified by T001–T004)
  against this repo's own current state and report its findings. Do not
  auto-apply fixes — this task's job is confirming the new skill
  produces a coherent, correctly-scoped triage table (using judgment to
  sanity-check its own output, not to independently re-derive the
  drift), not fixing every finding. File genuinely accepted findings via
  `/ardd-feedback` as the skill's own triage step directs; record which
  findings were filed (if any) as this task's completion note. The
  research report already cites concrete candidates (epics undocumented
  on the by-epic breakdown / milestone mapping; `/ardd-plan --slate`
  unrouted in `USAGE.md`/`core-loop.md`) — expect the sweep to surface
  at least these, and treat their absence from the sweep's output as a
  signal the procedure itself needs another look, not that they were
  already fixed.

## Complexity Tracking

No deviations requiring justification — this closely follows the
`prerelease-sweep` structural precedent for a local-only skill; the
judgment procedure itself is new but is scoped narrowly (human-facing
docs only, no mechanization attempt).

## Open Questions

- [OPEN: Should `docs-sweep`'s default scope (skills changed since the
  last stable tag) also need a "no releases yet" fallback, mirroring
  `ardd-update-check.sh`'s `no-releases` handling? Resolve at
  implementation time by checking whether this repo always has at least
  one stable tag by the time this skill would realistically run.]
- [OPEN: Does a finding accepted during T007's dogfood run get filed as
  one `/ardd-feedback` batch, or should genuinely unrelated findings
  (e.g. an epics gap vs. a `--slate` gap) become separate feedback
  files? The skill's own step 5 says "accepted items become
  `/ardd-feedback` entries" without specifying batching — leave this to
  the skill author's judgment at T004, consistent with how
  `/ardd-feedback` itself already batches compound notes into one file
  with separate `F###` items.]
