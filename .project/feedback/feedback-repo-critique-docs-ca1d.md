---
status: open      # open -> planned
created: 2026-07-06
plan: null        # set to the consuming plan's filename once planned
---

# Feedback — repo critique, part 2 of 2: docs / positioning

Source: full-repo critique session 2026-07-06, revised after a
second-agent review; split from `feedback-repo-critique-6ad1.md` (the
structural/determinism half) so each group feeds its own plan.
Parallelization correction from the review: these items are logically
independent but three of them edit the same README.md/USAGE.md text, so
the docs-touching items (tiering, four-artifact demotion, naming) must
ride ONE branch or they'll merge-conflict; only the archaeology strip and
the frontmatter-description work are safely parallel to that branch.

## Bugs

None.

## UX

- [ ] (P2, docs-touching — same branch as the other README/USAGE items)
  Docs present all 18 skills with equal weight, which reads heavier than
  the system is. Tier the documentation: a core loop (bootstrap/refine →
  plan → tasks → implement, analyze auto-running) presented as *the*
  workflow, with sync/render/critique/verify/featurize/codify/converge/
  feedback documented as opt-in extensions. README/USAGE restructure
  only — no skill behavior change.
- [ ] (P3, docs-touching — same branch) ADD vs. ARDD naming is
  inconsistent across README, USAGE, skill names, and docs. Pick one name
  and apply it everywhere before developing this publicly.
- [ ] (P3, docs-touching — same branch) Document inline-on-a-branch as
  the blessed degradation path for delegation: the worktree model depends
  on undocumented, regressing harness behavior (`worktree.baseRef`), and
  a harness regression should degrade to a documented fallback, not a
  workflow outage. Docs-only; worktree-align.sh already handles the
  mechanics.

## Reconsidered

- [ ] (P2, parallel-safe vs. the docs branch — touches CLAUDE.md and
  skill prose, not README/USAGE) Shipped skill prose and CLAUDE.md carry
  development archaeology (history notes about removed designs,
  smoke-test dates, reverted-approach explanations in ardd-implement /
  ardd-plan; ~24KB CLAUDE.md) — context cost and distraction in every
  target-project invocation, in tension with Principle VII for prose.
  Move history to source-repo-only `docs/decisions/` notes; keep skills
  and CLAUDE.md to current invariants with one-line pointers. Estimated
  25–30% skill token reduction, no behavior change intended — safest to
  *land* after the smoke test from part 1 exists, but drafting can start
  anytime.
- [ ] (P2, docs-touching — same branch; also edits ardd-bootstrap)
  The fixed four-artifact set (constitution/infrastructure/datamodel/ui)
  has a web-app bias — this repo's own dogfooded `.project/artifacts/`
  contains only constitution.md and features.md, so the flagship set
  didn't fit the flagship project. Demote the four to suggested defaults
  per project shape (ardd-bootstrap already uses judgment); stop
  presenting them in README/USAGE as the definition of the system ("a
  declared set of living artifacts," not "four living documents").
- [ ] (P2, parallel-safe vs. the docs branch until its final
  table-regeneration step, which should land after the docs branch
  merges) Skill descriptions are duplicated in four places (README table,
  USAGE, the WORKFLOW.md template embedded in ardd-bootstrap step 6 and
  ardd-codify step 6, each SKILL.md) and lint-docs.sh checks names only,
  so descriptions will drift the way USAGE command names once did. Add
  YAML frontmatter with a `description:` field to each SKILL.md (also
  aids Claude Code skill discovery), generate the README/WORKFLOW tables
  from it, and extend lint-docs.sh to catch drift. Fold in the related
  audit finding: WORKFLOW.md is explicitly non-project-specific, so stop
  having bootstrap/codify transcribe it from embedded prose — ship it as
  a static template via install.sh and `cp` it into place.
