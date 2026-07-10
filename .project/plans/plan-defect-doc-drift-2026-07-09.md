---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: defect-doc-drift
created: 2026-07-09
features: []
surfaced-defects: [b7d2252c, f666274c]
---

# Plan — defect-doc-drift

## Goal

Bring the constitution and `README.md` back in line with what `new.sh`
actually does, closing both defects `/ardd-verify` opened on 2026-07-09.

## Scope

**Included**

- `b7d2252c` — the constitution's "no readable `/dev/tty` → safe default"
  bound, stated unconditionally but true only on the ask path; and
  `README.md`'s "it declines rather than hangs", which is false when
  `--kickoff` is passed.
- `f666274c` — "cloning one if absent", which overstates: only the owned
  `~/.ardd/source` is ever cloned.
- Constitution v1.2.4 → v1.2.5, with a Sync Impact Report.

**Not included**

- Any change to `new.sh`. Both defects are documentation drift; the code is
  correct and its behavior was deliberately chosen. This plan changes prose
  to match code, never the reverse.
- The smoke-coverage residue (`970d935b`), already tracked and not
  re-promptable. Provisioning `ANTHROPIC_API_KEY` is its own thread.

## Technical Approach

The fix is prose, but the failure it corrects is not cosmetic in kind: the
artifact stated a bound the code doesn't hold, and a *test* (`test-new.sh`
case 10) already encoded the real behavior. Where a test and an artifact
disagree, the test is the evidence and the artifact is the claim — so the
artifact moves.

The corrected rule has to name the asymmetry rather than blur it. Two
distinct things were collapsed into one sentence at v1.2.4:

| Path | Behavior | Why |
|---|---|---|
| No flag, no usable tty | decline, print next steps, exit 0 | there is no way to ask, so take the safe default |
| `--kickoff`, no usable tty | launch on inherited stdin | the user already answered; there is no question to fail to ask |

The unifying rule is *never block on a question it cannot ask* — which the
`--kickoff` path satisfies trivially, because no question is pending. The
v1.2.4 wording instead promised "when `/dev/tty` isn't readable it takes the
safe default," which describes only the first row. Say both rows.

`README.md`'s sentence is replaced, not softened: it currently makes a flat
claim a reader could rely on when scripting.

Constitution versioning: PATCH (v1.2.5). No principle, standard, or behavior
changes — this corrects a description of behavior that already shipped.
Governance requires the SIR and footer bump regardless of size.

## Phase Breakdown

Single phase; the tasks are independent and touch different files except
where noted.

- **T001** `[artifacts: constitution]` `[defect: b7d2252c]` Reword the
  interactivity paragraph to state both rows of the table above, and bump to
  v1.2.5 with a Sync Impact Report.
- **T002** `[defect: b7d2252c]` Replace `README.md:149`'s false sentence.
- **T003** `[artifacts: constitution]` `[defect: f666274c]` Tighten "cloning
  one if absent" to name the owned checkout. Same file as T001 — sequence
  after it, not parallel.
- **T004** Re-run `./install.sh .`, then `lint-docs.sh`, `lint-project.sh`,
  `test-new.sh`. Re-run `/ardd-verify` to confirm both defects drop out of
  `DEFECTS.md` — a regenerated all-clear on these two is the only real proof
  the fix landed, since no automated check can catch prose drift.

## Complexity Tracking

None.

## Open Questions

None.

## Production Annotation Summary

None.
