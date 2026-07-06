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

2 open feedback files, both from the 2026-07-06 downstream upgrade:
`feedback-migration-dangling-tags-b959.md` (1 bug — migration 0003
leaves dangling `features` bracket-tags) and
`feedback-artifacts-none-tag-9fc6.md` (1 UX — no sanctioned way to mark
a task as needing no artifacts; ardd-tasks' "MUST state" wording drives
agents to invent placeholder names like `none`). Both are small; bundle
into the next plan together. The 5 older feedback files are `planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 2 implemented — now as per-feature
files in `.project/features/` (migration 0003 ran; legacy features.md
removed).

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
DEFECTS.md entry clears. There are also two small open
feedback items (migration tag gap; artifacts-none convention) for the
next `/ardd-plan` to consume — bundle them into whatever plan comes
next. Otherwise: normal
feature work via `/ardd-feature` → `/ardd-plan <slug>`.
