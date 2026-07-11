---
plan: plan-primary-stays-on-main-2026-07-11.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-11
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Constitution standing decision

- [x] T001 [artifacts: constitution] Add a standing decision to
  `constitution.md`'s Project Scope & Intent (adjacent to the acquisition /
  `new.sh` material): **the primary/default worktree of this repo never
  leaves `main`.** Rationale to state: this repo is the local source other
  projects install/update from — `install.sh`/`/ardd-update` read this
  checkout (via a recorded `Source-Path` or `~/.ardd/source`) and install
  from whatever branch is checked out, so a checked-out feature branch serves
  unmerged/possibly-broken skills to consumers and can provoke their update
  flows into re-checking-out `main` under in-flight work. State the remedy:
  all feature work happens in a **separate worktree** (`git worktree add`, or
  the skills' `isolation: "worktree"` delegation), which branches without
  moving the primary HEAD. Cite the 2026-07-11 ref-lock anomaly as the
  concrete failure prevented. Follow the amendment process: Sync Impact Report
  + version bump (resolve MINOR-vs-PATCH; a new material standing decision
  leans MINOR, matching the npx-scrap bump). Prefer `/ardd-refine
  constitution` for correct SIR/footer/frontmatter versioning rather than
  hand-editing. Verify `scripts/lint-project.sh` green on the artifact.

## Phase 2: CLAUDE.md workflow note

- [ ] T002 Add a short workflow note to `CLAUDE.md` (near the Commands /
  worktree material) operationalizing T001's decision for anyone working in
  this repo: do feature work in a **separate worktree** and keep the primary
  checkout on `main`; do **not** take `/ardd-plan`/`/ardd-implement`'s inline
  `git checkout -b` branch-gate option here (that option remains valid for
  ordinary consumer projects, which are not sources others read). Include the
  one-line recovery move if the primary is ever found off `main`
  (`git checkout main`; unmerged work stays safe on its branch/worktree — see
  the 2026-07-11 anomaly). Keep `scripts/lint-docs.sh` green.

## Phase 3: Verify

- [ ] T003 Run the doc/lint gates and confirm green: `scripts/lint-docs.sh`,
  `scripts/lint-project.sh`, and `scripts/gen-skill-docs.sh --check`. Confirm
  the constitution's version bookkeeping is internally consistent
  (SIR target == footer version == frontmatter `last_updated` alignment — the
  write-time hook guards this, but verify explicitly). Last gate before the
  worktree branch is merged back to `main`.
