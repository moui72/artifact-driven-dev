# artifact-driven-dev — Project Status

_Updated: 2026-07-12 (two-channel git-ops MERGED — constitution v1.8.0;
awaiting cutover: the next push of main mints the first beta). Keep this current as artifacts are refined and open
questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.8.0; `delegation: eager`, `merge_policy: auto`) | — |

## Open Questions

None in the artifact. One plan-scoped item remains, non-blocking
(`plan-quickstart-new-project-2026-07-09.md` — optional `gh repo create`).

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-12 (seventh pass). The
smoke-tier entry (`7efff3a5`) was accepted into the merge-driver plan:
scenarios for Reconcile mode and both `/ardd-init` modes now exist
(structurally verified; still gated on the deliberately-unprovisioned
`ANTHROPIC_API_KEY`, now documented at the point of contact). The residual
"never executed" state clears when the key is provisioned — next
`/ardd-defects` pass will re-derive the narrowed entry.

## Feedback

None open — `feedback-git-ops-channels-9f03.md` vetted by
`research-two-channel-git-ops-2026-07-12-450d.md` (proceed verdict) and
consumed by `plan-git-ops-channels-2026-07-12-e77e.md`.

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

0 backlogged · 10 implemented · 1 retired — see `.project/features/`.

- (register fully worked: 10 implemented · 1 retired · 0 backlogged)

## Audit

`.project/audit.md`: 4 open items — 3 suggestions (new.sh tty narrative →
decision record; Governance workflow-field exemption; primary-on-main
deterministic guard, now MOOT after the v1.7.0 retirement — reject/close
it) and 1 risk (smoke key unprovisioned). The register-enum [Q] is resolved.

## Recommended Next Step

**Cutover checklist (user acts):** (1) push `main` — the beta workflow's
maiden run mints `v0.9.1-beta.1` once lint goes green (this is its
acceptance test); (2) dispatch stable-release (Actions → Run workflow,
bump=patch) when ready — creates the `release` branch and cuts `v0.9.1`
(until then the documented `…/release/new.sh` URL 404s; `main`'s copy
serves beta/dev); (3) optionally protect `release` in GitHub settings.
Also open: audit checklist; smoke key provisioning. Note: workflows need
default Actions token write permissions (`permissions: contents: write`
declared — verify if org-restricted).
