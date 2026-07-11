---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: scrap-npx-channel
created: 2026-07-11
features: []
surfaced-defects: []
---

# Plan — Scrap the npx channel, add an existing-project curl bootstrap

## Goal

Replace the poorly-working `npx skills add` acquisition channel with an
existing-project curl bootstrap, and remove `/ardd-setup` — so every
acquisition route converges *directly* on `install.sh` with no bridge skill.

## Scope

**In:**
- Revise `constitution.md`'s acquisition-channels standing decision:
  two routes (clone, curl bootstrap), both converging directly on
  `install.sh`; remove the npx channel and the `/ardd-setup` bridge (F002).
- Add an existing-project curl bootstrap (F003): a `new.sh` mode/variant that
  clones/reuses `~/.ardd/source` and runs `install.sh` against the current,
  **already-populated** project dir.
- Delete `skills/ardd-setup/` as dead architecture (F004).
- Propagate the ripple: `README` Install section, `USAGE`, `guides/`,
  `CLAUDE.md`'s npx/`ardd-setup` discussion, `scripts/lint-docs.sh`.

**Out:**
- Technically *disabling* `npx skills add` — the vercel-labs CLI reads the
  repo's `skills/` dirs and we can't stop it; scope is dropping documentation
  and support, not preventing the command. How to handle a user who npx-adds
  anyway (now with no `/ardd-setup` to complete it) is an open question below.
- The catalog-consolidation work (separate, already merged).

## Technical Approach

The existing-project bootstrap reuses `new.sh`'s machinery rather than a
fresh script (Principle VIII): `new.sh` already resolves a source checkout
(cloning only the `~/.ardd/source` it owns; a `--source`/`$ARDD_SOURCE` path
is read, never mutated), honors the `/dev/tty` interactivity discipline, and
*invokes* `install.sh` directly — exactly what the existing-project case
needs. The one real difference (feedback F003): `new.sh` refuses a non-empty
target; the existing-project mode must instead *accept* a populated project
dir while still refusing a directory it doesn't own. So this is a **mode that
inverts one specific guard**, not a reimplementation — the source-resolution,
tty, and `install.sh`-invocation code is shared. (Mode-vs-sibling-script is
an open question, but the lean is a mode for exactly this reuse reason.)

Deleting `/ardd-setup` is safe now that `install.sh` prunes removed skill
dirs (just landed on `main`): an upgrade drops the stale
`.claude/skills/ardd-setup/` from existing installs automatically.

## Phase Breakdown

### Phase 1 — Constitution revision (artifact-first)
`[artifacts: constitution]` (F002, F004). Depends on: nothing.
- Revise the acquisition-channels standing decision (constitution ~lines
  68–90): enumerate two routes (clone, curl bootstrap incl. the
  existing-project variant), both converging directly on `install.sh`;
  remove `npx skills add` and the `/ardd-setup` bridge rationale; keep and
  extend the "must never grow a `/ardd-setup`-style bridge" discipline to
  cover the existing-project bootstrap. Perform via the constitution's own
  amendment process — Sync Impact Report + version bump (magnitude is an open
  question: this is narrative standing-decision text, not a numbered
  principle). Prefer routing through `/ardd-refine constitution` so
  versioning is handled correctly.
- Demonstrable increment: constitution no longer references npx or
  `/ardd-setup`; `lint-project.sh` green on the artifact.

### Phase 2 — Existing-project curl bootstrap (test-first)
Depends on: nothing (parallel to Phase 1). Core deliverable (F003).
- Test-first (Principle V): extend `scripts/test-new.sh` with a case for the
  existing-project mode — a NON-empty target is accepted and converges to
  `install.sh`; a directory it doesn't own is still refused; the three
  invariants hold (refuse-not-ask on unowned dir; never block without a
  usable `/dev/tty`; only ever clone/pull the owned `~/.ardd/source`).
  Keep the suite hermetic (pin `$ARDD_SOURCE`, never clone) as the existing
  cases do. Prove the new case red first.
- Implement the mode in `new.sh` (POSIX sh) to green. Reuse the existing
  source-resolution / tty / `install.sh`-invocation paths; invert only the
  non-empty-target guard for this mode.
- Demonstrable increment: from a populated project dir, one curl-to-sh
  command lands a complete install with an owned source checkout.

### Phase 3 — Delete /ardd-setup (Principle VII)
Depends on: Phase 2 (replacement must work before removing the bridge).
- Delete `skills/ardd-setup/`. Update `scripts/lint-docs.sh` (drop the
  `ardd-setup` name) and any remaining SKILL.md prose naming `/ardd-setup`
  (grep). No install-prune work needed — `install.sh` already prunes.
- Demonstrable increment: `/ardd-setup` gone from source; `lint-docs.sh`
  green; a fresh `install.sh` run prunes it from an existing install.

### Phase 4 — Docs ripple
Depends on: Phases 1–3.
- `README` Install section: remove the npx block; document clone + the
  existing-project curl bootstrap. `USAGE`, `guides/`. `CLAUDE.md`: remove
  the extensive npx/`ardd-setup` discussion (source/target split notes, the
  `/ardd-setup` bridge rationale) and reconcile to the two-route model.
  `lint-docs.sh` green.

### Phase 5 — Verify
Depends on: 1–4.
- Full local CI-equivalent green: `test-new.sh` (incl. the new case),
  `lint-docs.sh`, `lint-project.sh`, and every `scripts/test-*.sh` the branch
  touches. Last gate before mergeable.

## Complexity Tracking

| Deviation | Why justified | Simpler alternative rejected because |
|---|---|---|
| `new.sh` gains an existing-project mode (a second entry shape) | Reuses source-resolution + tty + install.sh-invocation (Principle VIII); the alternative duplicates that hard-won `/dev/tty` logic in a second script | A standalone sibling script re-implements `new.sh`'s three invariants and the tty traps documented in CLAUDE.md — exactly the duplication Principle VIII forbids |

## Open Questions

- **Constitution version-bump magnitude:** the acquisition-channels text is
  narrative standing-decision, not a numbered principle — does the amendment
  process treat this as MINOR (material narrative revision) or PATCH? Resolve
  when performing Phase 1 (via `/ardd-refine`).
- **`new.sh` mode vs sibling script:** lean = mode (reuse). Confirm during
  Phase 2 implementation once the guard-inversion's actual size is visible.
- **Orphaned npx users:** the vercel CLI can still copy the repo's `skills/`
  dirs, but with `/ardd-setup` gone there's no completion path — such an
  install is broken. Options: accept it as unsupported (docs point only to
  clone / curl bootstrap), or leave a minimal tombstone/notice. Decide before
  merge; not blocking the plan.
