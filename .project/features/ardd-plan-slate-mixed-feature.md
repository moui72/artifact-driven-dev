---
slug: ardd-plan-slate-mixed-feature
status: implemented
logged: 2026-07-24
plan: plan-ardd-plan-slate-mixed-feature-2026-07-24-a7fb.md
tasks: tasks-ardd-plan-slate-mixed-feature-4469.md
---

/ardd-plan --slate should plan across a mixed slate of both backlogged features and feedback items in a single run, rather than being scoped to one input kind.

## Research notes (2026-07-24)

**Mixed *planning* already works** — a normal `/ardd-plan` run accepts a feature
slug and a `feedback-*.md` arg in one invocation, and the bare picker already
spans features + feedback + defects. Only the `--slate` *advisory analysis* is
feature-only: its Usage prose says "no feedback load," and slate step 1
enumerates only `feature-list.sh --status backlogged`.

**The gap** is purely slate's enumeration + relation model — it never globs
`.project/feedback/`, so a slate can recommend fanning out a feature whose
footprint collides with an open bug fix. The recommendation grammar
(`/ardd-plan <slug> feedback-x.md`) is already valid scoped-run input; slate
just never emits it.

**Real payoff:** a `## Reconsidered` feedback item tagged with an artifact a
slated feature would also modify is a dependency edge — today a fan-out can
design a feature against an artifact a pending reversal is about to overturn.
Mixed slate would bundle them.

**Design:** treat each feedback *file* (not each F### item) as one slate item,
footprint = union of its `[artifacts:]` tags + grep-grounded refs. Slate stays
read-only → **zero new state machinery**; all flips remain in the normal run
(feedback `feedback-mark`/`feedback-planned` at step 4; feature flips at
steps 11/14). No `lint-project.sh` enum or script changes.

**Effort: small-to-medium, prose-only.** Changes `skills/ardd-plan/SKILL.md`
(Usage `--slate` para — drop "no feedback load," keep read-only guarantee —
plus slate steps 1–5 and the report example); verify/sync
`docs/reference/skills/ardd-plan.md` hand-written body; optional one-sentence
note in `skills/ardd-feedback/SKILL.md` "Consumption by /ardd-plan." Ships as
`feat:`. Low risk — a bad grouping only costs an ignorable recommendation.
