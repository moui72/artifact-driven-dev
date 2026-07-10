---
plan: plan-readme-rewrite-2026-07-10.md
generated: 2026-07-10
status: in-progress
---

# Tasks

## Phase 1: Establish ground truth

- [ ] T001 Read every claim in `README.md` against the repo — not against the
  README's own account of itself — and write a drift inventory into this
  tasks file (append it under a `## Drift inventory` heading below Phase 4;
  it is scratch state for Phases 2–4, not a shipped artifact). For each
  claim record: the claim, its line/section, and a verdict of accurate /
  stale / dangling / missing. Sources of truth, in order: `skills/*/SKILL.md`
  frontmatter and prose; the actual behavior of `install.sh` and `new.sh`;
  and `.project/artifacts/constitution.md`. Where README prose and
  `CLAUDE.md` disagree about repo architecture, `CLAUDE.md` wins unless the
  code says otherwise. Confirm at minimum the three drifts the plan already
  found (skill count, "Project structure created" omissions, dangling
  `workflow_mode` reference) and surface any others. No edits to `README.md`
  in this task.

## Phase 2: Correct the mechanical drift

- [ ] T002 [feedback: F001] Fix the skill-count claim in `README.md`'s opening
  paragraph (currently "~18 skills"; there are 21). Resolve the plan's open
  question first: prefer a claim that cannot rot — "the skills" or "a couple
  dozen skills" over an exact count that drifts every time a skill lands —
  but keep the "disciplined, not lightweight" framing that warns a prospective
  adopter about the surface area. Depends on T001. Verify: `diff` touches
  `README.md` only; `./scripts/lint-docs.sh` passes.
- [ ] T003 [feedback: F001] Rewrite the "Project structure created" block in
  `README.md` to match `.project/` and `.claude/` as they actually are. Add
  the missing entries — `features/`, `feedback/`, `STATUS.md`, `DEFECTS.md`,
  `WORKFLOW.md`, and `.claude/skills/ardd-scripts/` — each with a one-line
  gloss consistent with the existing entries' style. Confirm every path shown
  actually exists in this repo before writing it. Depends on T001. Verify:
  `diff` touches `README.md` only; `./scripts/lint-docs.sh` passes.

## Phase 3: Close the workflow_mode gap

- [ ] T004 [feedback: F001] Add a short `README.md` section documenting solo
  vs. collaborative `workflow_mode`, placed near the existing
  `next_step_prompt` prose (they are siblings — both `constitution.md`
  frontmatter workflow fields, both asked once at bootstrap, neither bumps
  the constitution version). State the operative difference: collaborative
  mode never commits to the *local* default branch, and its in-flight channel
  is a pushed draft PR rather than `inflight-worktrees.sh`. Resolve the
  dangling "Like `workflow_mode`, it's a frontmatter workflow field" reference
  (currently ~line 110) so it points at the new section. Source content from
  `CLAUDE.md`'s "Two operating modes" and `lint-project.sh`'s `workflow_mode`
  enum; invent no behavior. Depends on T002, T003 (same region of the file).
  Verify: `diff` touches `README.md` only; `./scripts/lint-docs.sh` passes.

## Phase 4: Coherence pass

- [ ] T005 [feedback: F001] Read the rewritten `README.md` start to finish as
  a first-time reader. Fix ordering/transition damage the earlier phases
  exposed — notably the dangling "For an existing project, use `install.sh`
  directly:" line that currently ends the Quickstart section by announcing the
  `## Install` heading that follows it. Confirm every internal anchor link
  (e.g. `#when-artifacts-earn-their-keep`) still resolves to a real heading.
  Then delete the `## Drift inventory` scratch section T001 appended — it is
  working state, not shipped documentation. Depends on T002, T003, T004.
  Verify: `diff` touches `README.md` only; `./scripts/lint-docs.sh` passes.
