---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: update-channel-switch-flags
created: 2026-07-15
features: [update-channel-switch-flags, plan-approval-browser-preview]
surfaced-defects: []
---

# Plan: update-channel-switch-flags + plan-approval-browser-preview

## Goal

Give `/ardd-update` explicit `--local|--beta|--stable` flags for a
deliberate channel switch (today only reachable by raising it with the
agent, and by hand-crafting `ARDD_CHANNEL`), and give `/ardd-plan`'s
approval checkpoint a browser-preview offer (render `plan.md` as an
Artifact, open it, and print the URL) as an alternative to reading raw
markdown in the terminal.

## Scope

In scope:
- `/ardd-update` Usage/step 1 rewrite: `--local`, `--beta`, `--stable`
  flags, their precedence when combined with the existing bare-form
  channel-resolution flow, and the reinstall step's `ARDD_CHANNEL` wiring.
- `/ardd-plan` step 10 (approval checkpoint) prose: an offer, asked once
  per checkpoint arrival, to publish `plan.md` as an Artifact and open it,
  before the existing Approve/Revise/Stop question.
- Reference docs: `docs/reference/skills/ardd-update.md`,
  `docs/reference/skills/ardd-plan.md`.

Out of scope:
- No script changes. `source-resolve.sh --channel stable|beta` already
  exists (v1.8.0); `--local` reuses its existing dev-mode detection
  (`channel=dev` branch) rather than adding new channel logic.
- No change to `install.sh`'s `ARDD_CHANNEL` handling — it already reads
  the env var at reinstall time (`install.sh:26,371-386`).
- No constitution changes — neither feature introduces a new principle,
  data-model concept, or production shortcut, and this repo has no
  `datamodel.md`/`infrastructure.md`/`ui.md` to touch.

## Technical Approach

### `--local`/`--beta`/`--stable` (update-channel-switch-flags)

Today `/ardd-update`'s step 1 always resolves on the *recorded* channel
(`Channel:` in `.project/ardd-version.md`, absent = `stable`) and only
mentions a switch as something to do "when the user raises it" — manually
re-running `source-resolve.sh --channel <new>` and setting
`ARDD_CHANNEL=<new>` for step 4's reinstall. This plan promotes that
into three explicit flags on the skill itself:

- `--stable` / `--beta`: skip reading the recorded `Channel:` line: call
  `source-resolve.sh --channel stable` / `--channel beta` directly
  against the owned checkout, exactly like today's manual-switch path,
  and pass the matching `ARDD_CHANNEL` through to step 4's `install.sh`
  invocation so it gets re-recorded. No `source-resolve.sh` change needed
  — the flag already exists there.
- `--local`: switch to the **recorded or available dev-mode checkout**
  instead of a release tag — i.e. whatever `source-resolve.sh` would
  report as `channel=dev` (a `Source-Path` already naming a live
  checkout) or, if none is recorded, prompt for one the same way step 1's
  `resolved=false` branch already does today (never guess or search the
  filesystem). This is the one new code path in skill prose: today
  dev-mode is only ever *discovered* (the recorded `Source-Path` happens
  to be a live checkout); `--local` makes it a *deliberate* request. Since
  `install.sh` records `Source-Path: $SCRIPT_DIR` from wherever it's
  invoked, "switching to local" is just invoking the dev checkout's own
  `install.sh` in step 4 instead of the owned checkout's — no new
  resolution mechanism, just a different reinstall source and no
  `ARDD_CHANNEL` (dev-mode ignores the channel flag entirely, per
  `source-resolve.sh`'s existing doc comment).
- Bare form (no flag): unchanged — resolves on the recorded channel,
  exactly as today.
- Flags are mutually exclusive; more than one is a usage error, same
  style as `source-resolve.sh`'s own `reason=usage` handling (skill-level
  prose check, not a new script — the existing scripts never see
  more than one channel value at a time).
- Every switch is deliberate and confirmed once (existing collaborative
  "ask" language extends naturally), never silently automatic — this
  matches the standing "offer a channel switch only when raised" rule,
  just making the flag itself the raising.

### Plan browser preview (plan-approval-browser-preview)

At step 10, before presenting the existing Approve/Revise/Stop
`AskUserQuestion`, offer a one-time preliminary question: view the plan
in the browser first? On yes: publish `.project/plans/plan-<slug>-...md`
via the `Artifact` tool (Markdown file — no HTML skeleton needed),
capture the resulting URL, and open/display it, then continue to the
Approve/Revise/Stop question as normal. On no (or the question is
skipped on a later loop through the same checkpoint after a Revise), go
straight to Approve/Revise/Stop. This doesn't change the three-way
decision itself — it's a pure presentation offer layered in front of it.
A revised plan (the Revise path looping back through steps 8–9) gets the
offer again each time it re-reaches step 10, so the browser preview
always reflects the latest draft.

## Phase Breakdown

### Phase 1: `/ardd-update` channel flags [feature: update-channel-switch-flags]

- T001 [artifacts: none] Rewrite `skills/ardd-update/SKILL.md`'s Usage
  section to document `--local`, `--beta`, `--stable` alongside the
  existing bare form and `--reconfigure`, and rewrite step 1 to branch on
  the flag: `--stable`/`--beta` call `source-resolve.sh --channel
  <flag>` directly (bypassing the recorded-channel read) and set
  `ARDD_CHANNEL=<flag>` for step 4; `--local` resolves the dev-mode
  checkout (recorded `Source-Path` if it's already `channel=dev`, else
  prompt for a path per the existing `resolved=false` handling) and
  reinstalls from it in step 4 without setting `ARDD_CHANNEL`. Mutually
  exclusive flags are a usage error, reported before step 1 proceeds.
  Prose-only change (Principle V documentation-only exception — no test
  task).
- T002 [artifacts: none] [parallel] Update
  `docs/reference/skills/ardd-update.md`'s Usage and "What a run does"
  sections to match T001.

### Phase 2: `/ardd-plan` browser-preview offer [feature: plan-approval-browser-preview]

- T003 [artifacts: none] Add the browser-preview offer to
  `skills/ardd-plan/SKILL.md` step 10, immediately before the existing
  Approve/Revise/Stop `AskUserQuestion`: a one-time preliminary question
  asking whether to view the plan in the browser first; on yes, publish
  the plan file via the `Artifact` tool, open it, and display the
  resulting URL, then proceed to the existing three-way question
  unchanged. Note that this offer re-fires each time a Revise loop
  returns to step 10 (the artifact republish targets the same URL on a
  later redeploy of the same plan file). Prose-only change (Principle V
  documentation-only exception — no test task).
- T004 [artifacts: none] [parallel] Update
  `docs/reference/skills/ardd-plan.md` to document the browser-preview
  offer at the approval checkpoint.

## Open Questions

- Should `--local`'s dev-mode prompt (when no `Source-Path` is currently
  dev-mode) offer to remember the path the same way install-time
  `--source`/`$ARDD_SOURCE` does, or always ask fresh each `--local` run?
  Left to the implementing session's judgment — either is consistent with
  existing dev-mode handling, which never auto-remembers beyond what
  `install.sh` itself records via `Source-Path`.
- Does the plan-preview artifact need a stable favicon/title scheme
  across different plans, or is a generic one fine? Cosmetic, left to
  implementation.
