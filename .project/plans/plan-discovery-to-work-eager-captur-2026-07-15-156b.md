---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: discovery-to-work-eager-captur
created: 2026-07-15
features: [discovery-to-work-eager-captur, backlog-sweep-reconcile-from-a]
surfaced-defects: []
---

# Plan: The artifact→register bridge (eager capture + retroactive sweep)

## Goal

Close the gap where capabilities documented in artifacts but not yet built
never become work items: capture them eagerly at the moment of salience
(`/ardd-init`, `/ardd-refine`) and retroactively via a sweep
(`/ardd-status` detection + `/ardd-backlog --from-artifacts`).

## Scope

**In:** skill-prose changes to `skills/ardd-init/SKILL.md`,
`skills/ardd-refine/SKILL.md`, `skills/ardd-status/SKILL.md`,
`skills/ardd-backlog/SKILL.md`, a routing note in
`skills/ardd-defects/SKILL.md`, and the matching `docs/reference/skills/`
pages. Consumes feedback `feedback-artifact-register-bridge-116a.md`
(F001 discovery limbo, F002 pivot limbo, F003 defects framing).

**Out:** no new scripts (the capability-vs-design-note judgment is LLM
work — a proposal list, not automation; consistent with the mechanization
non-goals); no schema/frontmatter changes, so `lint-project.sh` is
untouched; no changes to this repo's own artifacts; the related
`epics-grouping-in-feature-regi` and `plan-time-defrag-slate-analysi`
backlog items (separate plans later).

## Technical Approach

All register writes go through the existing `ardd-state.sh
feature-create` path — no new mutation mechanism, and single-writer
ownership is preserved: `/ardd-status` only *detects* (advisory report
section, never a register write); `/ardd-backlog` remains the writer.
Batched confirmation follows the existing `/ardd-feedback` re-file
pattern (one grouped AskUserQuestion, never N sequential prompts). New
prose follows constitution Principle IX (explicit actor language). All
tasks are documentation/prose — the explicit Principle V test exception;
`scripts/lint-docs.sh` in CI still guards skill-name references.

## Phase Breakdown

**Phase 1 — Eager capture (feature: discovery-to-work-eager-captur; F001, F002)**
1. `/ardd-init` gains a terminal step (both greenfield and
   existing-codebase paths): after artifacts are written, enumerate
   capabilities they describe that have no register entry and no
   implementation, and offer to backlog them in one batched confirmation
   via `feature-create`.
2. `/ardd-refine` gains the same step scoped to the *delta* of the edit
   (the pivot case): only capabilities newly introduced or materially
   changed by this refine are offered.

**Phase 2 — Retroactive sweep (feature: backlog-sweep-reconcile-from-a; F001, F003)**
3. `/ardd-status` gains an advisory "Documented but untracked" report +
   STATUS.md section: stable artifacts' described capabilities with no
   register entry and no implementation, each with a pointer to
   `/ardd-backlog --from-artifacts`. Detection only — never writes the
   register; STATUS.md remains its only write.
4. `/ardd-backlog --from-artifacts` mode: walk stable artifacts, propose
   candidate entries (grounded in artifact text, deduplicated against the
   existing register including implemented/retired slugs), batch-confirm,
   and `feature-create` the approved ones.
5. `/ardd-defects` routing note (F003): documented-but-never-built scope
   is backlog territory, not a defect — point to `/ardd-backlog
   --from-artifacts` rather than recording greenfield gaps in DEFECTS.md.

**Phase 3 — Docs (depends on Phases 1–2)**
6. Update `docs/reference/skills/` pages for ardd-init, ardd-refine,
   ardd-status, ardd-backlog, ardd-defects below their `generated:end`
   markers; touch USAGE.md/guides only where flows are described.

## Open Questions

- Noise control for detection (both eager and sweep): what makes a
  passage a "capability" vs. a design note is judgment — the guardrails
  are: proposal-only, batched confirmation, stable artifacts only for the
  sweep, and dedupe against all register statuses. Acceptable to tune
  from real use (atelier is the first intended consumer).
- Whether `/ardd-init`'s existing feature-register bulk-extraction step
  and the new terminal capture step should be unified prose or stay
  distinct (extraction reads *code*, capture reads *artifacts*) — decide
  while editing.
