# artifact-driven-dev — Project Status

_Updated: 2026-07-09 (post-/ardd-implement, quickstart-new-project complete). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.3) | — |

## Open Questions

None in the artifact. Two plan-scoped questions remain recorded in
`plan-quickstart-new-project-2026-07-09.md` and were deliberately not
resolved: whether `new.sh` should optionally `gh repo create`, and whether it
should pin a tag rather than track `main`. Neither blocks anything; log a
feature if either becomes wanted.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-06 (third pass): the
behavioral-smoke-tier claim still exceeds coverage. Reduced-scope residue of
already-surfaced 970d935b. Worth refreshing with `/ardd-verify`: three
features have landed since that pass (next-step-prompt, npx-skills-install,
quickstart-new-project), and the last of those added a source-side script
(`new.sh`) and a skill (`/ardd-kickoff`) that verify has never examined.

## Feedback

None open — all 14 feedback files are `status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see
`.project/features/`. `quickstart-new-project` completed today
(`tasks-quickstart-new-project-80e5.md`, 10/10): `new.sh` curl-to-sh
quickstart, the `/ardd-kickoff` greenfield first-session skill, a
`new-project` CI job, and docs. Constitution amended to v1.2.3 to record
`curl | sh` as a third acquisition channel converging on `install.sh`.

## In Flight

Branch `quickstart-new-project` (this checkout): 5 commits ahead of `main`,
work complete, awaiting merge. No sibling worktrees. The
`tasked→implemented` register flip rides this branch and lands on merge.

## Recommended Next Step

Merge `quickstart-new-project` into `main` (fast-forward), then re-run
`./install.sh .` to refresh the dogfooded skill copies and re-record
`ardd-version.md` at the merge commit. The quickstart's public `curl` URL
points at `main`, so it does not resolve until this branch is pushed —
verify the one-liner end to end after pushing. Then `/ardd-verify` to
refresh `DEFECTS.md` against `new.sh` and `/ardd-kickoff`.
