---
plan: plan-chore-feedback-status-readines-2026-07-23-659e.md
generated: 2026-07-23
status: in-progress
---

# Tasks

## Phase 1: Rework badge-sync workflow to survive branch protection

- [ ] T001 In `.github/workflows/ardd-badge.yml`, replace the "Commit if
      changed" step's direct `git push` to `main` (currently lines 80-91)
      with a PR-based path: after detecting a diff in
      `.github/badges/ardd-version.json`, create a short-lived branch
      (e.g. `badge-sync-<run-id>` or similar unique name), commit the
      regenerated JSON there, push that branch, and run
      `gh pr create --base main --title "chore: sync ArDD version badge"
      --body "..." --label ...` (use the existing `GITHUB_TOKEN`, granting
      `pull-requests: write` alongside the existing `contents: write`
      permission at the top of the job). Do not attempt `git push` to
      `main` directly anywhere in this step. [feedback:
      feedback-branch-protection-badge-exception-a8a9.md F001]
- [ ] T002 Immediately after the `gh pr create` call
      added in T001, attempt `gh pr merge --auto --squash` on the opened
      PR so it merges itself once/if the ruleset's approval requirement is
      satisfied by an existing bypass; if the `gh pr merge --auto` call
      fails (e.g. non-zero exit because auto-merge isn't enabled on the
      repo, or the approval requirement blocks it), let the step exit
      successfully anyway with a note in the job log that the PR is open
      and awaiting manual approval/merge — never fail the workflow run
      over an unmergeable badge-sync PR. [feedback:
      feedback-branch-protection-badge-exception-a8a9.md F001]
- [ ] T003 Manually verify the reworked `ardd-badge.yml` step: run
      `actionlint .github/workflows/ardd-badge.yml` (or equivalent YAML/
      shell lint available in this repo) to confirm the script block is
      still well-formed, then trigger the workflow via
      `gh workflow run ardd-badge.yml` against a throwaway branch/fork if
      possible, or at minimum review the rendered step logic by hand for
      correctness (branch name uniqueness, `gh pr create`/`gh pr merge`
      flag correctness) since this repo has no existing
      `scripts/test-*.sh` harness for GitHub Actions workflow files.
      [feedback: feedback-branch-protection-badge-exception-a8a9.md F001]

## Phase 2: Isolate the update-check test's live-tag dependency

- [ ] T004 In `scripts/test-ardd-update-check.sh`,
      before the "producer contract" section (~line 228 onward, which
      currently sets `REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"` and runs
      `install.sh` directly against it), add a step that creates an
      untagged clone of `$REPO_ROOT` at its current `HEAD` SHA into a
      fresh directory under `$WORK` (e.g.
      `git clone --no-tags --branch <detached-not-applicable> ...` is not
      valid for a plain SHA checkout — instead: `git init` a new repo in
      `$WORK/repo-clone`, `git -C "$WORK/repo-clone" fetch --depth 1
      "$REPO_ROOT" HEAD`, then `git -C "$WORK/repo-clone" checkout
      FETCH_HEAD` — this fetches only the commit object graph reachable
      from `HEAD`, pulling in no tags from `$REPO_ROOT`). Store this
      clone's path in a new variable (e.g. `REPO_CLONE`).
- [ ] T005 In `scripts/test-ardd-update-check.sh`, change the two producer-
      contract `install.sh` invocations (the `Source-Commit` assertion and
      the "records Channel: stable by default" assertion, currently both
      running `( cd "$REPO_ROOT" && sh ./install.sh "$TP" )`) to instead
      run `( cd "$REPO_CLONE" && sh ./install.sh "$TP" )` — using the
      untagged clone from T004 so `install.sh`'s `git tag --points-at
      HEAD` inference (`install.sh:573-576`) always sees zero tags and the
      channel deterministically resolves to `stable`, regardless of
      whether `beta-release.yml` has tagged the real repo's `HEAD` by the
      time this test runs. Leave every other `install.sh` invocation in
      the file (e.g. the `ARDD_CHANNEL=beta`, re-install-preserves-channel,
      and unknown-`ARDD_CHANNEL`-refused cases) targeting `$REPO_ROOT` as
      before — those assertions pass explicit `ARDD_CHANNEL` values or
      test rejection behavior, not the tag-inference fallback, so they
      aren't affected by live tag state.
- [ ] T006 Run `sh scripts/test-ardd-update-check.sh` locally and confirm
      every assertion passes, in particular "install.sh records Channel:
      stable by default" — first with the repo's real `HEAD` untagged (the
      common case), and, if a beta tag currently points at `HEAD` in this
      checkout, confirm the assertion still passes despite that (proving
      the fix actually decouples the test from live tag state). [feedback:
      feedback-test-ardd-update-check-channel-0bc9.md F001]
