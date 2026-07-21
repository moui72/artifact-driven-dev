---
plan: plan-multi-harness-2026-07-21-76ba.md
generated: 2026-07-21
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: Harness metadata in install.sh

- [x] T001 [artifacts: constitution] Red-first: extend
  `scripts/test-install-harness.sh` with failing cases pinning the new
  metadata contract — (a) `--harness claude` install writes
  `Harnesses: claude` to `.project/ardd-version.md` (or the absent-line
  backward-compat form the implementation chooses — assert the parseable
  contract); (b) `--harness codex` writes `Harnesses: codex`; (c) dual
  install claude-then-codex and codex-then-claude both end with
  `Harnesses: claude,codex` (order-normalized) and BOTH skill trees
  (`.claude/skills/ardd-*/`, `.agents/skills/ardd-*/`) intact; (d) a
  reinstall of one harness preserves the sibling's membership in the
  line; (e) dev-mode reinstall (source resolving `channel=dev`) records
  `Channel: dev` and drops any stale `Source-Ref` (878c F002). Confirm
  the new cases fail against current `install.sh` before T002.
- [ ] T002 [artifacts: constitution] Implement in `install.sh`:
  union-write the `Harnesses:` line (read existing, add the invoking
  harness, sort/normalize; absent line parses as `claude` for old
  files); write `Channel: dev` and omit `Source-Ref` when the source
  resolved dev-mode; keep `ardd-update-check.sh` and
  `source-resolve.sh` parsing unaffected by the new line. All T001
  cases green; full existing install suite stays green.
- [ ] T003 [artifacts: constitution] Harness-neutral shared prose +
  bounded ignore guidance: the generated reviewer guide
  (`templates/dot-project-readme.md` and install.sh's write of it)
  lists every installed harness root rather than hardcoding
  `.claude/`; install.sh's gitignore suggestion and `.worktreeinclude`
  handling name `.agents/skills/ardd-*/` alongside
  `.claude/skills/ardd-*/` when (and only when) the codex harness is
  installed — never a broader parent (Principle III). Test: extend
  `scripts/test-install-harness.sh` (or the worktreeinclude/gitignore
  suites where the assertions already live) red-first for the dual and
  codex-only shapes.

## Phase 2: Pre-commit hook staged-path scoping

- [ ] T004 [parallel] Red-first: extend `scripts/test-hooks-pre-commit.sh`
  with marker-file-stub routing cases in a real `git init` fixture —
  (a) stage only `.project/x.md` → only the lint-project stub ran;
  (b) stage `scripts/branch-info.sh` → its `test-branch-info.sh` stub
  ran and the `test-new.sh` stub did not; (c) stage an unmapped path
  (e.g. `.github/x`) → all stubs ran; (d) empty staged list → all
  stubs ran; (e) `ARDD_HOOK_ALL=1` → all stubs ran regardless of
  staged paths. Existing aggregation/short-circuit cases unchanged.
- [ ] T005 Implement staged-path scoping in `hooks/pre-commit`
  (POSIX sh): pattern table for `lint-docs.sh` (README/USAGE/
  CONTRIBUTING/docs/skills), `lint-project.sh` (`.project/`),
  `test-new.sh` (`new.sh`), the `test-install-*`/`test-merge-driver`/
  `test-ardd-update-check` family (`install.sh`, `templates/`,
  `migrations/`, `skills/`), and `test-hooks-pre-commit.sh`
  (`hooks/`); generic rule `scripts/test-X.sh` guards `scripts/X.sh`;
  fail-safe run-all on empty staged list, unmapped staged path, or a
  test with no matching subject file; `ARDD_HOOK_ALL=1` override. All
  T004 cases green.

## Phase 3: Docs drift

- [ ] T006 Rewrite `docs/reference/skills/ardd-update.md` "What a run
  does" step 4 body (below the `generated:end` marker): reinstall
  reads `HARNESS=` from `harness-capabilities.env` and passes
  `--harness <harness>`, refusing (with the safe choices) when a Codex
  install's selected source lacks `--harness` support; replace "Your
  README is never edited; the snippet is yours to paste" and the
  suggestions sentence with the confirm-with-diff posture (offer to
  apply, exact diff shown, ask before writing). Doc-only — no test
  requirement (Principle V exception); `scripts/lint-docs.sh` and
  `gen-skill-docs.sh --check` stay green.
- [ ] T007 Document `install.sh --harness codex` in `docs/install.md`
  (flag semantics, `.agents/skills/` target, degraded-v1 caveats per
  the constitution's Multi-harness section, dual-install metadata
  shape from Phase 1) and add a USAGE.md routing line for the Codex
  install path. Doc-only — no test requirement; lint-docs stays green.

## Phase 4: Skill-prose and scenario hardening

- [ ] T008 [parallel] Harden `tests/scenarios/GUARDRAILS.md`: before ANY
  guardrails-prescribed git mutation (`git remote remove origin`,
  `git init`, adding the fake origin) the subagent must verify cwd is
  inside `$SCRATCH` (`case "$PWD" in "$SCRATCH"/*) ;; *) stop and
  report ;; esac`); prefer structural `git -C "$SCRATCH/..."` /
  absolute-path forms over cwd-dependent invocations; any damage to a
  path outside `$SCRATCH` is reported immediately as an incident,
  never silently fixed. Prose-only — no test requirement.
- [ ] T009 [parallel] Add to `skills/ardd-plan/SKILL.md` step 10 an
  explicit clause: the browser-preview question and the
  approve/revise/stop question are two separate, sequential prompts —
  never one AskUserQuestion — and a requested preview is published,
  opened, and its URL shown before the approval question fires.
  Prose-only — no test requirement.
- [ ] T010 [parallel] Fix scenario S2's cold-fixture premise
  (`tests/scenarios/S2.md`): name/prepare a genuinely never-ArDD clone
  source — either a cleanup step cleansing the daily-huddle clone of
  committed ArDD state (`.project/`, `.ardd-applied`, old
  `.claude/skills/`) inside `$SCRATCH` before the run, or a different
  fixture repo — so the reverse-engineer path is exercised without
  ad-hoc `rm -rf`. Brief edit only — validated by the next sweep run,
  never mid-sweep.
- [ ] T011 [parallel] Add to `tests/scenarios/S7.md` setup a one-line
  post-install check that the `.project/README.md` reviewer guide is
  present and coherent (878c F005 / graduation G2). Brief edit only.
- [ ] T012 [parallel] Add the collaborative-mode scaffold note to
  `skills/ardd-init/SKILL.md` and `skills/ardd-backlog/SKILL.md`: in
  `workflow_mode: collaborative`, pre-plan `.project/` scaffold writes
  stay uncommitted on the default branch (or go straight to a branch)
  — `/ardd-plan`'s branch gate carries them onto the work branch;
  committing them to the local default branch violates the mode.
  Prose-only — no test requirement.
