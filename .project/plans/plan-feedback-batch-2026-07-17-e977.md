---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: feedback-batch
created: 2026-07-17
features: []
surfaced-defects: []
---

# Plan: feedback-batch (2026-07-17)

## Goal

Fix the five accepted feedback items from today's prerelease sweeps and
the plan-preview reconsideration: `new.sh`'s git-init isolation bug and
its downstream `install.sh` gitignore-diagnostic symptom, the misleading
dev-mode "behind" wording, the missing `.project/.lock` gitignore
entry, `/ardd-init`'s unverified git-log feature-extraction trust gap,
and a configurable `plan_preview` workflow setting to replace the
always-ask browser-preview prompt.

## Scope

**In scope:**
- `new.sh`'s git-init guard (`new.sh:240`): replace the
  `--is-inside-work-tree` check (true for *any* directory under an
  enclosing repo) with a real "is `$TARGET` its own repo root" check.
- `install.sh`'s gitignore-diagnostic block (`install.sh:400-482`):
  confirm `$TARGET` is its own repo top-level before trusting
  `git check-ignore` results, so it can't misattribute an outer repo's
  unrelated ignore rule.
- `install.sh`: proactively add `.project/.lock` to the
  generated/suggested `.gitignore` block (or detect a pre-existing
  `.lock` and gitignore it immediately) instead of only mentioning it
  conditionally in printed text.
- `ardd-update-check.sh` / `skills/ardd-status/SKILL.md` step 1: special-case
  a dev-mode checkout whose installed commit is *ahead* of (not behind)
  the latest release tag, so the "behind ... run /ardd-update" line
  isn't printed when following it would regress the target.
- `skills/ardd-init/SKILL.md` step 7: instruct verifying a `feat:`
  commit's actual diff (or cross-referencing the step-2 code survey)
  before treating its message as evidence a capability is implemented
  and shipped.
- A new `plan_preview` workflow frontmatter field
  (`always-browser` | `always-console` | `ask`, default/absent =
  `ask` = current behavior), added to `scripts/lint-project.sh`'s
  workflow-field enum and `ardd-state.sh stamp`'s supported keys, and
  consumed by `skills/ardd-plan/SKILL.md` step 10 to skip the "view in
  browser?" `AskUserQuestion` when the field is set to a definite
  choice.
- Generalizing the constitution's Governance "Exception" clause to cover
  any field in `lint-project.sh`'s workflow-field enum by reference,
  rather than naming each field — closes the pre-existing gap where
  `delegation`/`merge_policy`/`update_check_max_age_days` were already
  SIR-exempt in practice but omitted from the named list.

**Out of scope:**
- Any change to `/ardd-init`'s or `/ardd-update`'s existing interview
  questions for the other three workflow fields — `plan_preview` gets
  the same one-time-ask-or-reconfigure treatment as `delegation`, not a
  bespoke flow.
- Backfilling `Channel:`/`Source-Ref:` consistency validation — that's
  the separately-backlogged `channel-source-ref-consistency` feature,
  not this batch.
- Any script/schema change beyond the workflow-field enum and
  `ardd-state.sh stamp` — the `new.sh`/`install.sh` fixes are guard-logic
  corrections, not new mechanisms.

## Technical Approach

Four of the five fixes are corrections to existing deterministic script
logic (`new.sh`, `install.sh`, `ardd-update-check.sh`) or existing skill
prose (`ardd-init` step 7) — no new mechanism, no schema change, just
closing a gap in each. The fifth (`plan_preview`) follows the exact
precedent `delegation`/`merge_policy` already set: add the enum entry to
`lint-project.sh`, add the `stamp` subcommand support in `ardd-state.sh`,
and branch on it in the consuming skill's prose (`ardd-plan` step 10) the
same way `merge_policy`/`delegation` are already branched on elsewhere.
The constitution's Governance clause generalization is a pure wording
fix (PATCH-level, no principle/standing-decision change) that removes
the future maintenance cost of re-amending it on every new workflow
field.

## Phase Breakdown

### Phase 1: `new.sh` / `install.sh` isolation fixes
- T001 (test-first) Add a regression case to `scripts/test-new.sh`
  covering a target path nested under an existing git-controlled
  directory: `new.sh <target-nested-under-a-repo>` must still create a
  real, isolated repo at `$TARGET` (own `.git`, no inherited remote/
  history) — confirm this fails against current `new.sh` first (red).
  [feedback: F001, feedback-prerelease-smoke-sweep-849d]
- T002 Fix `new.sh:240`'s git-init guard: replace
  `git -C "$TARGET" rev-parse --is-inside-work-tree` with a check of
  whether `$TARGET` itself is a repo root (e.g.
  `git -C "$TARGET" rev-parse --show-toplevel` compared against
  `$TARGET`'s realpath, or `[ -e "$TARGET/.git" ]`). T001's test goes
  green. [feedback: F001, feedback-prerelease-smoke-sweep-849d]
- T003 [parallel] Fix `install.sh:400-482`'s gitignore-diagnostic block:
  confirm `$TARGET` is its own repo top-level before trusting
  `git check-ignore` results against it, so a target that isn't its own
  repo (a residual case even post-T002, e.g. an already-broken existing
  install) can't misattribute an outer repo's ignore rule to the ardd-*
  pattern. Add a regression case to `scripts/test-install-gitattributes.sh`
  or a new fixture covering this. [feedback: F002 downstream note, feedback-prerelease-smoke-sweep-849d]
- T004 [parallel] `install.sh`: add `.project/.lock` to the
  generated/suggested `.gitignore` block unconditionally (alongside the
  existing `.claude/skills/ardd-*/` pattern), rather than only
  mentioning it in printed ACTION NEEDED text. Add a regression case to
  `scripts/test-install-gitattributes.sh` confirming a fresh install's
  `.gitignore` contains the `.lock` pattern without the user needing to
  add it by hand. [feedback: F001, feedback-prerelease-full-sweep-62ae]

### Phase 2: dev-mode "behind" wording + ardd-init trust gap (independent of Phase 1)
- T005 [parallel] Fix `ardd-update-check.sh`: when the installed commit
  is a strict git ancestor of (i.e. behind) the compared tag, keep
  reporting `behind` as today; when it is instead a descendant (ahead)
  of the latest release tag with no `Source-Ref` at HEAD (the dev-mode-
  ahead case), report a distinct outcome (e.g. `dev-ahead`) instead of
  `behind`. Add a regression case to `scripts/test-ardd-update-check.sh`
  (or equivalent) covering an ahead-of-tag dev-mode checkout. [feedback: F002, feedback-prerelease-smoke-sweep-849d]
- T006 Update `skills/ardd-status/SKILL.md` step 1's banner-line
  template to handle `ardd-update-check.sh`'s new `dev-ahead` outcome
  distinctly from `behind` — don't recommend `/ardd-update` when doing
  so would regress the target; either stay silent (matching the
  existing `self-hosted`/`up-to-date` silent cases) or print a
  clearly-different note. [feedback: F002, feedback-prerelease-smoke-sweep-849d]
- T007 [parallel] Edit `skills/ardd-init/SKILL.md` step 7's git-log
  feature-extraction guidance: add an explicit instruction to verify a
  `feat:`-titled commit's actual diff (or cross-reference against the
  step-2 code survey) before treating it as evidence a capability is
  implemented and shipped — a commit's message is not proof of its
  diff. No test task — prose-only skill-file change (no new invariant
  to regression-test, matching the precedent for pure guidance-wording
  fixes elsewhere in this repo). [feedback: F002, feedback-prerelease-full-sweep-62ae]

### Phase 3: `plan_preview` workflow field (independent of Phases 1-2)
- T008 (test-first) Add `plan_preview` to `scripts/lint-project.sh`'s
  workflow-field enum (`always-browser` | `always-console` | `ask`) and
  a regression case to `scripts/test-lint-project.sh` covering a valid
  value, an invalid value (rejected with the allowed-set message), and
  the field absent (valid, treated as `ask`) — confirm the invalid-value
  case fails against current `lint-project.sh` first (red).
  [feedback: F001, feedback-plan-preview-setting-63b3]
- T009 Add `plan_preview` to `ardd-state.sh stamp`'s supported keys
  (mirroring `delegation`/`merge_policy`'s existing stamp support) and a
  regression case to `scripts/test-ardd-state.sh` covering set/replace/
  no-duplicate-keys/bad-value-refused, matching the existing
  `delegation`/`merge_policy` test blocks. T008's lint case goes green
  once a valid value can actually be stamped. [feedback: F001, feedback-plan-preview-setting-63b3]
- T010 [parallel] Edit `skills/ardd-plan/SKILL.md` step 10: before the
  existing "view the plan in the browser first?" `AskUserQuestion`,
  grep `.project/artifacts/constitution.md` frontmatter for
  `plan_preview` (absent = `ask`, current behavior — keep asking). On
  `always-browser`, skip the question and always publish+open. On
  `always-console`, skip the question and never publish — go straight
  to the three-way approve/revise/stop question. On `ask` (or absent),
  behavior is unchanged. [feedback: F001, feedback-plan-preview-setting-63b3]
- T011 [artifacts: constitution] Apply the confirmed Governance
  "Exception" clause generalization: rewrite the paragraph naming only
  `workflow_mode`/`next_step_prompt` to instead cover any field in
  `scripts/lint-project.sh`'s workflow-field enum by reference. Bump
  the constitution PATCH version (wording/scope clarification only, no
  principle or standing-decision change) and add the corresponding
  Sync Impact Report entry via the normal Governance amendment process
  (frontmatter `last_updated`, footer version/date). [feedback: F001, feedback-plan-preview-setting-63b3]
- T012 Update `docs/reference/skills/ardd-plan.md`'s hand-written body
  to mention the `plan_preview` field's effect on the approval-checkpoint
  browser-preview offer. [feedback: F001, feedback-plan-preview-setting-63b3]

## Open Questions

- T005/T006's exact outcome-token naming (`dev-ahead` vs. reusing an
  existing token) is left to implementation judgment — pick whatever
  reads clearly against `ardd-update-check.sh`'s existing outcome
  vocabulary (`behind`, `at-release`, `self-hosted`, etc.).
- Whether `plan_preview: always-console` should still allow a Revise
  loop to re-offer the browser question on a later pass, or stay
  silent every time within the same run — leaning toward staying silent
  every time (that's the point of the setting), but worth confirming
  during implementation if it reads awkwardly.
