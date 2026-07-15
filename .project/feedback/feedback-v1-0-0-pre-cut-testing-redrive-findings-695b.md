---
status: open
created: 2026-07-15
plan: null
---

# Feedback

Source: redrive of the 3 v1.0.0 pre-cut dry-run scenarios (collaborative
mode lifecycle, solo inline core loop, peripheral-skills sweep) whose
first attempt was killed by an account-wide API spend-limit outage that
also wiped their scratchpad before reports could be captured — see
`feedback-v1-0-0-pre-cut-testing-findings-0344.md` for the original
4-scenario batch (S1/S2/S3/S6). This batch's 3 subagents were briefed to
write reports progressively this time, and all 3 survived intact with
genuinely complete findings.

## Bugs

- [ ] F001 `lint-project.sh`'s constitution Sync Impact Report check
  requires the literal Unicode arrow `→` and silently fails to parse the
  version bump when a user (or an agent) writes the more natural ASCII
  `->` instead. Worse, the resulting error message is misleading — it
  reports something like "footer says X" rather than "the arrow character
  isn't the one I'm looking for," which sends a real user hunting in the
  wrong place. Worth either accepting both `->` and `→` as equivalent, or
  making the error message explicitly name the exact character it
  expected.
- [ ] F002 `/ardd-defects`'s generated `DEFECTS.md` can go stale within
  the same day with no way to tell from the report itself. A redrive
  scenario hit this directly: `DEFECTS.md` asserted an `Entity` had no
  `long_form_keys` field — true at the moment `/ardd-defects` ran, but a
  commit landing roughly an hour later added exactly that field, making
  the "known defect" now false without anything in `DEFECTS.md` signaling
  it might be stale. The regeneration mechanism itself is sound (a fresh
  full run would catch it), but there's no way to tell *how* stale a
  specific claim inside an existing report is without just re-running the
  whole thing. Worth considering whether each claim, or the report as a
  whole, could record something (a commit SHA it was checked against)
  that would let a reader judge staleness without a full re-run.

## UX

- [ ] F003 `skills/ardd-implement/SKILL.md`'s collaborative-mode paragraph
  describes offering to push a branch and open a draft PR, but doesn't
  specify what to report or do if the `gh pr create` step itself fails
  (no GitHub remote, no auth, etc.) — only the push half is
  fully-specified. In a sandboxed redrive test this left a live agent
  needing to improvise once it reached that point. Worth adding one
  sentence covering the failure path: report the `gh` error verbatim, the
  push already succeeded so the branch is safe, and let the user open the
  PR by hand or retry once `gh` is configured.
- [ ] F004 `/ardd-plan`'s generated task phrasing assumes existing code to
  modify even for a greenfield project's very first feature — e.g. a task
  said "extend the counting function" when no code existed yet to extend,
  on a project's first-ever backlogged feature. Not a real blocker (any
  competent implementer reads "extend" as "create" when nothing exists
  yet), but worth having the task-generation step distinguish "this is
  the first task touching this file/function" (create) from later ones
  (extend) for clarity.
- [ ] F005 `scripts/ardd-update-check.sh`'s actual output field name
  (`latest-release=`) doesn't match the field name `skills/ardd-status/SKILL.md`
  documents it as printing (`source-tip=`) — cosmetic doc/implementation
  drift, easy to fix by aligning one to the other.
- [ ] F006 `/ardd-diagram` silently creates a brand-new `README.md` when
  none exists in the target, rather than calling this out explicitly.
  Technically correct per its own spec (it upserts into a configurable
  destination, default `README.md`), but a first-time user running it
  against a project with no README yet would likely be surprised to find
  one now exists. Worth a one-line "creating README.md (none existed)"
  note in its output when this happens.
- [ ] F007 Documentation clarity gap: `skills/ardd-init/SKILL.md` and
  `skills/ardd-update/SKILL.md` describe `workflow_mode`, `next_step_prompt`,
  `delegation`, and `merge_policy` in similar enough phrasing that a
  reader can reasonably expect all four to be "stamped" identically —
  but `workflow_mode` is deliberately written inline during artifact
  authoring (by `/ardd-init` directly) rather than via
  `ardd-state.sh stamp` like the other three, which is why `stamp`'s key
  enum excludes it. This is intentional and already covered in
  CLAUDE.md's architecture notes, but the SKILL.md-level phrasing doesn't
  make the distinction obvious to someone reading only the skill files.
  Worth a short clarifying line wherever the four fields are introduced
  together.
