---
plan: plan-feat-complexity-model-routing-2026-07-25-fd96.md
generated: 2026-07-26
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: complexity stamp machinery
- [ ] T001 Extend `scripts/ardd-state.sh stamp` to accept `complexity` with enum validation `simple|moderate|complex` (any other value refused via `dieu`, naming the legal values), add it to the usage text's stamp inventory, and add red-first regression cases to `scripts/test-ardd-state.sh`: set on a tasks-file fixture, replace, and a bogus-value refusal (exit 2) — test and change in the same commit (Principle V).
- [ ] T002 Extend `scripts/lint-project.sh` to validate an optional `complexity` frontmatter field on tasks files: absent is always valid (every pre-feature file lacks it); present must be `simple|moderate|complex`, else a finding naming the legal values. Keep the enum in the top-of-script schema block. Add a bad-value case to `tests/fixtures/bad-project` and an assertion (plus the EXPECTED_BAD_FINDINGS bump) to `scripts/test-lint-project.sh`, red-first, same commit. Depends on T001 (same schema-block conventions).

## Phase 2: plan-side wiring
- [ ] T003 Update `skills/ardd-plan/SKILL.md` step 13: the generated tasks file's frontmatter template gains `complexity: simple|moderate|complex`, stamped at generation time (same write as `status: generating`) from plan-time judgment — one grading sentence stating the signal (how much implementation judgment the file's tasks need: mechanical/single-seam = simple, multi-file but well-specified = moderate, design-heavy/cross-cutting = complex). State that absent stays legal (old files) and that corrections are script-performed via `ardd-state.sh stamp <tasks-file> complexity <value>`. Depends on T002.
- [ ] T004 Update `skills/ardd-plan/SKILL.md` step 10 (approval checkpoint): the presented skeleton gains one line showing the complexity the tasking half will stamp, and the Revise option's text covers correcting it (re-stamp via the T003 command) — no new prompt, it rides the existing approve/revise/stop gate. Sync the hand-written body of `docs/reference/skills/ardd-plan.md` with the `complexity:` field and `docs/reference/scripts.md`'s stamp inventory with `complexity`. `scripts/lint-docs.sh` must stay green. Depends on T003.

## Phase 3: delegate_model field machinery
- [ ] T005 Extend `scripts/lint-project.sh` to validate an optional constitution frontmatter field `delegate_model`: absent valid; present must be either a single tier alias `haiku|sonnet|opus`, or a comma map of `simple=<alias>`/`moderate=<alias>`/`complex=<alias>` pairs (each key optional, at least one pair, no duplicate keys, keys and aliases from the enums, e.g. `complex=opus` or `simple=haiku,complex=opus`) — else a finding naming the grammar. Enum/grammar lives in the top-of-script schema block. Fixture coverage: valid map in `tests/fixtures/good-project`, invalid value in `bad-project`, EXPECTED_BAD_FINDINGS bump, red-first, same commit. Depends on T002 (same schema block).
- [ ] T006 Extend `scripts/ardd-state.sh`: `stamp` accepts `delegate_model` with the same single-alias-or-map validation as T005 (shared grammar, refusal names it), and `unstamp`'s removable-field allowlist gains `delegate_model` (absent = no routing, the documented default). Update the usage text. Regression cases in `scripts/test-ardd-state.sh`: valid single alias, valid map, bogus alias refused, bogus map key refused, unstamp removal — red-first, same commit. Depends on T005.

## Phase 4: dispatch resolution + docs
- [ ] T007 Update `skills/ardd-implement/SKILL.md`'s delegation step (step 3, including the fan-out launch): before dispatching a worktree subagent, grep `delegate_model` from `.project/artifacts/constitution.md` frontmatter. Resolution rules, stated deterministically: absent → no `model` param (inherit the session model, unchanged behavior); single alias → pass it as the `Agent` call's `model`; map → read the chosen tasks file's `complexity:` frontmatter — a mapped value passes that alias, an unmapped or absent complexity inherits (never guess, never route down implicitly). Fan-out resolves per selected tasks file (files may route to different models in one fan-out). Depends on T004, T006.
- [ ] T008 Document the pair: `docs/reference/configuration.md` gains a `delegate_model` section (grammar, resolution rules incl. the asymmetric absent-inherits default, delegation-boundary-only rationale — fresh subagent context, no prompt-cache cost) and cross-references the tasks-file `complexity:` stamp; `docs/reference/scripts.md`'s stamp/unstamp inventories gain `delegate_model`. `scripts/lint-docs.sh` stays green. Depends on T007.

## Phase 5: verification
- [ ] T009 Run `scripts/test-ardd-state.sh`, `scripts/test-lint-project.sh`, `scripts/lint-project.sh .`, and `scripts/lint-docs.sh`; confirm all pass with no new findings. Depends on T001, T002, T003, T004, T005, T006, T007, T008.
