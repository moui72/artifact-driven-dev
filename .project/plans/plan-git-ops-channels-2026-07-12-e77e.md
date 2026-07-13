---
status: approved
branch: git-ops-channels
created: 2026-07-12
---

# Plan: two-channel git-ops (beta on push, dispatched stable)

_Consumes `feedback-git-ops-channels-9f03.md` (F001–F003, all accepted;
overrides user-directed). Design input:
`research-two-channel-git-ops-2026-07-12-450d.md` — its recommendations are
adopted here: semver-canonical `-beta.N` tag format, GitHub-API-created
tags (web-flow Verified, no CI key management), beta publish gated on the
test workflow, one shared version-compute script (DRY)._

## Goal

Pushing `main` publishes a beta prerelease automatically; stable releases
are cut by an explicitly dispatched workflow that fast-forwards `main` into
a `release` branch and tags; consumers target `stable` (default) or `beta`,
with local-tip dev-mode unchanged and maintainer-only.

## Scope

**In:**
- **Constitution amendment (v1.8.0, MINOR)** [F001+F002+F003]: the
  release-channel standing decision is rewritten for two channels — push to
  `main` = the beta-publish act (CI, gated on the suite); the deliberate
  act for *stable* relocates from a local command to a dispatched workflow
  (ff-merge `main`→`release`, tag via the GitHub API); the `release` branch
  is the stable pointer AND the stable raw-URL base for `new.sh`
  acquisition; channels are `stable` (default) / `beta` (opt-in) /
  dev-mode `--source` (maintainer-only, unchanged); pack-semver policy
  gains prerelease semantics (`vX.Y.Z-beta.N`; betas make no
  compatibility promises).
- **`scripts/next-version.sh`** — the single version-compute authority:
  given the tag list and a mode (`beta` | `stable [major|minor|patch]`),
  prints the next tag (`v0.9.1-beta.1`, `v0.9.1-beta.2`, `v0.9.1`);
  prerelease-aware ordering via `versionsort.suffix=-beta.`; fully
  fixture-tested including the empirically-pinned ordering trap
  (`v0.9.1-beta.2` must sort BEFORE `v0.9.1`).
- **`.github/workflows/beta-release.yml`** — on push to `main`
  (path-filtered to skip `.project/`-only and docs-only pushes): requires
  the lint/test workflow green for the same SHA, computes the next beta
  tag via `next-version.sh`, publishes a **prerelease** via
  `gh release create` (API-created tag → GitHub web-flow Verified).
- **`.github/workflows/stable-release.yml`** — `workflow_dispatch` (bump
  input: patch/minor/major, default patch): verifies CI green on `main`
  tip, fast-forward-merges `main` into `release` (creating the branch on
  first run; refuse non-ff), computes the stable tag, publishes a full
  release. The dispatch click is the deliberate act (v1.5.0 spirit kept).
- **Channel plumbing**: `source-resolve.sh` gains `--channel stable|beta`
  (stable = today's strict filter; beta = latest tag overall under
  prerelease-aware ordering); `ardd-update-check.sh` compares within the
  recorded channel; `install.sh` records `Channel:` in `ardd-version.md`
  (absent = stable — additive, old files fine); `/ardd-update` reads the
  recorded channel, reports it, and offers a switch only when the user
  asks; `new.sh` gains `--beta` (default stable) and its documented curl
  base moves to the `release` branch for stable acquisition.
- **`release.sh` retires** (Principle VII, proposed — see Open Questions):
  its validation now lives in CI gating, its tag/publish in the workflows;
  `test-release.sh` retires with it or shrinks to cover `next-version.sh`.
- Docs: README/USAGE (channels, new curl base), CLAUDE.md commands block,
  `docs/decisions/0007-two-channel-git-ops.md` (the reversal arc, with the
  research doc referenced).

**Out:**
- Formalizing a tip channel (dev-mode `--source` unchanged, audience of
  one — research Rejected Alternatives).
- Beta-tag retention/pruning policy (revisit with evidence; keep all for
  now).
- Consumer channel migrations — all five stay `stable` by default; any
  beta opt-in is a per-repo choice later.
- Branch-protection settings on `release` (GitHub UI, user's act — noted
  in the close-out report, not a task).

## Technical Approach

The constitution amendment leads (the artifact is the source of truth the
workflows implement). All version logic lives in `next-version.sh` — the
workflows are thin YAML around it, because YAML can't be fixture-tested and
the script can (Principle II). Workflows aren't executable locally: their
bar is static validity (YAML parse, `gh workflow` lint if available) plus
fully-tested inputs/outputs of the scripts they call; the first live beta
publish is the acceptance test, verified at close-out. API-created tags
sidestep CI signing entirely (research finding: web-flow key → Verified).
Channel plumbing is additive to every interface it touches: new
`--channel`/`Channel:`/`--beta` inputs, no changed meanings — pre-1.0
installs keep parsing (the ratchets pass's dual-format discipline).

## Phase Breakdown

### Phase 1 — Constitution amendment
1. [artifacts: constitution] v1.7.0 → v1.8.0 amendment per Scope; SIR
   records the three reversals and cites the research doc.

### Phase 2 — Version authority (test-first)
2. `scripts/next-version.sh` + `scripts/test-next-version.sh` (red first;
   ordering-trap case mandatory) + CI job; `install.sh` does NOT ship it
   (source-side: only workflows and maintainers call it).

### Phase 3 — Workflows
3. `beta-release.yml` (push-gated, suite-green-required, path-filtered) +
   `stable-release.yml` (dispatch, ff-only to `release`, bump input);
   static validation; `release.sh`/`test-release.sh` retirement per the
   resolved Open Question.

### Phase 4 — Channel plumbing (test-first)
4. `source-resolve.sh --channel` + ordering fixtures; `ardd-update-check.sh`
   within-channel comparison; `install.sh` `Channel:` recording; tests for
   old-file/absent-channel compatibility.
5. `/ardd-update` SKILL.md channel handling; `new.sh --beta` + stable curl
   base → `release` branch (hermetic `test-new.sh` cases, tty discipline
   preserved).

### Phase 5 — Docs + cutover
6. README/USAGE/CLAUDE.md; decision record 0007; close-out checklist for
   the user: push `main` (first live beta publishes), dispatch the first
   stable when ready, optionally protect `release` in GitHub settings.

## Complexity Tracking

| Deviation | Justification |
|---|---|
| Two GitHub workflows (untestable-locally YAML) | All logic they carry lives in the fully-tested `next-version.sh`; the YAML is thin glue. The alternative (local-only publishing) is the single-machine dependency this plan exists to remove. |
| A third recorded field in ardd-version.md (`Channel:`) | Absent = stable keeps every existing file valid; without it, update-check can't compare within-channel and beta consumers would see stable as "behind." |

## Open Questions

1. **`release.sh` fate** — proposed: retire it (Principle VII; validation
   → CI gate, publish → workflows). Alternative: keep as an offline
   maintainer fallback. Confirm at Phase 3.
2. **Docs-only skip predicate** for beta publishes — proposed path filter:
   skip when a push touches only `.project/**` and `*.md` outside
   `skills/`/`templates/`. Confirm exact globs at Phase 3 (a skill's .md IS
   the product — must NOT be skipped).
