---
plan: plan-scrap-npx-channel-2026-07-11.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-11
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Constitution revision (artifact-first)

- [x] T001 [artifacts: constitution] Revise the acquisition-channels standing
  decision in `.project/artifacts/constitution.md` (~lines 68–90): enumerate
  **two** acquisition routes — cloning the repo, and the curl bootstrap
  (`new.sh`, now including the existing-project variant from T003) — both
  converging directly on `install.sh`. Remove `npx skills add` / the
  vercel-labs CLI from the channel list, and remove the `/ardd-setup` bridge
  rationale. Keep the existing "must never grow a `/ardd-setup`-style bridge"
  discipline and extend it explicitly to the existing-project bootstrap.
  This changes constitution content, so follow the amendment process: emit a
  Sync Impact Report and bump the version (resolve MINOR-vs-PATCH per the open
  question — narrative standing-decision revision). Prefer running
  `/ardd-refine constitution` so versioning is handled correctly rather than
  hand-editing frontmatter. Verify `scripts/lint-project.sh` stays green.

## Phase 2: Existing-project curl bootstrap (test-first)

- [x] T002 Test-first (Principle V). Extend `scripts/test-new.sh` with a case
  exercising the existing-project bootstrap mode: a **non-empty** target dir
  is accepted and the run converges to `install.sh`; a directory `new.sh`
  doesn't own is still refused (refuse-not-ask); the run never blocks when
  `/dev/tty` is unusable; and only the owned `~/.ardd/source` is ever
  cloned/pulled (a pinned `--source`/`$ARDD_SOURCE` is read, never mutated).
  Keep the case hermetic exactly like the existing ones (pin `$ARDD_SOURCE`,
  never clone; timeout-guard any branch that could reach a `read`). Prove the
  new case **red** against current `new.sh` (which has no such mode) before
  T003.

- [x] T003 Implement the existing-project mode in `new.sh` (POSIX sh) to make
  T002 green. Reuse the existing source-resolution, `/dev/tty` interactivity,
  and `install.sh`-invocation paths — invert only the non-empty-target guard
  for this mode (accept a populated project dir; still refuse a dir it doesn't
  own). Do not duplicate the tty logic into a separate script (Principle VIII;
  the mode-vs-sibling open question resolves here — default to a mode). Respect
  the `exec claude … < /dev/tty` read-only-fd trap documented in CLAUDE.md if
  this mode offers any Claude Code handoff.

## Phase 3: Delete /ardd-setup (Principle VII)

- [x] T004 Delete `skills/ardd-setup/` in the same change that removes its last
  references (no dead architecture). Drop the `ardd-setup` name from
  `scripts/lint-docs.sh`'s allowlist, and grep all remaining `skills/*/SKILL.md`
  for `/ardd-setup` / `ardd-setup` and remove/redirect those references. No
  install-side prune work is needed — `install.sh` already prunes removed ardd
  skill dirs from existing installs (landed on `main`). Verify
  `scripts/lint-docs.sh` green.

## Phase 4: Docs ripple

- [x] T005 Reconcile all docs to the two-route model. `README.md` Install
  section: remove the npx block; document clone + the existing-project curl
  bootstrap. Update `USAGE.md` and `guides/`. `CLAUDE.md`: remove the extended
  npx / `/ardd-setup` discussion (the source/target-split notes about the CLI,
  the bridge rationale) and reconcile to two routes. **Also resolve the
  orphaned-npx open question here and reflect the decision in the docs:**
  surface to the user whether an npx-acquired (now un-completable) install is
  documented as explicitly unsupported, or gets a minimal tombstone/notice.
  Verify `scripts/lint-docs.sh` green.

## Phase 5: Verify

- [ ] T006 Run the full local CI-equivalent and confirm green: `test-new.sh`
  (including the new existing-project case), `lint-docs.sh`, `lint-project.sh`,
  and every other `scripts/test-*.sh` this branch touched. Fix any failure
  before marking complete — last gate before the branch is mergeable.
