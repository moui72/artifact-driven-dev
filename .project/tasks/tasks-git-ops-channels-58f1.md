---
plan: plan-git-ops-channels-2026-07-12-e77e.md
generated: 2026-07-12
status: completed
---

# Tasks

_Design input: `research-two-channel-git-ops-2026-07-12-450d.md` (adopted:
`-beta.N` tags, GitHub-API-created tags, suite-gated betas, one
version-compute script). Plan Open Questions 1–2 carry proposals to
confirm with the user at T003._

## Phase 1: Constitution amendment

- [x] T001 [artifacts: constitution] Amend the constitution (v1.7.0 →
  v1.8.0, MINOR, new SIR citing the research doc and naming the three
  reversals): rewrite the release-channel standing decision for two
  channels — push to `main` = the beta-publish act (CI workflow, gated on
  the suite, prerelease tags `vX.Y.Z-beta.N`); the deliberate act for
  stable relocates to a dispatched workflow that ff-merges `main` into the
  `release` branch (the stable pointer AND the stable raw-URL base for
  `new.sh` acquisition) and tags via the GitHub API (web-flow Verified —
  no CI signing keys); consumer channels are `stable` (default) / `beta`
  (opt-in) / dev-mode `--source` (maintainer-only, unchanged). Extend the
  pack-semver policy with prerelease semantics (betas make no
  compatibility promises). `last_updated` stamped; lint clean.

## Phase 2: Version authority (test-first)

- [x] T002 Create `scripts/next-version.sh` (POSIX sh, source-side — NOT
  shipped by install.sh): reads the repo's tags; `next-version.sh beta`
  prints the next beta for the upcoming patch version (`v0.9.1-beta.1`,
  then `-beta.2`, …; after a stable `v0.9.1` exists, betas target
  `v0.9.2`); `next-version.sh stable [major|minor|patch]` (default patch)
  prints the next stable tag. All ordering under
  `-c versionsort.suffix=-beta.` — the fixture tests MUST pin the ordering
  trap (`v0.9.1-beta.2` sorts before `v0.9.1`) and mixed-tag scenarios
  (no tags; only stable; only betas; beta-after-stable rollover;
  non-semver tags ignored). Test-first (`scripts/test-next-version.sh`,
  red confirmed), CI job same commit.

## Phase 3: Workflows

- [x] T003 Create `.github/workflows/beta-release.yml` (on push to `main`:
  path-filter per plan Open Question 2 — proposed: skip pushes touching
  only `.project/**` and top-level `*.md`/`docs/**`, NEVER skipping
  `skills/**` or `templates/**`; require the lint/test workflow green for
  the same SHA — `workflow_run` on lint.yml success or an equivalent gate;
  compute the tag via `next-version.sh beta`; `gh release create <tag>
  --prerelease --generate-notes --target <sha>`) and
  `.github/workflows/stable-release.yml` (`workflow_dispatch` with a
  `bump` choice input major/minor/patch default patch: verify CI green on
  `main` tip, ff-merge `main` into `release` — create the branch on first
  run, refuse and fail on non-ff — compute via `next-version.sh stable
  <bump>`, `gh release create` full release targeting the `release` tip).
  Static validation (YAML parse; `actionlint` if available, else careful
  review). CONFIRM WITH USER before finalizing: plan Open Question 1 —
  retire `release.sh`+`test-release.sh` (proposed, Principle VII) or keep
  as offline fallback; and Open Question 2's exact skip globs. On
  retirement: delete both in this task and update every reference
  (CLAUDE.md commands block, decision records stay historical).

## Phase 4: Channel plumbing (test-first)

- [x] T004 `scripts/source-resolve.sh` gains `--channel stable|beta`
  (default stable): stable keeps the strict `^v[0-9]+\.[0-9]+\.[0-9]+$`
  filter; beta selects the latest tag among stable+prerelease under
  `versionsort.suffix=-beta.` (a newer stable beats an older beta — the
  pinned trap). `scripts/ardd-update-check.sh` compares within the
  recorded channel; `install.sh` writes `Channel: <stable|beta>` to
  `ardd-version.md` (absent = stable — old files keep parsing, pinned by
  a compatibility test case). All key=value outputs stay additive.
  Test-first across all three scripts' regression suites.

- [x] T005 [artifacts: constitution] Skill + acquisition plumbing:
  `skills/ardd-update/SKILL.md` reads and reports the recorded channel,
  resolves via `source-resolve.sh --channel <recorded>`, and offers a
  channel switch only when the user raises it (no new routine prompt);
  `new.sh` gains `--beta` (default stable; sets the channel install
  records), and its documented curl base for stable acquisition moves to
  the `release` branch (`raw.githubusercontent.com/.../release/new.sh`)
  with `main` documented as the beta/dev base — hermetic `test-new.sh`
  cases extended test-first, tty discipline and timeout guards preserved.

## Phase 5: Docs + cutover

- [x] T006 [parallel] README/USAGE channel documentation (update guidance,
  curl bases, what beta means), CLAUDE.md commands block
  (`next-version.sh`, workflows, release.sh removal if confirmed);
  `docs/decisions/0007-two-channel-git-ops.md` recording the reversal arc
  (v1.5.0 deliberate-act → v0.9.0 friction → two channels; cite the
  research doc); full suite + lint green. Close-out report lists the
  user's cutover acts: push `main` (first live beta publishes — the
  acceptance test), dispatch the first stable when ready, optionally
  protect `release` in GitHub settings.
