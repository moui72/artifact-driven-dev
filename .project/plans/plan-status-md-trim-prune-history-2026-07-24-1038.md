---
status: approved
branch: chore-docs-sweep-feedback
created: 2026-07-24
features: [status-md-trim-prune-history]
surfaced-defects: []
---

# Plan: bound STATUS.md history with a keep-last-N prune

## Goal

Give `/ardd-status` a deterministic, opt-in keep-last-N prune of STATUS.md's
`_Updated:` chronology so the live file stays slim in long-running projects,
preserving recent blocks verbatim and relying on git for full history.

## Scope

**In scope**
- A deterministic `scripts/status-prune.sh <file> --keep <N>` that removes
  `_Updated:` blocks beyond the newest N, touching only the chronology tail
  (never head matter, never a kept block's contents), plus its fixture
  regression test and a CI job.
- A new constitution workflow frontmatter field `status_history_keep: <N>`
  (absent = unbounded — existing installs unchanged), settable only via
  `ardd-state.sh stamp`, validated by `lint-project.sh` (positive integer or
  absent).
- Wiring: `/ardd-status` step 6 calls `status-prune.sh` after its prepend when
  the field is set; `/ardd-init` asks the field once; `/ardd-update` offers it
  to installs whose constitution lacks it and can re-ask under
  `--reconfigure`.
- `install.sh` installs `status-prune.sh` into `ardd-scripts` (target-side).
- Prose: narrow the `ardd-status` SKILL.md step-6 invariant and CLAUDE.md's
  "grows over time by design" note; sync any user-facing doc describing
  STATUS.md growth.

**Out of scope**
- Summarizing/condensing blocks — the never-summarize half of the invariant is
  kept intact; prune only drops older verbatim blocks (recoverable from git).
- An age-based cap or `STATUS-archive.md` file — both rejected in the research
  (git already archives; age is fragile for bursty/dormant projects).
- A separate `/ardd-prune` skill — the trim stays inside STATUS.md's single
  writer (`/ardd-status`).
- Changing the default behavior of existing installs — absent field = today's
  unbounded retention.

## Technical Approach

Follows the research recommendation
(`.project/plans/research-status-md-trim-prune-history-2026-07-24-e8a4.md`).
The mechanical tail-cut is a POSIX `sh` script (constitution Principle II —
mutations that are mechanical are script-performed, not left to LLM
compliance); the retention number lives in one place, a constitution workflow
field, matching the existing `workflow_mode` / `next_step_prompt` pattern
(asked by `/ardd-init`, offered by `/ardd-update`, re-askable via
`--reconfigure`, stamped via `ardd-state.sh`, enforced by `lint-project.sh`).
The narrowed invariant: *the most recent N `_Updated:` blocks are preserved
verbatim; older blocks are pruned but recoverable from git; blocks are never
summarized.* Single-writer ownership is unchanged — only `/ardd-status` prunes,
in the same write it already owns.

`status-prune.sh` is a target-side script (installed to `ardd-scripts`,
alongside `branch-info.sh` et al.), so it ships via `install.sh` and its test
runs in this repo's CI like every other `test-*.sh`.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is tracked in
the linked tasks file.

**Phase 1 — The prune script + test + CI**
- Write `scripts/status-prune.sh <file> --keep <N>`: split the file into head
  matter + `_Updated:`-delimited blocks, keep the newest N blocks, rewrite the
  file. Refuse rather than corrupt on a malformed/absent file or a
  non-positive N; be a no-op when block count ≤ N. Never rewrite a kept
  block's bytes.
- Write `scripts/test-status-prune.sh` (fixture STATUS.md files: more-than-N
  blocks, exactly-N, fewer-than-N, head-matter-present, malformed) asserting
  the tail is cut, head + kept blocks are byte-identical, and refusals are
  clean.
- Add a CI job for `test-status-prune.sh` in `.github/workflows/lint.yml`.

**Phase 2 — Constitution workflow field + validators (depends on Phase 1)**
- Extend `scripts/lint-project.sh` to validate `status_history_keep` (absent,
  or a positive integer) in constitution frontmatter; add a fixture case to
  `test-lint-project.sh`.
- Confirm `ardd-state.sh stamp` already handles an arbitrary
  `<field> <value>`; if scoped to an allowlist, add `status_history_keep`.
- Update `/ardd-init` to ask the field once (suggested default surfaced in
  Open Questions) and stamp it; update `/ardd-update` to offer it to installs
  whose constitution lacks the field and to re-ask under `--reconfigure`.

**Phase 3 — Wire `/ardd-status` + narrow the invariant (depends on Phase 2)**
- Update `skills/ardd-status/SKILL.md` step 6: after the prepend-and-preserve
  write, if `status_history_keep` is set, call
  `ardd-scripts/status-prune.sh <STATUS.md> --keep <N>` (installed-copy /
  source-fallback rule like the other script calls). Rewrite the
  "prepend-and-preserve" prose to the narrowed invariant, keeping the
  never-summarize guarantee explicit.
- Update `CLAUDE.md`'s "STATUS.md grows over time by design" note to the
  bounded framing (git backstops full history).

**Phase 4 — Install wiring + doc sync (depends on Phase 3)**
- Update `install.sh` to copy `scripts/status-prune.sh` into the target's
  `ardd-scripts` directory (same handling as the other installed scripts) and
  add it to `CLAUDE.md`'s Commands list.
- Sync user-facing docs that describe STATUS.md's unbounded growth (README's
  "Concurrency and `.project/` merge conflicts" neighborhood / any
  `docs/` mention) and the `templates/dot-project-readme.md` reviewer guide if
  it states the preserve-verbatim rule.
- Run `scripts/lint-docs.sh`, `scripts/lint-project.sh`, and the new/edited
  `test-*.sh` to confirm green.

## Open Questions

- **Suggested default N** for the `/ardd-init` prompt — 3? 5? Blocks are large
  (~300 lines each here), so even N=3 is a substantial cut. The field stays
  optional regardless; this only sets the suggestion.
- **Adopt on this repo now?** This repo dogfoods its own `.project/`; setting
  `status_history_keep` here would immediately slim its 193 KB STATUS.md.
  Decide whether that stamp is part of this change or a separate follow-up.
- **Head-matter boundary.** Confirm during Phase 1 whether STATUS.md's
  non-`_Updated` sections (artifact table, open questions) are a stable head
  block or interleaved, so the script's block delimiter is robust to the
  documented structure (this repo's file is effectively all `_Updated:`
  blocks, but the script must not assume that).
- **`ardd-state.sh stamp` scope** — verify whether it accepts arbitrary
  fields or needs `status_history_keep` added to an allowlist (Phase 2).
