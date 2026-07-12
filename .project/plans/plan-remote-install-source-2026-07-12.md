---
status: approved
branch: remote-install-source
created: 2026-07-12
features: [remote-install-source]
---

# Plan: remote install source via GitHub releases

## Goal

Consumers install and update ARDD from tagged GitHub releases resolved
through `~/.ardd/source` — never from the tip of a live local checkout —
with live-checkout installs demoted to explicit, warned dev-mode, ending in
the retirement of the primary-stays-on-main mandate.

## Scope

**In:**
- Release-cutting mechanics (source-side): `scripts/release.sh` — validate
  (clean tree, on default branch, full test suite green), create an
  annotated semver tag, push it, `gh release create`. Fixture-based test for
  its refusal logic.
- Release resolution (target-side): a new `scripts/source-resolve.sh`
  installed to `ardd-scripts` — reads the recorded `Source-Path`; for the
  owned `~/.ardd/source` checkout it fetches tags (offline-tolerant: on
  network failure, warn and use existing state), computes the latest semver
  tag with a portable comparison, checks it out, and prints
  `resolved=<path> ref=<tag> channel=release`; for any other path it prints
  `channel=dev` so callers warn. Refuse-never-resolve discipline throughout.
- `scripts/ardd-update-check.sh`: compare the installed commit against the
  latest release tag (not source tip); `behind` means "not the latest
  release." `self-hosted` outcome unchanged.
- `install.sh`: record the release tag (when installing from one) in
  `.project/ardd-version.md` alongside the commit.
- `new.sh`: pin the latest release tag when cloning/refreshing
  `~/.ardd/source` (answers the quickstart plan's open question);
  `--source`/`$ARDD_SOURCE` stays dev-mode. `test-new.sh` stays hermetic —
  fixture source repos grow local tags.
- `/ardd-update` SKILL.md: resolve via `source-resolve.sh`; on
  `channel=dev`, surface the dev-mode warning and ask before proceeding.
- First release cut (proposed `v1.0.0`) + repoint sweep of the five
  consumers (atelier, yet-another-rank-games ×2, assisted-review,
  sync-tab-scroll) to the release channel.
- Terminal artifact-revision task: retire the primary-stays-on-main
  standing decision (constitution amendment + CLAUDE.md note removal +
  decision record), once no consumer reads the dev checkout live.
- Docs: README/USAGE acquisition sections, CLAUDE.md architecture notes.

**Out:**
- No tip-of-main channel (decided at design time — Principle VI; release or
  dev-mode only).
- No CI-automated release publishing — `release.sh` is run by a human
  deliberately; automation can come later with evidence.
- No changes to skill *content* delivery — `install.sh` remains the only
  entry point (constitution v1.5.0 reaffirms it).

## Technical Approach

The constitution amendment (v1.5.0, applied in this run's design step)
carries the decision; this plan builds its mechanics. The resolution layer
is a deterministic script per Principle II — judgment stays in `/ardd-update`
prose (whether to accept a dev-mode source), while tag fetching, semver
comparison, and checkout are scripted and regression-tested against local
fixture remotes (no network in tests). `~/.ardd/source` may sit detached at
a tag between updates — it's the tooling-owned checkout, so that's fine and
expected. Semver comparison needs a small portable implementation because
BSD `sort` lacks `-V` (Complexity Tracking). `gh` is required only
source-side (release cutting); consumers need only `git`.

Ordering: build and test everything against fixtures first, cut the real
first release only when the resolution path is proven, then repoint
consumers, and only then retire the mandate — it stays binding for the
whole implementation window (this plan's own work uses the current rules).

## Phase Breakdown

### Phase 1 — Release mechanics (source-side, test-first)
1. `scripts/release.sh <version>` with validation-refusal tests
   (`scripts/test-release.sh`: dirty tree, not-on-default, bad version
   format, tag-already-exists; the tag/push/gh steps are thin and gated
   behind the validations). CI job added same commit.

### Phase 2 — Resolution + update-check (target-side, test-first)
2. `scripts/source-resolve.sh` + `scripts/test-source-resolve.sh` (fixture
   remotes in temp dirs: latest-tag selection incl. 2-digit components,
   offline fallback warns, dev-path → `channel=dev`, detached-at-tag
   re-resolve). Installed via `install.sh` to `ardd-scripts`; CI job same
   commit.
3. `ardd-update-check.sh` compares against latest release tag; update its
   regression tests (behind-release, at-release, no-tags-yet fallback to
   tip comparison with a note, self-hosted unchanged).
4. `install.sh` records `Source-Ref: <tag>` in `ardd-version.md` when the
   source checkout is at a tag; test via existing install fixtures.

### Phase 3 — Acquisition routes
5. `new.sh`: clone/refresh `~/.ardd/source` then checkout latest release
   tag (offline-tolerant); extend hermetic `test-new.sh` cases (fixture
   tags; no-tags source falls back to default branch with a note).
6. `/ardd-update` SKILL.md: resolve via `source-resolve.sh`; `channel=dev`
   → explicit warning + user confirmation; report the resolved tag.

### Phase 4 — Docs
7. README/USAGE acquisition sections + CLAUDE.md (architecture notes,
   commands block) describe the release channel and dev-mode; `lint-docs.sh`
   green.

### Phase 5 — First release + consumer repoint
8. Cut the first release with `scripts/release.sh` (version per Open
   Question 1) after a full suite pass.
9. Repoint sweep: for each of the five consumers, run the updated flow so
   `Source-Path` records `~/.ardd/source` (release channel) and
   `ardd-version.md` records the tag; commit each consumer's record
   (signed, no push). Any consumer the user wants left dev-pointed is
   skipped explicitly (Open Question 3).

### Phase 6 — Retire the mandate
10. [artifacts: constitution] Amend the constitution to retire the
    primary-stays-on-main standing decision (magnitude per Open Question
    2), remove CLAUDE.md's "primary checkout stays on main" section, and
    write `docs/decisions/0006-release-channel.md` recording the arc
    (mandate → root-cause fix → retirement). Only executable once Phase 5
    is verified complete.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| Hand-rolled semver comparison in POSIX sh | Principle VIII checked: `sort -V` is GNU-only (absent on macOS/BSD), `git tag --sort=v:refname` exists but ordering across annotated/lightweight tags and pre-release suffixes needs pinning either way; a ~10-line compare with fixture tests is the smallest portable option. Prefer `git tag --sort=v:refname` if its behavior proves sufficient in tests — the custom compare is the fallback, not the default. |
| New `source-resolve.sh` script | The resolution decision tree (owned vs dev path, offline fallback, tag selection) is a pure function of disk/remote state — Principle II says script it; burying it in two skills' prose would duplicate and drift. |

## Open Questions

1. **First release version.** Proposed `v1.0.0` (the pack is in real use
   across five consumers). Alternative: `v0.x` to signal instability.
   Decide at Phase 5, task 8.
2. **Retirement amendment magnitude.** Removing a standing decision:
   MAJOR (reads as "principle removal") or MINOR (scope-decision cleanup)?
   Decide at Phase 6 with the user.
3. **Do any consumers stay dev-pointed?** Default: all five move to the
   release channel; the dev escape remains available ad hoc. Confirm at
   Phase 5, task 9.
4. **Signed tags?** Annotated tags proposed; signing with the on-disk key
   is cheap — decide in task 1.
