# artifact-driven-dev — Project Status

_Updated: 2026-07-19 (`/ardd-feedback` — logged
`feedback-sweep-coverage-expansion-3452.md` (`open`, 6 UX items) from a
Fable audit of `tests/prerelease/scenarios/` coverage vs recently
shipped surfaces. Verdict: suite structurally healthy; two expansions
matter — dynamic-badge checks into S1 (field failure, zero coverage;
write after the in-flight fix branch merges) and Work Queue/
parallel-matrix consumer-visible checks into S8 (two real d06a bugs,
shell-test pin only) — plus smaller S5 (bare-plan picker), S7
(`--view` single-writer discipline; `constitution --review`)
extensions and a systemic F006: dispatcher-supplied "recent feature"
stress ages out after one sweep, so real-finding surfaces should
graduate into durable briefs. Judged adequate as-is: channels, epics,
fold/reap/align, rejected/subsumed (deterministic layer), `--slate`,
source-side skills. Meanwhile the delegated
`dynamic-badge-discoverability` worktree run is in flight at 3/4.
Prior update, same day, `/ardd-plan feedback-dynamic-badge-discoverability-a123.md`
— consumed the badge feedback (all 6 items accepted, file now
`planned`): drafted, approved, and tasked
`plan-dynamic-badge-discoverability-2026-07-19-23cf.md` — 4 tasks/3
phases in `tasks-dynamic-badge-discoverability-6887.md` (`ready`).
Phase 1 (test-first): install.sh badge-section fixes — fill
`OWNER/REPO/BRANCH` in the printed snippet from the target's own git
remote/branch (placeholder + printed replace-instruction fallback),
marker-guard the `ARDD_VERSION_BADGE=1` snippet reprint, advisory when
a README carries the wrong latest-release badge shape (both paths),
private-repo caveat line, and a default-output mention of the
`ARDD_VERSION_BADGE=1` opt-in. Phase 2: `/ardd-update` offers the
dynamic badge and sets the env var on the re-run (F006 resolved: env
var stays the mechanism, skill prose becomes the interface). Phase 3:
docs/templates (public-repo-only limitation, USAGE routing,
`ardd-update` reference page). Out of scope deliberately: in-place
README rewriting (would break the never-edit posture) and the sync
workflow's push-failure modes. No feature slugs targeted
(`features: []`). Committed to `main` (721f786). Prior update, same
day, `/ardd-feedback` — logged
`feedback-dynamic-badge-discoverability-a123.md` (`open`, 3 bugs + 2 UX
+ 1 Reconsidered) after the `ARDD_VERSION_BADGE` dynamic-badge feature
failed in the field: a consuming agent asked to add a version badge
hand-rolled the wrong shields.io `github/v/release` badge (the exact
"runs ahead silently" shape the feature was built to prevent) because
the env-var opt-in is documented nowhere — zero mentions in `skills/`,
`docs/`, `README.md`, or `USAGE.md`, and `/ardd-update` never offers
it — then wrapped the wrong badge in `ardd-badge-start/end` markers,
which now suppress install.sh's suggestion permanently. Also filed:
the printed two-badge snippet's literal `OWNER/REPO/BRANCH`
placeholders (the explanatory comment isn't printed), the
`ARDD_VERSION_BADGE=1` branch reprinting the snippet despite existing
markers, the missing private-repo caveat (shields.io can't fetch
`raw.githubusercontent.com` on private repos), and a Reconsidered item
questioning whether an env-var gate is the right interface for an
agent-mediated workflow at all. The next `/ardd-plan` run picks it up.
Prior update, same day, **v1.0.1 shipped** — ship-gate sweep e33f (S3 S5
S6 S8) came back fully clean: all checklists green, the
stamp-workflow-mode fix verified live, F002/F003/F004 holding, F001
reproduced exactly as known-open; only new items were three
taste-deferred subjective UX notes (advisory-lock same-session noise,
constitution-tag shared-artifact prevalence, fold-branch leftover).
Pushed `main` (9fd6fbb), confirmed lint green, dispatched
`stable-release.yml` (`bump: patch`) through GitHub API 503 flakiness
— `v1.0.1` published and marked Latest. This closes the loop begun
with sweep d06a and self-heals its headline finding: `/ardd-update
--stable` consumers now get the fixed install.sh riding the stable
tag. Full arc today: d06a targeted sweep → 4 fixes → 51a7 regression
rerun (1 new finding) → stamp-workflow-mode fix → e33f clean gate →
ship. Prior update, same day, regression sweep 51a7 +
`stamp-workflow-mode`
fix — the S3/S5/S6/S8 regression rerun verified all four d06a fixes
(F002/F003/F004 confirmed live; F001 reproduced as known-open until
v1.0.1) but surfaced one new bug: `--reconfigure` prose stamps
`workflow_mode`, which `cmd_stamp`'s enum rejected. Fixed via the full
loop (feedback `feedback-stamp-workflow-mode-ca7d.md` → plan →
delegated implement, red-first, 6 new assertions, merged + reaped).
Per user instruction the ship gate is now: full re-sweep S3 S5 S6 S8;
on a clean pass, push + dispatch v1.0.1 stable. Prior update, same
day, `/ardd-implement` coordinator — the delegated
`sweep-d06a-fixes` worktree run completed all 5 tasks and merged
fast-forward; worktree reaped; dogfooded install refreshed. Fixed:
parallel-matrix `features: []` now reads `none` (unknown reserved for a
broken chain) and the same-file ready-vs-worktree-claim pair gets the
new `verdict=claimed` (precedence claimed > shared-feature >
shared-artifact > independent) — red-first, 15/15 asserts green;
`claimed` named in both consuming skills' prose + reference docs; Work
Queue data-source clarification applied; and T005 found `c7cb703`
shipped with no regression test — added case4 (dual-tagged HEAD →
stable `Source-Ref:`) to `test-install-channel-default.sh`, green
against the existing fix. Next per user instruction: regression sweep
S3 S5 S6 S8 re-verifying F001–F004; if clean, push + dispatch v1.0.1
stable. Prior update, same day,
`/ardd-plan feedback-prerelease-sweep-d06a-f8ce.md`
— consumed the sweep feedback (all 4 items incorporated, file now
`planned`): drafted, approved, and tasked
`plan-sweep-d06a-fixes-2026-07-19-502e.md` — 5 tasks/3 phases in
`tasks-sweep-d06a-fixes-ccf0.md` (`ready`). Phase 1 (test-first):
parallel-matrix verdict fixes — explicit `features: []` reads `none`
not `unknown`, and a new `verdict=claimed` (precedence claimed >
shared-feature > shared-artifact > independent) for the same-file
ready-vs-worktree-claim pair. Phase 2: `claimed` named in both
consuming skills + the Work Queue data-source clarification
(tasks-list supplies entries, matrix supplies verdicts) + reference
docs. Phase 3 [parallel]: verify/add dual-tag stable-preference
regression coverage for F001, whose operational remedy is dispatching
v1.0.1 stable. Same-file hard exclusion unchanged. Prior update, same
day, `/prerelease-sweep S3 S5 S6 S8` + triage +
`/ardd-feedback` — targeted regression sweep over every post-v1.0.0
surface (run `2026-07-19-d06a`, ~348K tokens, ~$1.50–3.50, ~8m40s
parallel). **All four scenarios passed**; the changed surfaces (bare-plan
picker, Work Queue, parallel-matrix, picker annotations,
rejected/subsumed, install dual-tag fix) all verified working. 7
findings triaged → 4 accepted, filed as
`feedback-prerelease-sweep-d06a-f8ce.md` (`open`, 2 bugs + 2 UX):
headline F001 — `/ardd-update --stable` on real consumers today
records a stale beta `Source-Ref:` under `Channel: stable` (v1.0.0's
install.sh predates fix c7cb703; self-heals when the next stable
ships, so this argues FOR cutting v1.0.1 promptly); F002
parallel-matrix `features: []` misread as `unknown`; F003 same-file
claimed pair mislabeled `shared-feature`; F004 Work Queue prose
data-source clarification. Deferred/dropped: STATUS.md-accretion
guidance (taste), fold branch-ref cleanup (taste), advisory-note
duplicate, harness worktree-binding artifact. Prior update, same day,
`/ardd-implement` coordinator — the delegated
`bare-plan-target-prompt` worktree run completed both tasks and merged
fast-forward; worktree reaped; dogfooded install refreshed. A bare
`/ardd-plan` now has step 1a: it enumerates plannable inputs
(backlogged slugs, open feedback, unsurfaced defects) and offers them
as one multi-select picker forwarding into the existing scope
machinery; with truly nothing plannable it ends in prose + next-step
suggestions instead of a complaint. `lint-docs` green;
`docs/reference/skills/ardd-plan.md` body updated. No bound features
(plan `features: []`), so no register flip. Prior update, same day,
`/ardd-plan` (bare) — consumed
`feedback-bare-plan-target-prompt-dc5f.md` (both UX items accepted, file
now `planned`): drafted, approved, and tasked
`plan-bare-plan-target-prompt-2026-07-19-03ba.md` — 2 tasks/2 phases in
`tasks-bare-plan-target-prompt-6bcd.md` (`ready`). A bare `/ardd-plan`
gains a step-1a target pick: it enumerates plannable inputs
(backlogged slugs via `feature-list.sh`, open feedback files,
unsurfaced defects) and offers them as one multi-select picker,
forwarding the selection into the existing scope machinery; with truly
nothing plannable it ends in prose + next-step suggestions
(`/ardd-backlog`, `/ardd-feedback`, `/ardd-implement`) instead of a
complaint. No new scripts; `--list`/`--slate`/`--from` untouched. No
feature slugs targeted. Prior update, same day, `/ardd-implement`
coordinator — the delegated
`work-queue-parallel-safety` worktree run completed all 6 tasks and
merged fast-forward; worktree reaped; dogfooded install refreshed via
`./install.sh .` (the new script is live in
`.claude/skills/ardd-scripts/`). Shipped: `scripts/parallel-matrix.sh`
(pairwise `independent|shared-feature|shared-artifact` verdicts among
`ready` tasks files and in-flight worktree claims; test-first, 11/11
regression cases green, CI job + install manifest wired), the Work
Queue section in `/ardd-status` (report + STATUS.md, omit-if-none), the
matrix-annotated pick list in `/ardd-implement` (`shared-feature` =
strong warning, same-file claim stays the only hard exclusion), and
both reference-doc bodies. Feature `work-queue-parallel-safety`:
`tasked` → `implemented`. Prior update, same day, `/ardd-feedback` —
logged
`feedback-bare-plan-target-prompt-dc5f.md` (2 UX items, `open`): F001 a
bare `/ardd-plan` should prompt with the plannable items it found
(backlogged slugs, open feedback, unsurfaced defects) rather than
complaining about no feedback input; F002 with truly nothing plannable
it should end in prose + concrete next-step suggestions
(`/ardd-backlog`/`/ardd-feedback`/`/ardd-implement`). The next
`/ardd-plan` run picks it up. Prior update, same day,
`/ardd-plan work-queue-parallel-safety` — drafted,
approved, and tasked
`plan-work-queue-parallel-safety-2026-07-19-4c10.md`: 6 tasks/4 phases
in `tasks-work-queue-parallel-safety-eadb.md` (`ready`). Phase 1
(test-first): `parallel-matrix.sh` + regression test + CI/install
wiring — pairwise `independent|shared-feature|shared-artifact` verdicts
among `ready` tasks files and in-flight worktree claims (feature overlap
via the tasks→plan→`features:` chain, `unknown` when broken; artifact
overlap via `[artifacts: ...]` tag intersection; deliberately no path
heuristics). Phases 2–3: Work Queue section in `/ardd-status` +
matrix-annotated fan-out picker in `/ardd-implement` (`shared-feature`
is a strong warning, never a hard exclusion — the same-file claim check
stays the only hard one; `independent` means "no declared overlap",
`merge_policy` still governs). Phase 4: docs. Both research-doc open
questions resolved in the plan; no artifact edits needed. Feature
`work-queue-parallel-safety`: `backlogged` → `tasked`. Prior update,
same day, `/ardd-implement` coordinator — the delegated
`rejected-feature-status` worktree run completed all 8 tasks and merged
fast-forward; worktree reaped. `rejected` and `subsumed` are now real
register statuses: `lint-project.sh`'s `FEATURE_STATUS_ENUM` extended;
`ardd-state.sh feature-flip` grew the five legal transitions
(`backlogged/planned→rejected`, `backlogged/planned/tasked→subsumed` —
the asymmetry is deliberate: absorption can be noticed after tasking,
rejection can't) with regression tests; good-project fixtures, `docs/
reference/project-files.md`, and `ardd-status`/`ardd-plan` prose all
updated. Feature `rejected-feature-status`: `tasked` → `implemented`.
Subagent process note: one commit briefly landed with `--no-verify`
after the pre-commit suite outran a tool timeout, self-caught and
redone properly with hooks passing. Prior update, same day,
`/ardd-research` + `/ardd-backlog` — vetted and
logged `work-queue-parallel-safety`: a single-pane work-queue view — an
installed `parallel-matrix.sh` reporting feature- and artifact-overlap
verdicts among `ready` tasks files and in-flight worktrees (deliberately
no path heuristics — prose paths are unstructured, so path-contact
assessment stays agent judgment at presentation time), surfaced as a
Work Queue section in `/ardd-status` and as annotations on
`/ardd-implement`'s fan-out multi-select picker. Research doc (lens
results, rejected alternatives incl. a separate `/ardd-board`
report-owner skill, open question on whether `shared-feature` should be
a hard fan-out exclusion or a warning):
`research-work-queue-parallel-safety-vie-2026-07-19-25f7.md`. Prior
update, same day, `/ardd-plan rejected-feature-status` — a fable
design review (dispatched at the approval checkpoint) recommended
extending the original rejected-only plan to also add `subsumed` (an
entry whose scope shipped under a *different* feature/plan entry): this
repo's own register had zero real instances of the `rejected` problem
but a concrete example of the `subsumed` one, in the feature's own
`Why:` line. Plan and the already-applied `constitution.md` edit both
revised in place to cover both statuses (still one MINOR bump, 1.11.1 →
1.12.0). `subsumed` deliberately not named `superseded` — that word
already means something different at the *plan* level (a same-document
replacement for the same feature) than this cross-feature scope-absorption
case. Approved and tasked: 8 tasks/3 phases in
`tasks-rejected-feature-status-2fb8.md` (`ready`) — schema
(`lint-project.sh` enum), state mutation (`ardd-state.sh`'s
`cmd_feature_flip`, including an asymmetric `tasked -> subsumed` edge
`rejected` doesn't get, since absorption can be noticed later than a
pre-work rejection decision), skill prose
(`ardd-status`/`ardd-plan`/`project-files.md`), and manual verification
against two throwaway fixtures. Feature `rejected-feature-status`:
`backlogged` → `tasked`. Prior update, same day, `/ardd-backlog` —
logged `rejected-feature-status`:
a new `rejected` status for the feature register's status enum
(backlogged/planned/tasked/implemented/retired), for a backlogged or
planned idea the team decides not to pursue and that never gets
built — a terminal state distinct from `retired` (shipped then
deliberately removed). Motivated partly by a related, illustrative gap
from a consumer project: a feature whose scope shipped under a
*different* plan/feature entry didn't cleanly fit `retired` or
`implemented` either, and was worked around by closing it as
`implemented` bound to the other plan with an explanatory note — flagged
in the entry's `Why:` as a separate, related gap (a "subsumed" status or
similar) not solved by this same change. Prior update, same day, **v1.0.0
shipped** — pushed `main` (publishing
`v0.10.3-beta.4` on the beta channel automatically), confirmed `lint`
and `beta-release` both green on that commit, then dispatched
`stable-release.yml` with `bump: major`. The workflow fast-forwarded
`release` to `main`'s tip and published `v1.0.0` as the latest stable
release (https://github.com/moui72/artifact-driven-dev/releases/tag/v1.0.0).
This closes the full loop that began with the 2026-07-18 full prerelease
sweep: sweep → triage → 6 accepted findings → fix plan → implement →
regression rerun (all green) → push → CI green → stable dispatch. Prior
update, same day, `/prerelease-sweep S2 S3 S4 S6 S7` — regression
rerun (run `2026-07-18-abb8`, ~$2.50–3.75, ~414K tokens, ~8min real
elapsed) of the scenarios that produced the 6 `prerelease-sweep-fixes`
findings. **All 6 confirmed fixed** — see
`dev-notes/prerelease-runs/2026-07-18-abb8/RUN.md`'s regression triage
table for the full per-finding verification. One incidental catch (not
a product bug): S6 found this repo's own dogfooded
`.claude/skills/ardd-scripts/` was several commits stale — fixed
immediately by re-running `./install.sh .` against this repo itself.
No new defects found. **Verdict: green light for the 1.0 stable cut**
as far as this sweep's scope is concerned — the plan/implement/regression
loop that started with the full sweep is now closed. Prior update, same
day, `/ardd-implement` — the delegated
`prerelease-sweep-fixes` worktree run completed all 12 tasks, fixing all
6 accepted prerelease-sweep findings: `install.sh` now infers `Channel:`
from `Source-Ref:`'s `-beta.` suffix shape (F001, manually verified
across all 3 precedence tiers — explicit `ARDD_CHANNEL`, preserved prior
channel, and the new inferred default); `ARDD_VERSION_BADGE=1` now
writes its supporting files even when a README already has the static
badge marker (F002, manually verified — no-README and unset-env-var
paths confirmed unchanged); `ardd-state.sh feature-flip ...
implemented` now cross-checks the bound tasks file's completion status
(F003); `task-check` gives a diagnostic message on a malformed
colon-suffixed checkbox (F004); `lint-project.sh`'s `plan:`
path-vs-filename error is now distinct and clear, no more doubled path
(F005, bad-project fixture's `EXPECTED_BAD_FINDINGS` 38→39); the
epic-drained-to-zero case is now documented in `ardd-status`'s
`SKILL.md` (F006). New test coverage:
`scripts/test-install-channel-default.sh` (new) plus extended cases in
`test-install-version-badge.sh`, `test-ardd-state.sh`,
`test-lint-project.sh` — all passing. Merged clean (fast-forward) and
the worktree reaped. No feature slugs targeted. **Next: regression-rerun
`/prerelease-sweep S2 S3 S4 S6 S7` (the scenarios that produced these
findings) before dispatching the stable-release workflow for 1.0.**
Prior update, same day, `/ardd-plan` — drafted, approved, and tasked
`plan-prerelease-sweep-fixes-2026-07-18-d341.md`: 12 tasks/3 phases in
`tasks-prerelease-sweep-fixes-e4d8.md` (`ready`) fixing all 6 findings
from the full prerelease sweep. Highest priority (F001/T001-T002):
`install.sh` now infers the default `Channel:` from `Source-Ref:`'s own
`-beta.` suffix shape instead of hardcoding `stable`, when neither
`$ARDD_CHANNEL` nor a previously-recorded channel applies — fixes ArDD's
own installer tripping its own `channel-source-ref-consistency` lint
check in the normal between-releases state. Also: F002/T003-T005
(`ARDD_VERSION_BADGE=1` now writes files even if the static badge marker
already exists), F003/T006-T007 (`feature-flip ... implemented` now
cross-checks the bound tasks file's actual completion status),
F004/T008-T009 (`task-check` gives a diagnostic message on a malformed
colon-suffixed checkbox), F005/T010-T011 (`lint-project.sh`'s `plan:`
path-vs-filename error no longer garbles the message), F006/T012 (epic-
drained-to-zero case documented in `ardd-status`'s `SKILL.md`). Consumed
`feedback-prerelease-sweep-2026-07-18-50ea-ad22.md` (now `planned`). No
feature slugs targeted. Prior update, same day, `/prerelease-sweep full`
+ `/ardd-feedback` — ran
the full 8-scenario (S1–S8) prerelease dry-run in parallel background
subagents (run `2026-07-18-50ea`, ~$4–7, ~725K tokens, ~12min real
elapsed) ahead of a potential 1.0 stable cut. 16 raw findings triaged
(`dev-notes/prerelease-runs/2026-07-18-50ea/TRIAGE.md`) down to 6
accepted, 2 taste-deferred, 4 duplicates, 4 harness-artifacts (including
the pre-known, still-unresolved Agent-tool nested-worktree limitation
from S8 — not consumer-facing). Logged the 6 accepted findings as
`feedback-prerelease-sweep-2026-07-18-50ea-ad22.md`: **highest priority**
— `install.sh` defaults `Channel: stable` regardless of the source
checkout's actual tag shape, so installing from a checkout sitting on a
beta tag (the normal between-releases state — true right now) produces
a `Channel:`/`Source-Ref:` pair ArDD's own `channel-source-ref-consistency`
lint check rejects; reproduced independently in 5 of 8 scenarios. Also:
`ARDD_VERSION_BADGE=1` silently no-ops when a README already has the
static badge marker (new-feature gap); `feature-flip ... implemented`
has no completion cross-check against its bound tasks file; plus 3 minor
docs/UX findings (`task-check` colon-format error message,
`plan:` frontmatter path-vs-filename lint error clarity, epic-drained-to-zero
undocumented in `ardd-status`'s `SKILL.md`). Recommended next: `/ardd-plan`
these, fix, then regression-rerun `/prerelease-sweep S2 S3 S4 S6 S7`
before dispatching the stable-release workflow. Prior update, same day,
`/ardd-implement` — the delegated `docs-drift-fixes`
worktree run completed all 4 tasks: documented `/ardd-status --view` and
the register's `epic:` field / by-epic Feature Backlog breakdown on
`docs/reference/skills/ardd-status.md`, and routed `/ardd-plan --slate`
in both `USAGE.md`'s "How do I…?" table and `docs/guides/core-loop.md`'s
narrative — the three gaps `docs-sweep`'s first dogfood run found. No
feature slugs targeted, so no register flip. Merged clean (fast-forward)
and the worktree reaped. Prior update, same day, `/ardd-plan` — drafted, approved, and tasked
`plan-docs-drift-fixes-2026-07-18-2fbb.md`: 4 tasks/2 phases in
`tasks-docs-drift-fixes-c159.md` (`ready`) fixing the three doc gaps
`docs-sweep`'s first dogfood run found — `/ardd-status --view` +
epics/by-epic breakdown missing from `docs/reference/skills/ardd-status.md`,
and `/ardd-plan --slate` unrouted in `USAGE.md`/`docs/guides/core-loop.md`.
Consumed both feedback files (both now `planned`). No feature slugs
targeted — pure doc additions. Prior update, same day, `/ardd-implement`
— fanned out both `ready` tasks
files to parallel background worktree subagents (file-disjoint, no
dependency), both completed and merged clean:
- `docs-sweep`: all 7 tasks done — new
  `.claude/skills/docs-sweep/SKILL.md` (local-only, never installed,
  usage `/docs-sweep [--all]`), plus one-line cross-reference pointers in
  `CONTRIBUTING.md`'s Releases section and
  `.claude/skills/prerelease-sweep/SKILL.md`. T007's live dogfood run
  (scoped to skills changed since `v0.10.2`: `ardd-backlog`, `ardd-plan`,
  `ardd-refine`, `ardd-status`) found 3 genuine gaps, filed as 2 new open
  feedback files: `feedback-ardd-status-reference-page-mis-7fa5.md`
  (`/ardd-status --view` and the `epic:`/by-epic breakdown undocumented
  on that reference page) and `feedback-ardd-plan-slate-mode-unrouted-c563.md`
  (`/ardd-plan --slate` documented on its own reference page but unrouted
  in `USAGE.md`/`docs/guides/core-loop.md`) — matching the research
  report's pre-cited candidates plus one new find (`--view`).
  `ardd-backlog --assign-epics` and `ardd-refine constitution --review`
  were both already fully documented — no findings there. Feature
  `docs-sweep`: `tasked` → `implemented`.
- `dynamic-version-badge-sync`: all 6 tasks done — `install.sh` gained
  an `ARDD_VERSION_BADGE=1` opt-in (mirrors the `ARDD_CHANNEL` env-var
  pattern) writing `templates/ardd-badge-workflow.yml` (GitHub Action,
  path-filtered on `.project/ardd-version.md`) and
  `.github/badges/ardd-version.json` (seeded with the real recorded
  version) into a target, replacing the static-only badge suggestion
  with a two-badge pair when opted in; default (unset) path confirmed
  byte-for-byte unchanged. New `scripts/test-install-version-badge.sh` +
  CI job added together; caught and fixed a real POSIX-`sh` env-var
  leak bug in the test itself along the way (a var prefixed onto a
  shell *function* call persists after return, unlike an external
  command — fixed with an explicit export/unset wrapper). Feature
  `dynamic-version-badge-sync`: `tasked` → `implemented`.

Both worktrees merged clean and reaped. Prior update, same day,
`/ardd-plan docs-sweep dynamic-version-badge-sync`
— drafted, approved, and tasked as two separate plans (file-disjoint, no
dependency between them, per an explicit plan-grouping check): `docs-sweep`
(`plan-docs-sweep-2026-07-18-b6ef.md`, 7 tasks/3 phases in
`tasks-docs-sweep-e6c1.md`) adds a local-only `.claude/skills/docs-sweep/SKILL.md`
judging human-facing docs (README/USAGE.md/docs/concepts.md/reference-page
bodies) against actual SKILL.md behavior, ending in a triage table →
`/ardd-feedback`, same placement/pattern as `prerelease-sweep`; and
`dynamic-version-badge-sync` (`plan-dynamic-version-badge-sync-2026-07-18-35aa.md`,
6 tasks/3 phases in `tasks-dynamic-version-badge-sync-4553.md`) adds an
`ARDD_VERSION_BADGE=1` env-var opt-in to `install.sh` (mirrors the
existing `ARDD_CHANNEL` pattern, deliberately not a new CLI flag or
interactive prompt) writing a shields.io endpoint-badge JSON + sync
workflow into a target, replacing the current static-only badge
suggestion with a two-badge pair when opted in. Both features:
`backlogged` → `tasked`. Prior update, same day, `/ardd-feedback` — re-filed a new-capability item to
the register as `dynamic-version-badge-sync` (per the skill's mirror
check: this described something the system doesn't do yet, not a bug/UX
fix): install.sh installing a dynamic "ArDD version" README badge —
shields.io endpoint JSON + a GitHub Action watching
`.project/ardd-version.md` (or firing off `/ardd-update`'s own commit)
— replacing the current static-only badge suggestion
(`templates/badge.md`), which structurally can't carry a version since
it's copied verbatim to every target. Motivated by a consumer
(assisted-review) already hand-building this exact plumbing from
scratch. Prior update, same day, `/ardd-implement` — the delegated
`status-view-mode`
worktree run completed all 9 tasks: added `/ardd-status --view` (a
read-only side door running discovery steps 1–5 unchanged, then printing
the report and stopping — no `STATUS.md` write, no orphaned-flip
confirmation, no next-step prompt), manually verified against this
repo's own `.project/` state (T003); wired the three previously-unwired
migration regression tests (`migration-critique-to-audit`,
`migration-sync-to-tracker`, `migration-workflow-table`) into
`.github/workflows/lint.yml`, all three confirmed passing locally first;
wrote a new `tests/prerelease/scenarios/S8.md` (full tier — Agent-tool
worktree fan-out delegation, folding in the `fold-to-main.sh`
eager-background path as setup), extended `S3.md` (channel-switch flow)
and `S7.md` (`epic:` labels), and registered S8 in
`.claude/skills/prerelease-sweep/SKILL.md`'s hardcoded `full` tier list
(`docs/reference/skills/prerelease-sweep.md` doesn't exist, so no doc
edit needed there). Feature `status-view-mode`: `tasked` → `implemented`.
Merged clean and the worktree reaped. Also, after a user correction that
the prior docs-freshness research had drifted off-target (it reframed
the ask as CI/test-wiring coverage rather than human-facing docs
staying current), a fresh agent dispatch wrote a corrected report —
`research-docs-freshness-human-facing-2026-07-18.md` — recommending a
new local-only `docs-sweep` skill (mirrors `prerelease-sweep`'s
placement/pattern) judging README/USAGE.md/docs/concepts.md/guides/
reference-page bodies against actual current SKILL.md behavior, run
manually before dispatching the stable-release workflow. Cites concrete
drift already found: epics (`/ardd-status`'s by-epic breakdown,
`/ardd-tracker`'s milestone mapping) and `/ardd-plan --slate` are
currently undocumented on the site. Logged as backlog item `docs-sweep`.
Prior update, same day, `/ardd-plan status-view-mode` — approved and tasked
`plan-status-view-mode-2026-07-18-ce1f.md`: 9 tasks/3 phases in
`tasks-status-view-mode-6377.md` (`ready`) covering a read-only
`/ardd-status --view` mode (Phase 1), the CI-wiring fix for the three
unwired migration tests (Phase 2), and prerelease-sweep scenario
additions — new S8 (Agent-tool fan-out delegation), extended S3 (channel
switching), extended S7 (`epic:` labels) (Phase 3). Consumed both
feedback batches from earlier today
(`feedback-ci-migration-tests-unwired-37ee.md`,
`feedback-prerelease-sweep-scenario-gaps-95f6.md`, both now `planned`).
Feature `status-view-mode`: `backlogged` → `tasked`. Prior update, same
day, `/ardd-implement` — the delegated `constitution-trim-review-relev`
worktree run completed all 6 tasks: added
a `--review` mode to `/ardd-refine constitution` (enumerate declared
principles → ground a keep/trim judgment per principle against the
current project → batch-confirm trim candidates, mirroring `/ardd-plan`
step 3c's shape → apply confirmed trims via the skill's existing
constitution special-case handling — version bump, Sync Impact Report →
report), documented in `docs/reference/skills/ardd-refine.md` and
`USAGE.md`, and dogfood-verified live against this repo's own real
`constitution.md` (T006): all nine current principles graded **keep**,
zero trim-candidates — expected, since this constitution was recently
pruned. No write was made to the real constitution.md by the dry run.
Feature `constitution-trim-review-relev`: `tasked` → `implemented`.
Merged clean (`ort` strategy, no conflicts) and the worktree reaped. Also,
`/ardd-plan status-view-mode` drafted `plan-status-view-mode-2026-07-18-ce1f.md`
consuming both feedback batches from earlier today (`feedback-ci-migration-tests-unwired-37ee.md`,
`feedback-prerelease-sweep-scenario-gaps-95f6.md`, both now `planned`) plus
the `status-view-mode` backlog item — awaiting approval at the
checkpoint. Separately, an `/ardd-research`-shaped agent dispatch wrote
`research-docs-freshness-skill-2026-07-18.md`: recommends a new
deterministic `scripts/lint-coverage.sh` (CI-wired, catches
tests-not-wired-into-CI drift, complementary sibling to `lint-docs.sh`)
plus a new source-side `coverage-sweep` skill (judgment half, modeled on
`prerelease-sweep`) — not yet actioned into a plan. Prior update, same
day, `/ardd-backlog` — logged `status-view-mode`: a
`/ardd-status --view` read-only mode that reports a summary,
incomplete/in-flight snapshot, and recommended next step without
regenerating `STATUS.md` (mirrors `/ardd-plan --list` /
`/ardd-implement --list`'s read-only side-door pattern). Also, a review
agent weighed the `constitution-trim-review-relev` design question
(audit vs. refine) and confirmed the plan's existing choice —
`/ardd-refine --review` — is correct: single-writer ownership of
constitution.md edits and the skill-naming system both point there, not
at `/ardd-audit` (whose job is surface-only, into `audit.md`); no plan
change needed. Prior update, same day, `/ardd-implement` — the delegated
`backlog-assign-epics-automated` worktree run reported back with all 6
tasks complete: T001 (test-first) added a red case to
`scripts/test-ardd-state.sh` for `feature-field <slug> epic <value>`;
T002 added `epic` to `ardd-state.sh`'s `feature-field` valid-key case
statement; T003–T005 added the `--assign-epics` mode (enumerate →
propose thematic groupings → batched confirm → apply via `feature-field
... epic` → report) to `skills/ardd-backlog/SKILL.md`; T006 documented it
in `docs/reference/skills/ardd-backlog.md`. Feature
`backlog-assign-epics-automated`: `tasked` → `implemented`. Merged
clean (`ort` strategy, no conflicts) and the worktree reaped. Prior
update, same day, `/ardd-plan constitution-trim-review-relev` — drafted,
approved, and tasked `plan-constitution-trim-review-relev-2026-07-18-8c82.md`
(solo mode, no branch gate, on `main`): adds a `--review` mode to
`/ardd-refine constitution` that enumerates the declared principles,
grounds a keep/trim-candidate judgment for each against the current
project (never a fixed rubric), batch-confirms proposed trims (mirroring
`/ardd-plan` step 3c's shape), then reuses the skill's existing
constitution-special-case handling (version bump, Sync Impact Report) to
apply confirmed removals. 6 tasks across 3 phases in
`tasks-constitution-trim-review-relev-3a39.md` (`ready`). No artifact
changes (this is a new skill capability, not a constitution change).
Feature `constitution-trim-review-relev`: `backlogged` → `tasked`.
Meanwhile, `/ardd-implement` delegated
`tasks-backlog-assign-epics-automated-e23f.md` to a background worktree
subagent (`delegation: eager`), now at 5/6 tasks — not yet merged. Prior
update, same day, `/ardd-implement` + `/ardd-plan` — delegated
worktree run completed and merged both tasks of
`tasks-channel-source-ref-consistency-824e.md` (now `completed`): T001
(test-first) added `Channel:`/`Source-Ref:` fixtures to
`good-project`/`bad-project` (consistent vs. atelier-shaped mismatch,
`EXPECTED_BAD_FINDINGS` 37→38) plus a targeted message-quality case;
T002 added the actual check to `lint-project.sh` — reuses
`install.sh`/`ardd-update-check.sh`'s existing `sed` read style for
`.project/ardd-version.md` and `source-resolve.sh`/`next-version.sh`'s
`-beta.` prerelease-suffix recognition, reporting `Channel: stable but
Source-Ref: <value> is a prerelease tag — a prerelease tag under a
stable channel is self-contradictory` when triggered. Feature
`channel-source-ref-consistency`: `tasked` → `implemented`. Merged
fast-forward (`9ce5b1a..3447331`) and the worktree reaped. Meanwhile,
also drafted, approved, and tasked
`plan-backlog-assign-epics-automated-2026-07-18-3d8f.md` (the second
parallel-set item from today's `--slate` run, solo mode, no branch
gate, on `main`): adds a new `epic` key to `ardd-state.sh
feature-field` (Phase 1, test-first) and a new `/ardd-backlog
--assign-epics` sweep mode (Phase 2) structurally mirroring the
existing `--from-artifacts` bulk mode — walk the register for
`epic`-less entries, propose thematic groupings by judgment (never
forcing a non-clustering item into a bucket), one batched
`AskUserQuestion` confirmation, apply accepted groups via the new write
path. 6 tasks across 2 phases in
`tasks-backlog-assign-epics-automated-e23f.md` (`ready`). No artifact
changes (no new principle/workflow field — this is a new skill
capability, not a constitution change). Prior update, same day,
`/ardd-plan channel-source-ref-consistency` —
drafted, approved, and tasked
`plan-channel-source-ref-consistency-2026-07-18-461b.md` (solo mode, no
branch gate, on `main`). Picked as the top-priority item from an
`/ardd-plan --slate` run over the 4-item backlog: graded
`channel-source-ref-consistency` `high` confidence (a clear, well-
understood seam — `install.sh:371-388` writes `Channel:`/`Source-Ref:`,
`lint-project.sh` has zero existing check for their consistency,
confirmed via grep), pairwise file-disjoint from the other three
backlogged items (no bundles this round). Also graded
`backlog-assign-epics-automated` and `constitution-trim-review-relev`
`medium` (parallel-set-safe) and `codex-second-harness-support`
solo-deferred (gated on its own drafted plan's blocking live-CLI
smoke-test go/no-go, not a parallel-set candidate at this time). No
artifact changes needed (no new principle/workflow field). 2 tasks in
1 phase in `tasks-channel-source-ref-consistency-824e.md` (`ready`):
T001 (test-first) adds consistent/inconsistent
`.project/ardd-version.md` fixtures to `good-project`/`bad-project`
plus a targeted message-quality case; T002 adds the actual
`Channel:`/`Source-Ref:` consistency check to `lint-project.sh`,
reusing `source-resolve.sh`/`next-version.sh`'s existing prerelease-tag
recognition. Feature `channel-source-ref-consistency`: `backlogged` →
`planned` → `tasked`. Prior update, same day, `/ardd-update` — this
repo's own installed
`.claude/skills/ardd-scripts/` copy had gone stale (last self-installed
at commit `a656512`, predating the `feature-list.sh` manifest-gap fix
and several other recent scripts), discovered when `/ardd-backlog
--list` (not a real mode — corrected to a direct `feature-list.sh` call)
hit a missing-file error. Re-ran `install.sh` against this repo
(self-hosted, `channel=dev`); refreshed to commit `66bd323`
(today's docs-audit commit). No migrations pending, no workflow-field
backfill needed (all four already set), `.worktreeinclude`/
`.gitattributes` already correct. Prior update, same day, release ops —
pushed `main` (`a802dbc..db95bae`,
publishing the v0.10.2 fix batch as `v0.10.2-beta.1`), then ran a
targeted `/prerelease-sweep S1 S2 S3` regression check (run
`2026-07-17-db69`) specifically re-verifying S2-F001 (`ardd-init` diff
guidance) and S3-F001 (`plan_preview` gating) via live reproduction —
both confirmed genuinely fixed, no new findings, no branch-protection
snag this time. Dispatched `stable-release.yml` (`bump: patch`) —
succeeded on the first try. **`v0.10.2` is now the published stable
release**; confirmed via direct `curl` that the diff-verification
guidance is live in the real `release` branch. This closes the
phantom-completion incident end-to-end: found by the full sweep →
fixed inline with explicit diff verification per task → regression-
checked → shipped. Prior update, same day, `/ardd-implement` — ran
`tasks-v0-10-2-fixes-53cb.md`
**inline, deliberately not delegated** (given the tasks file exists
because a delegated subagent falsely claimed task completion, this run
verified each task's `git diff` in real time rather than trusting
another delegated self-report). All 7 tasks completed (now
`completed`): T001-T003 re-landed the three missing v0.10.1 edits —
`ardd-status` now handles `dev-ahead` distinctly from `behind`,
`ardd-init` step 7 warns that a `feat:` commit's message isn't proof of
its diff, `ardd-plan` step 10 actually gates the browser-preview
question on `plan_preview` — each verified via `git diff` against the
named file before being marked complete. T004 (test-first, `--no-verify`
documented in the commit body per this repo's shell-test convention,
since there's no language-level xfail marker) added a regression case
proving `tasks-flip completed` didn't check for unchecked tasks; T005
fixed `ardd-state.sh` to refuse the flip with the still-open task ID(s)
named, confirmed green. T006 added a mandatory pre-`task-check` diff
self-check to `/ardd-implement` step 7 itself — the process fix meant to
prevent this exact failure class going forward. T007 confirmed the full
test suite green and the tree clean before completion. No feature flip
— `features: []`. All work committed directly to `main` (solo mode, no
worktree). Prior update, same day, `/ardd-plan` — drafted, approved, and
tasked
`plan-v0-10-2-fixes-2026-07-17-4465.md` (solo mode, no branch gate, on
`main`). Consumed `feedback-prerelease-full-sweep-v0-10-1-e5d8.md`'s all
3 items (accepted): F001 (the phantom-completion gap — the three missing
edits actually need to land this time, each with an explicit
`git diff`-based self-check before being marked complete), F002
(`ardd-state.sh tasks-flip completed` should refuse when unchecked tasks
remain), F003 (the process root cause — `/ardd-implement` step 8 needs a
mandatory pre-`task-check` diff self-check). No unsurfaced defects, no
feature slugs targeted. 7 tasks across 4 phases in
`tasks-v0-10-2-fixes-53cb.md` (`ready`): Phase 1 (T001-T003, parallel)
re-lands the three missing v0.10.1 edits, each carrying an explicit
"verify via `git diff` before marking complete" instruction naming that
this exact task was claimed-but-unapplied once already. Phase 2 (T004,
test-first; T005) adds a real deterministic `tasks-flip` checkbox
refusal. Phase 3 (T006) tightens `/ardd-implement`'s own process so this
failure mode is caught before a commit ever claims work that wasn't
done. Phase 4 (T007) is the pre-cut verification gate; the plan's own
Phase 4 notes (push, targeted `/prerelease-sweep S1 S2 S3` regression,
`stable-release` dispatch) are release ops for after tasks complete, not
tasked directly. Prior update, same day, `/ardd-feedback` — a
`/prerelease-sweep full` run
against **v0.10.1** (run `2026-07-17-b924`, S1-S7, all completed
cleanly) found a critical issue: three tasks from the earlier
`tasks-feedback-batch-ec6e.md` run (T006, T007, T010) were marked `[x]`
complete with commits describing the intended edit, but the edits never
actually landed — independently reproduced by 4 of 7 scenarios (S2, S3,
S5, S7). **v0.10.1, already stable, ships this gap**: `ardd-status`
still doesn't handle the `dev-ahead` update-check outcome, `ardd-init`
step 7 still has no diff-verification guidance, and `plan_preview` is
fully wired everywhere except the one place (`ardd-plan` step 10) that's
supposed to consume it. Logged as
`feedback-prerelease-full-sweep-v0-10-1-e5d8.md` F001, alongside F002
(`ardd-state.sh tasks-flip completed` doesn't verify checkboxes, and
`completed`'s terminal design leaves no scripted recovery from a
wrongly-flipped file — found by S6) and F003 (the process root cause:
`/ardd-implement`'s task-completion flow has no verification step
before `task-check` marks a task done). Not yet consumed by a plan.
Everything else in the sweep was clean or non-actionable (S1/S4 clean
passes; S1-F001/S4-F001 working-as-designed/harness-only). Cost: ~649K
tokens / ~$3-10 across 7 subagents; full breakdown in
`dev-notes/prerelease-runs/2026-07-17-b924/RUN.md`. Prior update, same
day, release ops — pushed `main` (`a978ab7..a802dbc`,
publishing the `new.sh` fix as a beta), then ran a `/prerelease-sweep S1`
regression check (run `2026-07-17-cc3b`) against the real quickstart
URL. It confirmed the fix is correct on `main` but caught something more
important: `new.sh`'s public curl URL always resolves through the
`release` branch regardless of `--beta`/`--stable`, and `release` was
several commits behind — so the fix hadn't reached real users yet.
Dispatching `stable-release.yml` then failed
(`GH006: Protected branch update failed — must not contain merge
commits`): `main`'s history holds two legitimate non-fast-forward merge
commits from 2026-07-15 (sanctioned by `merge_policy: auto`), colliding
with `release`'s `required_linear_history` GitHub branch-protection rule
— a latent conflict between two of this repo's own standing decisions,
not a new bug, but one that would have silently blocked every future
stable dispatch. With explicit user permission, disabled just that one
protection flag via `gh api` (nothing else touched — force-pushes and
deletions on `release` are still blocked) and re-dispatched successfully.
**`v0.10.1` is now the published stable release**; `release` is
fast-forwarded to `main`'s tip; confirmed via a direct `curl` that the
fixed `new.sh` guard logic is live at the real public URL. Prior update,
same day, `/ardd-implement` — delegated worktree run
completed and merged all 12 tasks of `tasks-feedback-batch-ec6e.md`
(now `completed`): T001/T002 (test-first) fixed the release-blocking
`new.sh` git-init isolation bug — `new.sh:242` now compares
`git rev-parse --show-toplevel` against `$TARGET`'s realpath instead of
using `--is-inside-work-tree` (true for any nested directory, not just
a real repo root), so a target nested under an existing git-controlled
directory finally gets its own isolated repo instead of silently
inheriting the outer one's identity. T003/T004 fixed the two downstream
`install.sh` symptoms: gitignore-diagnostic misattribution (now confirms
`$TARGET` is its own repo top-level before trusting `check-ignore`) and
`.project/.lock` now gets written to `.gitignore` unconditionally
instead of only mentioned in printed text. T005 taught
`ardd-update-check.sh` to distinguish a dev-mode checkout genuinely
*behind* a release tag from one that's *ahead* with no `Source-Ref`
(new outcome token: `dev-ahead`); T006 made `/ardd-status`'s banner
treat that distinctly (never recommends `/ardd-update` when it would
regress the target). T007 added diff-verification guidance to
`/ardd-init` step 7's git-log feature-extraction heuristic. T008/T009
(test-first) added the new `plan_preview` workflow field
(`always-browser`/`always-console`/`ask`) to `lint-project.sh`'s enum
and `ardd-state.sh stamp`, mirroring `delegation`/`merge_policy`; T010
wired `/ardd-plan` step 10's browser-preview question to respect it;
T011 generalized the constitution's Governance "Exception" clause to
cover any workflow-field-enum member by reference (closing the
pre-existing gap where `delegation`/`merge_policy`/
`update_check_max_age_days` were already exempt in practice but
unnamed) — constitution PATCH-bumped 1.11.0 → 1.11.1, new SIR entry
prepended correctly (avoided the bare-`---`-inside-a-comment parsing
trap this same plan's drafting session hit and reverted earlier
today). T012 documented `plan_preview` in the `/ardd-plan` reference
doc. Full test suite confirmed passing before merge. No feature flip —
this plan consumed feedback only (`features: []`). Merged fast-forward
(`3980965..4fc55d8`) and the worktree reaped. Prior update, same day,
`/ardd-plan` — drafted, approved, and tasked
`plan-feedback-batch-2026-07-17-e977.md` (solo mode, no branch gate, on
`main`). Consumed all 3 open feedback files (5 items — all accepted):
`feedback-plan-preview-setting-63b3.md` F001 (Reconsidered — the
`/ardd-plan` browser-preview prompt becomes a configurable
`plan_preview` workflow field), `feedback-prerelease-full-sweep-62ae.md`
F001/F002 (`.project/.lock` gitignore gap; `ardd-init`'s unverified
git-log trust gap), `feedback-prerelease-smoke-sweep-849d.md` F001/F002
(`new.sh` git-init isolation bug + its `install.sh` downstream symptom;
misleading dev-mode "behind" wording) — all now `planned`. During the
Reconsidered-item negotiation, also surfaced and confirmed a related fix:
the constitution's Governance "Exception" clause named only
`workflow_mode`/`next_step_prompt` as SIR-exempt workflow fields, though
`delegation`/`merge_policy`/`update_check_max_age_days` were already
exempt in practice — generalizing that clause to cover the enum by
reference is now T011, rather than applied ad hoc during planning (an
earlier direct edit was made and then correctly reverted, since a
Reconsidered item's artifact fix belongs in the plan as a task, not
applied during `/ardd-plan` itself). No unsurfaced defects, no feature
slugs targeted (`features: []`). 12 tasks across 3 phases in
`tasks-feedback-batch-ec6e.md` (`ready`): Phase 1 (T001, test-first;
T002; T003, T004 parallel) fixes `new.sh`'s git-init guard and its two
downstream `install.sh` symptoms (gitignore misattribution, `.lock` not
gitignored). Phase 2 (T005, T006; T007 parallel) fixes
`ardd-update-check.sh`'s misleading "behind" wording for ahead-of-tag
dev-mode installs and adds diff-verification guidance to `ardd-init`
step 7. Phase 3 (T008, test-first; T009; T010 parallel; T011
`[artifacts: constitution]`; T012) adds the `plan_preview` workflow
field end-to-end (enum, `ardd-state.sh stamp`, `ardd-plan` step 10
consumption, the Governance clause fix, and docs). Open questions: exact
naming for `ardd-update-check.sh`'s new ahead-of-tag outcome token; and
whether `plan_preview: always-console` should stay silent across a
Revise loop within the same run (leaning yes). Prior update, same day,
`/ardd-feedback` — logged
`feedback-plan-preview-setting-63b3.md`, 1 Reconsidered item: the
`/ardd-plan` approval checkpoint's "view in browser?" prompt (added
`62052ae`) always asks on every run; reconsidered to a configurable
workflow field (`always-browser` / `always-console` / `ask`, default
`ask` = current behavior), analogous to `delegation`/`merge_policy`/
`next_step_prompt`. Not yet consumed by a plan. Prior update, same day,
`/ardd-backlog` — logged
`constitution-trim-review-relev`: an agent-driven review mode (e.g.
`/ardd-refine constitution --review`) that audits a project's existing
constitution principle-by-principle and proposes trimming any that
aren't relevant or load-bearing for guiding agents toward better code
quality on that project, batched for confirmation. Why: constitutions
only ever grow via `/ardd-init`'s suggestion catalog and later
`/ardd-refine` passes — nothing currently looks back and asks whether an
accumulated principle still earns its place. Prior update, same day,
`/ardd-feedback` — a `/prerelease-sweep full` run
(2026-07-17-fab5, S1-S7) completed, and its S6 result triggered a
redesign: S6 (delegated worktree execution) was replaced with a
script-layer-only scenario (`tests/prerelease/scenarios/S6.md`) that
verifies `worktree-align.sh`/merge/`worktree-reap.sh` against a
manually-created second worktree, dropping the untestable-from-sweeps
`Agent`-tool nested-worktree question — that question now has an
actionable manual recipe in the README's Coverage backlog instead
(second terminal, scratch project, real `/ardd-implement` delegate).
Feedback captured: `feedback-prerelease-full-sweep-62ae.md` (2 new
items — F001 bug, `install.sh` never actually gitignores
`.project/.lock`, only mentions it in printed text; F002 ux,
`/ardd-init` step 7 trusts `feat:` commit titles without diff
verification, risking a false "implemented" register entry on repos
with misleadingly-labeled commits). `feedback-prerelease-smoke-sweep-849d.md`
(still open) got two reconfirmation notes appended, not new items: its
F001 (`new.sh` git-init nesting bug) reproduced again plus a new
downstream symptom (`install.sh`'s gitignore-diagnostic misattribution);
its F002 (misleading "behind" wording) reproduced again on a different
dev-mode install. Full sweep found zero net-new bugs beyond those two —
S3 (`--slate` against atelier's real 12-item backlog) and S5 (solo
inline core loop) both passed clean. Cost: ~615K tokens / ~$3-9 across
the 6 background subagents (S6 ran inline in the dispatching session);
full breakdown in `dev-notes/prerelease-runs/2026-07-17-fab5/RUN.md`
(gitignored). Prior update, same day, `/ardd-backlog` — logged
`backlog-assign-epics-automated`: an automated `/ardd-backlog
--assign-epics` pass over the feature register, open feedback, and
`DEFECTS.md` that proposes `epic:` groupings for related items, batched
for confirmation. Why: `epics-grouping-in-feature-regi` added the field
and manual by-epic views, but assignment itself is still entirely
manual; conceptually the epic-dimension counterpart to `--slate`'s
footprint-based grouping. A `/prerelease-sweep full` run is in progress
concurrently (run `2026-07-17-fab5` — S1-S3, S5, S6 completed; S4 still
running); this entry was logged mid-sweep and doesn't touch any sweep
state. Prior update, same day, `/ardd-feedback` — captured the prerelease smoke
sweep's (run `2026-07-17-1d42`) 2 accepted feedback items in
`feedback-prerelease-smoke-sweep-849d.md`: F001 (bug) `new.sh`'s git-init
guard walks up the directory tree for any enclosing `.git`, silently
folding a nested target into the outer repo instead of creating its own
— a release-blocker candidate, not scratch-harness-specific; F002 (ux)
`ardd-update-check.sh`/`/ardd-status`'s "behind" wording is misleading
for a dev-mode checkout that's ahead of the latest release tag. The
third accepted finding (S7-F002 — nothing validates `ardd-version.md`'s
`Channel:`/`Source-Ref:` consistency) was re-filed as a new backlog
feature instead, `channel-source-ref-consistency` — it's a missing
capability, not a bug in existing behavior. Prior update, same day,
`/ardd-implement` — delegated worktree run completed
and merged all 9 tasks of `tasks-plan-time-defrag-slate-analysi-2c40.md`
(now `completed`): added `/ardd-plan --slate` — a read-only advisory mode
that computes an ephemeral "defrag" grouping over the open backlog
(bundles / parallel sets / solo-deferred, per the two research
prototypes' two-axis overlap+dependency model) and ends in a recommended
`/ardd-plan <slug...>` invocation, never writing a plan/tasks file or
touching the register itself. T008's end-to-end dry-run against this
repo's own real backlog (N=1 at the time — only
`codex-second-harness-support` was `backlogged`) correctly exercised the
N=1 branch. Merged fast-forward (`320f7c8..a6ca315`) and the worktree
reaped. Feature `plan-time-defrag-slate-analysi`: `tasked` →
`implemented`. Prior update, same day, a `/prerelease-sweep smoke` run
(S1, S5, S7; run `2026-07-17-1d42`, reports in `dev-notes/` — gitignored,
not committed) found one likely release-blocking bug: `new.sh`'s
git-init guard (`new.sh:240`, `git rev-parse --is-inside-work-tree`)
walks *up* the directory tree for any enclosing `.git`, so a target
nested under an existing git-controlled directory silently skips
`git init` and gets folded into the outer repo (shares its `.git`,
branch, history, remote) — not scratch-harness-specific, hits any real
user whose target sits under a monorepo/dotfiles/versioned home dir.
Also found: `ardd-update-check.sh` reports "behind" for a dev-mode
checkout that's actually ahead of the latest tag (misleading — the
suggested fix would regress it), and a pre-existing atelier-repo
`Channel`/`Source-Ref` inconsistency nothing currently detects. Triage
table at `dev-notes/prerelease-runs/2026-07-17-1d42/TRIAGE.md`; not yet
folded into `/ardd-feedback` — awaiting user go-ahead. Prior update,
same day, `/ardd-plan plan-time-defrag-slate-analysi` —
drafted, approved, and tasked
`plan-plan-time-defrag-slate-analysi-2026-07-17-1a95.md` (solo mode, no
branch gate, on `main`). Designs a codified `/ardd-plan --slate` mode,
grounded in both prototype `/ardd-research` passes' findings
(sync-tab-scroll N=1: the N≤1 degenerate branch; atelier N=12: the
two-axis file-overlap/dependency model, confidence grading, and the
register-direct-read discipline). No new deterministic script — footprint
grading is agent judgment (Principle II only mechanizes what's actually a
pure function of file state); the one mechanical sub-step
(enumerate `backlogged` items) reuses the existing
`scripts/feature-list.sh --status backlogged`, unmodified. No artifact
changes (this repo has only `constitution.md`, and the feature introduces
no new principle). 9 tasks across 4 phases in
`tasks-plan-time-defrag-slate-analysi-2c40.md` (`ready`): Phase 1
(T001–T002) adds the `--slate` argument-shape dispatch and the N=0/N=1
degenerate branch; Phase 2 (T003–T005) adds per-item confidence grading
and the two-axis pairwise relation-finding, verified against a scratch
fixture; Phase 3 (T006–T008) adds classification into bundle/parallel-
set/solo-deferred plus the `next_step_prompt` handoff, verified
end-to-end against this repo's own real 2-item backlog; Phase 4 (T009)
updates the `/ardd-plan` reference doc. No test tasks for the skill-prose
edits themselves (matches the `--list` precedent — read-only, no state
mutation to regression-test). `plan-time-defrag-slate-analysi`:
`backlogged` → `planned` → `tasked`. The plan's own draft initially
omitted the required Phase Breakdown section — caught and fixed before
tasking, re-confirmed with the user. Prior update, same day (2026-07-16),
`/ardd-implement` — delegated worktree run completed
and merged all 4 tasks of `tasks-delegation-preflight-autocommit-a977.md`
(now `completed`): T001 (audit) built a throwaway scratch repo and tested
`skills/ardd-implement/SKILL.md` step 3's pre-flight check against 3
scenarios — untracked plan file and modified tasks file both correctly
surfaced, but a `plan:` frontmatter naming a nonexistent plan file was a
real scope-miss (`git status --short` on a missing path prints nothing
and exits 0, indistinguishable from clean). T002-T003 changed the
pre-flight to auto-commit the plan/tasks file(s) in solo mode (scoped
`git add`, signed commit per this repo's `CLAUDE.md` convention,
announcing paths + short hash) and moved it ahead of the `on_default:
false` → `fold-to-main.sh` step so an uncommitted file no longer causes
a spurious fold refusal. T004 fixed the scope-miss found in T001: the
check now verifies the resolved plan file exists on disk before running
`git status`, stopping and surfacing a message (both modes) if it's
missing. No feature flip — this plan consumed feedback only
(`features: []`), a documented no-op case. Merged fast-forward
(`f3f81db..55571a3`) and the worktree reaped. Prior update, same day,
`/ardd-plan` — drafted, approved, and tasked
`plan-delegation-preflight-autocommit-2026-07-16-0ca8.md` (solo mode, no
branch gate, on `main`). Consumed the sole open feedback item
(`feedback-delegation-preflight-autocommit-06b1.md` F001 — user chose to
accept it, over declining, after the plan surfaced that the root cause
was unconfirmed; file now `planned`). No unsurfaced defects, no feature
slugs targeted, no artifact changes (pure skill-prose fix). 4 tasks
across 3 phases in `tasks-delegation-preflight-autocommit-a977.md`
(`ready`): Phase 1 (T001) manually audits the existing
`skills/ardd-implement/SKILL.md` step 3 pre-flight check's frontmatter
resolution and `git status --short` scoping against three scenarios,
since the feedback's root cause couldn't be confirmed and the check may
have a latent scope-miss independent of the UX question. Phase 2 (T002;
T003, parallel) changes the check to auto-commit the plan/tasks file(s)
in solo mode instead of asking, and reorders it ahead of the
`on_default: false` → `fold-to-main.sh` dirty-tree check so an
uncommitted file doesn't cause a spurious fold refusal. Phase 3 (T004)
is conditional — fixes any mechanics gap Phase 1 finds, or is skipped
with a recorded no-defect outcome. Open question: whether the
auto-commit message should embed the tasks file's slug for
traceability (leaning yes). Prior update, same day, `/ardd-feedback` —
logged
`feedback-delegation-preflight-autocommit-06b1.md`, 1 Reconsidered item:
the delegation pre-flight check added for
`feedback-uncommitted-plan-tasks-delegat-a3ff.md` (`skills/ardd-implement/SKILL.md`
step 3) currently offers to commit an uncommitted plan/tasks file or
blocks delegation — user reports this recurs often enough ("this
happens often") that the ask-first behavior should be reconsidered to
an automatic commit in solo mode, since it's almost always the obvious
right move (the files are what the immediately-prior `/ardd-plan` run
just wrote). Not yet consumed by a plan. Prior update, same day,
`/ardd-implement` — delegated worktree run completed
and merged all 5 tasks of `tasks-install-manifest-gap-fix-6cfb.md` (now
`completed`): T001/T002 (test-first, one commit — T001's assertion is
expected-red and the pre-commit hook runs the full `test-*.sh` suite)
added a `feature-list.sh` executable check to
`test-install-worktreeinclude.sh`'s Case 1b block, confirmed it failed
against the real bug, then added the missing `cp`/`chmod +x`/`echo`
lines to `install.sh` (the script was absent from all three, not just
the `cp` list as first suspected). T003/T004 added
`scripts/test-install-manifest-complete.sh` — diffs scripts referenced
by `skills/*/SKILL.md` and `install.sh`'s own `chmod +x` list against
its actual `cp` manifest; the subagent caught and fixed a real bug in
its own new script during development (a newline- vs space-separated
matching mismatch that made every script falsely report missing) before
committing. T005 added the matching CI job. Merged fast-forward
(`83a0da2..209b339`, no signing needed) and the worktree reaped. No
feature flip — this plan consumed feedback only (`features: []`), a
documented no-op case. Both feedback items
(`feedback-install-manifest-gap-b773.md` F001/F002) now fully delivered.
Prior update, same day, `/ardd-plan` — drafted, approved, and tasked
`plan-install-manifest-gap-fix-2026-07-15-20fb.md` (solo mode, no branch
gate, on `main`). Consumed both open items of
`feedback-install-manifest-gap-b773.md` (F001 bug, F002 UX — both
incorporated; file now `planned`). No unsurfaced defects, no feature
slugs targeted, no artifact changes (pure packaging-script fix). 5 tasks
across 2 phases in `tasks-install-manifest-gap-fix-6cfb.md` (`ready`):
Phase 1 (T001, test-first; T002) adds the missing `cp`/`chmod +x` line
for `scripts/feature-list.sh` to `install.sh`, proven by extending
`test-install-worktreeinclude.sh`'s existing Case 1b
installed-and-executable pattern. Phase 2 (T003, test-first; T004;
T005) adds `scripts/test-install-manifest-complete.sh` — a new
packaging-manifest regression check diffing skill-referenced/
`chmod`-listed scripts against `install.sh`'s `cp` manifest, so this
class of gap fails CI mechanically going forward — plus its CI job.
Open question: whether the same manifest-completeness check should
extend to `templates/*.md`/artifact-template copies too; left out of
scope for now (the `<name>.sh` grep pattern doesn't generalize cleanly
to those paths without more design). Prior update, same day,
`/ardd-feedback` — logged
`feedback-install-manifest-gap-b773.md`, 2 items (1 bug, 1 UX) discovered
by manual inspection of an installed project: `scripts/feature-list.sh`
(added for `list-mode-for-plan-and-impleme`/beta.8 and extended for
`epics-grouping-in-feature-regi`/beta.9) has no `cp` line in
`install.sh`'s explicit per-file `ardd-scripts` manifest — confirmed via
`grep` and direct inspection of `install.sh:169-184` — so it never
reaches an installed target. Impact: `/ardd-plan --list`, `--epic`
filtering, and any other `feature-list.sh` consumer are dead outside
this self-hosted repo; the rest of epic grouping (the `epic:` field,
`lint-project.sh` validation, `/ardd-status`'s by-epic breakdown,
`/ardd-tracker`'s milestone assignment) is unaffected since those live
in already-installed files. F002 flags the missing packaging-manifest
test that would catch this class of gap mechanically. Not yet consumed
by a plan. Prior update, same day, `/ardd-implement` — delegated worktree run completed
and merged all 6 tasks of `tasks-epics-grouping-in-feature-regi-42f2.md`
(now `completed`): T001/T002 (test-first) added `epic` emptiness
validation to `lint-project.sh`'s feature-register loop (free-text
pattern, not the numeric `gh_issue` check), plus fixtures on both sides
(bad-project empty-`epic` case, good-project non-empty `epic:
platform-widgets`). T003/T004 (test-first) extended `feature-list.sh`:
rewrote its arg parsing into a loop to support `--epic <slug>` alongside
`--status`/`--all`, and added `epic` as a fifth tab-separated output
column. T005 added an optional "by epic" breakdown to `/ardd-status`'s
Feature Backlog section (omitted when no feature has `epic` set — the
case right now, so it stays invisible in this very report). T006 added
one-directional GitHub-milestone push/assignment to `/ardd-tracker`
(idempotent creation, register → tracker only, pull never reads a
milestone back). T005/T006 had no test tasks (Principle V
documentation-only exception, confirmed before relying on it). Merged
fast-forward (`6b269e3..1750e8c`, no signing needed) and the worktree
reaped. Feature `epics-grouping-in-feature-regi` flipped `tasked` →
`implemented` (rode the branch). Prior update, same day, `/ardd-plan
epics-grouping-in-feature-regi` —
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
| constitution.md | stable ✅ (v1.12.0; `delegation: eager`, `merge_policy: auto`) | — |

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

1 open — `feedback-sweep-coverage-expansion-3452.md` (6 UX items:
prerelease-sweep scenario-brief extensions from the coverage audit —
badge→S1, Work Queue→S8, bare-plan picker→S5, `--view` +
`constitution --review`→S7, plus the graduate-to-brief rule). Will be
picked up by the next `/ardd-plan`; its F001 deliberately waits for the
in-flight badge fix branch to merge first. Delivered earlier today:
`feedback-dynamic-badge-discoverability-a123.md` (3 bugs, 2 UX,
1 Reconsidered) is now `planned`, consumed by
`plan-dynamic-badge-discoverability-2026-07-19-23cf.md` — see the
`_Updated` note above. All earlier batches
delivered — `feedback-prerelease-sweep-2026-07-18-50ea-ad22.md` (the 6
accepted prerelease-sweep findings) is now `planned`, consumed by
`plan-prerelease-sweep-fixes-2026-07-18-d341.md` — see the `_Updated`
note above. All other batches delivered, including `feedback-ardd-status-reference-page-mis-7fa5.md` and
`feedback-ardd-plan-slate-mode-unrouted-c563.md` (filed by `docs-sweep`'s
first live dogfood run, consumed by
`plan-docs-drift-fixes-2026-07-18-2fbb.md`),
`feedback-ci-migration-tests-unwired-37ee.md` and
`feedback-prerelease-sweep-scenario-gaps-95f6.md` (both now `planned`,
consumed by `plan-status-view-mode-2026-07-18-ce1f.md` — see the
`_Updated` note above); earlier ones include
`feedback-prerelease-full-sweep-v0-10-1-e5d8.md` (now `planned`,
consumed by `plan-v0-10-2-fixes-2026-07-17-4465.md` — see the
`_Updated` note above; `feedback-prerelease-smoke-sweep-849d.md`,
`feedback-prerelease-full-sweep-62ae.md`,
`feedback-plan-preview-setting-63b3.md` — all `planned`, consumed by
`plan-feedback-batch-2026-07-17-e977.md`;
`delegation-preflight-autocommit-06b1`, `install-manifest-gap-b773`,
`artifact-register-bridge-116a`, `findings-0344`, `redrive-695b`).

## Recent Releases

**v0.10.2 (2026-07-18)** — stable cut fixing the phantom-completion gap
`v0.10.1` unknowingly shipped: `ardd-status`'s `dev-ahead` handling,
`ardd-init`'s diff-verification guidance, and `ardd-plan`'s
`plan_preview` gating are now genuinely landed (all three were
previously marked complete without the edits actually applying — see
`_Updated` note) — plus a real `tasks-flip completed` checkbox
verification and a process fix to `/ardd-implement` itself to catch
this failure class going forward. v0.10.1 (2026-07-17) — stable cut
carrying the `new.sh` git-init isolation fix. First dispatch after
`release`'s `required_linear_history` protection was relaxed — future
dispatches no longer need that workaround, the flag is off. v0.9.1
(2026-07-13) — first fully-automatic two-channel cycle. v0.9.0
(2026-07-12) — first GitHub release. Full history: GitHub Releases and
`docs/decisions/0006`/`0007`.

## Feature Backlog

1 backlogged · 29 implemented · 1 retired — see
`.project/features/`. No feature currently carries an `epic` value, so
no "by epic" breakdown to show yet.
Backlogged:
- `codex-second-harness-support` — single-source Codex CLI support via
  `install.sh --harness codex`; spec = the accepted Codex-harness research
  report plus the de-risking spike (both GO). Still `backlogged`: a plan
  was drafted (`plan-codex-second-harness-support-2026-07-15-f837.md`,
  `status: draft`) but stopped at the approval checkpoint, un-tasked —
  resume with `/ardd-plan --from plan-codex-second-harness-support-2026-07-15-f837.md`.
  Per the `--slate` run: solo-deferred, not a parallel-set candidate,
  gated on its own Phase 1 go/no-go.
Target a backlogged slug with `/ardd-plan <slug>`.
Newest implemented: `work-queue-parallel-safety` and
`rejected-feature-status` — see the `_Updated` notes above.

## Audit

`.project/audit.md`: 1 open suggestion (two-channel release paragraph →
decision-record pointer) + 1 open risk (smoke key unprovisioned, now
documented as a deliberate standing state). 2 suggestions resolved this
pass (new.sh tty narrative → decision record, v1.8.1; Governance
workflow-field exemption, v1.8.2).

## Work Queue

- `tasks-dynamic-badge-discoverability-6887.md` — plan
  `plan-dynamic-badge-discoverability-2026-07-19-23cf.md`, features:
  none (`features: []`):
  - vs in-flight worktree copy: **claimed by in-flight worktree** — the
    same tasks file is `ready` here and `in-progress` (3/4) in the
    delegated worktree; never start a second run against it.

## In Flight

- Worktree `.claude/worktrees/agent-a8f831407115021ef` (branch
  `worktree-agent-a8f831407115021ef`) —
  `tasks-dynamic-badge-discoverability-6887.md` in-progress, 3/4. The
  delegated badge-fix run; merges eagerly on completion
  (`merge_policy: auto`), then reap. `main` is ahead of `origin/main` (unpushed commits
since the last push).

## Recommended Next Step

Wait for the in-flight `dynamic-badge-discoverability` worktree run
(3/4) to report back; on merge, run `/ardd-plan
feedback-sweep-coverage-expansion-3452.md` to consume the sweep
coverage feedback (its F001 badge brief depends on the merged fix).
Other standing options: v1.0.1 is out and the sweep loop is closed;
update the consumer repos (`/ardd-update` in atelier etc. now resolves
the fixed stable); pick up the three taste-deferred UX notes from
runs 51a7/e33f if any start to grate; or plan the remaining backlog
(`codex-second-harness-support`) and the off-target research file
(`research-docs-freshness-skill-2026-07-18.md`, the CI/coverage-wiring
framing) that's superseded in spirit but left on disk — not consumed by
any plan. `codex-second-harness-support` is drafted-but-untasked:
`/ardd-plan --from plan-codex-second-harness-support-2026-07-15-f837.md`
(Phase 1 is a blocking live skill-to-skill-chaining smoke test on a real
Codex CLI — the true final go/no-go — before Phases 2–5's install-time
substitution work proceeds). Standing options otherwise unchanged: the
new `/prerelease-sweep smoke|full|S<n>` exercise (once reviewed and
committed); dispatch the stable release workflow when consumers should
get the accumulated `main` work; resolve the remaining
`.project/audit.md` suggestion; or `/ardd-defects` to re-verify against
the docs-site and skill-prose surfaces.
