# artifact-driven-dev — Project Status

_Updated: 2026-07-09 (post-/ardd-tasks, npx-skills-install tasked). Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.2.2) | — |

## Open Questions

None.

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-06 (third pass):
the behavioral-smoke-tier claim still exceeds coverage. Reduced-scope
residue of already-surfaced 970d935b. Run `/ardd-verify` to refresh —
worth doing soon: the next-step-prompt implementation (merged today)
added skill behavior verify has never checked.

## Feedback

None open — all 14 feedback files are `status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 1 tasked · 5 implemented — see
`.project/features/`. `npx-skills-install` is `tasked`
(plan approved: `plan-npx-skills-install-2026-07-09.md`; tasks:
`tasks-npx-skills-install-568d.md`, ready, 0/6).

## In Flight

On branch `npx-skills-install` (this checkout, not yet merged to
`main`), all uncommitted: constitution v1.2.2 (npx acquisition-channel
standing decision), the approved plan, the ready tasks file (0/6), and
the register flips. No sibling worktrees.

## Recommended Next Step

Run `/ardd-implement` and pick `tasks-npx-skills-install-568d.md`
(6 tasks: CLI frontmatter compat + lint, /ardd-setup skill,
gen-skill-docs registration, install.sh symlink guard, docs, live npx
verification — T006 is manual/network-dependent). Standing threads:
re-sign today's unsigned commits before pushing; smoke-key
provisioning (970d935b).
