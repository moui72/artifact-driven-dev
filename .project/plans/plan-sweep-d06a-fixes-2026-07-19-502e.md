---
status: approved
branch: sweep-d06a-fixes
created: 2026-07-19
features: []
---

# Plan: Prerelease sweep d06a fixes

## Goal

Fix the four accepted findings from prerelease sweep 2026-07-19-d06a —
two `parallel-matrix.sh` verdict bugs (empty `features: []` misread as
`unknown`; same-file claimed pair mislabeled `shared-feature`), the
Work Queue prose data-source clarification, and the record/verification
work for the `--stable` stale-beta-ref bug whose real remedy is
shipping v1.0.1.

## Scope

**In scope** (consumes `feedback-prerelease-sweep-d06a-f8ce.md`, all
four items accepted):
- F002: `scripts/parallel-matrix.sh` — an intact plan chain with an
  explicitly empty `features: []` reports `features=none`, reserving
  `unknown` for a genuinely broken chain (missing plan file or missing
  `features:` field). Regression cases in
  `scripts/test-parallel-matrix.sh`.
- F003: a new `verdict=claimed` for the pair where the *same* tasks
  file appears ready-in-primary and claimed-in-a-worktree (ranked
  above `shared-feature`); script + test + the annotation prose in
  `skills/ardd-status/SKILL.md` and `skills/ardd-implement/SKILL.md`.
- F004: one-line Work Queue prose clarification in
  `skills/ardd-status/SKILL.md` (matrix supplies pair verdicts;
  `tasks-list.sh` supplies the entries) + matching reference-doc body.
- F001: verification only — confirm the dual-tag stable-preference
  regression coverage from `c7cb703` pins the consumer `--stable`
  path, adding an explicit case if it doesn't. The operational remedy
  (dispatching v1.0.1 stable) is a user act outside this plan; the
  finding is recorded here so the release decision carries it.

**Out of scope:**
- The two taste-deferred sweep items (STATUS.md-accretion guidance,
  fold-to-main branch-ref cleanup) and the duplicate/harness-artifact
  rows — see TRIAGE.md.
- Any change to the same-file *hard exclusion* in `/ardd-implement` —
  the `claimed` verdict is visibility; the exclusion rule is untouched.

## Technical Approach

- **F002** is a one-branch fix at the features-resolution site
  (~line 64): distinguish "field present, list empty" (→ `none`) from
  "field/plan missing" (→ `unknown`). `shared-feature` remains
  impossible for both `none` and `unknown` sides.
- **F003** adds a pre-check before the overlap verdicts: when a pair's
  two paths resolve to the same repo-relative tasks filename (one via
  the primary's ready set, one via an in-flight worktree claim), emit
  `verdict=claimed` and skip feature/artifact comparison (comparing a
  file with itself is meaningless). Precedence: `claimed` >
  `shared-feature` > `shared-artifact` > `independent`. Consuming
  skills' prose names the new verdict: in `/ardd-implement` it maps to
  the existing same-file hard exclusion (the verdict is how the matrix
  *reports* what the exclusion already enforces); in `/ardd-status` it
  reads "claimed by in-flight worktree".
- **F004** is prose-only, per the S5 report's wording.
- **F001**: inspect `scripts/test-install-channel-default.sh` (and the
  `c7cb703` test) for a case pinning "source HEAD carries both a
  stable and a beta tag → recorded `Source-Ref:` is the stable tag";
  add it if absent. No install.sh change expected — the fix exists;
  only its coverage is being confirmed.

## Phase Breakdown

### Phase 1: parallel-matrix verdict fixes (test-first) — no dependencies
- F002: regression cases red (empty-list `none`; `unknown` still for
  broken chain), then the script fix.
- F003: regression case red (same-file claimed pair →
  `verdict=claimed`), then the script fix with the precedence rule.

### Phase 2: consuming prose + docs — depends on Phase 1
- F003 prose: name `claimed` in both consuming skills' annotation
  passages.
- F004: Work Queue data-source clarification in `ardd-status` prose +
  `docs/reference/skills/ardd-status.md` body; `lint-docs.sh` green.

### Phase 3: F001 coverage verification — no dependencies, [parallel]
- Confirm/add the dual-tag stable-preference regression case; note in
  the tasks file output that v1.0.1's stable dispatch is the
  operational remedy.

## Open Questions

- None. (Verdict precedence and the `claimed` name are decided above;
  the same-file hard exclusion is explicitly unchanged.)
