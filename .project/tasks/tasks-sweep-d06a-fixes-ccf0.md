---
plan: plan-sweep-d06a-fixes-2026-07-19-502e.md
generated: 2026-07-19
status: in-progress
---

# Tasks

## Phase 1: parallel-matrix verdict fixes (test-first)

- [x] T001 Add regression cases (red first) to
  `scripts/test-parallel-matrix.sh`: (a) two ready files whose plans
  both exist and carry explicitly empty `features: []` → pair line has
  `features=none` (not `unknown`) and verdict falls through to
  artifact comparison; (b) broken chain (missing plan file / missing
  `features:` field) still yields `features=unknown`; (c) the same
  tasks file appearing ready-in-primary AND claimed by an in-flight
  worktree (real second worktree in the fixture, mirroring the
  existing in-flight case) → `verdict=claimed`, no feature/artifact
  comparison columns beyond the standard format. Confirm the new cases
  fail against the current script before T002.

- [x] T002 Fix `scripts/parallel-matrix.sh`: at the features-resolution
  site (~line 64) distinguish "plan resolves and `features:` present
  but empty" (→ `none`) from "plan/field missing" (→ `unknown`) —
  `shared-feature` stays impossible for both; and add the same-file
  pre-check emitting `verdict=claimed` (precedence: `claimed` >
  `shared-feature` > `shared-artifact` > `independent`) when a pair's
  two sides resolve to the same repo-relative tasks filename via the
  primary ready set + an in-flight worktree claim. Update the header
  comment's verdict list. All `test-parallel-matrix.sh` cases green
  (fixes sweep-d06a F002 + F003, script half).

## Phase 2: consuming prose + docs

- [ ] T003 Update the matrix-annotation prose in
  `skills/ardd-implement/SKILL.md` (step 1) and
  `skills/ardd-status/SKILL.md` (step 1 / Work Queue) to name the new
  `claimed` verdict: in implement it maps to the existing same-file
  hard exclusion (the verdict is how the matrix reports what the
  exclusion already enforces — the rule itself is unchanged); in
  status it reads as "claimed by in-flight worktree". Also apply the
  F004 one-line clarification in `skills/ardd-status/SKILL.md`: entry
  data for the Work Queue section comes from `tasks-list.sh`;
  `parallel-matrix.sh` supplies only the pair verdicts (and is
  silent, by design, with fewer than two participants). Verify
  `./scripts/lint-docs.sh` green.

- [ ] T004 Update the hand-written bodies (below `generated:end`) of
  `docs/reference/skills/ardd-status.md` and
  `docs/reference/skills/ardd-implement.md` to mention the `claimed`
  verdict and the Work Queue data-source split, mirroring T003.
  `./scripts/lint-docs.sh` green.

## Phase 3: F001 coverage verification

- [ ] T005 [parallel] Verify the dual-tag stable-preference coverage
  from fix `c7cb703`: inspect `scripts/test-install-channel-default.sh`
  and `scripts/test-install-gitattributes.sh`/siblings for a case
  pinning "source HEAD carries BOTH a stable and a beta tag → recorded
  `Source-Ref:` is the stable tag". If present, run it and record the
  result; if absent, add the case (fixture repo with a dual-tagged
  HEAD) and make it green. No `install.sh` change expected. Note in
  the task output: the operational remedy for sweep-d06a F001 (real
  consumers hitting a stale beta `Source-Ref:` under `--stable`) is
  dispatching the v1.0.1 stable release — a user act outside this
  tasks file.
