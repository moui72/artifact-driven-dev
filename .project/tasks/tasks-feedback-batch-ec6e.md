---
plan: plan-feedback-batch-2026-07-17-e977.md
generated: 2026-07-17
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: `new.sh` / `install.sh` isolation fixes
- [x] T001 (test-first) Add a regression case to `scripts/test-new.sh`
  covering a target path nested under an existing git-controlled
  directory: `new.sh <target-nested-under-a-repo>` must still create a
  real, isolated repo at `$TARGET` (own `.git`, no inherited remote or
  history). Confirm this new case fails against current `new.sh`
  (red — `new.sh:240`'s `git -C "$TARGET" rev-parse
  --is-inside-work-tree` guard walks up to any enclosing `.git`, so it
  currently skips `git init` for a nested target). Apply the test
  framework's expected-failure marker on this red commit per the
  constitution's full-suite pre-commit hook convention.
  [defect: n/a] [feedback: F001]
- [x] T002 Fix `new.sh:240`'s git-init guard: replace
  `git -C "$TARGET" rev-parse --is-inside-work-tree` with a real check
  of whether `$TARGET` itself is a repo root (e.g. compare
  `git -C "$TARGET" rev-parse --show-toplevel` against `$TARGET`'s
  realpath, or `[ -e "$TARGET/.git" ]`). Remove T001's expected-failure
  marker — its case should now pass (green). [feedback: F001]
- [x] T003 [parallel] Fix `install.sh:400-482`'s gitignore-diagnostic
  block: before trusting `git -C "$TARGET" check-ignore` results,
  confirm `$TARGET` is its own repo top-level (same check-style as
  T002). This covers the residual case where `$TARGET` still isn't its
  own repo (e.g. an already-broken existing install predating T002's
  fix) — the diagnostics should not misattribute an outer repo's
  unrelated ignore rule to the ardd-* pattern. Add a regression case to
  `scripts/test-install-gitattributes.sh` (or a new fixture file, if
  that script's existing structure doesn't fit) covering: a target
  nested under an existing git-controlled directory, confirming the
  gitignore-diagnostic warning either doesn't fire or names the correct
  cause rather than a misattributed one. [feedback: F002]
- [x] T004 [parallel] `install.sh`: add `.project/.lock` to the
  generated/suggested `.gitignore` block unconditionally, alongside the
  existing `.claude/skills/ardd-*/` pattern — do not rely solely on the
  conditional printed ACTION NEEDED reminder. Add a regression case to
  `scripts/test-install-gitattributes.sh` confirming a fresh install's
  `.gitignore` contains the `.lock` pattern without requiring the user
  to add it by hand. [feedback: F001]

## Phase 2: dev-mode "behind" wording + ardd-init trust gap (depends on nothing; independent of Phase 1)
- [x] T005 [parallel] Fix `ardd-update-check.sh`: when the installed
  commit is a strict git ancestor of (behind) the compared release tag,
  keep reporting `behind` as today. When it is instead a descendant
  (ahead) of the latest release tag with no `Source-Ref` recorded at
  HEAD (the dev-mode-ahead case), report a distinct outcome token
  (e.g. `dev-ahead installed=<x> latest-release=<y>`) instead of
  `behind`. Add a regression case to the script's existing test suite
  (`scripts/test-ardd-update-check.sh` or wherever its cases live)
  covering an ahead-of-tag dev-mode checkout, confirming it does NOT
  report `behind`. [feedback: F002]
- [x] T006 Update `skills/ardd-status/SKILL.md` step 1's banner-line
  template to handle `ardd-update-check.sh`'s new `dev-ahead` outcome
  from T005 distinctly from `behind`: do not recommend `/ardd-update`
  when doing so would regress the target. Either treat it as a silent
  case (matching the existing `self-hosted`/`up-to-date` silent
  outcomes) or print a clearly different, non-misleading note. No test
  task — prose-only skill-file change. [feedback: F002]
- [x] T007 [parallel] Edit `skills/ardd-init/SKILL.md` step 7's git-log
  feature-extraction guidance: add an explicit instruction that a
  `feat:`-titled commit's message is not proof of its diff, and
  instruct verifying the commit's actual diff (or cross-referencing
  against the step-2 code survey) before treating it as evidence a
  capability is actually implemented and shipped, rather than merely
  proposed or documented. No test task — prose-only skill-file change,
  no new invariant to regression-test. [feedback: F002]

## Phase 3: `plan_preview` workflow field (depends on nothing; independent of Phases 1-2)
- [x] T008 (test-first) Add `plan_preview` to `scripts/lint-project.sh`'s
  workflow-field enum (`always-browser` | `always-console` | `ask`).
  Add a regression case to `scripts/test-lint-project.sh` covering: a
  valid value passes, an invalid value is rejected with a message
  naming the field and the allowed set, and the field's absence is
  valid (treated as `ask`). Confirm the invalid-value case fails
  against current `lint-project.sh` first (red — the field doesn't
  exist in the enum yet, so an invalid value wouldn't currently be
  rejected as *this* field). Apply the expected-failure marker on this
  red commit. [feedback: F001]
- [x] T009 Add `plan_preview` to `ardd-state.sh stamp`'s supported keys,
  mirroring the existing `delegation`/`merge_policy` stamp support
  (set/replace/no-duplicate-keys, bad-value refused with the allowed
  set named). Add a matching regression case to
  `scripts/test-ardd-state.sh` covering set, replace, no-duplicate-keys,
  and bad-value-refused, matching the existing `delegation`/
  `merge_policy` test blocks' structure. Remove T008's expected-failure
  marker — its lint case should now pass (green), since a valid value
  can actually be stamped. [feedback: F001]
- [x] T010 [parallel] Edit `skills/ardd-plan/SKILL.md` step 10: before
  the existing "view the plan in the browser first?" `AskUserQuestion`,
  grep `.project/artifacts/constitution.md` frontmatter for
  `plan_preview` (absent = `ask`, current behavior — keep asking as
  today). On `always-browser`: skip the question, always publish via
  `Artifact` and open it, then proceed to the three-way
  approve/revise/stop question unchanged. On `always-console`: skip the
  question, never publish, go straight to the three-way question. On
  `ask` (or absent): behavior unchanged from today. [feedback: F001]
- [x] T011 [artifacts: constitution] Apply the confirmed Governance
  "Exception" clause generalization to
  `.project/artifacts/constitution.md`: rewrite the paragraph currently
  naming only `workflow_mode`/`next_step_prompt` to instead cover any
  field in `scripts/lint-project.sh`'s workflow-field enum by
  reference, closing the pre-existing gap where
  `delegation`/`merge_policy`/`update_check_max_age_days` were already
  SIR-exempt in practice but omitted from the named list. Bump the
  constitution's PATCH version (wording/scope clarification only — no
  principle or standing-decision change) via the normal Governance
  amendment process: prepend a new Sync Impact Report entry above the
  most recent one (preserve prior entries), update the frontmatter
  `last_updated` via `ardd-state.sh stamp`, and update the footer
  `**Version**`/`**Last Amended**` line to match. Run
  `scripts/lint-project.sh` after to confirm frontmatter/footer
  consistency (it checks footer-vs-frontmatter drift and
  SIR-target-vs-footer-version drift). [feedback: F001]
- [ ] T012 Update `docs/reference/skills/ardd-plan.md`'s hand-written
  body to mention the `plan_preview` field's effect on the
  approval-checkpoint browser-preview offer, mirroring how `--list` and
  `--from` are already documented there. [feedback: F001]
