# artifact-driven-dev — Project Status

_Updated: 2026-07-09 (post-/ardd-implement, npx-skills-install complete). Keep this current as artifacts are refined and open questions are resolved._

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
increasingly worth doing: both next-step-prompt and npx-skills-install
(merged/completed today) added behavior verify has never checked.

## Feedback

None open — all 14 feedback files are `status: planned`.

## Feature Backlog

0 backlogged · 0 planned · 0 tasked · 6 implemented — see
`.project/features/`. `npx-skills-install` completed today
(tasks-npx-skills-install-568d.md, 6/6): npx quick start via the
vercel-labs skills CLI, `/ardd-setup` bridge skill, install.sh symlink
guard, lint-docs frontmatter checks. T006's live verification caught
and fixed a real bug (5 skill descriptions with unquoted colons were
silently dropped by the CLI's YAML parser).

## In Flight

Branch `npx-skills-install` (this checkout): 6 commits ahead of `main`,
work complete, awaiting merge. No sibling worktrees.

## Recommended Next Step

Merge `npx-skills-install` into `main` (fast-forward), then re-run
`./install.sh .` to refresh the dogfooded skill copies. Before pushing
anywhere: re-sign today's unsigned commits (1Password was locked all
session — every commit since `8c7a8db` on main and all 6 on this branch
are unsigned). After merge+push, re-verify T006's remote form
(`npx skills add moui72/artifact-driven-dev`). Then `/ardd-verify` to
refresh DEFECTS.md against today's new behavior. Standing thread:
smoke-key provisioning (970d935b).
