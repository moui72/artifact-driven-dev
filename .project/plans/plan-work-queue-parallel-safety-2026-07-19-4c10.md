---
status: approved
branch: work-queue-parallel-safety
created: 2026-07-19
features: [work-queue-parallel-safety]
---

# Plan: Work-queue parallel-safety view

## Goal

Give the user a single-pane answer to "what work is pending, and what is
safe to launch in parallel with what" — a deterministic
`parallel-matrix.sh` overlap report, surfaced as a Work Queue section in
`/ardd-status` and as annotations on `/ardd-implement`'s fan-out
multi-select picker.

## Scope

**In scope:**
- New installed script `scripts/parallel-matrix.sh` (POSIX sh, shipped to
  `ardd-scripts` by `install.sh`) computing pairwise overlap verdicts
  among `ready` tasks files and in-flight worktrees.
- Fixture-based regression test `scripts/test-parallel-matrix.sh` and a
  CI job in `.github/workflows/lint.yml`, same commit as the script.
- A **Work Queue** section in `/ardd-status`'s report and `STATUS.md`.
- Matrix-annotated options in `/ardd-implement`'s fan-out multi-select
  pick list, plus one judgment sentence prompting the agent to flag
  likely code-path contact.
- Docs: reference pages for the two skills, `CLAUDE.md` commands list.

**Out of scope (per the vetting in
`research-work-queue-parallel-safety-vie-2026-07-19-25f7.md`):**
- Any path-mention heuristic tier in the script — prose paths are
  unstructured; path-contact assessment stays agent judgment at
  presentation time.
- A separate `/ardd-board` report-owner skill or new report file.
- Comparing against collaborative-mode draft PRs (solo-mode-first; a
  follow-up if needed).
- Structured `paths:` frontmatter on tasks files.

## Technical Approach

The script consumes existing on-disk structure only:

- **Inputs:** every `.project/tasks/tasks-*.md` at `status: ready` in the
  current checkout, plus `inflight-worktrees.sh` output (each in-flight
  worktree's claimed tasks file, read from that worktree's copy). The
  script invokes `inflight-worktrees.sh` from its own directory (sibling
  script, same pattern as `branch-info.sh` consumers).
- **Feature overlap** via the existing binding chain: tasks file `plan:`
  frontmatter → plan file `features:` list. When the chain breaks
  (missing plan file, no `features:` field — true of pre-worktree-native
  files), report `features=unknown` for that side and never guess; a pair
  with an `unknown` side can still get an artifact verdict but never
  `shared-feature`.
- **Artifact overlap** via `[artifacts: ...]` tag intersection across the
  two files' task lines (the tags `lint-project.sh` already validates).
- **Output:** one line per pair, machine-parseable in the house style:
  `pair=<a>:<b>\tverdict=independent|shared-feature|shared-artifact\tfeatures=<slugs|unknown|none>\tartifacts=<tags|none>`
  where `shared-feature` wins over `shared-artifact` when both hold.
  `independent` means **no declared overlap only** — the script's header
  comment, both skills' prose, and the docs all state this explicitly;
  `merge_policy` conflict handling still governs at merge time.
- **Verdict severity is advisory, not blocking:** `shared-feature` is a
  strong warning in the picker, not a hard exclusion (the same-file claim
  check remains the only hard exclusion). Worktree-native state makes a
  bad pairing recoverable at merge, so blocking would be
  disproportionate.

Skill wiring reuses the established shared-script split (`branch-info.sh`
precedent): computation once in the script, presentation duplicated in
the two skills' prose.

## Phase Breakdown

### Phase 1: parallel-matrix.sh (test-first) — no dependencies
- Create `scripts/parallel-matrix.sh` per the Technical Approach.
- Create `scripts/test-parallel-matrix.sh` against throwaway fixture
  repos: independent pair; shared-feature pair (via plan chain);
  shared-artifact pair; broken chain → `features=unknown` and no
  `shared-feature` verdict; ready file vs in-flight worktree claim;
  zero/one ready file → no output, exit 0. Red before implementation.
- CI job in `.github/workflows/lint.yml`; `install.sh` ships the script
  to `ardd-scripts` with an installed-and-executable assertion in the
  install tests. Same commit.

### Phase 2: /ardd-status Work Queue section — depends on Phase 1
- `skills/ardd-status/SKILL.md`: step 1 runs `parallel-matrix.sh`
  (installed copy, absolute-path fallback, present-or-fallback rule);
  new **Work Queue** report section and STATUS.md line(s): each `ready`
  tasks file with its plan/features and verdicts against other ready
  files and in-flight claims; omit the section when no `ready` file
  exists. State the "no declared overlap" meaning of `independent`.

### Phase 3: /ardd-implement picker annotations — depends on Phase 1
- `skills/ardd-implement/SKILL.md`: step 1's pick list (and the fan-out
  multi-select) annotates each option from the same script output;
  `shared-feature` = strong warning, never a hard exclusion; one
  judgment sentence telling the agent to skim apparently-related files
  and flag likely code-path contact; restate that `merge_policy` still
  governs.

### Phase 4: Docs — depends on Phases 2–3
- `docs/reference/skills/ardd-status.md` and `ardd-implement.md`
  hand-written bodies; `CLAUDE.md` commands list entry for the new
  script + test; `scripts/lint-docs.sh` stays green.

## Open Questions

- None blocking. (The two questions the research doc left open are
  resolved in this plan: `shared-feature` is a warning, not a hard
  exclusion; collaborative-mode draft-PR comparison is out of scope,
  solo-mode-first.)
