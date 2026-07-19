---
status: planned      # open -> planned
created: 2026-07-18
plan: plan-prerelease-sweep-fixes-2026-07-18-d341.md
---

# Feedback

## Bugs
- [x] F001 `install.sh` records `Channel: stable` in
  `.project/ardd-version.md` regardless of the source checkout's actual
  tag shape — `SOURCE_REF` capture (`git describe --exact-match --tags
  --match 'v[0-9]*'`) matches prerelease tags fine, but `CHANNEL`
  defaults to `stable` independently with no cross-check against what
  `SOURCE_REF` actually resolved to. Reproduces on any `install.sh` run
  from a checkout sitting on a beta tag — the normal state between
  stable releases (e.g. right now, this repo's HEAD is at
  `v0.10.3-beta.3`). Result: a self-contradictory `Channel:`/`Source-Ref:`
  pair that `lint-project.sh`'s own `channel-source-ref-consistency`
  check (shipped 2026-07-18) correctly flags as an error — ArDD's own
  installer, run in its own normal between-releases state, currently
  produces output its own linter rejects. Highest priority: reproduced
  independently in 5 of 8 scenarios (S2, S4, S5, S6, S8) in the
  2026-07-18 full prerelease sweep (run `2026-07-18-50ea`). Root cause
  and reproduction: `dev-notes/prerelease-runs/2026-07-18-50ea/S2-report.md`.
- [x] F002 `ARDD_VERSION_BADGE=1 ./install.sh` silently no-ops — writes
  neither the workflow file nor the seed JSON, and prints no message
  explaining why — when the target README already contains the
  `ardd-badge-start` marker (e.g. from a prior hand-pasted static badge,
  as in the atelier consumer repo). A project that already adopted the
  static badge can never get the dynamic version badge without first
  stripping the marker on their own, with no guidance that this is
  required. Found in S3:
  `dev-notes/prerelease-runs/2026-07-18-50ea/S3-report.md`.
- [x] F003 `ardd-state.sh feature-flip <slug> implemented` performs no
  cross-check against the bound tasks file's actual completion status —
  it succeeded in S6's dry run even while the tasks file was still
  `status: in-progress`, which could let a real orphaned
  "implemented but the tasks file never actually completed" state occur
  undetected. This is the opposite-direction gap from what
  `completion-flip-check.sh` already catches (merged-branch-but-still-tasked).
  Found in S6: `dev-notes/prerelease-runs/2026-07-18-50ea/S6-report.md`.

## UX
- [x] F004 `ardd-state.sh task-check`'s checkbox match is a strict
  `- [ ] $id ` pattern that fails with an unhelpful/generic error on a
  `T001:` (colon-suffixed) checkbox format, even though real `/ardd-plan`
  output always uses the colon-free format per its own SKILL.md — low
  real-world impact, but the failure message doesn't explain what's
  actually wrong. Found in S6.
- [x] F005 When a tasks file's `plan:` frontmatter is given a path
  instead of a bare filename, `lint-project.sh`'s resulting error
  message doubles/garbles the path segment in a confusing way rather
  than clearly stating "expected a bare filename, got a path." Found in
  S4: `dev-notes/prerelease-runs/2026-07-18-50ea/S4-report.md`.
- [x] F006 `skills/ardd-status/SKILL.md`'s by-epic Feature Backlog
  breakdown section doesn't document the "epic drained to zero" case
  (what the report should say when every entry under a previously-seen
  epic value moves to `implemented`/`retired` and none remain in the
  actionable `backlogged`/`planned`/`tasked` states). Found in S7:
  `dev-notes/prerelease-runs/2026-07-18-50ea/S7-report.md`.
