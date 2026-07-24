---
plan: plan-status-md-trim-prune-history-2026-07-24-1038.md
generated: 2026-07-24
status: in-progress
---

# Tasks

## Phase 1: Prune script + test + CI
- [x] T001 Write `scripts/status-prune.sh` (POSIX `sh`) taking `<file> --keep <N>`: read the file, split it into head matter (everything before the first `^_Updated:` line) plus the sequence of `_Updated:`-delimited blocks, keep the head matter and the newest N blocks (the file is prepend-ordered, so newest = topmost), and rewrite the file in place. It must (a) be a clean no-op when block count ≤ N, (b) refuse with a nonzero exit and a `reason=` message rather than corrupting on an absent/unreadable file or a non-positive/non-integer N, and (c) never alter the bytes of any kept block or the head matter. Do not assume the file is all `_Updated:` blocks — preserve head matter when present.
- [x] T002 Write `scripts/test-status-prune.sh` covering fixtures: more-than-N blocks (tail cut, head + kept blocks byte-identical), exactly-N (no-op), fewer-than-N (no-op), head-matter-present (head preserved verbatim), and malformed/absent-file + non-positive-N (clean refusal, nonzero exit, file untouched). Follow the throwaway-fixture pattern of the existing `test-*.sh` scripts — never operate on this repo's real STATUS.md. Depends on T001.
- [x] T003 Add a CI job running `scripts/test-status-prune.sh` to `.github/workflows/lint.yml`, alongside the other `test-*.sh` jobs. Depends on T002.

## Phase 2: Constitution workflow field + validators
- [ ] T004 [artifacts: constitution] Extend `scripts/lint-project.sh` to validate a new constitution frontmatter field `status_history_keep`: accept absent, or a positive integer; reject zero/negative/non-numeric with a clear finding. Keep the enum/field definitions in the existing top-of-script schema block (schema-of-record). Depends on T003.
- [ ] T005 Add fixture coverage for `status_history_keep` to `scripts/test-lint-project.sh` and `tests/fixtures/{good,bad}-project`: a valid positive-integer case and an invalid (zero/negative/non-numeric) case. Depends on T004.
- [ ] T006 Verify whether `scripts/ardd-state.sh stamp` accepts arbitrary `<field> <value>` pairs or restricts fields to an allowlist. If allowlisted, add `status_history_keep`; if arbitrary, confirm no change is needed and note it. Depends on T004.
- [ ] T007 Update `skills/ardd-init/SKILL.md` to ask `status_history_keep` once during initialization (offer a suggested default per the plan's Open Questions — resolve the exact number with the user or default to keeping it unset), stamping it via `ardd-state.sh stamp` — mirroring how `workflow_mode` / `next_step_prompt` are asked. Depends on T006.
- [ ] T008 Update `skills/ardd-update/SKILL.md` to offer `status_history_keep` to installs whose constitution lacks the field (same one-time offer it already makes for `next_step_prompt`) and to re-ask it under `--reconfigure`. Depends on T006.

## Phase 3: Wire /ardd-status + narrow the invariant
- [ ] T009 Update `skills/ardd-status/SKILL.md` step 6 so that, after the prepend-and-preserve write, it greps `status_history_keep` from `.project/artifacts/constitution.md` frontmatter and — when set — calls `.claude/skills/ardd-scripts/status-prune.sh <STATUS.md> --keep <N>` (installed-copy-with-source-fallback rule, same as the other ardd-scripts calls). Absent field = no prune (unchanged behavior). Depends on T003.
- [ ] T010 Rewrite the "Prepend-and-preserve" prose in `skills/ardd-status/SKILL.md` step 6 to the narrowed invariant: the most recent N `_Updated:` blocks are preserved verbatim; older blocks are pruned (recoverable from git); blocks are never summarized or condensed. Keep the never-summarize guarantee explicit and the single-writer boundary intact. Depends on T009.
- [ ] T011 Update `CLAUDE.md`'s "STATUS.md grows over time by design" description to the bounded framing (recent-N verbatim in the live file; git backstops full history), consistent with the narrowed SKILL.md invariant. Depends on T010.

## Phase 4: Install wiring + doc sync
- [ ] T012 Update `install.sh` to copy `scripts/status-prune.sh` into the target's `.claude/skills/ardd-scripts/` directory, exactly as the other installed scripts (e.g. `branch-info.sh`) are handled. Depends on T001.
- [ ] T013 Add `scripts/status-prune.sh` and `scripts/test-status-prune.sh` to `CLAUDE.md`'s Commands list with one-line descriptions matching the existing entries' style. Depends on T012.
- [ ] T014 Sync user-facing docs that describe STATUS.md's unbounded growth to the bounded framing: README's "Concurrency and `.project/` merge conflicts" neighborhood and any `docs/` mention, plus `templates/dot-project-readme.md` if it states the preserve-verbatim rule. Depends on T011.
- [ ] T015 Run `scripts/lint-docs.sh`, `scripts/lint-project.sh`, `scripts/test-status-prune.sh`, and `scripts/test-lint-project.sh` and confirm all pass with no new findings. Depends on T005, T013, T014.
