# artifact-driven-dev — Project Status

_Updated: 2026-07-06 (post-/ardd-implement, ardd-state-determinism complete). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.0) | — |

## Open Questions

None.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-06 (third pass):
the behavioral-smoke-tier claim still exceeds coverage (2 scenarios
exist, converge/feedback/refine/sync paths uncovered, none executable
until the API key is provisioned). This is the reduced-scope residue of
already-surfaced 970d935b — /ardd-plan won't re-prompt it. The BSD-sed
defect (58bd7dd2) cleared this run. Run `/ardd-verify` to refresh.

## Feedback

3 open feedback files:
`feedback-migration-dangling-tags-b959.md` (1 bug — migration 0003
leaves dangling `features` bracket-tags),
`feedback-artifacts-none-tag-9fc6.md` (1 UX — no sanctioned
no-artifacts annotation; agents invent `none`), and
`feedback-docs-review-core-loop-5ef3.md` (5 bugs, 3 UX, 1 reconsidered —
docs review: staleness sweep, table ordering, README section moves, a
new guides/continuing.md, and the three-tier reframe putting
feature/feedback in the core loop as the recurring delivery cycle's
intake). All three fit one plan comfortably. The 5 older feedback files
are `planned`.

## Feature Backlog

1 backlogged · 0 planned · 0 tasked · 2 implemented — per-feature files
in `.project/features/`. Backlogged: `built-with-ardd-badge` (opt-in
"built with ARDD" README badge injectable by install.sh into downstream
consumers) — target with `/ardd-plan built-with-ardd-badge`, or bundle
with the three open feedback files.

## In Flight

Nothing — `ardd-state-determinism` merged into `main` (fast-forward,
2026-07-06) and the branch was deleted; the dogfooded skill copies were
refreshed via `./install.sh .`.

## Recommended Next Step

Both critique plans are fully landed on `main` and pushed. Nothing is
in flight. The one open thread is smoke-harness promotion: provision
the `ANTHROPIC_API_KEY` secret, prove the two scenarios actually run
(expect a tuning pass — headless `claude -p` against interactive skill
gates is unexercised), drop `continue-on-error`, then extend scenarios
toward the uncovered paths (converge/feedback/refine/sync) so the last
DEFECTS.md entry clears. Three open feedback files
await the next `/ardd-plan`: the docs-review batch (three-tier core-loop
reframe + continuing.md guide + staleness fixes) plus the two small
downstream-upgrade items — all bundle into one plan comfortably. Note
the reframe item (F009 in 5ef3) reverses a decision from the
just-landed docs plan, so /ardd-plan will ask for explicit confirmation. Otherwise: normal
feature work via `/ardd-feature` → `/ardd-plan <slug>`.
