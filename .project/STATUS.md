# artifact-driven-dev — Project Status

_Updated: 2026-07-12 (RELEASE ARC COMPLETE — v0.9.0 published, five
consumers on the release channel, primary-stays-on-main mandate retired at
constitution v1.7.0). Keep this current as artifacts are refined and open
questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.7.0; `delegation: eager`, `merge_policy: auto`) | — |

## Open Questions

None in the artifact. One plan-scoped item remains, non-blocking
(`plan-quickstart-new-project-2026-07-09.md` — optional `gh repo create`).

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-11 (sixth pass): the
behavioral-smoke-tier residue (`970d935b`, key unprovisioned). Three large
merges plus the release arc post-date that pass — a `/ardd-defects` run is
the natural next audit of the tree.

## Feedback

None open — all feedback files consumed and `planned`.

## Released: v0.9.0 (2026-07-12)

- **First GitHub release published** —
  https://github.com/moui72/artifact-driven-dev/releases/tag/v0.9.0 —
  signed tag, curated notes (the rename/fold table). Chosen over v1.0.0 to
  signal one more stabilization cycle. Rollback tag `pre-surface-cleanup`
  also pushed.
- **All five consumers repointed** (atelier, yet-another-rank-games ×2,
  assisted-review, sync-tab-scroll): `Source-Path: ~/.ardd/source`,
  `Source-Ref: v0.9.0`, `ardd-update-check` at-release everywhere; the
  surface renames + migrations 0006–0008 applied (audit.md data preserved).
  Records committed signed in four repos; yet-another-rank-games-2 installed
  but left uncommitted (its ARDD state has never been tracked — user's call).
- **Mandate retired** (constitution **v1.7.0**, decision record
  `docs/decisions/0006-release-channel.md`): no consumer reads this checkout
  live, so the primary worktree may hold a feature branch like any ordinary
  project again. CLAUDE.md section removed.
- Earlier today, same arc: skill-surface cleanup (17→14 skills, v1.0.0-ready
  names), pre-release ratchets (v1.6.0: pack semver, `retired` state,
  ardd-version.md hardening), background-by-default flow
  (`delegation`/`merge_policy` knobs), releases-as-channel (v1.5.0).

## Feature Backlog

2 backlogged · 8 implemented · 1 retired — see `.project/features/`.

- `disposable-report-merge-driver` — backlogged: `.gitattributes` merge
  driver for the disposable single-writer reports; unlocks parallel
  auto-merge fan-out.
- `worktree-reap-and-fanout` — backlogged: deterministic reap of merged
  delegated worktrees + delegation-gate fan-out (depends on the merge
  driver).

## Audit

`.project/audit.md`: 4 open items — 3 suggestions (new.sh tty narrative →
decision record; Governance workflow-field exemption; primary-on-main
deterministic guard, now MOOT after the v1.7.0 retirement — reject/close
it) and 1 risk (smoke key unprovisioned). The register-enum [Q] is resolved.

## Recommended Next Step

`main` has 2 unpushed commits (the retirement + close-out) — push when
ready. Then, in whatever order appeals: `/ardd-defects` (three merges since
the last pass), the audit checklist (one item is now moot), or
`/ardd-plan disposable-report-merge-driver` (starts the parallel-agent
thread). Post-v0.9.0 stabilization feedback accumulates via `/ardd-feedback`
toward v1.0.0.
