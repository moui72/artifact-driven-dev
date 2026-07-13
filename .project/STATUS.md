# artifact-driven-dev — Project Status

_Updated: 2026-07-13 (documentation rewritten ground-up: minimal README,
USAGE as index + How-do-I routing + picker ergonomics notes,
docs/{concepts,install,example}.md, 9 guides incl. from-spec-kit, full
reference set with generator-backed skill pages; validated by a
four-agent review — doc findings fixed, system findings planned and
tasked). Keep this current as artifacts are refined and open questions
are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.8.0; `delegation: eager`, `merge_policy: auto`) | — |

## Open Questions

None in the artifact. One plan-scoped item remains, non-blocking
(`plan-quickstart-new-project-2026-07-09.md` — optional `gh repo create`).

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-12 (seventh pass). The
smoke-tier entry (`7efff3a5`) clears when the deliberately-unprovisioned
`ANTHROPIC_API_KEY` is provisioned; the next `/ardd-defects` pass
re-derives it. Note: the docs rewrite (uncommitted) touches doc/script
surfaces DEFECTS.md was verified against — worth a re-run after it lands.

## Feedback

None open — `feedback-docs-review-findings-f868.md` (all 5 items
incorporated) consumed by `plan-docs-review-findings-2026-07-13-1cf4.md`
(approved 2026-07-13), which produced
`tasks-docs-review-findings-3aec.md` (**ready**, 6 tasks / 4 phases:
skill-prose fixes, document `retired`, drop the "(formerly ardd-X)"
suffixes + regenerate, CLAUDE.md convention note).

## Recent Releases

v0.9.1 (2026-07-13) — first fully-automatic two-channel cycle:
v0.9.1-beta.1 on push, stable cut by dispatch, `release` branch created
and protected. v0.9.0 (2026-07-12) — first GitHub release; all five
consumers repointed. Full history: GitHub Releases and
`docs/decisions/0006`/`0007`.

## Feature Backlog

0 backlogged · 10 implemented · 1 retired — see `.project/features/`.
The register is fully worked; new scope arrives via `/ardd-backlog` or
the open feedback above.

## Audit

`.project/audit.md`: 4 open items — 3 suggestions (new.sh tty narrative →
decision record; Governance workflow-field exemption; primary-on-main
deterministic guard, MOOT after the v1.7.0 retirement — reject/close it)
and 1 risk (smoke key unprovisioned).

## In Flight

Nothing — no sibling worktrees, no reap candidates. (The docs rewrite is
committed and pushed — `694431d`, published as v0.9.2-beta.1; the new
plan/tasks/feedback state sits uncommitted in the working tree.)

## Recommended Next Step

Run `/ardd-implement` to execute `tasks-docs-review-findings-3aec.md`
(6 prose/frontmatter tasks, PATCH-level).
