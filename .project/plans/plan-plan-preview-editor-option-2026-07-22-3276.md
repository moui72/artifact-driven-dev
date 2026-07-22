---
status: approved        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
branch: plan-preview-editor-option       # the branch inline implementation would use; may never be created (see step 1)
created: 2026-07-22
features: [plan-preview-editor-option]
surfaced-defects: []
---

# Plan: plan-preview-editor-option

## Goal

At `/ardd-plan`'s approval checkpoint, give the user a one-keypress way to
open the just-written plan file in their configured local editor, alongside
the existing browser-preview offer, driven by a new `plan_preview_editor`
constitution workflow field.

## Scope

**In scope:**
- A new optional constitution frontmatter workflow field, `plan_preview_editor`
  — a shell command template containing a `{path}` placeholder (e.g.
  `code {path}`), stamped via `ardd-state.sh stamp <file> plan_preview_editor
  <template>`.
- `scripts/lint-project.sh` schema: when present, `plan_preview_editor` must
  be non-empty and contain the literal `{path}` placeholder.
- `scripts/ardd-state.sh stamp`: accept `plan_preview_editor` as a stamp key,
  free-text validated (non-empty, contains `{path}`) rather than enum-checked
  like `plan_preview`.
- `/ardd-plan` step 10 (the approval checkpoint): when `plan_preview_editor`
  is set, the preliminary question gains an "open in editor" branch alongside
  the existing browser-preview yes/no, substituting the plan file's absolute
  path into `{path}` and running the resulting command. This is additive to
  the existing `plan_preview` (`always-browser`/`always-console`/`ask`)
  behavior, not a replacement of it — a user can have both, either, or
  neither configured.
- Reference docs: `docs/reference/configuration.md` (new field section,
  mirroring the existing `plan_preview` block), `docs/reference/scripts.md`
  (new `stamp` usage line).
- Regression tests: `scripts/test-lint-project.sh` (bad-fixture case for a
  `plan_preview_editor` missing `{path}`), `scripts/test-ardd-state.sh`
  (stamp accept/reject cases).

**Out of scope:**
- Auto-detecting an installed editor or defaulting the field to any value —
  absent means the editor option is simply never offered, same "absent =
  today's behavior" pattern as every other workflow field.
- Any change to the existing `plan_preview` field's own enum or semantics.
- Windows/`cmd.exe` quoting concerns — the command template is passed to the
  same shell `/ardd-plan` already runs in (POSIX `sh` per this repo's shell
  convention); no new quoting layer is introduced.

## Technical Approach

`plan_preview_editor` follows the same "workflow field, stamped via
`ardd-state.sh`, exempt from constitution Sync Impact Reports by the
Governance Exception (which already references `scripts/lint-project.sh`'s
enum/field set by name, not a fixed list)" pattern as `plan_preview`,
`delegation`, `merge_policy`, and `update_check_max_age_days` — no
constitution.md *body* prose changes, no version bump, no SIR entry. Its
validation shape differs from every existing workflow field, though: those
are all enums or a positive integer; this one is a free-text shell command
template. `lint-project.sh` and `ardd-state.sh stamp` both get a narrower
check — non-empty and contains `{path}` — rather than an `in_enum` call, so
the plan's lint task must add a *new* validation branch, not extend
`PLAN_PREVIEW_ENUM`.

At the approval checkpoint, `/ardd-plan` step 10 already special-cases
`plan_preview: always-browser|always-console|ask`. The editor offer is
independent of that value: it is offered whenever `plan_preview_editor` is
present, regardless of what (if anything) `plan_preview` is set to. The
existing one-time preliminary `AskUserQuestion` ("view the plan in the
browser first? yes/no") becomes a preliminary question with up to three
options when both fields are configured — browser / editor / skip — with
each present-but-not-both field collapsing it back to a two-option
yes/no, exactly mirroring today's shape when only `plan_preview_editor` is
configured (editor / skip) or only `plan_preview: ask` is configured
(browser / skip, unchanged). Selecting "editor" substitutes the plan's
absolute path into the `{path}` placeholder and runs the resulting command
via the shell, then continues straight to the unchanged three-way
Approve/Revise/Stop question — same as the browser path today. This offer
re-fires on every Revise loop back to the checkpoint, same as the browser
offer.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is tracked
in the linked tasks file.

### Phase 1: Schema and state-script support (no skill-prose changes yet)
Add the field to the two deterministic layers first, test-first, so the
skill-prose phase (2) has a validated field to wire against.
- Add a bad-fixture case to `scripts/test-lint-project.sh` for a
  `plan_preview_editor` present without `{path}`, confirm it fails against
  current `lint-project.sh` (no such check exists yet), then add the
  validation branch to `scripts/lint-project.sh` and confirm the test
  passes.
- Add accept/reject cases to `scripts/test-ardd-state.sh` for `stamp <file>
  plan_preview_editor <template>` (accepts a template containing `{path}`,
  rejects one that omits it or is empty), confirm failing against current
  `ardd-state.sh`, then add the `plan_preview_editor` case to `stamp`'s
  key `case` block (and its `usage`/error-message key list) and confirm
  passing.

### Phase 2: Wire the checkpoint offer into `/ardd-plan`
Depends on Phase 1 (the field must already validate before the skill prose
references it).
- Edit `skills/ardd-plan/SKILL.md` step 10: extend the preliminary-question
  logic to grep `plan_preview_editor` alongside the existing `plan_preview`
  grep, and describe the three-way/two-way collapsing behavior from
  Technical Approach — including the "editor" branch's command
  substitution and execution, and that it re-fires on every Revise loop
  identically to the browser offer.

### Phase 3: Reference docs
Depends on Phase 2 (docs describe the shipped behavior, not the plan).
- Add a `plan_preview_editor` section to `docs/reference/configuration.md`,
  mirroring the existing `plan_preview` section's structure (what it is,
  default/absent behavior, how to set it).
- Add a `stamp <file> plan_preview_editor <template>` usage line to
  `docs/reference/scripts.md`'s `ardd-state.sh` section, alongside the
  existing `plan_preview` line.

## Complexity Tracking

No deviations from the codebase's existing patterns — this reuses the
established "workflow field via `ardd-state.sh stamp`, validated in
`lint-project.sh`, exempt from constitution SIRs" shape wholesale; nothing
here needs justifying beyond it.

## Open Questions

- Exact `AskUserQuestion` option labels/wording for the three-way
  preliminary question (e.g. "Yes — browser" / "Yes — editor" / "No") are
  left to the implementing task's judgment, consistent with this repo's
  existing prose-is-for-judgment convention (constitution Principle II) —
  not pinned in this plan.
- Whether a malformed/failing editor command (e.g. `code` not on `$PATH`)
  should surface an inline error and fall through to the three-way
  Approve/Revise/Stop question, or block — left to the implementing task;
  the existing browser-publish path has no analogous failure mode to
  mirror, so this needs a fresh decision at implementation time.
