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

None open — all 8 feedback files are `status: planned`. The three from
2026-07-06 (migration dangling-tags, artifacts-none convention, docs
review/three-tier reframe) were consumed this run by
`plan-built-with-ardd-badge-2026-07-06.md`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 3 implemented —
`built-with-ardd-badge` completed this run (flip rides branch
`built-with-ardd-badge`, lands on merge).

## In Flight

Nothing — `ardd-state-determinism` merged into `main` (fast-forward,
2026-07-06) and the branch was deleted; the dogfooded skill copies were
refreshed via `./install.sh .`.

## Recommended Next Step

`tasks-built-with-ardd-badge-2ebc.md` is **completed** (11/11) on branch
`built-with-ardd-badge`: badge template + opt-in install.sh suggestion,
migration 0004 (dangling register tags — downstream repos fixed on next
install), artifacts-none convention (softened wording + pointed lint
message), generator workflow ordering, the three-tier docs reframe
(Getting started / core loop with feature+feedback intake / Extensions),
guides/continuing.md, USAGE bootstrap rewrite, staleness sweep, README
restructure. **All commits on this branch are unsigned (1Password
locked) — re-sign before pushing** (`git rebase HEAD~N --exec 'git
commit --amend --no-edit -S -n'` after unlocking). Then: merge into
main, `./install.sh .`, push, and re-install downstream (applies
migration 0004 and offers the badge).
