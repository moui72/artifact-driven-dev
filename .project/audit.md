# Audit
_Updated: 2026-07-14_

## constitution

- [x] **[S]** resolved: extracted, constitution v1.8.1 (2026-07-14) — The
  `new.sh` `/dev/tty` interactivity narrative moved to
  `docs/decisions/0008-new-sh-tty-interactivity.md`; Project Scope &
  Intent now carries only the two bounding rules plus a pointer.
  CLAUDE.md's copy was left as-is (out of scope for this refine; it's the
  shorter of the two and wasn't the growth vector) — still a candidate
  for a future pass if it drifts further.

- [ ] **[S]** The two-channel release-publishing paragraph (lines 101-134)
  has the same shape as the `new.sh` finding above: a full behavioral
  narrative (workflow names, tag formats, `versionsort.suffix` trap,
  channel resolution rules) sitting in the constitution even though
  `docs/decisions/0007-two-channel-git-ops.md` already exists to carry
  exactly this story, and CLAUDE.md restates most of it a third time.
  Unlike the `new.sh` case this one is at least freshly written
  (2026-07-12) rather than accreted over multiple reversions, but it's
  the same disease at an earlier stage — worth trimming to the standing
  rule plus a pointer before a v1.9.0 edit has three copies to keep in
  sync instead of two.
  > `/ardd-refine constitution trim the two-channel release-publishing paragraph (lines ~101-134) in Project Scope & Intent down to the standing rule (beta-on-push, stable-by-dispatch, channel selection) plus a pointer to docs/decisions/0007-two-channel-git-ops.md for the workflow/tag/versionsort mechanics`

- [x] **[S]** resolved: added, constitution v1.8.2 (2026-07-14) — Governance
  now carries an explicit Exception paragraph after the numbered amendment
  requirements: `workflow_mode` and `next_step_prompt` are per-project
  operational settings stamped via `ardd-state.sh`, not amendments to this
  constitution, and don't require a SIR or version bump.

- [ ] **[R]** The smoke-test tier's secret-gated non-execution was
  reaffirmed as a deliberate standing state in the v1.8.0-era smoke.yml
  comment (2026-07-12) rather than left implicit — that's an improvement
  over the prior audit's framing, since it's no longer silently
  decorative. The underlying risk is unchanged, though: the behavioral
  tier has never actually executed, so no smoke scenario has ever been
  proven to catch a real regression, and "skip fast, continue-on-error"
  means a broken scenario file would itself go unnoticed indefinitely.
  Worth revisiting if a skill-behavior regression ever ships that a live
  smoke run would have caught.

## Summary
1 open suggestion (2 resolved) · 0 questions · 1 risk across 1 artifact.

Resolved since last audit: the primary-stays-on-main deterministic-guard
suggestion (2026-07-11 audit) is moot — the underlying standing decision
was itself retired in v1.8.0 (2026-07-12; see Project Scope & Intent and
`docs/decisions/0006-release-channel.md`), so there is no longer an
invariant to guard. The register-status-for-removed-features question was
already resolved (v1.6.0, `retired` enum value added) and stays closed.
