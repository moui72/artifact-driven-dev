# Prerelease dry-run testing (source-side, manual, no CI)

Scenario-based end-to-end testing of ArDD's *non-deterministic* half —
does `/ardd-init` produce good artifacts, does `/ardd-plan` read right,
does delegation actually isolate — the half `scripts/test-*.sh`
structurally cannot cover. Run by hand before cutting a release.
Deliberately NOT wired into GitHub Actions (solo, CI billing deferred).

First run of this pattern: 2026-07-15 pre-v1.0.0 (7 scenarios, 13 real
findings, one fix plan). Background context lives in
`dev-notes/prerelease-testing-context.md` (local-only).

## Layout

- `GUARDRAILS.md` — non-negotiable isolation + reporting rules, injected
  verbatim at the top of every subagent brief. Edit here, never fork
  per-scenario copies.
- `scenarios/S1.md` … `S7.md` — one durable brief per scenario: setup,
  steps, **scripted answers** for every interactive pause (background
  subagents have no `AskUserQuestion` tool), and a pass/fail checklist.
- Reports land in `dev-notes/prerelease-runs/<run-id>/Sx-report.md`
  (gitignored; on repo disk, not the session scratchpad, so they survive
  subagent death — the 2026-07-15 outage lesson).

## How to run

Invocation is Claude-Code-driven — `Agent`-tool dispatch can't be
scripted from `sh`. Use the source-side skill:

    /prerelease-sweep smoke        # S1 + S5 + S7 (routine betas)
    /prerelease-sweep full         # all seven (before a stable cut)
    /prerelease-sweep S3 S6        # named subset (e.g. regression rerun)

(`.claude/skills/prerelease-sweep/` — repo-local, never installed to
consumers; install.sh only copies from `skills/`.) It creates the run
directory, launches one background subagent per scenario with
GUARDRAILS.md + the brief, monitors, and summarizes reports when done.
Manual fallback: do the same by hand — paste GUARDRAILS.md + the brief
into a background `Agent` call, one per scenario.

## Tiering

- **smoke** (every beta worth checking, ~1 hr wall clock): S1
  (acquisition), S5 (core solo loop), S7 (peripheral sweep). One from
  each axis; cheap enough to run routinely.
- **full** (before any stable dispatch, or after a large skill-prose
  batch): all seven. S6 tests the delegation **script layer** against a
  manually-created second worktree; the `Agent`-tool
  `isolation: "worktree"` nesting question is explicitly out of sweep
  scope (see Coverage backlog).
- **regression rerun**: after a fix batch lands, rerun exactly the
  scenarios that produced the fixed findings, with the fixed finding IDs
  listed in the dispatch prompt so the subagent explicitly re-checks each.

## Judging and acting on results (the loop)

1. **Triage first, feedback second.** Read every report; build a triage
   table in the run directory (`TRIAGE.md`): finding → accept /
   duplicate / harness-artifact / taste-only-defer. Harness artifacts
   (no-AskUserQuestion, scratchpad quirks, spend-limit deaths) never
   become feedback entries.
2. Accepted findings → one consolidated `/ardd-feedback` capture per run
   (bugs + UX), same as the 2026-07-15 pass.
3. Feedback → `/ardd-plan` → fixes, the normal loop. Taste-only items can
   sit in the triage table across runs; promote one only when it recurs.
4. After fixes merge: regression rerun (above), then cut.

## Coverage backlog (not yet written as briefs)

- `install.sh --existing` on a populated non-ArDD project
- multi-hop `/ardd-update` stacking 3+ migrations deliberately
- dev-mode / `--source` acquisition
- `defects-unsurfaced.sh` re-offer/decline bookkeeping across repeated
  `/ardd-plan` runs
- `workflow_mode` switching mid-project via `/ardd-update --reconfigure`
- the `Agent`-tool nested-worktree question — **structurally untestable
  from any sweep dispatch** (established over two runs: a background
  subagent's worktree call is 2 levels deep, where a silent collapse
  onto the primary checkout was observed on 2026-07-15; a top-level
  dispatch's `isolation: "worktree"` binds to the ArDD repo itself,
  not the scratch project — no parameter targets a foreign repo).
  S6 was rewritten 2026-07-17 to cover only the script layer.
  Resolving the harness question requires a **manual, separate
  top-level session**: open a second terminal, `cd` into a scratch
  target project (ArDD installed, one `ready` tasks file), run
  `claude`, run `/ardd-implement`, choose delegate at the gate, and
  verify via `git worktree list` from the primary that a real second
  worktree carried the work — that is 1-deep nesting, the actual
  consumer path. The 2-deep case matters only to this sweep harness,
  not to consumers, and stays unresolved-by-design; the defensive
  positive-worktree check in `worktree-align.sh` makes any repeat
  collapse loud.

## Maintenance rules

- Briefs are versioned product-adjacent files: when a skill's interactive
  pauses change (new gate, renamed prompt), update the affected briefs'
  "Scripted answers" in the same commit — a stale scripted answer stalls
  or misleads a subagent the same way a stale enum misleads the linter.
- Anything learned operationally (new failure mode, new guardrail) goes
  into GUARDRAILS.md or this README, not a chat transcript.
- Coverage graduation: dispatcher-stressed surfaces earn standing brief
  lines via the sweep skill's triage step (prerelease-sweep SKILL.md,
  step 6) — brief edits land through the fix plan, never mid-sweep.
