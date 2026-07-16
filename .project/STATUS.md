# artifact-driven-dev — Project Status

_Updated: 2026-07-15 (`/ardd-plan epics-grouping-in-feature-regi` —
drafted, approved, and tasked
`plan-epics-grouping-in-feature-regi-2026-07-15-d215.md` (solo mode, no
branch gate, on `main`). No open feedback or unsurfaced defects to
consume this run. Artifact change: `constitution.md` amended to add
`epic` to the feature register's documented optional fields (MINOR,
v1.10.0 → v1.11.0, SIR written) — applied ahead of drafting, on
confirmation, since the feature's own scope requires it (a documented
schema change per this repo's semver policy). 6 tasks across 4 phases in
`tasks-epics-grouping-in-feature-regi-42f2.md` (`ready`): Phase 1
(T001–T002, test-first) adds `epic` emptiness validation to
`lint-project.sh` plus fixtures. Phase 2 (T003–T004, test-first) extends
`feature-list.sh` with an `epic` output column and `--epic <slug>`
filter. Phase 3 (T005) adds an optional "by epic" breakdown to
`/ardd-status`'s Feature Backlog section, omitted when no feature has
`epic` set. Phase 4 (T006) adds one-directional GitHub-milestone mapping
to `/ardd-tracker`'s push phase — register owns `epic`, pull never reads
a milestone back. T005/T006 have no test tasks (Principle V
documentation-only exception; T006 also matches the standing
mechanization non-goal that `ardd-tracker`'s `gh` glue stays
judgment-heavy skill prose). Feature `epics-grouping-in-feature-regi`
flipped `backlogged` → `planned` → `tasked`. Deliberately out of scope:
no `epic` files with their own lifecycle, no `/ardd-plan` interactive
epic picker (multi-slug `/ardd-plan <slug> <slug> ...` already covers
it), no milestone-clearing on `epic` removal (open question). Prior
update, same day, `/ardd-implement` — delegated worktree run completed
and merged all 6 tasks of `tasks-list-mode-for-plan-and-impleme-2bf9.md`
(now `completed`): T001/T002 (test-first) added `scripts/feature-list.sh`
+ `scripts/test-feature-list.sh` — mirrors `tasks-list.sh`'s glob/
frontmatter-parse pattern, filters the feature register by status
(default `backlogged`; `--status <list>`; `--all`), confirmed red state
before implementing (the pre-commit hook's `scripts/test-*.sh` glob meant
T001+T002 landed in one commit — noted in the message rather than forcing
an artificial split). T003 added a matching CI job to `lint.yml`. T004/T005
added `--list` usage forms to `/ardd-plan` (shells to `feature-list.sh`)
and `/ardd-implement` (shells to `tasks-list.sh`, filtered to
`ready`/`in-progress`) — both stop before their skill's first step, no
writes. T006 documented both in their reference pages. Merged
fast-forward (`8ae0449..f51eff8`, no signing needed) and the worktree
reaped. Feature `list-mode-for-plan-and-impleme` flipped `tasked` →
`implemented` (rode the branch). Prior update, same day, `/ardd-plan
list-mode-for-plan-and-impleme` —
drafted, approved, and tasked
`plan-list-mode-for-plan-and-impleme-2026-07-15-a2c2.md` (solo mode, no
branch gate, on `main`). No open feedback or unsurfaced defects to
consume this run. No artifact changes — skill-prose plus one new
deterministic script; no new principle, data-model concept, or
production shortcut. Used the new plan-approval browser-preview offer
(published as an Artifact) for the first time since it shipped. 6 tasks
across 2 phases in `tasks-list-mode-for-plan-and-impleme-2bf9.md`
(`ready`): Phase 1 (T001–T003) adds `scripts/feature-list.sh` —
test-first, mirroring `tasks-list.sh`'s glob/frontmatter-parse pattern,
enumerating the feature register with a `--status`/`--all` filter
(default `backlogged`) — plus a CI job. Phase 2 (T004–T006) adds
`--list` usage forms to `/ardd-plan` (shells to `feature-list.sh`) and
`/ardd-implement` (shells to the existing `tasks-list.sh`, filtered to
`ready`/`in-progress` in prose), plus matching reference-doc updates.
No test tasks for Phase 2 (Principle V documentation-only exception).
Feature `list-mode-for-plan-and-impleme` flipped `backlogged` →
`planned` → `tasked`. Open questions: whether `feature-list.sh`'s
description column needs truncation, and whether `--list`'s
ready/in-progress filter should cross-reference in-flight worktrees —
both left to implementation. Separately, a background `fable` subagent
(dispatched outside this skill's flow, on user request) designed a
repeatable prerelease-testing exercise from `dev-notes/prerelease-testing-context.md`:
new `tests/prerelease/` (README runbook, `GUARDRAILS.md`, 7 scenario
briefs `S1`–`S7`) and a new source-side-only skill,
`.claude/skills/prerelease-sweep/SKILL.md` (`/prerelease-sweep smoke |
full | S<n> ...`) — none of this committed yet, sitting untracked for
review. Prior update, same day, `/ardd-update` — self-hosted (this repo is its own
ArDD source), so `/ardd-update`'s reinstall step was run directly against
this checkout to refresh `.claude/skills/` from the current tree (includes
the v1.10.0 constitution amendment and the codex-second-harness plan from
the prior step) rather than pulling from elsewhere. All 15 skills, 3
reference dirs, and all scripts reinstalled clean; all 8 migrations
already applied (none pending); `.worktreeinclude` and
`.project/.gitattributes` already correct. `.project/ardd-version.md`
re-stamped to commit `a656512`. `next_step_prompt`/`delegation`/
`merge_policy` frontmatter fields already present — no backfill asked.
Nothing pulled or pushed; no dev-mode source involved (self-hosted, not
a separate checkout). Prior update, same day, `/ardd-plan
codex-second-harness-support` — drafted
`plan-codex-second-harness-support-2026-07-15-f837.md` (solo mode, no branch
gate, on `main`), then **stopped at the approval checkpoint** on user
request — the plan stays `status: draft`, not yet tasked. Before drafting,
applied the feature's own required constitution amendment: `constitution.md`
bumped 1.9.0 → 1.10.0 (MINOR, SIR written) with a new "Multi-harness
install" subsection under Project Scope & Intent, documenting
`install.sh --harness codex`'s five install-time substitutions
(`AskUserQuestion` → plain-text prompts; `Agent` worktree
delegation/fan-out → dropped, inline-only; `.worktreeinclude` → not carried
over; `next_step_prompt` → plain-text offer; and a newly-identified fifth
substitution the original backlog entry missed, `/ardd-X` → `$ardd-X`
invocation-sigil rewrite) — this both folds in the de-risking spike's
findings and formally executes the named scope reversal ("a Claude Code
skill pack" → primarily Claude Code, also Codex) the feature record flagged
as required. The plan's 5 phases: Phase 1 is a blocking live
skill-to-skill-chaining smoke test (the one gate the spike's docs-only
research couldn't close — a hostile result there aborts Phases 2–5 in favor
of don't-do-it); Phase 2 adds the `--harness` flag and one substitution
transformer to `install.sh`; Phase 3 implements and tests each of the five
substitutions; Phase 4 updates docs (`docs/concepts.md`'s now-stale
"currently Claude Code-specific" line, README, USAGE.md); Phase 5 is a full
regression pass. No feedback consumed (none open) and no unsurfaced
defects. Feature `codex-second-harness-support` stays `backlogged` — the
`backlogged` → `planned` flip only happens at plan approval (step 11),
which this run didn't reach. Resume tasking later with `/ardd-plan --from
plan-codex-second-harness-support-2026-07-15-f837.md`. Prior update, same
day, `/ardd-implement` — delegated worktree run completed
and merged all 4 tasks of `tasks-update-channel-switch-flags-c066.md` (now
`completed`): T001 added `--local`/`--beta`/`--stable` flags to
`/ardd-update` — `--stable`/`--beta` call `source-resolve.sh --channel`
directly on the owned checkout and set `ARDD_CHANNEL` for reinstall;
`--local` resolves a dev-mode checkout (recorded `Source-Path` if already
`channel=dev`, else prompts for one) and reinstalls from it without
`ARDD_CHANNEL`; combining flags is a usage error. T002 updated
`docs/reference/skills/ardd-update.md` to match. T003 added a one-time
preliminary browser-preview offer to `/ardd-plan` step 10, ahead of the
existing Approve/Revise/Stop question — publishes `plan.md` via the
`Artifact` tool and displays the URL, re-firing on each Revise loop back
to step 10. T004 updated `docs/reference/skills/ardd-plan.md` to match.
No test tasks (Principle V documentation-only exception, confirmed
present before relying on it). Merged with a real merge commit (`main`
had independently advanced with the codex-second-harness research/backlog
work while this ran — `2749ce1..<merge>`, signed with the on-disk Claude
key since 1Password was unavailable) and the worktree reaped. Features
`update-channel-switch-flags` and `plan-approval-browser-preview` flipped
`tasked` → `implemented` (rode the branch). Prior update, same day,
`/ardd-backlog` — logged
`codex-second-harness-support`: single-source Codex CLI support via
`install.sh --harness codex` installing the same `SKILL.md` files to
`.agents/skills/` with the ~4 Claude-specific clauses substituted at
install time (`AskUserQuestion`, `Agent` worktree delegation,
`.worktreeinclude`, `next_step_prompt`); Codex v1 deliberately
degraded to inline-only implementation, plain-text prompts, no lint
hook; no parallel prose tree, no adapter build system. Spec = the
accepted `/ardd-research` recommendation
(`research-codex-cli-second-harness-2026-07-15-2d3d.md`). First step is
a de-risking spike on the go/no-go gates (exact-name skill invocation,
reliable skill-to-skill chaining) before any install work; requires a
MINOR constitution amendment (named scope reversal); fallback if the
spike fails is don't-do-it.). Prior update, same day, `/ardd-implement`
— delegated worktree run completed
and merged all 6 tasks of `tasks-discovery-to-work-eager-captur-2b57.md`
(now `completed`): the artifact→register bridge shipped. T001/T002 added
terminal "capture newly documented capabilities" steps to `/ardd-init`
(both paths) and `/ardd-refine` (delta-scoped — the pivot case); T003
gave `/ardd-status` a detection-only "Documented but Untracked"
report/STATUS.md section; T004 added `/ardd-backlog --from-artifacts`
(stable-artifact walk, passage-grounded candidates, one batched
confirmation, existing `feature-create` path); T005 added `/ardd-defects`'
routing note (never-built documented scope → backlog, not DEFECTS.md);
T006 updated the five reference pages (USAGE/guides deliberately
untouched — no existing sentence became inaccurate). Merged to `main`
(true merge `da84e79`→signed `2d792da`, `merge_policy: auto`, no
conflicts — main had advanced with the parallel plan run) and the
worktree reaped. Features `discovery-to-work-eager-captur` and
`backlog-sweep-reconcile-from-a` flipped `tasked` → `implemented` (the
flips rode the branch). Separately, a `/ardd-research` pass vetted Codex
CLI as a second harness
(`research-codex-cli-second-harness-2026-07-15-2d3d.md`, uncommitted):
verdict M-effort single-source port (Codex now reads the same SKILL.md
format from `.agents/skills/`), inline-only v1, de-risking spike first,
MINOR constitution amendment required — awaiting user review before any
backlog entry. Prior update, same day, `/ardd-plan update-channel-switch-flags
plan-approval-browser-preview` — drafted, approved, and tasked
`plan-update-channel-switch-flags-2026-07-15-f22c.md` (solo mode, no
branch gate, on `main`, while a sibling worktree independently worked
`tasks-discovery-to-work-eager-captur-2b57.md`). No open feedback or
unsurfaced defects to consume this run. No artifact changes — both
targeted features are skill-prose-only: neither introduces a new
principle, data-model concept, or production shortcut, and
`source-resolve.sh --channel stable|beta` and its dev-mode detection
already existed, so no script changes either. 4 tasks across 2 phases in
`tasks-update-channel-switch-flags-c066.md` (`ready`): Phase 1 (T001,
T002) rewrites `/ardd-update`'s Usage/step 1 to add `--local`, `--beta`,
`--stable` flags — `--stable`/`--beta` call `source-resolve.sh --channel`
directly and set `ARDD_CHANNEL` for reinstall; `--local` resolves the
recorded-or-prompted dev-mode checkout and reinstalls from it without
setting `ARDD_CHANNEL` — plus the matching reference doc. Phase 2 (T003,
T004) adds a one-time preliminary browser-preview offer to `/ardd-plan`
step 10, ahead of the existing Approve/Revise/Stop question: publish
`plan.md` via the `Artifact` tool, open it, display the URL, then
proceed to the unchanged three-way choice — re-fires on each Revise loop
back to step 10 — plus its reference doc. No test tasks (Principle V's
documentation-only exception). Both features flipped `backlogged` →
`planned` → `tasked`. Open questions: whether `--local`'s dev-checkout
path should be remembered across runs, and whether the plan-preview
artifact needs a stable favicon/title scheme — both left to
implementation. Prior update, same day, `/ardd-backlog` — logged
`update-channel-switch-flags`: `/ardd-update` gains `--local`, `--beta`,
and `--stable` flags to switch the install to the named channel's latest,
overriding the recorded `Channel:` for the run and re-recording it going
forward (today the channel is fixed at install-record time; switching
means hand-editing `ardd-version.md` or reinstalling; `--local` =
dev-mode against a live checkout, interacting with `source-resolve.sh`'s
per-channel selection and the dev-mode warn-and-ask path). Prior update,
same day, `/ardd-plan discovery-to-work-eager-captur
backlog-sweep-reconcile-from-a` — drafted, approved, and tasked
`plan-discovery-to-work-eager-captur-2026-07-15-156b.md` (solo mode, no
branch gate, on `main`): the artifact→register bridge. Consumed all 3
items of `feedback-artifact-register-bridge-116a.md` (now `planned`). No
artifact changes — all skill-prose/docs work; no new scripts (the
capability-vs-design-note judgment stays LLM work per the mechanization
non-goals) and no schema changes. 6 tasks across 3 phases in
`tasks-discovery-to-work-eager-captur-2b57.md` (`ready`): Phase 1 —
terminal capture steps in `/ardd-init` (T001) and `/ardd-refine`
(T002, delta-scoped for the pivot case); Phase 2 — `/ardd-status`
advisory "Documented but untracked" section (T003, detection only),
`/ardd-backlog --from-artifacts` proposal/write mode (T004), and an
`/ardd-defects` routing note for greenfield unbuilt scope (T005); Phase
3 — reference docs + lint-docs (T006). Both features flipped
`backlogged` → `planned` → `tasked`. Open questions: detection noise
control (tune from atelier, the first intended consumer) and whether
init's code-based extraction and the new artifact-based capture stay
distinct prose. Prior update, same day, `/ardd-backlog` — logged
`plan-time-defrag-slate-analysi`: advisory, recomputed-at-plan-time
footprint analysis over open backlog items proposing session-optimized
slates (overlap bundles implemented serially in one plan; pairwise-disjoint
sets as separate tasks files for worktree fan-out). Its spec is the
now-completed sync-tab-scroll prototype research report
(`research-backlog-defrag-slate-analysis-2026-07-15-627c.md` in that
repo, uncommitted): the cross-item premise degenerated there (N=1 open
backlog) but the method worked one level down inside
`phase-2-in-app-authoring`, surfacing the key requirements — dependency
ordering as a third axis beyond file overlap, graded footprint confidence
(speculative items never in parallel sets), register-direct status reads,
and sensible N=0/N=1 handling. Suggested first step recorded in the
entry: a second research pass against a genuinely large backlog (e.g.
atelier after `backlog-sweep-reconcile-from-a` backfills its limbo scope)
before codifying a `/ardd-plan` slate mode. Prior update, same day,
`/ardd-backlog` — logged
`plan-approval-browser-preview`, a request for `/ardd-plan`'s plan-approval
checkpoint to offer rendering `plan.md` as an artifact and opening it in the
browser (plus displaying the URL), as an alternative to reading raw
markdown in the terminal. Prior update, same day, `/ardd-feedback` — logged
`feedback-artifact-register-bridge-116a.md`, 3 UX items documenting the
missing artifact→register bridge observed across consumer projects:
discovery limbo (atelier — post-`/ardd-init` foundational scope stranded
in artifacts with no register entry), pivot limbo (sync-tab-scroll — an
`/ardd-refine` pivot's new-capability delta had to be hand-backlogged),
and `/ardd-defects`' drift framing being wrong for greenfield unbuilt
scope. Three new-capability items were re-filed to the register in the
same pass (user pre-approved the batch): `discovery-to-work-eager-captur`
(init/refine terminal step offering to backlog newly-documented
capabilities), `backlog-sweep-reconcile-from-a` (status advisory
detection + `/ardd-backlog --from-artifacts` for retroactive limbo), and
`epics-grouping-in-feature-regi` (optional `epic:` frontmatter grouping
for release-cadence bundling). A related fourth idea — computed "defrag"
footprint analysis for plan-time bundling/parallelization — is
deliberately NOT backlogged yet: a prototype `/ardd-research` run is in
flight in the sync-tab-scroll consumer repo, and its report will become
that item's spec. Prior update, same day, `/ardd-implement` — delegated worktree run completed
and merged all 13 tasks of `tasks-v1-0-0-pre-cut-testing-finding-bf61.md`
(now `completed`). T001 (test-first): `worktree-align.sh` now refuses
`aligned=false reason=not-a-worktree` when run from the primary checkout
rather than a real linked worktree — the fix for the nested-delegation
collapse S6 found. T007 (test-first): `lint-project.sh`'s Sync Impact
Report parser now accepts `→`, `->`, and `-->` equivalently, fixing the
misleading-error bug. T002–T004 strengthened `/ardd-init`'s
existing-codebase entity cross-checking, added scale-sensitive
constitution suggestions, and nudged `/ardd-defects` after brownfield
init. T005–T006 made `install.sh`'s gitignore suggestion a bounded
`ACTION NEEDED` block and gave `source-resolve.sh` an opt-in, age-gated
fetch-skip diagnostic (`note=fetch-skipped-fresh-cache`), reusing the
existing `update_check_max_age_days` field rather than inventing a new
one. T008–T009 added a `DEFECTS.md` staleness caveat and fixed the
`ardd-update-check.sh`/`ardd-status` field-name doc mismatch. T010–T013
were skill-prose polish (`gh pr create` failure path, create-vs-extend
task phrasing, `/ardd-diagram`'s silent-README note, and the
`workflow_mode` inline-vs-stamp documentation clarity). Merged to `main`
(fast-forward, `merge_policy: auto`, `9f111a9..7b65228`) and the worktree
reaped. No features bound to this plan, so no feature flip. Both feedback
files (`findings-0344` and `redrive-695b`) fully delivered — all 13 items
from the v1.0.0 pre-cut testing pass are now fixed. Prior update, same
day, `/ardd-plan --from` — folded the redrive batch's 7
items into the existing `plan-v1-0-0-pre-cut-testing-finding-2026-07-15-b89e.md`
(added Phase 4: deterministic-script fixes — `lint-project.sh`'s Sync
Impact Report arrow parsing rejecting ASCII `->`, a `DEFECTS.md`
staleness caveat, and the `ardd-update-check.sh`/SKILL.md field-name
mismatch; Phase 5: skill-prose fixes — `/ardd-implement`'s undocumented
`gh pr create` failure path, `/ardd-plan`'s create-vs-extend task
phrasing, `/ardd-diagram`'s silent README creation, and the
workflow-field stamped-vs-inline documentation gap) rather than drafting
a second plan, since both feedback batches came from the same testing
effort and touch overlapping files. The old 6-task
`tasks-v1-0-0-pre-cut-testing-finding-32c3.md` (untouched, 0/6) was
abandoned and replaced with a fresh combined 13-task
`tasks-v1-0-0-pre-cut-testing-finding-bf61.md` (`ready`) spanning all 5
phases — worktree-align.sh's distinct-worktree check (T001) remains the
highest-value fix. Both feedback files now `planned`. Prior update, same
day, `/ardd-feedback` — logged
`feedback-v1-0-0-pre-cut-testing-redrive-findings-695b.md`, 7 items (2
bugs, 5 UX) from a redrive of the 3 v1.0.0 pre-cut scenarios that lost
their reports to the earlier spend-limit outage (collaborative-mode
lifecycle, solo inline core loop, peripheral-skills sweep) — this time
briefed to write reports progressively, and all 3 survived intact. All 7
scenarios from the original test plan now have genuine, complete
findings. Highlights: `lint-project.sh`'s Sync Impact Report check
silently mis-parses an ASCII `->` where it expects the literal Unicode
`→`, with a misleading error pointing the user elsewhere (F001);
`/ardd-defects`' `DEFECTS.md` can go stale within the same day with
nothing in the report signaling it (a claim about `Entity` lacking
`long_form_keys` was true when checked but false an hour later — F002);
`/ardd-implement`'s collaborative-mode step has no documented behavior
for a failed `gh pr create` (F003); `/ardd-plan`'s task phrasing assumes
existing code even for a project's very first feature (F004); a
`ardd-update-check.sh`/SKILL.md field-name mismatch (`latest-release=` vs
documented `source-tip=`, F005); `/ardd-diagram` silently creates a new
README when none exists (F006); and SKILL.md phrasing doesn't make clear
that `workflow_mode` is written inline (not `stamp`-ed like the other
three workflow fields) (F007). On the positive side: S4 confirmed the
collaborative branch gate and `merge_policy` exclusion work exactly as
documented; S5's full backlog→plan→implement→status loop built and ran
real working code cleanly end to end; S7's `/ardd-audit` produced
genuinely incisive findings (not boilerplate), and `/ardd-lint`,
`/ardd-refine`, `/ardd-diagram`, and `/ardd-tracker`'s graceful
`gh`-unavailable degradation all worked as documented. Not yet consumed
by a plan. Prior update, same day, `/ardd-plan` — drafted, approved, and tasked
`plan-v1-0-0-pre-cut-testing-finding-2026-07-15-b89e.md`, consuming all 6
items from `feedback-v1-0-0-pre-cut-testing-findings-0344.md` (now
`planned`). Notably declined the literal ask in F003 (auto-editing a
target's `.gitignore` the way `.worktreeinclude` self-applies) as
conflicting with a standing, deliberate ceiling decision — scoped the fix
to visibility instead (a distinct, hard-to-miss suggestion block, still
suggestion-only). No artifact changes: all 6 fixes are skill-prose or
script behavior. 6 tasks generated across 3 phases in
`tasks-v1-0-0-pre-cut-testing-finding-32c3.md` (`ready`): T001 (test-first)
adds a positive distinct-worktree check to `worktree-align.sh` so it fails
loud instead of silently collapsing onto the primary checkout (F001, the
highest-value fix — a real pre-1.0 gap in the delegation machinery);
T002–T004 (parallel) strengthen `/ardd-init`'s existing-codebase entity
survey, add scale-sensitivity to its constitution-suggestion catalog, and
nudge `/ardd-defects` as a same-session follow-up on the brownfield path
(F002/F004/F005); T005–T006 (parallel) improve `install.sh`'s gitignore
suggestion visibility and add resolution diagnostics to
`source-resolve.sh`/`/ardd-update` (F003/F006). No feature slugs bound.
Prior update, same day, `/ardd-feedback` — logged
`feedback-v1-0-0-pre-cut-testing-findings-0344.md`, 6 items (2 bugs, 4 UX)
from a pre-v1.0.0 dry-run testing pass: 7 parallel sandboxed scenarios
covering new.sh acquisition, brownfield reverse-engineer init, consumer
upgrade + the new `--reconfigure` flag, collaborative-mode lifecycle,
solo inline core loop, delegated-worktree execution, and a
peripheral-skills sweep. An account-wide API spend-limit outage killed 3
of the 7 subagents mid-run and wiped their scratchpad before reports were
captured (collaborative mode, solo inline core loop, peripheral-skills
sweep — all reportedly completed execution cleanly but left no usable
detail); the other 4 produced real findings. Highlights: `worktree-align.sh`
has no positive check that it's actually in a distinct worktree — a
nested-delegation test silently collapsed onto the primary checkout
instead of failing loud (F001); `/ardd-init`'s existing-codebase survey
missed an entity lacking a colocated schema during reverse-engineering,
only caught via an explicit spot-check demand (F002); `install.sh`'s
`.gitignore` guidance is print-only, unlike `.worktreeinclude`'s
self-applying handling (F003); the constitution-suggestion catalog can
feel over-built for trivial projects (F004); `/ardd-defects` right after
a brownfield init caught real drift `/ardd-init` had just introduced,
suggesting the docs should nudge that pairing (F005); and
`/ardd-update`'s real tag-resolution path had unclear same-day-publish
lag when testing the brand-new `--reconfigure` flag (F006). Not yet
consumed by a plan. Prior update, same day, `/ardd-implement` — delegated worktree run completed
and merged all 4 tasks of `tasks-redrive-configuration-choices-29ae.md`
(now `completed`). **First delegation attempt failed live** — the same
bug the delegation pre-flight check exists for was reproduced anyway: the
plan/feature/tasks files this run's `/ardd-plan` wrote were never
committed before delegating, so the fresh worktree aligned cleanly
(`aligned=true`) but couldn't find `tasks-redrive-configuration-choices-29ae.md`
and stopped correctly rather than fabricating work. Recovered by removing
the empty worktree, committing the session's feature/plan/tasks files to
`main` (`3aa4dfa`), and relaunching. The second run completed: T001
rewrote `skills/ardd-update/SKILL.md`'s Usage section and step 5 to add a
`--reconfigure` flag — without it, behavior is unchanged (backfill only
absent fields); with it, all four workflow fields (`workflow_mode`,
`next_step_prompt`, `delegation`, and — solo mode only — `merge_policy`)
are re-asked regardless of presence, showing current values, stamping
only what changes. T002–T004 updated
`docs/reference/skills/ardd-update.md`, `docs/reference/configuration.md`,
and `CLAUDE.md`'s two "asked once" passages to match. Merged to `main`
(fast-forward, `merge_policy: auto`, `3aa4dfa..95796aa`) and the worktree
reaped. Feature `redrive-configuration-choices` flipped `tasked` →
`implemented`. Everything from this session is now on `main`. Prior
update, same day, `/ardd-plan redrive-configuration-choices` —
drafted, approved, and tasked `plan-redrive-configuration-choices-2026-07-14-1e00.md`
(solo mode, no branch gate, on `main`). No artifact changes: constitution.md's
Governance section already exempts workflow frontmatter fields
(`workflow_mode`, `next_step_prompt`, `delegation`, `merge_policy`) from
Sync Impact Report/versioning even when *changed*, not just set. Design
chosen: extend `/ardd-update` with a new `--reconfigure` flag (over a
standalone `/ardd-configure` skill or an `/ardd-init --reconfigure` flag)
that re-asks all four fields regardless of presence, showing current
values, and stamps only what changes — generalizing step 5's existing
backfill-only logic rather than duplicating it. 4 tasks generated across 2
phases in `tasks-redrive-configuration-choices-29ae.md` (`ready`): T001
rewrites `skills/ardd-update/SKILL.md`'s Usage and step 5; T002–T004
(parallel, depend on T001) update `docs/reference/skills/ardd-update.md`,
`docs/reference/configuration.md`, and `CLAUDE.md`'s two "asked once"
passages to match. No test tasks — all documentation/prose changes, the
explicit exception under Constitution Principle V. Feature
`redrive-configuration-choices` flipped `backlogged` → `planned` →
`tasked`. Prior update, same day, `/ardd-backlog` — logged
`redrive-configuration-choices`, a request for a way to re-answer/redrive
one-time configuration choices (e.g. `workflow_mode`, `next_step_prompt`)
if the user changes their mind after initial setup — currently only
askable once by `/ardd-init` or `/ardd-update`, or by hand-editing
constitution frontmatter. Earlier update, same day, `/ardd-implement` — delegated worktree run completed
and merged all 4 tasks of `tasks-203c-6b16.md` (now `completed`).
**First delegation attempt failed live**, demonstrating the exact bug
`feedback-uncommitted-plan-tasks-delegat-a3ff.md` described: the worktree
subagent aligned cleanly (`aligned=true`) but the plan/tasks files didn't
exist there because they'd never been committed — it stopped correctly
per its instructions rather than fabricating work. Recovered by removing
the empty worktree, committing the session's plan/tasks/feedback/backlog
files to `main` (commit `f837b7f`), and relaunching. The second run
completed: T001 added a delegation pre-flight `git status` check to
`skills/ardd-implement/SKILL.md` (the fix for the very bug just
reproduced); T002/T003 added the "committing the red state"
expected-failure-marker note + framework table to
`templates/constitution-suggestions.md`'s Test-First Development and
Deterministic Gates entries; T004 mirrored the marker handling in
`ardd-implement`'s TDD execution step. Merged to `main` (fast-forward,
`merge_policy: auto`, `f837b7f..e8a6e0c`) and the worktree reaped. No
features bound to this plan (`features: []`), so no register flip.
Everything from this session is now on `main`. Prior update, same day,
`/ardd-plan` — drafted, approved, and tasked
`plan-203c-2026-07-14-bf43.md` (solo mode, no branch gate, on `main`),
consuming both open feedback files: `feedback-uncommitted-plan-tasks-delegat-a3ff.md`
(F001) and `feedback-tdd-xfail-precommit-contradiction-a639.md` (F001,
F002). Both flipped to `planned`. No feature slugs targeted this run.
4 tasks generated across 2 independent phases in
`tasks-203c-6b16.md` (`ready`): T001 adds a delegation pre-flight
uncommitted-files check to `ardd-implement`'s delegation gate; T002–T004
add the expected-failure-marker (`xfail`) resolution to
`templates/constitution-suggestions.md`'s Test-First Development and
Deterministic Gates entries and to `ardd-implement`'s TDD execution step.
Deliberately out of scope: this repo's own `.project/artifacts/constitution.md`
— its test-added-in-the-same-commit paradigm never produces the
separately-committed red state the contradiction depends on, so nothing
there needed to change. Prior update, same day, `/ardd-feedback` — logged
`feedback-tdd-xfail-precommit-contradiction-a639.md`, a design suggestion
from an Atelier consumer project. Earlier update, same day, `/ardd-backlog` — logged
`list-mode-for-plan-and-impleme`, a request for `/ardd-plan` and
`/ardd-implement` to gain a `--list` mode printing eligible
slugs/tasks-files with basic info, bypassing the interactive pick flow.
Earlier update, same day, `/ardd-feedback` — logged
`feedback-uncommitted-plan-tasks-delegat-a3ff.md`, a bug report from
inspecting a real delegation failure: `/ardd-plan` writes the plan and
tasks files to disk without committing them, and in solo mode — where
`/ardd-plan` often runs directly on the default branch — that leaves a
window where a `status: ready` tasks file is real on disk but absent from
commit history. `/ardd-implement`'s delegation gate has no pre-flight
check for this, so a worktree subagent can get `aligned=true` from
`worktree-align.sh` (which only fast-forwards committed history) and then
fail cleanly when the tasks file isn't there — after a full agent launch
round-trip. This is the second observed occurrence of this exact failure
mode.)
Keep this current as artifacts are refined and open questions are resolved._

## Artifact Status

| Artifact | Status | Open questions |
|---|---|---|
| constitution.md | stable ✅ (v1.11.0; `delegation: eager`, `merge_policy: auto`) | — |

## Open Questions

None in the artifact. One plan-scoped item remains, non-blocking
(`plan-quickstart-new-project-2026-07-09.md` — optional `gh repo create`).

## Code-vs-Artifact Defects

1 defect — see `DEFECTS.md`, last checked 2026-07-12 (seventh pass). The
smoke-tier entry (`7efff3a5`) clears when the deliberately-unprovisioned
`ANTHROPIC_API_KEY` is provisioned; the next `/ardd-defects` pass
re-derives it. The docs-site work added `mkdocs.yml`, `docs/index.md`,
and `.github/workflows/docs.yml` (all source-side) — a re-run would
verify DEFECTS.md against the enlarged doc/workflow surface.

## Feedback

None open. Newest consumed: `feedback-artifact-register-bridge-116a.md`
(3 UX items, all incorporated) →
`plan-discovery-to-work-eager-captur-2026-07-15-156b.md` /
`tasks-discovery-to-work-eager-captur-2b57.md` (completed 6/6). Prior
batches all delivered (`findings-0344`, `redrive-695b` via
`tasks-v1-0-0-pre-cut-testing-finding-bf61.md`, completed 13/13).

## Recent Releases

The Phase 2 docs-site push published the accumulated `main` commits
(catalog revision, stale-update-network-check, docs site) as the next
beta; cut a stable via the dispatch workflow whenever consumers should
get them. v0.9.1 (2026-07-13) — first fully-automatic two-channel
cycle. v0.9.0 (2026-07-12) — first GitHub release. Full history: GitHub
Releases and `docs/decisions/0006`/`0007`.

## Feature Backlog

2 backlogged · 1 tasked · 19 implemented · 1 retired — see
`.project/features/`.
Tasked: `epics-grouping-in-feature-regi` →
`tasks-epics-grouping-in-feature-regi-42f2.md` (0/6, `ready`).
Backlogged:
- `codex-second-harness-support` — single-source Codex CLI support via
  `install.sh --harness codex`; spec = the accepted Codex-harness research
  report plus the de-risking spike (both GO). Still `backlogged`: a plan
  was drafted (`plan-codex-second-harness-support-2026-07-15-f837.md`,
  `status: draft`) but stopped at the approval checkpoint, un-tasked —
  resume with `/ardd-plan --from plan-codex-second-harness-support-2026-07-15-f837.md`.
- `plan-time-defrag-slate-analysi` — advisory plan-time footprint/slate
  analysis (bundles + parallel sets); spec = the sync-tab-scroll defrag
  research report; first step: a second research pass on a large backlog
  (atelier, post-sweep).
Target a slug with `/ardd-plan <slug>`.
Newest implemented: `list-mode-for-plan-and-impleme` — `scripts/feature-list.sh`
(new, test-first) plus `--list` usage forms for `/ardd-plan` and
`/ardd-implement` (`tasks-list-mode-for-plan-and-impleme-2bf9.md`,
completed 6/6).

## Audit

`.project/audit.md`: 1 open suggestion (two-channel release paragraph →
decision-record pointer) + 1 open risk (smoke key unprovisioned, now
documented as a deliberate standing state). 2 suggestions resolved this
pass (new.sh tty narrative → decision record, v1.8.1; Governance
workflow-field exemption, v1.8.2).

## In Flight

Nothing — the `tasks-list-mode-for-plan-and-impleme-2bf9.md` worktree
merged (fast-forward, `8ae0449..f51eff8`) and was reaped; no sibling
worktrees remain. `main` is ahead of `origin/main` (local commits not yet
pushed).

## Recommended Next Step

`/ardd-implement` on `tasks-epics-grouping-in-feature-regi-42f2.md` is
`ready` (6 tasks, 4 phases: lint-project.sh schema validation,
feature-list.sh epic column/filter, /ardd-status epic breakdown,
/ardd-tracker milestone mapping). A drafted-but-untasked plan is also
still waiting: `/ardd-plan --from
plan-codex-second-harness-support-2026-07-15-f837.md` (Phase 1 is a
blocking live skill-to-skill-chaining smoke test on a real Codex CLI —
the true final go/no-go — before Phases 2–5's install-time substitution
work proceeds). Standing options otherwise unchanged: the new
`/prerelease-sweep smoke|full|S<n>` exercise (once reviewed and
committed); dispatch the stable release workflow when consumers should
get the accumulated `main` work (now includes the v1.10.0 constitution
amendment); resolve the remaining `.project/audit.md` suggestion; or
`/ardd-defects` to re-verify against the docs-site and skill-prose
surfaces.
