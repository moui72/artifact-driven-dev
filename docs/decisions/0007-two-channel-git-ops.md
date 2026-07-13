# 0007 — Two-channel git-ops: beta on push, stable by dispatch

_2026-07-12. Source-repo history only — never installed into targets.
Companion to the constitution's two-channel standing decision (v1.8.0);
design vetted in
`.project/plans/research-two-channel-git-ops-2026-07-12-450d.md`,
executed under `plan-git-ops-channels-2026-07-12-e77e.md`._

## The arc

**v1.5.0 — the deliberate act.** The release channel (decision record
0006) made tagged GitHub releases the stable install channel and
`release.sh` — a local, validated, SSH-signed tag-and-publish script —
the one way to cut one. "Cutting a release is the deliberate act that
publishes skill changes; merging to `main` alone no longer does." The
pre-release ratchets pass explicitly scoped out a tip-of-main channel
(Principle VI: add one only if real evidence demands it).

**v0.9.0 — the friction, same day.** Hours after the first release
shipped, the evidence arrived: consumers had no way to track fresh work
without the maintainer hand-cutting a release from the one machine that
carried the validations and the signing key — and that machine dependency
had already chafed on release day one (the user often works from a phone,
where 1Password can't unlock and local scripts can't run).

**v1.8.0 — two channels.** `feedback-git-ops-channels-9f03.md` proposed,
and the research doc vetted, the ecosystem-standard split:

- **Pushing `main` is the beta-publish act.**
  `.github/workflows/beta-release.yml` waits for the lint/test workflow
  to pass for the same SHA, computes the next `vX.Y.Z-beta.N` via
  `scripts/next-version.sh beta`, and publishes a GitHub *prerelease*.
  Path-filtered: a push touching nothing but `.project/**`, `docs/**`,
  and top-level `*.md` doesn't publish; `skills/**`, `templates/**`,
  scripts, `install.sh`, `new.sh` always do — a skill's `.md` IS the
  product.
- **Stable stays deliberate, relocated from a machine to a button.**
  `.github/workflows/stable-release.yml` (`workflow_dispatch`, bump
  input) verifies CI green on the `main` tip, fast-forward-merges `main`
  into the **`release` branch** — refusing on divergence, never forcing —
  and publishes a full release. The `release` branch is both the stable
  pointer and the stable raw-URL base for `new.sh` acquisition
  (`…/release/new.sh`; `main` serves the beta/dev edge).
- **Consumers record a channel.** `install.sh` writes
  `Channel: stable|beta` to `ardd-version.md` (absent = stable, so every
  pre-channel file keeps parsing); `source-resolve.sh --channel` and
  `ardd-update-check.sh` resolve/compare within it; `new.sh --beta` opts
  a new project in. Dev-mode (`--source`/`$ARDD_SOURCE`) is unchanged and
  maintainer-only.

## Decisions inside the design

- **Tag format `vX.Y.Z-beta.N`** (semver-canonical, dotted) — pinned
  together with the sort suffix, because the two must agree.
- **The ordering trap, empirically pinned.** git's default
  `--sort=v:refname` orders `v0.9.1-beta.2` *after* `v0.9.1`, so any
  naive "latest tag" pick prefers a stale beta over a newer stable. Every
  beta-aware sort site runs under `versionsort.suffix=-beta.`, and the
  fixture tests (`test-next-version.sh`, `test-source-resolve.sh`,
  `test-ardd-update-check.sh`, `test-new.sh`) each pin the trap — a newer
  stable must beat an older beta.
- **API-created tags, not CI signing keys.** `gh release create --target`
  makes GitHub create the tag server-side, attributed and shown Verified
  via the web-flow key. No secret key material in CI; local tag-signing
  died with `release.sh`.
- **One version authority.** All next-version computation lives in
  `scripts/next-version.sh` (source-side, fixture-tested, NOT installed);
  the workflows are thin YAML around it, because YAML can't be
  fixture-tested and the script can.
- **`release.sh` retired** (Principle VII, confirmed at the T003
  checkpoint): its validation became the CI gate, its tag/publish became
  the workflows. `test-release.sh` retired with it.

## Reversals, on the record

Three recorded decisions were knowingly reversed (constitution v1.8.0 SIR
names them): the v1.5.0 "merging to `main` alone no longer publishes"
(now: pushing `main` publishes *beta*; stable stays deliberate), the
ratchets-pass "no tip-of-main channel" (the beta channel is that channel,
formalized — the demanded evidence arrived within hours), and
`release.sh` as the publish path (moved to CI). The v1.5.0 *spirit* —
stable publishing is a deliberate act — survives intact as the dispatch
click.

## What deliberately did not happen

- No formalized tip channel: dev-mode `--source` covers the audience of
  one (research Rejected Alternatives).
- No beta retention/pruning policy: keep all beta tags until evidence
  demands otherwise.
- No consumer migrations: all existing consumers stay `stable` by
  default; beta is a per-repo opt-in later.
- Branch protection on `release` is a GitHub-settings act for the user,
  noted at close-out, not automated.
