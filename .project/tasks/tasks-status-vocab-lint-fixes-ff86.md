---
plan: plan-status-vocab-lint-fixes-2026-07-06.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-06
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

Testing paradigm (constitution Principle V, test-first): lint tasks
(T003, T005) add their bad-fixture cases and message/absence assertions
first, confirmed red, then implement. Prose tasks are the stated
exception. Mutations via `.claude/skills/ardd-scripts/ardd-state.sh`.

## Phase 1: Terminal-completion rule + status guidance [feedback 50a5]

- [x] T001 State the terminal-completion rule in prose (decided
  2026-07-06: a `completed` tasks file never reopens; later failures
  are new work via /ardd-feedback → plan): add to
  `skills/ardd-implement/SKILL.md`'s Rules section and
  `skills/ardd-converge/SKILL.md`'s reconcile step (converge marks
  work done/partial in non-completed files — it never resurrects a
  completed one), and extend `skills/ardd-tasks/SKILL.md`'s frontmatter
  template comment: "completed is terminal — post-completion failures
  become new feedback, never a status edit." Doc-only; lint-docs green.
- [x] T002 Read sync-tab-scroll's actual
  `.project/feedback/feedback-manual-verification-pass-4b3c.md`
  (status `split`) before finalizing T003's wording: determine what
  that agent was expressing — if it's partial consumption, the
  per-item convention already covers it and T003's message stands; if
  it's a need the convention can't express (e.g. items forked into two
  genuinely separate files), surface that to the user before T003
  instead of assuming. Decision task — record the finding in this
  file as a note on this line. [finding 2026-07-06: `split` expressed
  per-item redistribution — the file's items were forked into 4 group
  feedback files for parallel planning, the file kept as a historical
  record with one item (playback-tempo bug) deliberately left behind,
  still open. That is partial consumption: the per-item convention
  covers it (mark relocated items individually with a destination
  note; the file flips to planned when every item is resolved — the
  leftover open item is exactly why it can't flip yet). T003's default
  wording stands.]
- [ ] T003 lint-project.sh pointed status messages, test-first (bad
  fixtures + message assertions like the placeholder-name one; adjust
  EXPECTED_BAD_FINDINGS): (a) tasks status beginning `reopened` →
  "completed is terminal — capture post-completion failures with
  /ardd-feedback and plan them as new work" (prefix match: the
  observed value carried an inline annotation); (b) tasks status
  `superseded` → "did you mean 'abandoned'? superseded is a plan
  status"; (c) feedback status `split` → wording per T002, default:
  "not a status — mark items individually; the file flips to planned
  when every item is resolved."

## Phase 2: Item-line-scoped tag parsing [feedback 462c]

- [ ] T004 [parallel] Test-first red for the scoping change: add a
  body-prose line to a bad-project tasks fixture carrying a literal
  artifacts bracket-tag that must NOT be reported — assert its absence
  specifically (grep -v style assertion in test-lint-project.sh, not
  just the findings count), alongside the existing item-line
  violations asserting presence. Confirm red (current lint reports the
  prose line).
- [ ] T005 Implement: restrict both bracket-tag checks in
  lint-project.sh (artifact-reference and placeholder-name) to
  checklist item lines — lines matching the `- [ ]` / `- [x]` / `- [-]`
  prefix. T004's absence assertion goes green; all presence assertions
  stay green; EXPECTED_BAD_FINDINGS reconciled.
- [ ] T006 Unwind the dodge-vocabulary contortions in this repo's own
  `.project/` prose where wording got awkward (b959, 2ebc T004/T005
  text, 50a5) — only where the original phrasing was clearer; these
  files are historical records, so touch wording only, never marks,
  statuses, or IDs. Verify lint stays clean (the scoped parsing is
  what makes the original phrasing legal again). Doc-only.
