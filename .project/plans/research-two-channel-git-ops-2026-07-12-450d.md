---
topic: two-channel git-ops (beta on push, dispatched stable, channel targeting)
date: 2026-07-12
status: complete
---

# Research: two-channel git-ops proposal

## Question

Should ARDD move to: (1) push-to-`main` auto-publishing beta prereleases
via CI, (2) stable releases cut by an explicitly dispatched GitHub workflow
that ff-merges `main` into a `release` branch and tags, and (3)
stable/beta/dev-tip channel targeting in `/ardd-update`, `source-resolve.sh`
and `new.sh`? (Proposal from `feedback-git-ops-channels-9f03.md`, hours
after `v0.9.0` shipped under the one-channel model.)

## Findings

**Goals it serves.** (a) Consumers can track fresh work (beta) without the
maintainer cutting anything by hand — today they wait for a deliberate
`release.sh` run from one machine. (b) Stable publishing stops depending on
a configured local machine (validations + signing keys) — the dispatch
click works from anywhere, including a phone. (c) A `release` branch gives
stable a *browsable ref and raw-URL base*: today's `curl …/main/new.sh`
bootstrap serves whatever `main` holds — under beta-on-push that's
explicitly the beta channel, so stable acquisition needs
`…/release/new.sh`, which only exists if the branch does. This is an
underappreciated argument *for* the release branch: it's not just a tag
pointer, it's the stable content URL.

**Lens results** (audit lens list applied by reference):
- *Standardness:* strongly pro. Two-channel (stable + prerelease) is the
  ecosystem norm (npm dist-tags, Rust stable/nightly, Homebrew); the
  current bespoke "local script or nothing" is the odd one out.
- *Simplicity/proportionality:* the real costs are two workflows, one
  branch, and a channel parameter threaded through three scripts + two
  skills + `ardd-version.md`. Moderate, not trivial — but each piece is
  small and the alternative (maintainer-machine-only publishing) already
  showed friction on day one.
- *Failure modes:* (1) **Prerelease ordering** — verified empirically:
  default `git tag --sort=v:refname` orders `v0.9.1-beta2` AFTER
  `v0.9.1`, so a naive beta resolver would pick a stale beta over a newer
  stable; fix is `versionsort.suffix=-beta` (or `-beta.`) at every sort
  site, pinned by fixture tests. Stable resolution is already immune
  (`source-resolve.sh:92`'s strict `^v[0-9]+\.[0-9]+\.[0-9]+$` filter).
  (2) **Publishing a broken beta** — the beta workflow must require the
  full lint/test workflow green for that commit (workflow dependency or
  same-job gating), or every red push ships to beta consumers. (3) **Tag
  noise** — a beta tag per push to main; acceptable for machines, slightly
  noisy for humans; optionally skip when only `.project/`/docs changed.
  (4) **CI signing** — the on-disk SSH signing key is local-only. Options:
  store a dedicated CI signing key as a secret, or let the workflow create
  tags via the GitHub API (`gh release create` on a commit-ish creates the
  tag server-side, attributed and shown Verified via GitHub's web-flow
  key). The API route avoids key management entirely; local `release.sh`
  signing then becomes dev-only or retires.
- *DRYness:* version computation (next beta N, next stable) must live in
  ONE script that both workflows and any local path call — not duplicated
  YAML logic.
- *Semantics:* `0.9.1-beta1` vs semver-canonical `0.9.1-beta.1` — pick at
  plan time and pin in the tag-format regex + sort suffix together.
  "release" as the branch name is clear; "stable" would be equally fine.
- *Robustness:* ff-only merge to `release` preserves single-history (no
  divergence possible if nothing else ever commits to it — protect the
  branch); dispatch-gated stable keeps the v1.5.0 "deliberate act"
  principle, relocated from a local command to a button.

**Committed decisions it reverses** (all recorded, all recent):
1. Constitution v1.5.0 release-channel decision: "merging to `main` alone
   no longer publishes" → becomes "pushing `main` publishes *beta*; only
   stable stays deliberate." Partial reversal, same spirit for stable.
2. Pre-release-ratchets plan, Out: "no tip-of-main channel (Principle VI —
   add one only if real evidence demands it)" → the beta channel is that
   channel, formalized; the demanding evidence is this request arriving
   hours after v0.9.0.
3. `release.sh` as *the* publish path (T001 of remote-install-source) —
   its validate-then-tag role moves to CI; what remains locally is a
   Principle VII decision (evolve into the shared version-compute script,
   keep as dev fallback, or delete).

**Consumer impact.** Five consumers currently pin stable; nothing breaks —
stable stays the default channel and today's behavior. Beta is opt-in per
consumer (`ardd-version.md` records the channel; `ardd-update-check`
compares within-channel). The pack-semver policy (v1.6.0) needs one
sentence on prerelease semantics.

## Recommendation

**Worth it — proceed to `/ardd-plan feedback-git-ops-channels-9f03.md`
directly.** The design is well-enough understood to plan without a backlog
stop: the feedback file already carries the three facets, and this doc
resolves the main unknowns (ordering fix, CI-signing route, the release
branch's raw-URL role, DRY version-compute). The plan should decide: tag
format (`-beta.N` recommended), the beta-gating mechanism, GitHub-API tags
vs CI key (API recommended), `release.sh`'s fate, and whether `new.sh`
grows a channel flag or infers from which branch URL served it.

## Rejected Alternatives

- **Beta = a moving `beta` tag or branch, no per-push tags:** loses
  history/pinnability; `ardd-version.md`'s Source-Ref would be meaningless
  for betas.
- **Stable via local release.sh forever (status quo):** single-machine
  dependency demonstrated friction on release day one; no consumer-visible
  freshness between releases.
- **Three full channels incl. formalized tip:** tip stays informal
  dev-mode (`--source`), exactly as today — formalizing it adds surface
  for an audience of one.

## Open Questions

- Should the five consumers' default stay stable (assumed yes), and does
  any repo want beta from day one?
- Beta retention: prune old beta tags/releases ever, or keep all?
