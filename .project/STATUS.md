# artifact-driven-dev — Project Status

_Updated: 2026-07-09 (post-/ardd-verify, fourth pass). Keep this current as artifacts are refined and open questions are resolved._

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

3 defects — see `DEFECTS.md`, last checked 2026-07-09 (fourth pass, the first
to survey `new.sh`, `/ardd-kickoff`, and constitution v1.2.4).

- `b7d2252c` (drift, **new**) — the constitution's "no readable `/dev/tty` →
  safe default" bound is stated unconditionally, but `--kickoff` launches
  anyway on inherited stdin. The behavior is intended; the artifact and
  `README.md` both describe it wrongly. `README.md`'s "it declines rather
  than hangs" is simply false when `--kickoff` is passed.
- `f666274c` (cosmetic, **new**) — "cloning one if absent" overstates: only
  the owned `~/.ardd/source` is ever cloned; a missing `--source` is a hard
  error.
- `970d935b` residue (drift, tracked) — the behavioral-smoke-tier standard
  still exceeds coverage; no scenario has ever executed, and `/ardd-bootstrap`
  (now reachable via `/ardd-kickoff`) has never had one.

The two new defects are **unsurfaced**, so the next `/ardd-plan` will offer
them for inclusion. The smoke residue will not be re-prompted.

## Feedback

None open — all 15 feedback files are `status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 7 implemented — see
`.project/features/`.

## In Flight

Nothing. `main` is clean, and `origin/main` is up to date — today's
`quickstart-new-project` and `launch-prompt` work is pushed and the public
`curl` one-liner resolves (verified end to end against the live raw URL at
commit `4761c17`).

## Recommended Next Step

Run `/ardd-plan` to fold the two new defects into a plan — both are
documentation-vs-code drift introduced by today's `launch-prompt` work, and
both are cheap: reword the constitution's interactivity bound to name the
`--kickoff`-without-tty path, fix `README.md`'s false "it declines rather than
hangs" sentence, and tighten "cloning one if absent." Provisioning
`ANTHROPIC_API_KEY` remains the standing thread that would let the smoke
scenarios actually run (`970d935b`).
