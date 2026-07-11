---
plan: plan-consolidate-setup-skills-2026-07-11.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-11
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: install.sh prunes removed ardd skills (foundation)

- [x] T001 Write a test-first regression test for install.sh skill-pruning
  (Principle V — deterministic checks are test-first). Add
  `scripts/test-install-prune.sh` (POSIX sh) that: builds a fixture target,
  runs `install.sh` against it, plants a stale `.claude/skills/ardd-ghost/`
  dir plus a hand-written non-ardd skill (`.claude/skills/my-custom/`),
  re-runs `install.sh`, and asserts — ghost dir removed; `my-custom/`
  survives; the reference dirs (`ardd-scripts`, `ardd-artifact-templates`,
  `ardd-constitution-data`) survive. Wire a matching CI job into
  `.github/workflows/lint.yml` in the same commit. Test must fail against
  current install.sh (no prune logic yet).

- [x] T002 Implement the prune in `install.sh`: after copying `skills/ardd-*/`
  into `.claude/skills/`, enumerate existing `.claude/skills/ardd-*/` dirs in
  the target and remove any with no counterpart in source `skills/`, excluding
  the non-skill reference-dir allowlist (`ardd-scripts`,
  `ardd-artifact-templates`, `ardd-constitution-data`). Must be idempotent and
  touch only ardd-owned dirs. Make T001's test pass. POSIX sh only.

## Phase 2: Setup-tier merges (depends: Phase 1)

- [x] T003 Merge `/ardd-kickoff` into `/ardd-bootstrap` AND delete
  `skills/ardd-kickoff/` in the same change (Principle VII — no dead
  architecture). In `skills/ardd-bootstrap/SKILL.md`, add "step 0 — assess
  context sufficiency": if conversation context already establishes the
  project, synthesize as today; if thin (cold session / empty dir from the
  `new.sh` quickstart), conduct the design interview (the seven-topic
  interview currently in kickoff step 3, plus its reflect-back) first, then
  proceed. Carry over kickoff's install-complete guard (missing
  `ardd-scripts/` → point at `/ardd-setup`), which bootstrap currently lacks.
  Do not duplicate the constitution-suggestion catalog into the interview
  (kickoff explicitly warns against this).

- [x] T004 Merge `/ardd-featurize` into `/ardd-codify` AND delete
  `skills/ardd-featurize/` in the same change (Principle VII). In
  `skills/ardd-codify/SKILL.md`, fold featurize's feature-register extraction
  in as a step after the artifact-reverse-engineering pass (offered, or
  automatic — match codify's existing interaction style). Preserve
  featurize's register-writing mechanics (`ardd-state.sh` calls, `backlogged`
  seeding).

- [x] T005 Propagate the setup-merge ripple and re-green the guards. Update:
  `new.sh` (handoff offer + `--kickoff`/`--no-kickoff` flags now target
  `/ardd-bootstrap`) and its regression test `scripts/test-new.sh`;
  `README.md` Getting-started table (drop kickoff/featurize rows);
  `USAGE.md`; `guides/greenfield.md`; `scripts/lint-docs.sh` (remove the
  deleted skill names from any allowlist); and every remaining SKILL.md whose
  terminal handoff or prose names `/ardd-kickoff` or `/ardd-featurize`
  (grep for both). Run `scripts/lint-docs.sh` and `scripts/test-new.sh` —
  both must pass.

## Phase 3: Tier hygiene (parallel to Phase 2)

- [x] T006 [parallel] Re-tier `/ardd-analyze` and `/ardd-lint` from
  `extension` to core infrastructure. Change the `tier:` frontmatter in both
  SKILL.md files (use `core`, or introduce a `core-infra` value — if a new
  enum value, update the tier check + enum in `scripts/lint-project.sh` and
  its regression test `scripts/test-lint-project.sh` in the same commit).
  Move both from the Extensions table into the core-loop presentation in
  `README.md`, noting they run automatically (analyze as most skills'
  terminal step; lint behind the write-time hook). Keep `scripts/lint-docs.sh`
  green.

## Phase 4: Core-loop merge — /ardd-tasks → /ardd-plan (depends: Phase 1)

- [x] T007 Merge `/ardd-tasks` into `/ardd-plan` AND delete `skills/ardd-tasks/`
  in the same change (Principle VII). The merged `skills/ardd-plan/SKILL.md`
  writes the durable `plan-*.md`, then pauses at an **explicit
  approve/revise/stop checkpoint**, then (on approve) generates and writes
  `tasks-*.md` — folding in all of ardd-tasks' current mechanics: plan→approved
  flip, feature `backlogged→planned→tasked` transitions, tasks-file minting
  and `generating→ready` lifecycle. Add a `--from <plan-file>` argument that
  re-enters at the tasking step for re-task-without-re-planning. **Gate
  (from the plan's Complexity Tracking + Open Questions):** if the merged
  SKILL.md's length/modal complexity looks likely to degrade
  instruction-following, STOP and fall back to "separate files, single
  advertised surface" (not the status quo) — surface this to the user before
  committing to the monolithic form.

- [x] T008 Propagate the tasks→plan ripple. Update: the `next_step_prompt`
  three-skill set to {plan, analyze} everywhere it is enumerated — skill prose
  in `/ardd-analyze` and `/ardd-plan`, and `CLAUDE.md`'s extended
  `next_step_prompt` discussion; rewrite every terminal handoff or prose
  reference naming `/ardd-tasks` across all remaining SKILL.md files (grep for
  `ardd-tasks`), pointing at `/ardd-plan`; `README.md` core-loop table;
  `USAGE.md`; `scripts/lint-docs.sh` allowlist. Also scan `CLAUDE.md`'s many
  `/ardd-tasks` references (single-writer list, branch-gate exceptions, etc.)
  and reconcile them to the merged reality. Run `scripts/lint-docs.sh` green.

## Phase 5: Docs reconciliation + verification (depends: Phases 2, 3, 4)

- [ ] T009 [artifacts: constitution] Final catalog reconciliation pass across
  `README.md`, `USAGE.md`, `CLAUDE.md`, and `guides/`: every command list,
  count ("21 skills"), and cross-reference reflects the final catalog. Bump
  the constitution version ONLY if a principle actually changed — the
  tier-enum and `next_step_prompt`-set edits are workflow/schema, not
  principle changes, so likely no bump (confirm and state which). Load
  `constitution.md` to check whether any principle wording needs updating.

- [ ] T010 Run the full local CI-equivalent and confirm green:
  `scripts/lint-docs.sh`, `scripts/lint-project.sh`, `scripts/test-new.sh`,
  `scripts/test-lint-project.sh`, `scripts/test-install-prune.sh` (new), and
  every other `scripts/test-*.sh` touched by this branch. Fix any failures
  before marking complete. This is the last gate before the branch is
  mergeable.
