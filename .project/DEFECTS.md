# Defects

_Last verified: 2026-07-05_

## constitution.md

- **Claim:** Governance footer states `**Last Amended**: 2026-07-03`.
  **Actual:** The constitution body was amended on 2026-07-05 — the frontmatter
  itself records `last_updated: 2026-07-05`, and git shows substantive edits
  that day (e.g. `6820bc7` "T014 ... project-lock.sh", `c896120` removing
  worktree-info.sh, both touching this file). The footer's "Last Amended" date
  contradicts both the frontmatter and the commit history.
  **Location:** constitution.md:173 (footer) and :11 (frontmatter) vs `git log -1 --format='%ci' -- .project/artifacts/constitution.md` → 2026-07-05
  **Severity:** drift

- **Claim:** `**Version**: 1.0.0`, and the Sync Impact Report reads
  `Version change: (none) → 1.0.0 ... Added sections: all (initial)`.
  **Actual:** The document has been materially amended since its 2026-07-03
  ratification — the Pre-commit Enforcement script list was expanded to add
  the sync/project-lock test scripts (commit `29e63a4` "wire the three new
  sync test scripts", `6820bc7` project-lock), and a worktree-info entry was
  added then removed. Per the constitution's own Governance rules (§Governance
  points 2–3), such amendments require an updated Sync Impact Report and a
  version increment (MINOR for material expansion). Neither happened: the
  version is still 1.0.0 and the Sync Impact Report still describes only the
  initial creation.
  **Location:** constitution.md:1-6 (Sync Impact Report), :173 (Version), :161-172 (Governance procedure it violates)
  **Severity:** drift

## features.md

No defects found — both entries verified against the codebase:
- `pre-commit-lint-hook` (Status: implemented): Plan
  `plan-pre-commit-lint-hook-2026-07-03.md` (status: approved) and Tasks
  `tasks-pre-commit-lint-hook-afed.md` (status: completed) both resolve;
  `hooks/pre-commit` exists and runs the enforcement script list.
- `implicit-plan-approval` (Status: implemented): Plan
  `plan-implicit-plan-approval-2026-07-03.md` (status: approved) and Tasks
  `tasks-implicit-plan-approval-455c.md` (status: completed) both resolve;
  `skills/ardd-tasks/SKILL.md` flips a selected `draft` plan to `approved`
  in place (step ~52) and `skills/ardd-plan/SKILL.md` defers approval to
  `/ardd-tasks` (lines 191-239). `lint-project.sh` reports the metadata clean.
