---
plan: plan-plan-preview-editor-option-2026-07-22-3276.md
generated: 2026-07-22
status: ready   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
                     # (or -> abandoned, if superseded by a new tasks
                     # file generated for the same plan)
                     # completed is terminal — post-completion failures
                     # become new feedback (/ardd-feedback), never a
                     # status edit.
---

# Tasks

## Phase 1: Schema and state-script support

- [ ] T001 In `tests/fixtures/bad-project/.project/artifacts/constitution.md`,
  add a `plan_preview_editor` frontmatter value missing the `{path}`
  placeholder (e.g. `plan_preview_editor: code`). Bump
  `scripts/test-lint-project.sh`'s `EXPECTED_BAD_FINDINGS` by 1. Run
  `scripts/test-lint-project.sh` and confirm it now FAILS (the new bad
  fixture doesn't yet produce a finding — no such check exists in
  `lint-project.sh` yet). This is the red step.
- [ ] T002 In `scripts/lint-project.sh`, add a validation branch (near the
  existing `plan_preview` check, around line 175) for `plan_preview_editor`:
  when present on the `constitution` artifact, it must be non-empty and
  contain the literal substring `{path}`; report a finding otherwise
  (mirror the existing `report "$f: ..."` call shape used by
  `update_check_max_age_days`). Run `scripts/test-lint-project.sh` and
  confirm it now PASSES. [defect: none]
- [ ] T003 In `scripts/test-ardd-state.sh`, add cases exercising `stamp
  <file> plan_preview_editor <template>`: one accepting a template
  containing `{path}` (e.g. `code {path}`), one rejecting an empty value,
  one rejecting a template missing `{path}` (e.g. `code`). Run
  `scripts/test-ardd-state.sh` and confirm the new cases FAIL against the
  current `ardd-state.sh` (no such stamp key exists yet). This is the red
  step.
- [ ] T004 In `scripts/ardd-state.sh`, add `plan_preview_editor` as a
  `stamp` key: in the `case "$key" in ... esac` block (around line
  370), add a case that validates the value is non-empty and contains
  `{path}` (`dieu "stamp: plan_preview_editor must be a non-empty command
  template containing {path}, got '$val'"` on failure), and add
  `plan_preview_editor` to the `usage()` text (line 66) and the catch-all
  error message's key list (line 381). Run `scripts/test-ardd-state.sh`
  and confirm all cases now PASS. [defect: none]

## Phase 2: Wire the checkpoint offer into `/ardd-plan`

- [ ] T005 [artifacts: constitution] In `skills/ardd-plan/SKILL.md` step 10,
  extend the preliminary-question logic: grep
  `.project/artifacts/constitution.md` frontmatter for `plan_preview_editor`
  alongside the existing `plan_preview` grep. Describe the combined
  behavior: when only `plan_preview_editor` is set (and `plan_preview` is
  absent or `ask`), the one-time preliminary `AskUserQuestion` offers
  "open in editor" / "no" (mirroring today's browser yes/no shape); when
  both `plan_preview` (as `ask`, or absent) and `plan_preview_editor` are
  set, the question offers three options — browser / editor / no; when
  only `plan_preview` is set, behavior is unchanged from today. On
  selecting "editor", substitute the plan file's absolute path into the
  `{path}` placeholder of the configured template and run the resulting
  command (the implementer decides at this task whether a failing command
  surfaces inline and falls through to the three-way Approve/Revise/Stop
  question, or blocks — plan Open Questions leaves this to this task's
  judgment), then proceed to that same three-way question as today. Note
  explicitly that this offer re-fires on every Revise loop back to the
  checkpoint, identically to the browser offer. No test requirement — this
  is a prose-only skill-file edit with no deterministic script behind it
  (constitution Principle V exception: documentation/prose-only change).

## Phase 3: Reference docs

- [ ] T006 [parallel] In `docs/reference/configuration.md`, add a
  `plan_preview_editor` section directly after the existing `plan_preview`
  section (around line 82), mirroring its structure: what the field is, its
  absent-means-not-offered default, its value shape (a command template
  containing `{path}`), an example (`plan_preview_editor: code {path}`),
  and how to set it (`ardd-state.sh stamp <file> plan_preview_editor
  <template>`). No test requirement — documentation-only change.
- [ ] T007 [parallel] In `docs/reference/scripts.md`, add a `stamp <file>
  plan_preview_editor <command-template>` usage line to the `ardd-state.sh`
  section, alongside the existing `plan_preview` line, briefly noting the
  `{path}`-placeholder requirement. No test requirement —
  documentation-only change.
