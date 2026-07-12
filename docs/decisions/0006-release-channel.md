# 0006 — The release channel, and the retirement of primary-stays-on-main

_2026-07-12. Source-repo history only — never installed into targets.
Companion to the constitution's release-channel standing decision (v1.5.0)
and the retirement amendment (v1.7.0)._

## The arc

**The hazard.** Until 2026-07-12, a consumer's `install.sh`/`/ardd-update`
read this repository's live checkout (via a recorded `Source-Path` or
`~/.ardd/source`) and installed from whatever branch happened to be checked
out. Merging to `main` wasn't the release act — *being checked out* was.
A feature branch in the primary directory silently served unmerged,
possibly-broken skills to every consumer that updated while it was out, and
a consumer's update flow could re-checkout `main` underneath in-flight work
(a real ref-lock collision hit exactly this on 2026-07-11).

**The mandate (v1.4.0).** The first response treated the symptom: the
primary/default worktree never leaves `main`; all feature work happens in
separate worktrees. This worked — the skill-surface cleanup and the
release-channel implementation itself were both built under it — but it was
a standing tax on the repo's ergonomics that ordinary projects don't pay,
and it protected consumers only from *branches*, not from broken states of
`main` itself.

**The root-cause fix (v1.5.0 → v0.9.0).** GitHub releases became the stable
install channel: `/ardd-update` and `new.sh` resolve the source by fetching
`~/.ardd/source` and checking out the **latest release tag**
(`source-resolve.sh`); installing from a live checkout became explicit,
warned dev-mode. Cutting a release (`release.sh` — validated, signed tag,
`gh release`) is now the deliberate act that publishes skill changes;
merging to `main` alone no longer does. The pre-release "ratchet" pass
(v1.6.0) hardened the interfaces the first release would freeze:
structured `Source-Commit` in `ardd-version.md`, the pack semver policy,
append-only migrations, the register's `retired` state.

**The retirement (v1.7.0).** With `v0.9.0` published and all five known
consumers repointed (`Source-Path: ~/.ardd/source`, `Source-Ref: v0.9.0`,
`ardd-update-check` at-release everywhere), no consumer reads this checkout
live. The mandate's rationale evaporated, so the mandate was deleted —
Principle VII (no dead architecture) applies to governance text as much as
code. The primary worktree may hold a feature branch like any ordinary
project.

## Standing morals

- Prefer removing a hazard to legislating around it: the mandate cost
  every session a worktree dance; the release channel cost one plan and
  removed the hazard for every consumer forever.
- A retired rule is deleted with a pointer, not kept "for context" — this
  record is the context.
- The rollback ref for the surface freeze that rode this arc is the signed
  tag `pre-surface-cleanup`; the first published release is `v0.9.0`
  (chosen over v1.0.0 to signal one more stabilization cycle — the surface
  freeze semantics attach to the *first tag consumers pin*, whatever its
  number).
