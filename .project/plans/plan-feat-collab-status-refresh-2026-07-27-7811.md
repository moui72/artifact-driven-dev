---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: feat-collab-status-refresh
created: 2026-07-27
features: []
surfaced-defects: []
---

# Plan: collaborative mode always refreshes STATUS.md before a PR push

## Goal

In collaborative mode, no ArDD skill pushes a feature branch whose STATUS.md predates the state the push carries — every plan-only and implementation PR gets a terminal `/ardd-status` refresh on the feature branch as the last step before the push.

## Scope

**In:** feedback F001 (`feedback-collab-status-refresh-before-pr-a28b.md`,
a Reconsidered item superseding the rejected
`ci-status-refresh-on-main-coll` register entry). Prose-only skill edits
to `/ardd-implement`, `/ardd-plan`, and `/ardd-status`, plus the doc/
CLAUDE.md sync those skills' rules are mirrored in. Reverses two recorded
prose decisions: the blanket "a delegated subagent must never run
`/ardd-status`" rule (scoped down to solo mode), and `/ardd-plan`'s
refresh-free collaborative ending.

**Out:** any CI regeneration of STATUS.md on the default branch (rejected
by the research doc — the register entry stays `rejected`); any change to
solo-mode behavior (inline terminal refresh and post-merge coordinator
refresh are already correct there); any new scripts (the refresh is the
existing `/ardd-status` procedure plus the already-landed
`status-prune.sh`).

## Technical Approach

- **One owner per path, coordinator-preferred.** The invariant needs
  exactly one refresh per push, so each path names its owner explicitly:
  - `/ardd-implement`, collaborative **delegated**: the **coordinator**
    owns it. After the report-back and the fast-forward of the feature
    branch onto the subagent-reported branch, the coordinator — a live
    session in the primary checkout, now on the feature branch — runs
    `/ardd-status` (refresh + `status-prune.sh` when `status_history_keep`
    is set), commits it, and only then reaches the push/PR offer. The
    delegated subagent itself stays out of the STATUS.md business (it
    would have to re-derive the whole skill from prose mid-run); the rule
    it currently violates is re-scoped rather than inverted.
  - `/ardd-implement`, collaborative **inline**: already correct (step
    8's terminal refresh happens on the feature branch) — the edit just
    states that this satisfies the invariant and that the push offer must
    come after it, never before.
  - `/ardd-plan`, collaborative: before the first push/draft-PR offer —
    and again before any later push in the same run (e.g. the
    post-approval tasking push) — run the terminal `/ardd-status` on the
    feature branch so a plan-only PR's STATUS.md matches the plan/tasks
    state it carries.
- **Re-scope the delegated-no-status rule, don't delete it.** The
  trapped-write rationale is real in solo mode (an abandoned worktree
  traps the report) — solo delegated runs keep the prohibition and the
  post-merge coordinator refresh, unchanged. The prose in
  `/ardd-implement` (step 3 note + step 8) and `/ardd-status` ("run only
  from the primary checkout") gains the mode split: in collaborative
  mode the coordinator's refresh happens on the feature branch in the
  primary checkout — which is not the delegated-worktree case the
  prohibition guards against — and the invariant sentence is stated in
  all three skills verbatim: "in collaborative mode, no ArDD skill pushes
  a feature branch whose STATUS.md predates the state the push carries."
- **Docs sync.** CLAUDE.md's two-modes section and single-writer note,
  and the hand-written bodies of `docs/reference/skills/ardd-plan.md`,
  `ardd-implement.md`, `ardd-status.md`, get the same mode-scoped rule;
  `lint-docs.sh` green. No `lint-project.sh` changes — no new fields or
  enums.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

- **Phase 1 — `/ardd-implement` coordinator + inline wiring.** The
  collaborative report-back sequence becomes: side-effect checks →
  fast-forward feature branch → **status refresh + prune + commit** →
  push/PR offer; the delegated-no-status rule gains its solo-only
  scoping; inline step 8 gains the refresh-before-push ordering note.
- **Phase 2 — `/ardd-plan` collaborative ending.** Terminal refresh
  before every push offer in the collaborative path (initial plan push
  and post-tasking re-push). Depends on Phase 1 only for consistent
  wording of the shared invariant sentence.
- **Phase 3 — `/ardd-status` scoping.** "Run only from the primary
  checkout, never inside a delegated worktree" gains the collaborative
  clarification (feature-branch runs in the primary checkout are the
  required norm, not an exception) and the invariant sentence.
  Depends on Phase 1's wording.
- **Phase 4 — docs + verification.** CLAUDE.md and the three reference
  pages synced; `lint-docs.sh` + `lint-project.sh .` green. Depends on
  Phases 1–3.

## Complexity Tracking

No justified deviations — prose-only edits to three skills plus doc
sync; no new mechanism (the refresh and prune already exist), per
Principle VI.

## Open Questions

- Mid-run visibility pushes: `/ardd-implement`'s collaborative path may
  push after the *first* commit (the draft-PR visibility offer) long
  before completion. The plan treats that push as exempt — the invariant
  binds pushes that carry *terminal* state (plan approved/tasked,
  implementation completed), not incremental visibility pushes, since
  refreshing STATUS.md on every mid-run push would spam the chronology.
  Confirm this scoping at approval, or tighten to literally-every-push.
