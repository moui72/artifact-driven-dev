---
status: planned      # open -> planned
created: 2026-07-11
plan: plan-consolidate-setup-skills-2026-07-11.md
---

# Feedback

## Reconsidered
- [x] F001 The skill pack has too many skills (21), which raises the barrier
  to entry. This is a **catalog-level** concern, not a per-pair one: a
  newcomer meets all 21 commands on the shelf at once. The catalog already
  carries a `tier:` frontmatter system (`setup` 5 · `core` 6 · `extension`
  10) and README already groups by it, so the fix is (a) merges that shrink
  the most newcomer-facing tiers and (b) fixing what the tiers advertise.
  Concretely: the four setup-tier entry points (`kickoff`, `bootstrap`,
  `codify`, `featurize`) are the first surface a newcomer meets —
  consolidate the two setup-tier pairs so "how do I start a project" drops
  from 4 skills to 2 (see F002/F003).
- [x] F002 Merge `/ardd-kickoff` into `/ardd-bootstrap`. Kickoff is
  structurally a preamble: its guard (step 1) duplicates bootstrap's own
  step 1, and its only job is to manufacture the conversation context
  bootstrap consumes, then hand off. Fold the interview into bootstrap as a
  "step 0 — assess context sufficiency": if conversation context already
  establishes the project, synthesize as today; if thin (cold session /
  empty dir from the `new.sh` quickstart), conduct the design interview
  first, then proceed. Preserve kickoff's install-complete guard (→
  `/ardd-setup`), which bootstrap currently lacks. This is strictly better
  than the status quo, which routes a user who already described their
  project through a redundant interview. Ripples into `new.sh`'s handoff
  offer, `README`/`USAGE`/`guides/greenfield.md`, and `lint-docs.sh`.
- [x] F003 Merge `/ardd-featurize` into `/ardd-codify` — the same structural
  relationship as F002 (`featurize` is "one-time, after codify"). Codify
  reverse-engineers artifacts from a codebase; featurize then extracts the
  feature register from the same codebase. Make feature-register extraction
  part of the codify pass (offered or automatic). Same doc/lint ripple as
  F002.
- [-] F004 Explicitly out of scope for this round: merging `/ardd-implement`
  and `/ardd-converge`. They share the delegation/state model, but converge's
  job (reconcile after an interruption) is a genuinely different entry state
  with different failure modes, and it isn't a day-one barrier-to-entry
  surface. Higher risk, lower payoff — leave separate. (Recorded so the next
  plan doesn't re-open it.)
- [x] F005 Merge `/ardd-tasks` into `/ardd-plan` (core-loop tier, 6→5).
  Originally judged a weak candidate and left out; an adversarial critique
  (Fable subagent, 2026-07-11) reversed the call and the reasoning holds up:
  (1) the "durable reviewable plan file" and "approval checkpoint" are
  properties of the artifact/pause, not of having two commands — a merged
  skill can still write `plan-*.md` and stop for approval; (2) the checkpoint
  is *already* vestigial — `ardd-plan` step 10 states there is no separate
  approval step, `/ardd-tasks` selecting the plan is what approves it, and
  under `next_step_prompt: true` the seam is one keypress; (3) the "plan never
  delegates" constraint exists *because of* the cross-skill handoff and
  largely dissolves once merged. Design for the merge: one skill writes the
  durable `plan-*.md`, pauses at an explicit approve/revise/stop checkpoint
  (restoring the gate the current design eroded into a list-selection side
  effect), then emits `tasks-*.md`; accept a plan-file argument
  (`/ardd-plan --from <plan>`) for the re-task-without-re-planning case. The
  one honest counterweight is combined-prose length/modal complexity (~500
  lines, several modes) degrading LLM instruction-following — if that proves
  prohibitive in practice the fallback is NOT the status quo but "separate
  files, single advertised surface." Ripples: `README` core-loop table,
  `USAGE`, `lint-docs.sh`, every skill whose terminal handoff names
  `/ardd-tasks`, and the `next_step_prompt` three-skill set (plan/tasks/analyze).
- [x] F006 Fix what the tiers advertise, so the catalog reads as smaller than
  21 flat commands. Two sub-parts: (a) **re-tier mis-categorized skills** —
  `/ardd-analyze` is invoked automatically as the terminal step of nearly
  every core skill and `/ardd-lint` backs the write-time hook; these are core
  *infrastructure*, not opt-in `extension`s, and mislabeling them makes the
  core loop look like it needs 6 commands when it silently needs more.
  (b) **consider install.sh installing a curated default set** (setup + core
  + the infra extensions) with the genuinely-optional extensions
  (`sync`, `research`, `render`, `critique`, ...) opt-in — since nothing
  installed can be hidden from Claude Code's command palette, "fewer on the
  shelf" is only achievable by installing fewer. This half needs a design
  decision (is a two-tier install worth the install.sh complexity, or does
  better README/tier presentation suffice?) — carry it as an [OPEN] in the
  plan rather than presuming the answer.
