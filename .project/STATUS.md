# artifact-driven-dev — Project Status

_Updated: 2026-07-04. Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ | — |

## Open Questions

None.

## Code-vs-Artifact Defects

Never checked — run `/ardd-verify` to compare artifacts against the codebase.

## Feedback

None open — `feedback-plan-defects-check-4cdb.md` was incorporated into
`plan-worktree-state-hygiene-2026-07-04.md` this run and is now
`status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 2 implemented — see `.project/artifacts/features.md`.

## Recommended Next Step

`tasks-worktree-state-hygiene-5dd6.md` is now `status: completed` — all 21
tasks done (14 original + 7 gap tasks across three `/ardd-converge`
reconciliation passes mid-session, T015–T021), plus two further commits
after a live smoke test (see below), all on the `worktree-state-hygiene`
branch. **Every commit on this branch is unsigned** — 1Password was locked
this session — **the whole range needs re-signing before this branch is
pushed**.

A live smoke test — actually delegating via `Agent`'s `isolation:
"worktree"` against a throwaway plan+tasks file and inspecting the result,
rather than reasoning about it — found the delegated worktree's branch
had a merge-base with `origin/main`, not with the coordinator's current
commit: it never saw either pre-delegation commit. This traces to the
harness's `worktree.baseRef` setting (default `fresh`, branches from
`origin/<default-branch>`) — not something a `SKILL.md` can override —
and it invalidates the core premise the whole state-commit-before-branch
design rested on, especially given this project's local-commit-only
convention. As a result, `/ardd-implement`/`/ardd-converge` now default
the delegation question's suggested answer to **"no"** and label it
experimental, rather than defaulting to "yes." The same live test also
found and fixed a real, reproducible bug: `test-branch-info.sh` leaked
`GIT_DIR` into its fixture repos when run as this repo's own pre-commit
hook, causing deterministic commit failures (fixed, confirmed red/green).
It also surfaced a side effect — creating the `Agent`-tool worktree
flipped this repo's `.git/config` to `core.bare = true`, breaking ordinary
git commands in the primary checkout until manually reverted — noted in
CLAUDE.md as something to watch for.

`/ardd-plan` still deliberately never delegates — its draft plan file is
itself the state `/ardd-tasks` needs to see, so a worktree would trap it
there until manual merge. Plan's `features: []`, so nothing in
`features.md` changed from any of this.

Next: review the diff, re-sign the commit range, then merge
`worktree-state-hygiene` into `main` (this repo's dogfooded `.project/`
files were not exempted from that — they're on this branch too). If
delegation is worth relying on later, either confirm a
`worktree.baseRef: head`-equivalent setting fixes the base-ref mismatch,
or accept it as an opt-in, verify-before-use feature.

Separately, unrelated to this plan: `tasks-process-review-fixes-cfd8.md`
(bound to the already-merged `process-review-fixes` branch, PR #1) is at
`status: ready` with none of its tasks checked off, even though its branch
is merged into `main` — worth confirming whether that work actually landed
before treating it as done. No code-vs-artifact baseline has ever been
taken — run `/ardd-verify` when convenient.
