---
plan: plan-dot-project-reviewer-guide-2026-07-20-ee87.md
generated: 2026-07-20
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Source-Path portability

- [x] T001 Edit `install.sh` (~line 416) so the `Source-Path:` it writes into
  the target's `.project/ardd-version.md` is home-relative — when
  `$SCRIPT_DIR` sits under `$HOME`, record it as `~/<rest>`; otherwise keep
  the absolute path. POSIX `sh` only (prefix match on `$HOME/`, no bashisms).
  Add a regression case to `scripts/test-install-gitattributes.sh` or a new
  `scripts/test-install-source-path.sh` (fixture install into a temp target;
  assert the recorded line starts with `~/` when the source is under a
  faked `$HOME`) — same commit (test-first per constitution Principle V).
- [x] T002 [parallel] Teach both readers to expand a leading `~` in a
  recorded `Source-Path`: `scripts/source-resolve.sh` (~line 72) and
  `scripts/ardd-update-check.sh` (~line 65) — replace a leading `~/` with
  `$HOME/` after the `sed` extraction, never via eval. Extend
  `scripts/test-source-resolve.sh` with a `~`-recorded fixture case, same
  commit.
- [x] T003 Legacy repair in `install.sh`: when re-installing over a target
  whose existing `.project/ardd-version.md` records an absolute
  `Source-Path` under the current `$HOME`, rewrite it to the portable `~/`
  form and print a notice that the old absolute path remains in the
  consumer's git history — repairing history (rewrite/squash before sharing,
  or accepting the leak if already public) is the user's call, with a
  one-line recommendation (accept if already public). Leave the change
  uncommitted (plan Open Question 2's working assumption). Regression case
  in the same test file as T001, same commit.
- [x] T004 Edit `skills/ardd-update/SKILL.md` to relay T003's legacy-repair
  notice when install.sh prints it (relay verbatim, add the history-repair
  framing once — the skill already relays install output, so this is a
  pointer, not new mechanism).
- [x] T005 Sweep every other generated-and-committed file class for
  machine-specific absolute paths: grep the writers (`install.sh`,
  `scripts/*.sh`, `skills/*/SKILL.md` templates) for `$HOME`/`$SCRIPT_DIR`/
  `$PWD`-derived values written into committed target files. Fix any found
  the same home-relative way (with test), or record "none found" in the
  commit message.

## Phase 2: next_step_prompt auto + denial degradation

- [x] T006 [artifacts: constitution] Widen the `next_step_prompt` enum in
  `scripts/lint-project.sh`'s workflow-field enum block to
  `true | false | auto`, and update `scripts/test-lint-project.sh` fixtures
  (`tests/fixtures/good-project` gains an `auto` case; bad fixture keeps an
  invalid value rejected) — one commit, together with T007's prose
  (schema-of-record rule: enum and writer land in the same commit).
- [x] T007 Edit `skills/ardd-status/SKILL.md` step 8 and
  `skills/ardd-plan/SKILL.md` step 15 + the slate-mode prompt section:
  document `auto` — when `next_step_prompt: auto` and the recommendation is
  a concrete runnable `/ardd-*` invocation, invoke it directly (the
  existing terminal-handoff mechanism) without AskUserQuestion; state the
  invocation being auto-run in the report text first; non-runnable
  recommendations stay plain text. Same commit as T006.
- [x] T008 In the same two prompt sections (both skills), add the denial
  rule from feedback 20da F001: a denied or unavailable AskUserQuestion
  call (e.g. Claude Code's dontAsk permission mode) means "no — stop here"
  — never retry the prompt, never treat the denial as an error that
  discards the report/plan already written.
- [x] T009 Update the one-time configuration ask in
  `skills/ardd-init/SKILL.md` and `skills/ardd-update/SKILL.md`
  (`--reconfigure` and the backfill ask) to offer three values
  (`true`/`false`/`auto`) with one-line descriptions; stamped via
  `ardd-state.sh stamp` as today.
- [x] T010 Update docs mentioning the boolean field:
  `docs/reference/skills/` pages for status/plan/init/update hand-written
  bodies and any guide text (`scripts/lint-docs.sh` must stay green; run
  `/docs-sweep`-style spot check on the touched pages).

## Phase 3: Plan-record conventions

- [x] T011 Edit `skills/ardd-plan/SKILL.md` drafting prose (step 8) and the
  tasking template (steps 12–13): plans emit plain enumerations, never
  `- [ ]` checkboxes; the plan template carries a "phase lists are plan
  work-items, not live checklists — progress is tracked in the linked
  tasks file" note; and add the derivable-counts convention — never
  restate in prose a count derivable from an enumeration in the same
  document (feedback 19ce F003/F004; F004 decided: static historical
  record).
- [x] T012 [parallel] Verify `skills/ardd-implement/SKILL.md` nowhere
  implies it updates plan checklists or plan progress; if any wording
  suggests it, fix it to point at the tasks file as the sole progress
  record.

## Phase 4: .project/ reviewer guide

- [x] T013 Resolve plan Open Question 1, then author the guide as a
  source-side template (e.g. `templates/dot-project-readme.md`): how to
  read `.project/` — which files are generated vs authored, which look
  live but are static historical records (plans, planned feedback files,
  completed tasks files), the single-writer/disposable-report conventions,
  and that `.claude/skills/` is regenerated output. Check the known
  consumer repos for a hand-authored `.project/README.md` first; default
  to install.sh-owned overwrite-on-install, falling back to
  create-if-absent + drift notice if any consumer authors one.
- [x] T014 Wire it into `install.sh`: write the guide to the target's
  `.project/README.md` per T013's decision, add a one-line pointer in the
  generated `ardd-version.md`, and add a regression case (temp-target
  install asserts the file and pointer exist). Update install.sh's
  gitignore-check allowlist only if a new `.claude/skills/` directory is
  involved (it isn't expected to be).
- [ ] T015 Mention the installed guide in `README.md`/`USAGE.md` where
  `.project/` is introduced (keep `scripts/lint-docs.sh` green).
