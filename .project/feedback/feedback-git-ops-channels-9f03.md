---
status: open      # open -> planned
created: 2026-07-12
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

_User-directed git-ops strategy change (2026-07-12, hours after v0.9.0
shipped). All three items are facets of one strategy: a two-channel
release model with CI-published betas. They reverse parts of the
release-channel standing decision (v1.5.0) and the no-third-channel
decision (pre-release-ratchets plan, "Out") — substantial and
decision-reversing, so per the routing convention this should be vetted
with `/ardd-research` before `/ardd-plan` consumes it._

## Reconsidered

- [ ] F001 Push to `main` publishes a **beta** prerelease automatically
  (e.g. `0.9.1-beta1`) via a GitHub workflow on push. This reverses the
  v1.5.0 decision's "merging to `main` alone no longer publishes" — under
  the new model, pushing main IS the beta-publish act; only *stable* stays
  deliberate. Versioning mechanics (auto-increment betaN per push? semver
  prerelease format `-beta.N`?) are plan-time decisions.
  [artifacts: constitution]

- [ ] F002 Stable releases move from the local `release.sh` run to an
  **explicitly invoked GitHub workflow** (workflow_dispatch) that
  fast-forward-merges `main` into a `release` branch and publishes the
  stable tag (e.g. `0.9.2`). The `release` branch becomes the stable
  pointer; ff-only preserves the no-new-commit discipline. Implications to
  design at plan time: what remains of `release.sh` (validation may move
  to CI; the deliberate-act principle survives as the dispatch click), tag
  signing in CI (the on-disk SSH key is local-only — CI needs its own
  signing story or unsigned-in-CI policy), and branch protection on
  `release`. [artifacts: constitution]

- [ ] F003 `/ardd-update` and the install/resolve scripts gain **channel
  targeting**: `stable` (default — latest non-prerelease tag, today's
  behavior), `beta` (latest prerelease from main's auto-publishes), or
  local tip (dev-mode `--source`, existing, explicitly documented as
  maintainer-only). Reverses the ratchets plan's "no tip-of-main channel"
  Out-decision in its beta form — the evidence Principle VI asked for is
  this request. Touches: `source-resolve.sh` (its strict `vX.Y.Z` filter
  deliberately excludes prerelease tags today — beta resolution must relax
  it per-channel, keeping stable strict), `ardd-update-check.sh`
  (behind-ness is per-channel), `new.sh` (channel flag?), `ardd-version.md`
  (record the channel), constitution's release-channel decision text, and
  the pack-semver policy (prerelease semantics). [artifacts: constitution]
