---
status: open      # open -> planned
created: 2026-07-19
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

Source: prerelease sweep run 2026-07-19-d06a (S3/S5/S6/S8; triage in
`dev-notes/prerelease-runs/2026-07-19-d06a/TRIAGE.md`). 4 accepted
findings of 7; the sweep passed overall and none of these block a
stable cut — F001 in fact argues for cutting v1.0.1 promptly.

## Bugs

- [ ] F001 (S3-F003) `/ardd-update --stable` on a real consumer today
  records `Channel: stable` with a stale beta `Source-Ref:` (e.g.
  `v0.10.3-beta.4`) and `lint-project.sh`'s
  channel-source-ref-consistency check fires on tooling-produced
  state. Root cause: the v1.0.0 release commit carries both a stable
  and a beta tag, and v1.0.0's own `install.sh` predates the
  dual-tag fix `c7cb703` (which exists only on beta). Self-heals the
  moment the next stable release ships (the fixed install.sh then
  rides the stable tag) — record so the stable dispatch decision is
  made with this in view; no interim mitigation likely needed beyond
  cutting v1.0.1.
- [ ] F002 (S3-F001) `scripts/parallel-matrix.sh` reports
  `features=unknown` for an intact plan chain whose `features:` list
  is explicitly `[]` — it should report `none` (unknown is reserved
  for a broken chain: missing plan file or missing `features:`
  field). Practical impact: every one of atelier's real plans has
  `features: []`, so all real pairs there read `unknown`. Fix the
  empty-list case (~line 64) + regression case in
  `scripts/test-parallel-matrix.sh`.

## UX

- [ ] F003 (S6-F001) When the same tasks file appears as
  ready-in-primary and claimed-in-a-worktree, `parallel-matrix.sh`
  labels the pair `verdict=shared-feature`. A distinct verdict (e.g.
  `claimed` or `same-file`) would serve coordinators better; current
  output is safe (never claims independence) but semantically
  misleading. Script + test + the two consuming skills' prose.
- [ ] F004 (S5-F001) `skills/ardd-status/SKILL.md`'s Work Queue prose
  implies entry data comes from `parallel-matrix.sh`, but with
  exactly one `ready` file the matrix is silent by design — entry
  data actually comes from `tasks-list.sh`. One-line prose
  clarification (matrix supplies pair verdicts, tasks-list supplies
  the entries).
