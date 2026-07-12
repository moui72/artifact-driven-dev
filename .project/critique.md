# Critique
_Updated: 2026-07-11_

## constitution

- [ ] **[S]** The `new.sh` interactivity spec in Project Scope & Intent has grown
  into a full behavioral narrative — the v1.2.3 and v1.2.4 regression
  histories, the `/dev/tty` safe-default vs `--kickoff` case analysis — while
  the repo already has an established split for exactly this: Principle III
  keeps the rule and `docs/decisions/0002-gitignore-ceiling.md` carries the
  story. The same detail is also duplicated in CLAUDE.md's `new.sh` section,
  so three copies of the tty narrative now exist and will drift. Extract the
  narrative to a decision record and keep only the two bounding rules
  (refuses-rather-than-asks; never-blocks-on-a-question-it-cannot-ask) plus a
  pointer in the constitution.
  > `/ardd-refine constitution move the new.sh /dev/tty behavioral narrative (v1.2.3/v1.2.4 phrasing history, safe-default vs --kickoff case analysis) to a new docs/decisions/ record, keeping only the two bounding interactivity rules and a pointer to the record in Project Scope & Intent`

- [ ] **[S]** The Governance section states amendments require a Sync Impact
  Report and a version bump, but the workflow frontmatter fields
  (`workflow_mode`, `next_step_prompt`) are exempt — that exemption lives only
  in CLAUDE.md. Someone amending via the constitution alone (its stated role:
  "supersedes all other practices") would conclude a `next_step_prompt` flip
  needs a SIR. The governing document should carry its own exemption.
  > `/ardd-refine constitution add a Governance note that workflow frontmatter fields (workflow_mode, next_step_prompt) are stamped via ardd-state.sh and exempt from the SIR/version-bump amendment process`

- [ ] **[S]** The primary-stays-on-main standing decision (new in v1.4.0) is
  prose-only, yet "the primary checkout's HEAD is on `main`" is a pure
  function of git state — exactly what Principle II says gets a deterministic
  script, and unlike single-writer ownership there is no verified dead end
  here. The failure it guards against (consumers installing from an unmerged
  branch; ref-lock collisions) already happened once, silently. A cheap guard
  is available at either end: `install.sh` warning when the source checkout
  is not on its default branch, and/or a source-repo pre-commit/lint check.
  > `/ardd-feature deterministic guard for the primary-stays-on-main invariant: install.sh warns when the resolved source checkout is not on its default branch, plus a source-side check runnable from hooks/pre-commit`

- [ ] **[R]** The Quality Standards smoke-test tier is satisfied in letter but
  not in practice: `smoke.yml` exists but is secret-gated on an API key that
  has never been provisioned, so the behavioral tier has never actually run.
  The standard says conditional runs are acceptable "but must exist" —
  a permanently-skipped job meets that wording while providing zero coverage,
  which is precisely the decorative-principle failure the Proportionality
  lens asks about. Either provision the key or tighten the standard's wording
  so a never-run job doesn't count as compliance.

- [ ] **[Q]** The feature-register status enum
  (`backlogged|planned|tasked|implemented`, a standing decision in this
  constitution) has no terminal state for a feature that shipped and was
  later removed. `npx-skills-install` still reads `status: implemented`
  although the channel was deliberately removed on 2026-07-11 — the register
  now asserts something false about the system, and `/ardd-sync` would mirror
  that claim to a tracker. Options trade off differently: add a `removed`
  (or `retired`) enum value (requires amending the standing decision here
  and updating `lint-project.sh` in the same commit); delete the feature file
  (loses the historical record the per-file design was meant to keep); or
  leave `implemented` with a body note (keeps the enum small but makes
  status unreliable as a statement of present truth). Which does the
  register's status field mean — "reached implementation once" or "true of
  the system now"?

## Summary
3 suggestions · 1 question · 1 risk across 1 artifact (plus the feature register).
