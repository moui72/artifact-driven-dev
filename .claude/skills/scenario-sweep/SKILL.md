---
name: scenario-sweep
description: Source-side only (never installed to consumers; formerly prerelease-sweep). Dispatch the dry-run scenarios in tests/scenarios/ as background subagents with durable progressive reporting, then triage the results. Usage — /scenario-sweep smoke | full | S<n> [S<n> ...]
---

# Scenario sweep dispatcher

You are running ArDD's manual scenario dry-run exercise (the pre-release gate and regression-rerun harness). The briefs and
rules live in `tests/scenarios/` — read `tests/scenarios/README.md`
first if you haven't this session. This skill is a thin dispatcher: the
briefs are the product; never improvise scenario content from memory.

## 1. Resolve the tier

- `smoke` → S1, S5, S7
- `full` → S1–S8
- explicit `S<n>` list → exactly those
- no argument → ask the user (smoke / full / subset). If the user
  mentions this is a regression rerun after a fix batch, also ask for
  the fixed finding IDs and include them in each relevant dispatch
  prompt with "explicitly re-verify each of these".

S6 is dispatched as a normal background subagent like every other
scenario — it tests the delegation script layer against a
manually-created worktree and never makes an `isolation: "worktree"`
`Agent` call itself (see the brief's scope note; the harness-level
nesting question is out of sweep scope, per the README coverage
backlog). S8, by contrast, IS the scenario that makes real
`isolation: "worktree"` `Agent` calls — it dispatches its own two
worktree subagents from within its (already background) sweep
subagent, exercising the fan-out/merge/reap chain end to end. S3 and
S7 also carry additional steps (channel-switch flow; epic-label
coverage, respectively) beyond what their scenario briefs originally
covered — no separate scenario numbers were minted for those, the
briefs themselves grew.

## 2. Prepare the run

1. `run_id` = `YYYY-MM-DD-<short>` (date + 4 hex chars).
2. `mkdir -p dev-notes/scenario-runs/<run_id>` (repo-relative; this is
   the durable report location — never the session scratchpad).
3. Write `dev-notes/scenario-runs/<run_id>/RUN.md`: date, tier,
   scenario list, source HEAD (`git rev-parse HEAD`), and for beta-path
   scenarios the latest published beta tag.
4. Create a scratch root for the subagents, e.g.
   `dev-notes/scenario-runs/<run_id>/scratch/` (also gitignored).

## 3. Dispatch

For each scenario, launch ONE background `Agent` (general-purpose) whose
prompt is, in order:

1. The full text of `tests/scenarios/GUARDRAILS.md`, verbatim.
2. Concrete bindings: `$SCRATCH` = the scratch root above; report file =
   `dev-notes/scenario-runs/<run_id>/S<n>-report.md` (absolute path);
   local ArDD source checkout path; any dispatcher-supplied substitutions
   (S2/S7 clone source, S3's "recent features to stress" list — derive
   that list from `git log` since the last stable tag).

   While deriving S3's list, also grep-and-judge each recent
   consumer-facing surface against `tests/scenarios/*.md` —
   judge, don't slug-match: briefs deliberately don't name register
   slugs verbatim, so decide whether some brief step genuinely
   exercises the surface. Record every consumer-facing surface that has
   no brief line despite having been through a prior sweep as a
   `never-graduated: <surface>` line in RUN.md; these carry into
   triage's Graduation step (step 6).
3. The full text of `tests/scenarios/S<n>.md`, verbatim.
4. Closing reminder: "Report file first, append after every major step,
   scripted answers only — you have no AskUserQuestion tool."

Launch all selected scenarios in parallel. They are mutually isolated by
scratch subdirectory; no ordering dependency exists.

## 4. Monitor and collect

As each subagent returns, note completion in RUN.md, along with its
reported usage — `subagent_tokens`, `tool_uses`, `duration_ms` from the
task-completion notification. If one dies, its progressive report is the
deliverable — record `died-partial`, don't discard (and its usage
figures, if any were reported, still count toward the cost estimate
below). Offer the user a redrive for died scenarios.

## 5. Cost estimate (write to disk, every run)

Once every scenario has returned (or died-partial), append a **Cost**
section to `RUN.md` — a small table, one row per scenario:
`scenario | tokens | tool calls | wall clock`, plus a total row. Give a
rough dollar range from the total tokens using blended Sonnet pricing,
explicitly caveated: the harness only reports a total token count per
subagent, not the input/output/cache-read/cache-write split that pricing
actually depends on, so treat the dollar figure as order-of-magnitude
only, never precise billing. This is a standing requirement for every
sweep, not just the first one — the point is a durable, on-disk cost
history across runs (`dev-notes/scenario-runs/*/RUN.md`), not a
one-off. Report the same table + estimate to the user in this turn too,
not just on disk.

## 6. Triage (do NOT skip straight to /ardd-feedback)

When all are done, read every `S<n>-report.md` and write
`dev-notes/scenario-runs/<run_id>/TRIAGE.md`: one table row per
finding — id, scenario, kind, one-liner, disposition ∈ accept /
duplicate / harness-artifact / taste-defer, and a mandatory
`graduate ∈ yes / no / n-a` column. Harness artifacts (missing
AskUserQuestion, scratchpad/spend-limit incidents) never leave the
triage table. Present the table to the user and get
dispositions confirmed.

**Graduation.** Every accepted finding on a dispatcher-stressed surface
(one exercised only via dispatcher-supplied substitutions, not a standing
brief line), and every `never-graduated:` carry-in from RUN.md, gets
`graduate = yes` and produces a brief-coverage item in the consolidated
`/ardd-feedback` capture below, naming the target scenario and the
1–3-line step to add — extend an existing S<n> whose setup already
provides the precondition; propose a new S-file only when no existing
scenario's axes fit. Brief edits land via the fix plan and are validated
by the regression rerun — never edit `tests/scenarios/` during the
sweep itself. Criteria (anti-bloat): consumer-facing accepted findings
only; taste-defers, harness artifacts, and source-side surfaces never
graduate (`no` / `n-a`); smoke-tier additions must respect the ~1 hr
smoke budget — costly steps go full-tier.

Then, on the user's go-ahead only: run `/ardd-feedback` once with the
accepted findings (including any graduation brief-coverage items)
consolidated (this repo dogfoods its own `.project/`),
and remind that the normal next loop is `/ardd-plan` → fixes →
regression rerun (`/scenario-sweep S<the affected ones>`).

Never commit anything during a sweep; `dev-notes/` is gitignored and the
only writes outside it are the subagents' sandboxed scratch dirs.

`/docs-sweep` is the companion manual check for the human-facing doc
surface (README/USAGE/docs/) — run it alongside this one before a stable
release.
