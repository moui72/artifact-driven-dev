---
status: open      # open -> planned
created: 2026-07-20
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

Source: scenario sweep run 2026-07-20-cdf0 (full-tier regression pass for the
Codex port). The port did NOT regress the Claude skill surface; these are the
accepted non-taste findings. Harness artifacts and taste-defers are recorded
in `dev-notes/scenario-runs/2026-07-20-cdf0/TRIAGE.md`, not here. Graduation
item G1 (Codex `--harness` install assertions for S3) is deferred to the
in-flight Codex port of scenario-sweep + the scenario briefs, not captured
here.

## Bugs
- [ ] F001 S2 fixture no longer cold: the scenario clone source
  `~/dev/daily-huddle` ships committed ArDD state (`.project/` artifacts,
  `.ardd-applied`, an old `.claude/skills/` tree), contradicting S2's
  "never-ArDD, cold reverse-engineer" premise — the sweep subagent had to
  `rm -rf .project` to exercise the reverse-engineer path at all. Fix: clean
  the daily-huddle fixture of committed ArDD state, or update the S2 brief
  (`tests/scenarios/S2.md`) to name/prepare a genuinely never-ArDD clone
  source.
- [ ] F002 Dev-mode `/ardd-update` reinstall leaves a stale `Channel: beta`
  line in `.project/ardd-version.md` while dropping `Source-Ref` and pointing
  `Source-Path` at a dev checkout — an internally contradictory record
  (`Channel: beta` with no `Source-Ref` and a dev `Source-Path`). Inert today
  but misleading to a human reader; the channel line should be cleared or set
  to `dev` when a reinstall drops to dev-mode (`install.sh`,
  `scripts/source-resolve.sh`).

## UX
- [ ] F003 `.project/ardd-version.md` records no harness identity: a
  `--harness claude` vs `--harness codex` install produces a byte-identical
  `ardd-version.md`, leaving `ardd-scripts/harness-capabilities.env` as the
  sole record of which skills tree is live. Consider recording the harness in
  `ardd-version.md` so the committed provenance file alone can answer "which
  harness produced this install" (`install.sh`).
- [ ] F004 Collaborative `workflow_mode` forbids committing to the local
  default branch, but neither `/ardd-init` nor `/ardd-backlog` says where the
  pre-plan scaffold should go; the intended flow only works because
  `/ardd-plan`'s branch gate inherits uncommitted working-tree files. A user
  who commits the scaffold first violates the mode's own rule with no warning.
  Add a one-line collaborative-mode note to `skills/ardd-init/SKILL.md` and
  `skills/ardd-backlog/SKILL.md`.
- [ ] F005 Scenario-brief coverage gap (graduation G2): the
  `.project/README.md` reviewer guide (shipped since v1.0.1) has no scenario
  brief asserting its install or content. Add a one-line check to `S7`'s setup
  (`tests/scenarios/S7.md`) asserting the reviewer guide is present and
  coherent post-install. Brief edit lands via the fix plan, validated by the
  regression rerun — never edited mid-sweep.
