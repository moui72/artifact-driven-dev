---
plan: plan-work-queue-parallel-safety-2026-07-19-4c10.md
generated: 2026-07-19
status: in-progress
---

# Tasks

## Phase 1: parallel-matrix.sh (test-first)

- [x] T001 Create `scripts/test-parallel-matrix.sh` (POSIX sh, source-side
  regression test, red-first) against throwaway fixture repos built in a
  temp dir — never this repo's own worktrees. Cases: (a) two `ready`
  tasks files with disjoint plan `features:` lists and disjoint
  `[artifacts: ...]` tags → `verdict=independent`; (b) two `ready` files
  whose plans share a feature slug → `verdict=shared-feature` (and
  shared-feature wins when artifacts also overlap); (c) disjoint features
  but a shared `[artifacts: x]` tag → `verdict=shared-artifact`; (d) a
  tasks file with a missing plan file or a plan lacking `features:` →
  `features=unknown` on that side and never a `shared-feature` verdict;
  (e) a `ready` file paired against an in-flight worktree's claimed tasks
  file (real second worktree in the fixture repo) → pair line emitted;
  (f) zero or one `ready` file and no in-flight worktrees → no output,
  exit 0. Follow the harness conventions of
  `scripts/test-inflight-worktrees.sh` (closest sibling). Test must fail
  (red) before T002 lands.

- [x] T002 Create `scripts/parallel-matrix.sh` (POSIX sh, target-side —
  installed to `ardd-scripts`): enumerate `.project/tasks/tasks-*.md`
  with frontmatter `status: ready` in the current checkout, plus each
  in-flight tasks file from `inflight-worktrees.sh` (invoked from the
  script's own directory, `branch-info.sh`-consumer pattern; read the
  claimed file from that worktree's copy). For every pair emit one line:
  `pair=<a>:<b>	verdict=independent|shared-feature|shared-artifact	features=<slugs|unknown|none>	artifacts=<tags|none>`.
  Feature overlap via tasks `plan:` → plan `features:` chain (broken
  chain → `features=unknown`, never guess, never `shared-feature`);
  artifact overlap via `[artifacts: ...]` tag intersection across task
  lines; `shared-feature` wins over `shared-artifact`. Header comment
  states `independent` = "no declared overlap only; merge_policy still
  governs". No path heuristics. Exit 0 with no output when fewer than
  two participants. Makes T001 green.

- [x] T003 Wire distribution and CI, same commit as T001–T002: add a
  `test-parallel-matrix` job to `.github/workflows/lint.yml` (mirror an
  existing test job); add `parallel-matrix.sh` to `install.sh`'s
  `ardd-scripts` ship list with an installed-and-executable assertion in
  the existing install tests; add both script lines to `CLAUDE.md`'s
  Commands block.

## Phase 2: /ardd-status Work Queue section

- [x] T004 Update `skills/ardd-status/SKILL.md`: step 1 additionally runs
  `.claude/skills/ardd-scripts/parallel-matrix.sh` (installed copy;
  source-repo absolute-path fallback, same present-or-fallback rule as
  the other ardd-scripts calls); add a **Work Queue** section to the
  step-5 report template and a matching STATUS.md item in step 6 — one
  entry per `ready` tasks file (filename, bound plan/features, verdicts
  against other ready files and in-flight claims), omitted entirely when
  no `ready` file exists (house omit-if-none convention). State
  explicitly that `independent` means "no declared overlap", not
  "conflict-free", and that this is read-only visibility (single-writer
  boundaries unchanged).

## Phase 3: /ardd-implement picker annotations

- [x] T005 Update `skills/ardd-implement/SKILL.md` step 1: run
  `parallel-matrix.sh` (installed copy, absolute-path fallback) alongside
  the existing `inflight-worktrees.sh` call and annotate each pick-list /
  fan-out multi-select option with its verdicts against the other
  options and in-flight claims. `shared-feature` = strong warning in the
  option text, never a hard exclusion — the same-file claim check stays
  the only hard exclusion. Add one judgment sentence: when two candidate
  files look related, skim both and flag likely code-path contact before
  fanning out. Restate that `merge_policy` conflict handling still
  governs at merge time.

## Phase 4: Docs

- [x] T006 Update the hand-written bodies (below the `generated:end`
  marker) of `docs/reference/skills/ardd-status.md` and
  `docs/reference/skills/ardd-implement.md` to describe the Work Queue
  section and picker annotations, including the "no declared overlap"
  meaning of `independent`; run `./scripts/lint-docs.sh` and the full
  affected test set (`test-parallel-matrix.sh`, install tests,
  `lint-project.sh` self-check) to confirm green.
