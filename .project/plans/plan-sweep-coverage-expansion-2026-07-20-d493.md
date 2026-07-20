---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: sweep-coverage-expansion
created: 2026-07-20
features: []
surfaced-defects: []
---

# Plan: sweep-coverage-expansion

## Goal

Harden prerelease-sweep coverage: extend four scenario briefs with the
recently shipped surfaces that earned real findings (dynamic badge,
Work Queue/parallel-matrix, bare-plan picker, `--view`,
`constitution --review`), and wire a coverage-graduation step into the
sweep skill itself so dispatcher-stressed surfaces stop silently aging
out after one sweep.

## Scope

**In scope** (consumes `feedback-sweep-coverage-expansion-3452.md`, all
six items accepted):
- F001 — S1 gains dynamic-badge steps (fake GitHub remote, no push;
  `ARDD_VERSION_BADGE=1` snippet carries real coordinates; no reprint
  with markers present; default-output opt-in mention; wrong
  `github/v/release` badge draws the advisory). Written against the
  now-merged fixed behavior (`09abad7`).
- F002 — S8 gains Work Queue / parallel-matrix consumer-visible checks
  (verdicts incl. `features: []` → `none`, picker annotations,
  same-file pair reads `claimed`).
- F003 — S5 gains the bare `/ardd-plan` target-picker check.
- F004 — S7 gains `/ardd-status --view` incl. the STATUS.md-untouched
  single-writer check.
- F005 — S7 gains `constitution --review` (full-annotated: proposals
  project-specific, batched, never auto-applied).
- F006 — the graduation mechanism, per the accepted audit proposal
  (2026-07-19 Fable agent), which is this plan's design-of-record:
  - prerelease-sweep SKILL.md **step 3** (dispatch): while deriving
    S3's recent-features list, grep-and-judge each surface against
    `tests/prerelease/scenarios/*.md`; record aged-out consumer-facing
    surfaces as `never-graduated:` lines in RUN.md.
  - prerelease-sweep SKILL.md **step 6** (triage): the TRIAGE.md table
    gains a mandatory `graduate ∈ yes / no / n-a` column; every
    accepted finding on a dispatcher-stressed surface (and every
    `never-graduated:` carry-in) marked `yes` produces a brief-coverage
    item in the consolidated `/ardd-feedback` capture naming the target
    scenario and the 1–3-line step to add. Brief edits land via the fix
    plan, validated by the regression rerun — never edited during the
    sweep itself.
  - Graduation criteria (anti-bloat): accepted findings on
    consumer-facing surfaces only; taste-defers, harness artifacts, and
    source-side surfaces never graduate; smoke-tier additions must
    respect the ~1 hr budget (costly steps go full-tier).
  - One-line mirror in `tests/prerelease/README.md`'s Maintenance
    rules pointing at the skill's step 6.
  - Explicitly **no new script** — slug↔brief mapping fails the
    deterministic bar (briefs don't name slugs verbatim; some slugs
    are deliberately out of scope), consistent with the mechanization
    non-goals.

**Out of scope:**
- New S-files (all five coverage additions are extensions; the audit
  found no uncovered axis needing a new scenario).
- Tier promotions (smoke composition S1/S5/S7 judged sound).
- Surfaces judged adequate as-is: channels, epics, fold/reap/align,
  rejected/subsumed, `--slate`, source-side skills.
- Executing a sweep to validate the new steps (that's the next real
  sweep's job; brief text is validated by review here).

## Technical Approach

All edits are prose in markdown briefs and one SKILL.md — no shell
changes, so no regression-test additions; `lint-docs.sh` remains the
only deterministic gate (it doesn't parse scenario briefs, but runs
anyway pre-commit). Scenario edits follow each brief's existing step
style and numbering; each added step states its expected observation
explicitly (what "pass" looks like) matching how current briefs phrase
checks. The SKILL.md edits use the audit proposal's drafted prose
(step 3 bindings line + step 6 disposition-table column and graduation
paragraph), adjusted only to fit the file's current wording. S7 gets
both F004 and F005 in one edit pass; the F005 step carries a
`full-annotated` marker matching the brief's existing tier-annotation
convention (verify the exact convention in the file while editing).

## Phase Breakdown

**Phase 1 — scenario-brief extensions** (no dependencies; 4 work-items,
one per brief file, `[parallel]`-safe: S1, S5, S7, S8)
1. S1 + dynamic badge (F001)
2. S5 + bare-plan picker (F003)
3. S7 + `--view` and `constitution --review` (F004, F005)
4. S8 + Work Queue/parallel-matrix (F002)

**Phase 2 — graduation mechanism** (independent of Phase 1 in content,
sequenced after to keep the skill edit informed by how the new brief
steps were phrased)
5. prerelease-sweep SKILL.md step-3 and step-6 edits + README mirror
   (F006)

## Open Questions

- Should S1's badge steps be gated "full only" inside the brief to
  protect the smoke budget, or are they cheap enough for smoke as-is?
  Leaning: keep in smoke — the audit judged the step cheap (no push,
  no network), and S1 already runs install.sh anyway.
- Does S7's existing structure have a per-step tier-annotation
  convention for the F005 `full-annotated` marker, or does the
  distinction live only in the dispatcher's tier lists? Resolve while
  editing; if the latter, the F005 step gets a "full tier only" note in
  prose.
