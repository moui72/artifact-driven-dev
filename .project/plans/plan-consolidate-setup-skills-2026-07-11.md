---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: consolidate-setup-skills
created: 2026-07-11
features: []
surfaced-defects: []
---

# Plan — Shrink the skill catalog (barrier-to-entry consolidation)

## Goal

Reduce the ARDD command catalog from 21 skills to a smaller, better-tiered
surface a newcomer can take in at a glance — without losing any capability.

## Scope

**In:**
- Merge `/ardd-kickoff` → `/ardd-bootstrap` (F002) and `/ardd-featurize` →
  `/ardd-codify` (F003): setup tier 5 → 3.
- Merge `/ardd-tasks` → `/ardd-plan` (F005): core tier 6 → 5, with an explicit
  approval checkpoint and a `--from <plan>` re-task re-entry mode.
- Re-tier `/ardd-analyze` and `/ardd-lint` from `extension` to core
  infrastructure (F006a).
- Teach `install.sh` to prune ardd skill dirs that no longer exist in source,
  so upgrades don't leave dead commands in existing installs (Principle VII).
- Propagate every ripple: `new.sh`, `README`, `USAGE`, `guides/greenfield.md`,
  `lint-docs.sh`, and every skill whose terminal handoff names a removed skill.

**Out:**
- Merging `/ardd-implement` and `/ardd-converge` (F004 — different entry
  state, higher risk, not a day-one surface).
- Committing to a two-tier / curated default install (F006b) — carried as an
  open question, not built in this plan.

## Technical Approach

Each merge follows the same shape, already validated by the two setup pairs:
the absorbed skill is a preamble or a downstream step, never an independent
artifact producer, so the surviving skill gains a mode rather than losing a
capability. Per Principle VII, the absorbed skill's directory is **deleted in
the same change** — not left as a stub. Per Principle I, removing a slash
command is a breaking change to existing installs, which is why the
`install.sh` prune (Phase 1) lands *first*, before any deletion.

The merged-skill design for the harder core-loop case (F005) follows the
critique's recommendation: the surviving `/ardd-plan` writes the durable
`plan-*.md`, then **pauses at an explicit approve / revise / stop
checkpoint** (restoring the gate the current design eroded into a
list-selection side effect), then emits `tasks-*.md`. A `--from <plan-file>`
argument re-enters at the tasking step for the re-task-without-re-planning
case. `constitution.md`'s `next_step_prompt` three-skill set collapses from
{plan, tasks, analyze} to {plan, analyze}.

Tier hygiene (F006a) is frontmatter + docs only: `/ardd-analyze` (terminal
step of nearly every core skill) and `/ardd-lint` (backs the write-time hook)
are core infrastructure, and the catalog should say so.

## Phase Breakdown

### Phase 1 — `install.sh` prunes removed ardd skills (foundation)
Depends on: nothing. Blocks: Phases 2 and 4 (both delete skills).
- `install.sh`: after copying `skills/ardd-*/`, remove any
  `.claude/skills/ardd-*/` directory in the target that has no corresponding
  source skill (and isn't one of the non-skill reference dirs in the
  allowlist — `ardd-scripts`, `ardd-artifact-templates`,
  `ardd-constitution-data`). Idempotent; only touches ardd-owned dirs.
- Regression test under `tests/` + CI job, in the same commit (Principle V):
  fixture install with a stale `ardd-ghost/` dir, assert it's gone after
  re-run and that non-ardd skills and the reference dirs survive.
- Demonstrable increment: re-running install against a target with a
  deleted-in-source skill removes the dead command; nothing else disappears.

### Phase 2 — Setup-tier merges (F002, F003)
Depends on: Phase 1. `[artifacts: none]` — skill/code only.
- Fold `/ardd-kickoff`'s interview into `/ardd-bootstrap` as "step 0 — assess
  context sufficiency" (interview only when context is thin); carry over
  kickoff's install-complete guard. Delete `skills/ardd-kickoff/`.
- Fold `/ardd-featurize`'s register extraction into `/ardd-codify` (offered or
  automatic after the artifact pass). Delete `skills/ardd-featurize/`.
- Ripple: `new.sh` handoff offer (`--kickoff`/`--no-kickoff` → bootstrap),
  `README` Getting-started table, `USAGE`, `guides/greenfield.md`,
  `lint-docs.sh` (drop removed names), and any terminal handoff naming the
  removed skills.
- Demonstrable increment: a cold `new.sh` quickstart reaches a working
  greenfield init through `/ardd-bootstrap` alone; brownfield through
  `/ardd-codify` alone.

### Phase 3 — Tier hygiene (F006a)
Depends on: nothing (parallel to 2). Docs + frontmatter only.
- Re-tier `/ardd-analyze` and `/ardd-lint` to core (or a named
  `core-infra` value if the tier enum warrants it — decide during
  implementation; if a new enum value, update `lint-project.sh`'s tier check
  in the same commit).
- Move them in `README` from Extensions into the core-loop presentation with
  a note that they run automatically.
- Demonstrable increment: README's core section reflects what the loop
  actually depends on; `lint-docs.sh` still green.

### Phase 4 — Core-loop merge: `/ardd-tasks` → `/ardd-plan` (F005)
Depends on: Phase 1. Highest-risk phase. `[artifacts: none]`.
- Fold tasks generation into `/ardd-plan`: write `plan-*.md`, explicit
  approve/revise/stop checkpoint, then emit `tasks-*.md`. Add `--from <plan>`
  re-entry. Preserve the plan→approved flip and the feature
  `backlogged→planned→tasked` transitions (now within one skill).
- Delete `skills/ardd-tasks/`. Update the `next_step_prompt` set to
  {plan, analyze} everywhere it's enumerated (skill prose + CLAUDE.md +
  constitution notes). Rewrite every terminal handoff naming `/ardd-tasks`.
- Ripple: `README` core-loop table, `USAGE`, `lint-docs.sh`.
- **Gate during implementation:** if the merged SKILL.md's length/modal
  complexity looks likely to degrade instruction-following, stop and fall
  back to "separate files, single advertised surface" (not the status quo) —
  see Complexity Tracking and Open Questions.
- Demonstrable increment: `/ardd-plan` drafts, checkpoints, and tasks in one
  invocation; `/ardd-plan --from <plan>` re-tasks an approved plan.

### Phase 5 — Docs pass + version bump
Depends on: 2, 3, 4.
- Reconcile `README`/`USAGE`/`CLAUDE.md`/`guides/` to the final catalog;
  `lint-docs.sh` green. Constitution version bump only if a principle changes
  (the tier-enum or `next_step_prompt`-set edits are workflow/schema, not
  principle changes — likely no bump). Update `.project/ardd-version.md` is
  automatic on install.

## Complexity Tracking

| Deviation | Why justified | Simpler alternative rejected because |
|---|---|---|
| Merged `/ardd-plan` gains multiple modes (fresh / resume-draft / re-task via `--from`) — a longer, more modal SKILL.md | Eliminates a whole skill *and* a cross-skill file handoff seam; net catalog reduction (Principle VI is served at the catalog level) | Keeping tasks separate preserves the status quo the critique showed is already a merge-in-denial (one-keypress seam, list-selection "approval") |
| `install.sh` gains prune logic | Required by Principle VII — without it, every merge leaves a dead command in existing installs | Doing nothing violates "old approach deleted in the same change" for the target-install side |

## Open Questions

- **F006b (curated default install):** since nothing installed can be hidden
  from Claude Code's palette, "fewer on the shelf" needs `install.sh` to
  install fewer — a two-tier (core vs opt-in extensions) install. Is that
  worth the install.sh complexity, or does better README/tier presentation
  (Phase 3) suffice on its own? Not built in this plan; decide before opening
  a follow-up.
- **F005 prose-complexity gate:** does the merged `/ardd-plan` stay reliably
  executable? Resolved empirically during Phase 4; fallback is
  "separate files, single advertised surface."
- **Deprecation shim:** should removed commands (`/ardd-kickoff`,
  `/ardd-featurize`, `/ardd-tasks`) leave a one-line "moved to X" stub for
  one release instead of vanishing, given muscle memory (Principle I treats
  them as public API)? Or is the prune + changelog enough?
