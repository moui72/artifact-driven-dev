---
status: approved
branch: chore-feedback-status-readines
created: 2026-07-23
features: []
surfaced-defects: []
---

# Plan: Badge-sync branch protection fix + update-check test isolation

## Goal

Rework the ArDD version badge sync workflow so it keeps working under `main`
branch protection, and stop `scripts/test-ardd-update-check.sh` from relying
on this repo's own live tag state for its "Channel: stable by default"
assertion.

## Scope

In scope:
- `.github/workflows/ardd-badge.yml` — replace the direct `git push` to
  `main` with a path that survives the branch-protection rule added in
  `0a4d52a` (1 approving review required, changes via PR only).
- `scripts/test-ardd-update-check.sh` — isolate the "install.sh records
  Channel: stable by default" assertion (~line 238) from this repo's live,
  ever-changing tag state.

Out of scope:
- Changing the `main` branch protection ruleset itself (a GitHub repo
  setting, not a code change this plan can make — see Open Questions).
- Any other assertion in `test-ardd-update-check.sh` — only the one flagged
  in the feedback is order/timing-dependent on this repo's real tags.

## Technical Approach

**Badge-sync workflow (F001, `feedback-branch-protection-badge-exception-a8a9.md`).**
`ardd-badge.yml` currently commits the regenerated
`.github/badges/ardd-version.json` and pushes straight to `main`
(`ardd-badge.yml:80-91`), which now fails with `GH006` because `main`
requires changes via PR. Since this repo's ruleset requires 1 approving
review — auto-merge alone can't satisfy that without a bot/human approval
step — the workflow is reworked to open a PR against `main` instead of
pushing directly: create a short-lived branch, commit the regenerated JSON
there, `gh pr create`, and (only if the ruleset already carries a bypass or
auto-approve path) `gh pr merge --auto`. Where the badge JSON only ever
differs on version-bump commits, the resulting PR volume is low. The
`git push` failure mode itself (GH006) is left for the workflow to no-op
past when opening the PR isn't possible in some sandboxed run, rather than
hard-failing the whole workflow.

**Test isolation (F001, `feedback-test-ardd-update-check-channel-0bc9.md`).**
`test-ardd-update-check.sh` runs `install.sh` directly against
`$REPO_ROOT` (this repo's own checkout, `scripts/test-ardd-update-check.sh:229-230`)
and then asserts the resulting `Channel:` is `stable`. `install.sh`'s
channel inference (`install.sh:580-596`) falls back to inspecting
`git tag --points-at HEAD` on the source checkout — a beta tag landing on
the current commit (via `beta-release.yml`, which tags every push to
`main`) flips that inferred channel to `beta`, independent of any actual
bug. The fix isolates the producer-contract assertions (`Source-Commit`,
default `Channel`) from this repo's live tag state: clone `$REPO_ROOT` at
its current `HEAD` SHA into a fresh temp directory with tags excluded (a
`git clone --no-tags` of the local checkout, or an equivalent
`git init` + `git fetch <REPO_ROOT> HEAD` + checkout), and run `install.sh`
from that clone instead of `$REPO_ROOT` directly. With no tags reachable
in the clone, `ALL_REFS_AT_HEAD` is always empty and `SOURCE_REF`/channel
inference deterministically lands on `stable`, regardless of what
`beta-release.yml` has done to the real repo's tags in the meantime.

## Phase Breakdown

Phase lists are plan work-items, not live checklists — progress is tracked
in the linked tasks file.

**Phase 1: Rework badge-sync workflow to survive branch protection**
- Rework `.github/workflows/ardd-badge.yml`'s "Commit if changed" step to
  push its regenerated-JSON commit to a short-lived branch and open a PR
  against `main` via `gh pr create`, instead of pushing to `main` directly.
  [feedback: feedback-branch-protection-badge-exception-a8a9.md F001]

**Phase 2: Isolate the update-check test's live-tag dependency**
- Change `scripts/test-ardd-update-check.sh`'s producer-contract section
  (~line 229 onward) to run `install.sh` against a fresh, untagged clone of
  `$REPO_ROOT` at its current HEAD, rather than against `$REPO_ROOT`
  directly, so the "Channel: stable by default" assertion no longer depends
  on whether `beta-release.yml` has tagged the live checkout's HEAD yet.
  [feedback: feedback-test-ardd-update-check-channel-0bc9.md F001]

## Open Questions

- Does this repo's `main` branch ruleset allow `github-actions[bot]`
  (or the token the workflow runs as) to auto-merge a PR that satisfies
  its own "1 approving review" requirement, or does every badge-sync PR
  need a human approval? If the latter, the workflow should still open the
  PR (better than silently failing) but the badge will lag until someone
  approves it — that's an accepted, non-release-blocking trade-off per the
  original feedback.
- Is a bypass allowance for the workflow's actor on the branch protection
  ruleset (the feedback's other suggested option) preferable to the
  PR-based rework? That's a repo-settings change outside this plan's
  code scope — worth a follow-up decision by whoever owns the ruleset,
  independent of implementing the PR-based fallback here.
