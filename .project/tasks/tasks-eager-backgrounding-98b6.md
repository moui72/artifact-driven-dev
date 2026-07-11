---
plan: plan-eager-backgrounding-2026-07-10.md   # exact filename of the source plan — authoritative binding
generated: 2026-07-10
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
---

# Tasks

## Phase 1: fold-to-main helper

- [x] T001 Create `scripts/fold-to-main.sh` and its regression test in one
  commit (Quality Standards: a deterministic check ships with its
  fixture test). The script: resolve the default branch via the same
  fallback chain `branch-info.sh` uses; if the working tree is dirty, print
  `folded=false reason=dirty` and exit non-zero (refuse, don't stash); else
  fast-forward-only merge the current branch into the local default branch
  and `git checkout` the default, printing `folded=true`; if the fold is not
  a fast-forward (default diverged), print `folded=false reason=diverged` and
  exit non-zero — never resolve. POSIX `sh`. Add it to the set of scripts
  `install.sh` copies into `.claude/skills/ardd-scripts/`. Write
  `scripts/test-fold-to-main.sh` using throwaway repos under a temp dir
  (same paradigm as `test-worktree-align.sh`): assert clean-FF →
  `folded=true` and HEAD on default; dirty tree → refused `reason=dirty`;
  diverged default → refused `reason=diverged`. Follow Principle V — write
  the test, confirm it fails (script absent/incomplete) before the script is
  complete. Add a CI job in `.github/workflows/lint.yml`; the pre-commit hook
  glob-discovers the new `test-*.sh` automatically — run it to confirm green.
  (F002)

## Phase 2: eager delegation gates

- [ ] T002 Rewrite the solo-mode delegation gate in
  `skills/ardd-implement/SKILL.md` (step 3) and
  `skills/ardd-converge/SKILL.md` (step 2), keeping the two prose blocks
  identical (the deliberate residual duplication). Replace the
  "`on_default` false → continue inline" rule with an eager offer presented
  **regardless of `on_default`**: still run the in-flight-worktrees check
  first, then offer "delegate to a background subagent (recommended)" vs.
  "continue inline on the current branch." When the user accepts while on a
  non-default branch, run `fold-to-main.sh` (from T001): on `folded=true`,
  proceed to delegate — the subagent's worktree branches from `main` and
  `worktree-align.sh` carries the just-folded state in, and the focused
  session is left on `main` (F002); on `folded=false`, stop and surface the
  reason verbatim, never resolve. Preserve the inline opt-out. Scope this to
  **solo mode only** — leave collaborative mode's PR-based flow unchanged
  (state that explicitly). Per the plan's recommended resolution of Open
  Question 1, frame the eager offer as cleanest at run start; if mid-run,
  note the transient in-progress-on-`main` window. Depends on T001's script
  and its `folded=true|false reason=...` output contract. (F001, F002)

## Phase 3: doc + decision-record sweep

- [ ] T003 Update the prose that explains *why* inline-on-a-branch was the
  old default so it matches the new behavior: `CLAUDE.md`'s worktree-native
  state / delegation section, and a decision record capturing the
  fold-to-main rationale and the worktree-base obstacle it works around
  (extend `docs/decisions/0001-*.md` or add `0004-*.md`). Update `USAGE.md`
  if it describes the delegation flow. Run `scripts/lint-docs.sh` — it must
  stay green. Depends on T002 (documents its behavior). (F001)
