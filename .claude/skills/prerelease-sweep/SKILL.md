---
name: prerelease-sweep
description: Source-side only (never installed to consumers). Dispatch the prerelease dry-run scenarios in tests/prerelease/ as background subagents with durable progressive reporting, then triage the results. Usage — /prerelease-sweep smoke | full | S<n> [S<n> ...]
---

# Prerelease sweep dispatcher

You are running ArDD's manual prerelease dry-run exercise. The briefs and
rules live in `tests/prerelease/` — read `tests/prerelease/README.md`
first if you haven't this session. This skill is a thin dispatcher: the
briefs are the product; never improvise scenario content from memory.

## 1. Resolve the tier

- `smoke` → S1, S5, S7
- `full` → S1–S7
- explicit `S<n>` list → exactly those
- no argument → ask the user (smoke / full / subset). If the user
  mentions this is a regression rerun after a fix batch, also ask for
  the fixed finding IDs and include them in each relevant dispatch
  prompt with "explicitly re-verify each of these".

If the set includes S6, tell the user about its known-uncertain status
(see the brief) and offer to run S6 steps from THIS top-level session
instead of a background subagent (one less nesting level); background it
only if they say so.

## 2. Prepare the run

1. `run_id` = `YYYY-MM-DD-<short>` (date + 4 hex chars).
2. `mkdir -p dev-notes/prerelease-runs/<run_id>` (repo-relative; this is
   the durable report location — never the session scratchpad).
3. Write `dev-notes/prerelease-runs/<run_id>/RUN.md`: date, tier,
   scenario list, source HEAD (`git rev-parse HEAD`), and for beta-path
   scenarios the latest published beta tag.
4. Create a scratch root for the subagents, e.g.
   `dev-notes/prerelease-runs/<run_id>/scratch/` (also gitignored).

## 3. Dispatch

For each scenario, launch ONE background `Agent` (general-purpose) whose
prompt is, in order:

1. The full text of `tests/prerelease/GUARDRAILS.md`, verbatim.
2. Concrete bindings: `$SCRATCH` = the scratch root above; report file =
   `dev-notes/prerelease-runs/<run_id>/S<n>-report.md` (absolute path);
   local ArDD source checkout path; any dispatcher-supplied substitutions
   (S2/S7 clone source, S3's "recent features to stress" list — derive
   that list from `git log` since the last stable tag).
3. The full text of `tests/prerelease/scenarios/S<n>.md`, verbatim.
4. Closing reminder: "Report file first, append after every major step,
   scripted answers only — you have no AskUserQuestion tool."

Launch all selected scenarios in parallel. They are mutually isolated by
scratch subdirectory; no ordering dependency exists.

## 4. Monitor and collect

As each subagent returns, note completion in RUN.md. If one dies, its
progressive report is the deliverable — record `died-partial`, don't
discard. Offer the user a redrive for died scenarios.

## 5. Triage (do NOT skip straight to /ardd-feedback)

When all are done, read every `S<n>-report.md` and write
`dev-notes/prerelease-runs/<run_id>/TRIAGE.md`: one table row per
finding — id, scenario, kind, one-liner, disposition ∈ accept /
duplicate / harness-artifact / taste-defer. Harness artifacts (missing
AskUserQuestion, scratchpad/spend-limit incidents, S6 nesting ambiguity)
never leave the triage table. Present the table to the user and get
dispositions confirmed.

Then, on the user's go-ahead only: run `/ardd-feedback` once with the
accepted findings consolidated (this repo dogfoods its own `.project/`),
and remind that the normal next loop is `/ardd-plan` → fixes →
regression rerun (`/prerelease-sweep S<the affected ones>`).

Never commit anything during a sweep; `dev-notes/` is gitignored and the
only writes outside it are the subagents' sandboxed scratch dirs.
