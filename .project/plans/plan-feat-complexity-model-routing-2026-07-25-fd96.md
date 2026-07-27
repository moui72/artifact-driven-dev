---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: feat-complexity-model-routing
created: 2026-07-25
features: [plan-time-complexity-stamps, delegate-model-routing]
surfaced-defects: []
---

# Plan: complexity stamps + delegated-run model routing

## Goal

Every tasks file carries a plan-time `complexity:` stamp that the approval checkpoint surfaces for correction, and `/ardd-implement`'s delegated worktree dispatches resolve an optional `delegate_model` constitution field — a single tier alias or a complexity-keyed map — into the `Agent` call's model override.

## Scope

**In:** the two bundled features. `plan-time-complexity-stamps`: `/ardd-plan`
stamps `complexity: simple|moderate|complex` into each generated tasks
file's frontmatter, shows it at the approval checkpoint, and corrections go
through `ardd-state.sh stamp`; the enum lands in `lint-project.sh` the same
commit. `delegate-model-routing`: a `delegate_model` constitution
frontmatter workflow field (single tier alias, or a
`simple=<alias>,moderate=<alias>,complex=<alias>` map) that the delegation
step resolves to a `model:` override on the worktree `Agent` dispatch —
delegation-boundary only, where a fresh subagent context means routing
costs no prompt cache.

**Out:** any routing of inline (non-delegated) runs or per-skill session
routing (investigated and rejected per the register's `Why:`); automatic
complexity inference at implement time (the stamp is plan-time judgment);
an `/ardd-init`//`/ardd-update` interactive ask for `delegate_model` (set
via `ardd-state.sh stamp`, documented — a follow-up can add the ask if
demand appears); and any constitution body amendment (workflow fields, not
constitution content).

## Technical Approach

- **Stamp vocabulary and storage.** `complexity:` is tasks-file
  frontmatter, written at generation time alongside `status: generating`
  (the same write), value one of `simple|moderate|complex`. Absent is
  legal forever — every pre-feature tasks file lacks it, and absent means
  "no routing signal" (asymmetric default: nothing is ever routed *down*
  implicitly). Corrections are script-performed:
  `ardd-state.sh stamp <tasks-file> complexity <value>` — `stamp` is
  already file-generic, so this is an allowlist + enum-validation
  addition, with fixture tests in the same commit (Principle V).
- **Checkpoint surfacing.** The approval checkpoint (step 10) gains one
  line in the presented skeleton — the stamped complexity per generated
  tasks file — and Revise explicitly covers "change the stamp" via the
  stamp command above. No new prompt: it rides the existing
  approve/revise/stop gate.
- **`delegate_model` grammar.** Constitution frontmatter, validated by
  `lint-project.sh` (same top-of-script schema block as the other five
  enums): either a single tier alias from `haiku|sonnet|opus` — the
  harness's model *family* aliases, which already survive version churn,
  deliberately not dated model IDs — or a comma map
  `simple=<alias>,moderate=<alias>,complex=<alias>` where each key is
  optional but at least one pair must be present and keys/aliases must be
  from the enums. `ardd-state.sh stamp` gains the same validation;
  `unstamp`'s removable-field allowlist gains `delegate_model` (absent =
  no routing, the documented default).
- **Dispatch resolution.** In `/ardd-implement`'s delegation step (and its
  fan-out variant), after the pre-flight: grep `delegate_model`; absent →
  dispatch exactly as today (no `model` param — inherit). Single alias →
  pass it as the `Agent` call's `model`. Map → read the chosen tasks
  file's `complexity:`; a mapped value → pass that alias; unmapped or
  absent complexity → inherit (never guess). Prose-only skill change —
  the resolution is stated as deterministic rules the agent follows, and
  the two files it reads are both already loaded at that step.
- **Docs.** `docs/reference/configuration.md` gains a `delegate_model`
  section (grammar, resolution rules, asymmetric-default rationale) and
  the tasks-frontmatter `complexity:` field is documented on
  `docs/reference/skills/ardd-plan.md`'s hand-written body;
  `docs/reference/scripts.md`'s stamp/unstamp inventories gain both
  fields. `lint-docs.sh` stays green.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is
tracked in the linked tasks file.

- **Phase 1 — complexity stamp machinery.** `ardd-state.sh stamp`
  allowlist + enum validation for `complexity` (on tasks files), and the
  `lint-project.sh` optional tasks-field enum, each with regression cases
  in the same commit. Independent foundation.
- **Phase 2 — plan-side wiring.** `skills/ardd-plan/SKILL.md`: stamp at
  generation (step 13's frontmatter template + a grading sentence),
  surface at the approval checkpoint (step 10), correction path via
  stamp; docs sync (ardd-plan reference page, scripts.md inventory).
  Depends on Phase 1.
- **Phase 3 — `delegate_model` field machinery.** `lint-project.sh`
  validation for the alias/map grammar, `ardd-state.sh` stamp validation +
  `unstamp` allowlist entry, regression cases same commit. Independent of
  Phases 1–2 in code, sequenced after for the shared validator files.
- **Phase 4 — dispatch resolution + docs.** `skills/ardd-implement/
  SKILL.md` delegation + fan-out dispatch rules; `configuration.md`
  section; scripts.md inventory. Depends on Phases 1 and 3 (consumes both
  fields' grammars).
- **Phase 5 — verification.** `test-ardd-state.sh`,
  `test-lint-project.sh`, `lint-project.sh .`, `lint-docs.sh` all green.
  Depends on all prior phases.

## Complexity Tracking

No justified deviations — both features reuse existing mechanism (the
file-generic `stamp`/`unstamp`, the lint schema block, the existing
delegation gate) rather than adding new scripts or prompts; the declined
alternatives (per-skill session routing, implement-time inference, an
init/update ask) are recorded in Scope as outs per Principle VI.

## Open Questions

- Tier alias vocabulary: the plan uses the harness model family names
  (`haiku|sonnet|opus`) as the tier aliases, on the grounds that family
  names are already churn-stable. If a harness-neutral vocabulary
  (`light|standard|heavy`) is preferred, Phase 3's enum and Phase 4's
  resolution table change wording only — decide at approval.
- Should absent `complexity:` under a map with a `simple=` entry ever
  route down? The plan says no (absent = inherit, never guess) — confirm
  the asymmetric default is wanted at approval.
