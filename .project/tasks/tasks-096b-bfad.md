---
plan: plan-096b-2026-07-22-479f.md
generated: 2026-07-22
status: in-progress
---

# Tasks

## Phase 1: F002 — red-first script fix
- [x] T001 Add a case to `scripts/test-ardd-state.sh` asserting that
      `ardd-state.sh feature-create <slug>` prints the resolved absolute
      path of the file it wrote (e.g. matching
      `/.*\.project/features/<slug>\.md$/` against its stdout, not just
      the current bare confirmation text), and a second case making the
      same assertion for `ardd-state.sh stamp <file> last_updated
      <date>`. Run `scripts/test-ardd-state.sh` and confirm both new
      cases fail red — the absolute-path behavior doesn't exist yet.
- [x] T002 Update every write-performing `ardd-state.sh` subcommand
      (`feature-create`, `stamp`, `tasks-flip`, `task-check`,
      `feature-flip`, `feedback-mark`, `feedback-planned`, `mint`) to
      include the resolved absolute path of the file it wrote/mutated in
      its existing confirmation line (e.g. via
      `$(cd "$(dirname "$f")" && pwd)/$(basename "$f")` or equivalent
      POSIX-portable resolution). Run `scripts/test-ardd-state.sh` and
      confirm all cases (including T001's two new ones) pass green. Then
      run the full regression suite (every `scripts/test-*.sh`) and
      confirm nothing else regressed.

## Phase 2: F001, F003, F004, F006 — skill-prose fixes [parallel]
- [x] T003 [parallel] In `skills/ardd-update/SKILL.md` step 4
      (currently lines ~105-128), broaden the pre-reinstall
      `--harness`-support check to run for both harnesses, not just
      `HARNESS=codex`. Keep Codex's existing stop-and-explain behavior
      unchanged when unsupported. Add the new Claude-specific branch:
      when the resolved source's `install.sh` lacks `--harness` support
      and `HARNESS=claude`, omit `--harness claude` from the reinstall
      invocation (run `<source>/install.sh <this project's root>`
      instead of `<source>/install.sh --harness claude <this project's
      root>`) and note in the relayed output that the source predates
      explicit-harness recording, rather than stopping. Verify by
      reading the edited section back and confirming both harness
      branches are now covered by the pre-check.
- [x] T004 [parallel] In `skills/ardd-init/SKILL.md`'s existing-codebase
      reverse-engineer step, add guidance: before writing a
      universal-coverage claim in a generated artifact ("every X has
      Y"), enumerate each relevant instance of X individually and verify
      Y against it, rather than generalizing from a representative
      sample. When full verification isn't performed or isn't
      practical, phrase the claim conservatively ("N of M observed
      entities have Y") instead of an unverified "every."
- [x] T005 [parallel] In `skills/ardd-plan/SKILL.md` step 12 (Generate
      tasks), add a bullet alongside the existing test-requirement
      guidance (near the "Include a test requirement..." bullet): before
      phrasing a TDD red-first task ("confirm it fails first"), check
      whether its precondition work already landed via an earlier task
      in the same plan (an earlier phase, or an earlier task in the same
      phase) — if so, phrase the task as directly
      implementing/extending the already-existing code instead, since
      there is no red state left to confirm.
- [x] T006 [parallel] In `skills/ardd-status/SKILL.md`'s Feature
      Backlog report format (currently around lines 213-219), add one
      explicit sentence: the four core buckets
      (backlogged/planned/tasked/implemented) always print, even at
      zero — only `retired`/`rejected`/`subsumed` omit when their count
      is zero.
