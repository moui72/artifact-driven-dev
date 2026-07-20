---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: dot-project-reviewer-guide
created: 2026-07-20
features: [dot-project-reviewer-guide, next-step-prompt-auto]
surfaced-defects: []
---

# Plan: reviewer guide, next_step_prompt auto, source-path portability, plan-record conventions

## Goal

Stop `.project/` from leaking machine-specific paths and confusing external
reviewers, and make the next-step prompt fully configurable (`true | false |
auto`) with a defined degradation when AskUserQuestion is denied.

## Scope

**In:**
- `next-step-prompt-auto` feature: third `next_step_prompt` enum value
  `auto` — `/ardd-status` and `/ardd-plan` auto-run a concrete runnable
  `/ardd-*` recommendation instead of prompting.
- Feedback 20da F001: denied/unavailable AskUserQuestion in the two
  prompting skills reads as "no — stop here", never a retry or an abort.
- Feedback 19ce F001/F002: `Source-Path` recorded home-relative
  (`~/.ardd/source`) by `install.sh`; readers (`source-resolve.sh`,
  `ardd-update-check.sh`) expand a leading `~`; legacy absolute paths
  detected and rewritten on re-install//ardd-update with history advice;
  sweep other generated-and-committed files for the same leak class.
- Feedback 19ce F003: drafting convention — never restate a count that is
  derivable from an enumeration in the same document.
- Feedback 19ce F004 (confirmed reversal): a plan is a **static historical
  record** — no live-looking checkboxes; progress lives in the linked
  tasks file.
- `dot-project-reviewer-guide` feature: an installed "how to read
  `.project/`" orientation note for downstream AI reviewers.

**Out:**
- No lint check for count-vs-enumeration drift (convention first; escalate
  only if it proves inadequate).
- No retroactive rewrite of existing plans' checkboxes.
- No `codex-second-harness-support` work; `repo-critique-6ad1` feedback
  stays open for a later run.
- No change to this repo's own `next_step_prompt: true` setting.

## Technical Approach

Per the constitution: schema changes land in `lint-project.sh`'s enum block
in the same commit as the skill prose that writes the new value (Quality
Standards); every deterministic-script change carries its fixture-based
regression test in the same commit (Principle V); `install.sh` remains the
sole entry point into a target, and the reviewer guide installs through it
(Principle IV — target-side). The `auto` value is stamped via
`ardd-state.sh stamp`, exempt from constitution versioning (Governance
Exception; the small Codex-substitution clarification already landed as
constitution v1.12.1 in this run).

The reviewer guide is a generated, install.sh-owned file written to the
target's `.project/README.md` (overwritten on every install, like
`ardd-version.md`), and `ardd-version.md` gains a one-line pointer to it.
`[OPEN]` below covers the location question.

## Phase Breakdown

Phase lists are enumerations of plan work-items, not live checklists —
execution progress is tracked in the linked tasks file.

### Phase 1 — Source-Path portability (feedback 19ce F001, F002)
Depends on: nothing. Delivers: no consumer repo commits a machine-specific
absolute path.
- `install.sh`: record `Source-Path` home-relative (`~/…`) when the source
  checkout sits under `$HOME`; absolute otherwise.
- `scripts/source-resolve.sh` and `scripts/ardd-update-check.sh`: expand a
  leading `~` when reading `Source-Path` (POSIX-safe, no eval).
- Legacy repair: on re-install and `/ardd-update`, detect an absolute
  under-`$HOME` `Source-Path`, rewrite it to portable form, and advise the
  user (prose in `/ardd-update`'s SKILL.md) that scrubbing already-committed
  history is their call, with a brief recommendation.
- Sweep every other generated-and-committed file for absolute-path leaks;
  fix any found the same way.
- Regression tests updated/added in the same commits
  (`test-source-resolve.sh`, a new install.sh source-path case).

### Phase 2 — `next_step_prompt: auto` + denial degradation (feature
`next-step-prompt-auto`; feedback 20da F001)
Depends on: nothing (parallel-safe with Phase 1).
- `scripts/lint-project.sh`: widen the `next_step_prompt` enum to
  `true | false | auto`; `test-lint-project.sh` fixtures updated same
  commit.
- `skills/ardd-status/SKILL.md` step 8 and `skills/ardd-plan/SKILL.md`
  step 15 + slate prompt: document `auto` (auto-run a concrete runnable
  `/ardd-*` recommendation; non-runnable recommendations stay plain text)
  and the denial rule — a denied/unavailable AskUserQuestion means
  "no — stop here": never retry, never treat as an error that discards the
  report already produced.
- `/ardd-init` and `/ardd-update --reconfigure` (and update's backfill
  ask): the one-time question offers three values.
- Docs: reference pages / guides mentioning the boolean field updated
  (`docs-sweep` conventions apply).

### Phase 3 — Plan-record conventions (feedback 19ce F003, F004)
Depends on: nothing (prose-only; parallel-safe).
- `skills/ardd-plan/SKILL.md` step 8/12 drafting prose: plans emit plain
  enumerations, never `- [ ]` checkboxes; template includes a "progress is
  tracked in the linked tasks file" note; add the "don't restate derivable
  counts" convention.
- Confirm `/ardd-implement` nowhere implies it updates plan checklists.

### Phase 4 — `.project/` reviewer guide (feature
`dot-project-reviewer-guide`)
Depends on: Phase 3 (the guide states the plan-as-static-record convention,
so the convention must be settled first).
- Author the guide (source-side template): generated vs authored files,
  static-historical-record semantics (plans, planned feedback), the
  single-writer/disposable-report conventions, and that `.claude/skills/`
  is regenerated output.
- `install.sh`: write it to the target's `.project/README.md` on every
  install; add a pointer line in `ardd-version.md`; regression coverage in
  the install tests.
- Docs: mention the guide in README/USAGE where `.project/` is introduced.

## Complexity Tracking

No deviations from Simplicity/YAGNI to justify — every change extends an
existing mechanism (enum widening, install.sh copy step, prose
conventions); no new architecture.

## Open Questions

- Reviewer-guide location: `.project/README.md` (install.sh-owned,
  overwritten each install) is the working choice — confirm no consumer
  already hand-authors a `.project/README.md` before making it
  unconditionally overwriting (fallback: create-if-absent + drift notice).
- Should a legacy `Source-Path` rewrite auto-commit in the consumer repo,
  or leave the change staged for the user? (Working assumption: leave
  uncommitted; /ardd-update already relays install output.)
