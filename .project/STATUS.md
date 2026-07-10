# artifact-driven-dev — Project Status

_Updated: 2026-07-09 (post-/ardd-implement, launch-prompt complete). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.4) | — |

## Open Questions

None in the artifact. Two plan-scoped questions remain recorded in
`plan-quickstart-new-project-2026-07-09.md`: whether `new.sh` should
optionally `gh repo create`, and whether it should pin a tag rather than
track `main`. Neither blocks anything.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-06 (third pass): the
behavioral-smoke-tier claim still exceeds coverage. Reduced-scope residue of
already-surfaced 970d935b. Now four features stale: `/ardd-verify` has never
examined `new.sh`, `/ardd-kickoff`, or the v1.2.4 interactivity rules. Worth
a pass.

## Feedback

None open — all 15 feedback files are `status: planned`.
`feedback-launch-prompt-020f.md` was consumed today by
`plan-launch-prompt-2026-07-09.md`; both its items were incorporated.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see
`.project/features/`. The `launch-prompt` work carried no feature slug: it
came from feedback on an implementation, not from a backlogged idea.

## In Flight

Branch `launch-prompt` (this checkout): 3 commits ahead of `main`, work
complete, awaiting merge. No sibling worktrees.

`main` itself is 7 commits ahead of `origin/main` and unpushed — the SSH
agent (1Password) was locked all session, so `git push` could not
authenticate. Commits are signed with the on-disk `id_claude_signing` key and
verify locally; only the push is blocked.

## Recommended Next Step

Merge `launch-prompt` into `main`, re-run `./install.sh .`, then push once
1Password is unlocked. The quickstart's public `curl` URL points at `main`,
so it does not resolve until that push lands. After pushing, run the
one-liner end to end. Then `/ardd-verify` to refresh `DEFECTS.md` against
`new.sh`, `/ardd-kickoff`, and v1.2.4.
