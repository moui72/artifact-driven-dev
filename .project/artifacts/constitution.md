<!--
SYNC IMPACT REPORT
==================
Version change: 1.12.1 → 1.13.0 (MINOR — new standing decision appended to
the Multi-harness install section.)

Rationale: `/ardd-plan multi-harness-install-metadata` (2026-07-21), from
the inbox-captured dual-install observation: `.project/ardd-version.md`
and the reviewer guide are single shared install-owned files, so
whichever harness install runs last owns the recorded harness identity —
dual Claude+Codex installs work mechanically but the metadata
misrepresents the installed set. New standing decision: shared
install-owned `.project/` files must represent the full installed
harness set (preserve-on-reinstall semantics, never last-writer-wins);
one harness's install/update never removes or misrepresents the other;
per-harness gitignore/.worktreeinclude guidance stays bounded per
harness root (Principle III already covers the pattern — no principle
change). Modified sections: Multi-harness install (new closing
paragraph). Footer version/date updated.

Previous report (1.12.0 → 1.12.1):
Version change: 1.12.0 → 1.12.1 (PATCH — wording clarification only; no
principle or standing-decision change.)

Rationale: `/ardd-plan dot-project-reviewer-guide next-step-prompt-auto`
(2026-07-20). The `next_step_prompt` workflow field gains a third enum
value, `auto` (schema-of-record: `scripts/lint-project.sh`, widened in
the implementing commit — per the Governance Exception, the field's
values are not constitution content and need no entry here). The only
constitution prose describing the field's behavior is Multi-harness
substitution item 4, which covered only the prompt (`true`) degradation;
clarified that `auto` (auto-run, no prompt primitive needed) carries
over to Codex unchanged.

Modified sections: Multi-harness install, substitution item 4. Footer
version updated.

Previous SIR (1.11.1 → 1.12.0) follows below, preserved for history.
-->

<!--
SYNC IMPACT REPORT
==================
Version change: 1.11.1 → 1.12.0 (MINOR — schema-widening: two new
terminal status values on the feature register's status enum.)

Rationale: `/ardd-plan rejected-feature-status` (2026-07-19), extended
after a design review to cover the second case its own `Why:` line
flagged. The feature register's per-file schema (Quality Standards,
"Feature register format") gains two sibling terminal states:
`rejected` — a `backlogged` or `planned` idea the team decides not to
pursue and that never gets built — and `subsumed` — an entry whose
scope ended up shipping under a *different* feature/plan entry (not
independently built, not removed). Both answer "does this capability
exist in the shipped system?" differently from every other status
(rejected: no, never; subsumed: yes, credited elsewhere), which is why
they're separate enum values rather than one combined status or a body
note — this repo's own norm already treats ship-state distinctions as
status-grade (`retired` stays its own status rather than a note on
`implemented`). Named `subsumed`, not `superseded`, to avoid colliding
with the existing plan-level `superseded` (a newer plan replacing an
older *unapproved* one for the *same* feature — a same-document
one-for-one replacement, a different shape from a scope absorbed into
an already-ahead, different feature's work). Purely additive (two new
enum values; no existing value's meaning changes), matching this repo's
own semver policy's MINOR case for schema-widening changes — same
precedent as the `epic` field addition (1.10.0 → 1.11.0).

Modified sections: Quality Standards ("Feature register format" entry —
`rejected` and `subsumed` added to the status enum with one-sentence
definitions distinguishing both from `retired` and from each other; a
`subsumed` entry is expected to record the absorbing plan/feature).
Footer version updated.

Previous SIR (1.11.0 → 1.11.1) follows below, preserved for history.
-->

<!--
SYNC IMPACT REPORT
==================
Version change: 1.11.0 → 1.11.1 (PATCH — wording/scope clarification only;
no principle or standing-decision change.)

Rationale: `/ardd-plan feedback-batch` T011 (2026-07-17), closing a gap
`/ardd-plan feedback-batch` itself confirmed: the Governance "Exception"
paragraph named only `workflow_mode` and `next_step_prompt` by name, but
`delegation`, `merge_policy`, and `update_check_max_age_days` were already
exempt from the Sync Impact Report requirement in practice (each is stamped
via `ardd-state.sh stamp`, same as the two named fields) — they were simply
omitted from the list. The new `plan_preview` field (T009, same batch) would
have hit the identical gap on day one. Generalized the Exception to cover
any field in `scripts/lint-project.sh`'s workflow-field enum by reference,
instead of naming fields individually and drifting again the next time one
is added.

Modified sections: Governance (Exception paragraph reworded to reference
`scripts/lint-project.sh`'s enum instead of naming two fields). Footer
version updated.

==================

Previous SIR (1.10.0 → 1.11.0) follows below, preserved for history.
-->

<!--
SYNC IMPACT REPORT
==================
Version change: 1.10.0 → 1.11.0 (MINOR — schema-widening: new optional
feature-register field.)

Rationale: `/ardd-plan epics-grouping-in-feature-regi` (2026-07-15). The
feature register's per-file schema (Quality Standards, "Feature register
format") gains an optional `epic` field — a free-text slug grouping
related features for release-cadence-sized bundling. Purely additive
(a new optional field, matching this repo's own semver policy's MINOR
case for schema-widening changes); no existing field, enum, or required
key changes meaning. Distinct from the separate, ephemeral "defrag"
plan-time footprint-analysis idea still in the backlog — `epic` is
declared and durable register state, defrag is computed and never
stored.

Modified sections: Quality Standards ("Feature register format" entry —
`epic` added to the optional-fields list). Footer version updated.

Previous SIR (1.9.0 → 1.10.0) follows below, preserved for history.
-->

<!--
SYNC IMPACT REPORT
==================
Version change: 1.9.0 → 1.10.0 (MINOR — named scope reversal.)

Rationale: `/ardd-plan codex-second-harness-support` (2026-07-15), following
the accepted recommendation in
`research-codex-cli-second-harness-2026-07-15-2d3d.md` and the de-risking
spike `research-codex-spike-exact-name-invocat-2026-07-15-2423.md` (both
GO). Project Scope & Intent previously defined ArDD as "a Claude Code skill
pack" — a second harness (OpenAI Codex CLI) materially expands that scope,
so this is a named reversal per that section's own text, not a silent
drift. Codex's adoption of the identical `SKILL.md` format means the port
is single-source (Principle I intact): install-time substitution of five
localized Claude-specific clauses, no forked prose tree. Codex v1 is
deliberately degraded: inline-only implementation (no worktree
delegation/fan-out), plain-text prompts instead of `AskUserQuestion`, no
lint-on-write hook. A live skill-to-skill-chaining smoke test is the
mandatory first implementation task and remains the true final go/no-go.

Modified sections: Project Scope & Intent (new "Multi-harness install"
subsection). Footer version updated.

Previous SIR (1.8.2 → 1.9.0) follows below, preserved for history.
-->

<!--
SYNC IMPACT REPORT
==================
Version change: 1.8.2 → 1.9.0 (MINOR — new principle added.)

Rationale: /ardd-feedback item `feedback-next-step-prompt-terminology-6ce3.md`
(UX, 2026-07-14): next-step-prompt and other agent-facing prose can leave
"you"/"I" ambiguous between the human operator and the agent executing the
skill. Added Core Principle IX requiring explicit actor language ("the
user"/"the human"/"the controller" vs. "the agent"/"Claude"/"the system")
in new and edited agent-facing prose going forward — not a mandate to
sweep existing skill files in one pass.

Modified sections: Core Principles (new Principle IX, after VIII). Footer
version updated.

Previous SIR (1.8.1 → 1.8.2) follows below, preserved for history.
-->

<!--
SYNC IMPACT REPORT
==================
Version change: 1.8.1 → 1.8.2 (PATCH — clarifies an exemption that was
already true in practice (CLAUDE.md already documented it); no principle,
standing decision, or rule changes meaning.)

Rationale: ardd-audit finding, 2026-07-14. Governance stated amendments
always require a Sync Impact Report and version bump, with no exception,
while CLAUDE.md separately documented that `workflow_mode` and
`next_step_prompt` are stamped via `ardd-state.sh` and exempt from that
process. Since this constitution states its own supremacy ("supersedes
all other practices"), someone amending from this file alone would have
concluded a `next_step_prompt` flip needs a SIR. Added the exemption
directly to Governance.

Modified sections: Governance (new Exception paragraph after the
numbered amendment requirements). Footer version updated.

Previous SIR (1.8.0 → 1.8.1) follows below, preserved for history.
-->

<!--
SYNC IMPACT REPORT (1.8.0 → 1.8.1)
==================
Version change: 1.8.0 → 1.8.1 (PATCH — wording only: no principle,
standing decision, or rule changes meaning.)

Rationale: ardd-audit finding, 2026-07-14. The new.sh /dev/tty
interactivity narrative in Project Scope & Intent (the v1.2.3 unsound-
inference story, the v1.2.4 regression, the safe-default vs --kickoff
case analysis) had grown to four paragraphs and was duplicated in full in
CLAUDE.md, risking drift between the two on the next revision. Extracted
to a new decision record, docs/decisions/0008-new-sh-tty-interactivity.md
(source-repo history only, never installed), leaving only the two
bounding rules (refuses-rather-than-asks;
never-blocks-on-a-question-it-cannot-ask) and a pointer here.

Modified sections: Project Scope & Intent (new.sh interactivity
paragraphs condensed from four to one, pointing to the new decision
record). Footer version updated.

Previous SIR (1.7.0 → 1.8.0) follows below, preserved for history.
-->

<!--
SYNC IMPACT REPORT (1.7.0 → 1.8.0)
==================
Version change: 1.7.0 → 1.8.0 (MINOR — materially expands the
release-channel standing decision to two channels and extends the
pack-semver policy with prerelease semantics; no principle is removed or
redefined.)

Rationale: plan-git-ops-channels-2026-07-12-e77e (2026-07-12), design
vetted in research-two-channel-git-ops-2026-07-12-450d.md. Hours after
`v0.9.0` shipped under the one-channel model, its friction surfaced:
consumers had no way to track fresh work without the maintainer cutting a
release by hand, and stable publishing depended on one configured local
machine (validations + signing key). The two-channel design fixes both:
pushing `main` publishes a beta prerelease automatically (CI, gated on the
suite), and the stable release relocates to a dispatched GitHub workflow —
the deliberate act survives as a button click that works from anywhere.

This amendment knowingly reverses three recorded decisions (all named in
the research doc's Findings):
1. The v1.5.0 release-channel decision's "merging to `main` alone no
   longer publishes" — pushing `main` now publishes *beta*; only stable
   stays deliberate (partial reversal, same spirit for stable).
2. The pre-release-ratchets plan's Out-of-scope "no tip-of-main channel
   (Principle VI — add one only if real evidence demands it)" — the beta
   channel is that channel, formalized; the demanding evidence is the
   channel request arriving hours after v0.9.0.
3. `release.sh` as *the* publish path (T001 of remote-install-source) —
   its validate-then-tag role moves to CI gating plus the workflows;
   the local script is retired (Principle VII).

Modified sections: Project Scope & Intent (release-channel standing
decision rewritten for two channels: beta-on-push, dispatched stable via
ff-merge to the `release` branch — the stable pointer AND the stable
raw-URL base for `new.sh` acquisition — with GitHub-API-created tags;
consumer channels stable/beta/dev-mode). Release-versioning paragraph
(prerelease `vX.Y.Z-beta.N` semantics appended: betas make no
compatibility promises). Footer version updated.

Previous SIR (1.6.0 → 1.7.0) is in git history at this file's prior
revision.
-->

---
name: constitution
status: stable
last_updated: 2026-07-21

next_step_prompt: true
delegation: eager
merge_policy: auto
---

# artifact-driven-dev Constitution

## Project Scope & Intent

artifact-driven-dev (ArDD) is a skill pack — primarily for Claude Code, and,
as of 2026-07-15, also installable in a degraded v1 form to OpenAI Codex CLI
(see "Multi-harness install" below): markdown-defined slash commands
(`skills/*/SKILL.md`) installed into other projects via `install.sh`, plus a
small number of POSIX shell scripts for the parts of the system that must be
deterministic rather than left to LLM judgment.
There is no runtime application, database, or user interface belonging to
ArDD itself — the product is prose instructions an LLM executes in a target
project, plus the install/lint tooling that supports them. `datamodel.md`,
`infrastructure.md`, and `ui.md` accordingly do not exist for this project
and are not expected to: none of the concerns they own apply here.

ArDD is narrower in scope than Spec Kit, not lighter in absolute terms: it
assumes the user arrives with architectural clarity and needs a system to
capture, cross-check, and execute against decisions already made, rather
than a framework that discovers those decisions through structured
elicitation. See `README.md`'s "When artifacts earn their keep" for when
that overhead is actually worth it — for this repository specifically, it's
worth it because there is no external target codebase to serve as an
implicit spec for what ArDD itself should do next; the skills, scripts, and
docs *are* the product, and this constitution is the explicit source of
truth for the principles they follow.

The pack may be *acquired* through more than one route — cloning this
repository, or the `new.sh` curl-to-sh bootstrap (for a brand-new
project, or an already-populated one in its existing-project mode) — but
**`install.sh` is the only real install/upgrade entry point** (standing
decision, 2026-07-09; the `npx skills add` channel and its `/ardd-setup`
bridge were removed 2026-07-11). Every route converges *directly* on
`install.sh`: it alone runs migrations, creates the non-skill reference
directories, records `ardd-version.md`, and maintains `.worktreeinclude`.
There is no partial-delivery channel and no bridge skill — a route either
*is* a clone or *invokes* `install.sh` itself, and never reimplements any
part of it.

The former primary-stays-on-main standing decision (v1.4.0–v1.6.0) is
**retired** (2026-07-12): it existed because consumers once read this live
checkout directly, so a checked-out feature branch was silently "released"
to every consumer that updated. The release-channel decision below removed
that hazard at the root — consumers resolve tagged releases via
`~/.ardd/source`, and as of `v0.9.0` every known consumer has been
repointed; no one reads this checkout live. This repo's primary worktree
may now hold a feature branch like any ordinary project. The full arc
(hazard → mandate → root-cause fix → retirement) is recorded in
`docs/decisions/0006-release-channel.md`.

**Two release channels: beta on push, stable by dispatch** (standing
decision, 2026-07-12; rewrites the one-channel decision of earlier the
same day — reversal arc in the v1.8.0 Sync Impact Report and
`research-two-channel-git-ops-2026-07-12-450d.md`). Pushing `main` **is
the beta-publish act**: a CI workflow (`.github/workflows/
beta-release.yml`), gated on the full lint/test workflow passing for the
same commit, tags the push `vX.Y.Z-beta.N` (semver-canonical prerelease
format) and publishes a GitHub *prerelease*. The **deliberate act for
stable** relocates from a local command to a dispatched workflow
(`.github/workflows/stable-release.yml`): it verifies CI green on the
`main` tip, fast-forward-merges `main` into the **`release` branch** —
which is both the stable pointer and the stable raw-URL base for `new.sh`
acquisition (`raw.githubusercontent.com/…/release/new.sh`; `main` serves
the beta/dev base) — and tags via the GitHub API (`gh release create`
creates the tag server-side, shown Verified via GitHub's web-flow key; no
CI signing keys to manage). All next-version computation lives in one
source-side script, `scripts/next-version.sh`, under
`versionsort.suffix=-beta.` ordering (the empirically-pinned trap: default
version sort places `v0.9.1-beta.2` *after* `v0.9.1`). Consumers target a
recorded **channel**: `stable` (default — tagged full releases, today's
behavior, resolved via `~/.ardd/source` exactly as before), `beta`
(opt-in per consumer — latest tag including prereleases, where a newer
stable still beats an older beta), or dev-mode (`--source <path>` /
`$ARDD_SOURCE`, or a `Source-Path` recording a live checkout —
maintainer-only, warned as such, unchanged). Resolution never blocks
offline: when the network is unavailable, fall back to the existing
`~/.ardd/source` state with a warning — the same never-hang discipline
`new.sh` already follows. `install.sh` remains the only install/upgrade
entry point; this decision changes which checkout and ref the resolution
layer hands it, not the entry point itself. Dispatching the stable
workflow is thereby the deliberate act that publishes skill changes to
stable consumers — the v1.5.0 spirit, relocated from a machine to a
button; pushing `main` publishes only to the opt-in beta channel.

Release versions follow semver with skill-pack semantics: **MAJOR** for a
removed or renamed slash command, or a breaking change to a script's
output contract or a `.project/` schema (an existing key or field changes
meaning or disappears); **MINOR** for an additive skill, knob, or
schema-widening change (a new enum value, a new optional field, a new
output key); **PATCH** for prose and fixes that change no interface.
**Prerelease tags** (`vX.Y.Z-beta.N`, published automatically on push to
`main`) carry the version the *next* stable release will claim, but make
**no compatibility promises** of their own: a beta may change or revert
anything relative to a prior beta of the same version, and only the
stable `vX.Y.Z` release binds the semver contract above. Beta consumers
accept that by opting in.
**Migrations are append-only**: a `migrations/*.sh` file, once released,
is never renumbered, renamed, or deleted — the target's `.ardd-applied`
keys by filename, so a rename re-runs the migration on every consumer and
a deletion silently orphans its record; any release must be able to
upgrade any older install by replaying the migrations it hasn't recorded.
`.ardd-applied` itself **should be committed** in the target project:
left uncommitted, every teammate's first `/ardd-update` re-runs every
migration from scratch.

`new.sh` converges by the most direct route available: it resolves a
source checkout — cloning `~/.ardd/source`, the one checkout it owns, if
that is absent; a `--source` or `$ARDD_SOURCE` path that doesn't exist is
a hard error, never a clone target — and then *invokes* `install.sh` from
it, so it needs no bridge skill and must never grow one. This bridge-free
discipline binds both its modes: the brand-new-project path and the
existing-project path differ only in whether the target directory is
expected to be empty (new) or already populated (existing) — never in
whether they reach `install.sh` directly. It
is **source-side** under Principle IV — fetched and executed outside any
checkout, never shipped into a target project by `install.sh`. That it runs with no checkout of its own is a novel
execution shape, not a third install target: the source/target split
classifies a file by *where it runs and what it governs*, and `new.sh`
governs acquisition of the source.

Two rules bound `new.sh`'s interactivity, and neither is "never prompt":
it **refuses rather than asks** wherever writing into a directory it
doesn't own is at stake (a non-empty target, or a `--source` that isn't
an ArDD checkout), and it **never blocks on a question it cannot ask**
(the Claude Code handoff is offered on `/dev/tty`, with `--kickoff` and
`--no-kickoff` to answer in advance; with no flag and no readable
`/dev/tty` it takes the safe default — declines the launch, prints the
command to start the session by hand, exits 0 — rather than misreporting
a successful install as failed). Full narrative — the unsound v1.2.3
"never prompt" inference, the v1.2.4 regression, and the implementation
traps — in `docs/decisions/0008-new-sh-tty-interactivity.md`.

**Multi-harness install (`install.sh --harness codex`).** ArDD's primary
target remains Claude Code, but as of 2026-07-15 (feature
`codex-second-harness-support`) the pack also installs, in a deliberately
degraded v1 form, to **OpenAI Codex CLI** — the first second-harness port,
made viable because Codex adopted the identical `SKILL.md` format Claude
Code uses. This is a single-source port, never a forked prose tree
(Principle I): the same `skills/*/SKILL.md` files serve both harnesses,
with a fixed, small set of install-time substitutions applied by one
transformer step in `install.sh`, not scattered harness conditionals
through skill prose:

1. `AskUserQuestion` structured prompts → plain-text numbered questions.
2. `Agent` `isolation:"worktree"` delegation/fan-out → dropped; Codex v1 is
   **inline-only** (no background delegation, no multi-select fan-out) —
   Codex exposes worktrees and subagents but no structured
   launch-and-report-back primitive equivalent to Claude Code's `Agent`
   tool.
3. `.worktreeinclude` gitignored-file copy → not carried over pending
   verification of Codex's own worktree file-copy behavior.
4. `next_step_prompt`'s one-keypress offer (`true`) → a plain-text
   next-step suggestion. The `auto` value carries over unchanged — it
   auto-runs a concrete runnable recommendation and needs no prompt
   primitive on either harness.
5. The `/ardd-X` invocation sigil → rewritten to `$ardd-X` (Codex's
   exact-name invocation channel; its `/`-commands are a fixed built-in
   set that cannot be extended, confirmed against Codex issue #11817).
   This substitution applies to every user-facing invocation hint and
   every terminal-handoff line ("run `/ardd-status`" → "run
   `$ardd-status`").

Claude-only tool references (1–2 above) must be **stripped or degraded**
for the Codex install, never emitted-and-ignored — a Codex agent handed a
Claude tool call it can't honor is a broken behavior, not graceful
degradation. Skill-to-skill chaining (a skill's prose invoking another
skill by name — the mechanism every terminal handoff in this pack depends
on) is present on Codex and same-class as Claude Code's, but its
reliability is unproven by documentation alone; a live throwaway-install
smoke test of chaining is the mandatory first implementation task for this
feature and remains the final go/no-go independent of this scope change.
If a third harness ever materializes, *that* concrete case — not this
one — is what would justify generalizing the five-substitution list into
a real per-harness adapter system (Principle VI, YAGNI); building one now,
at two harnesses, would be the premature abstraction that principle
forbids.

**Dual installs are first-class (2026-07-21, feature
`multi-harness-install-metadata`).** Both harness trees
(`.claude/skills/ardd-*/`, `.agents/skills/ardd-*/`) may coexist in one
target project, installed in either order, and the shared install-owned
`.project/` files (`ardd-version.md`, the reviewer guide) must represent
the full installed harness *set* — preserve-on-reinstall semantics,
never last-writer-wins. One harness's install or update never removes,
overwrites the identity of, or misrepresents the other; a harness-aware
update preserves the invoking harness (already standing) *and* leaves
the sibling harness's recorded metadata intact. Gitignore and
`.worktreeinclude` guidance names each installed harness's bounded
`ardd-*` root only — never blanket `.claude/`, `.agents/`, or their
`skills/` parents (Principle III applies per harness root). Claude-only
installs remain backward-compatible (absent harness metadata = claude);
Codex-only installs record enough for update/check/status flows.
Deterministic tests must cover Claude-only, Codex-only, and dual-install
in both orders.

Two install targets exist and must not be conflated: files/scripts that
govern this source repository only (e.g. `scripts/lint-docs.sh`,
`tests/fixtures/`, `scripts/hook-lint-on-write.sh` + `.claude/settings.json`),
and files `install.sh` ships into a target project to run there (every
`skills/*/SKILL.md`, `scripts/lint-project.sh`, `scripts/branch-info.sh`,
`templates/`, `migrations/`). `CLAUDE.md` carries the full technical
breakdown of this split; it's stated here as a governing principle
(Principle IV) because conflating the two has already caused real mistakes.

## Core Principles

### I. Skill Files Are the Product

A `SKILL.md` edit is a behavior change to every project that has run
`install.sh` against that commit — treat it with the same care as changing
a public API. Don't rewrite a skill's steps without considering every
project already relying on its current behavior.

### II. Deterministic Checks and Mutations Over Prose, Wherever the Operation Is Actually Mechanizable

Any invariant that is a pure function of file state on disk — a status
enum, a required frontmatter field, a cross-reference that must resolve, a
doc that must name a real skill — gets a real deterministic script, not
reliance on an LLM reading instructions carefully every time. The same
rule applies to state *mutations*: any transition that is itself a pure
function of file state — a status flip, a checkbox mark, a frontmatter
stamp, a register append — is performed by a script (`ardd-state.sh` and
its siblings) that validates before writing, never by the LLM hand-editing
markdown per prose instructions. Skill prose decides *when* a mutation
happens; scripts do the *writing*. Prose is reserved for what genuinely
requires judgment: deciding a branch name, weighing a design tradeoff,
asking the user a clarifying question. Where an
invariant looks hardenable but a hook or script provably can't verify it
(e.g. single-writer file ownership, which requires knowing *which skill* is
currently active — information no Claude Code hook payload carries), that
limit is documented explicitly as a verified dead end, not left as
unexplained soft convention.

### III. Never Suggest Ignoring More Than Is Actually Regenerated

Any `.gitignore` guidance this project gives — its own, or what
`install.sh` suggests to a target project — names the narrowest directory
that is guaranteed to be ArDD-regenerated output, never a broader parent. A
broader pattern silently blocks tracking real content (`settings.json`, a
hand-written custom skill, hooks) without `-f`, and git gives no warning
when that happens. This was learned the hard way twice in the same
session, at two nested levels of the identical mistake — don't reintroduce
a third.

### IV. Two Install Targets, Never Conflated

Every script and doc in this repository is either source-side (governs
this repository only) or target-side (installed by `install.sh` into
another project and runs there). Before adding a new deterministic check or
doc, decide explicitly which side it belongs to.

### V. Deterministic Checks Are Test-First

Every code change — a deterministic script or otherwise — is preceded by a
test that exercises the behavior being added or changed, confirmed to fail
(or, for a check script, run against a deliberately-bad fixture) before the
change is considered complete. A task without a test requirement is the
exception (a pure research/decision task, or a documentation-only change),
not the default.

### VI. Simplicity / YAGNI

Complexity must be justified. Default to the simplest solution that
satisfies the requirement; introduce an abstraction only once duplication
across three or more concrete cases makes it unambiguous. Do not design for
hypothetical future requirements.

### VII. No Dead Architecture

When an approach is replaced, the old approach is deleted in the same
change — not archived in place, not left "for reference" in a directory
that no longer reflects reality. Documentation describes only what is
actually true of the current codebase.

### VIII. Check Library/Tool Idioms Before Building Custom Mechanism

Before implementing a custom mechanism to solve a problem already owned by
a depended-on tool (git, jq, the shell itself), check whether that tool
already has a built-in, idiomatic way to solve it. Reaching for a
hand-built solution without checking first is surfaced as a question
before being built, not discovered as duplicated work later.

### IX. Unambiguous Actor Language in Agent-Facing Prose

Skill prose that addresses "you" or "I" is ambiguous about which actor is
meant: the human running the session, or the agent executing the skill.
Where a `SKILL.md` (or other agent-facing prose this repository controls,
e.g. `next_step_prompt` option text) names an actor, prefer explicit terms
— "the user"/"the human"/"the controller" for the person, "the agent"/
"Claude"/"the system" for the automated actor — over ambiguous first- or
second-person pronouns. This applies going forward to new and edited
prose; it is not a mandate to sweep every existing skill file in one pass.

## Quality Standards

- **Testing paradigm**: fixture-based regression tests (`tests/fixtures/
  good-*`, `tests/fixtures/bad-*`, or throwaway repos under a temp dir for
  git-state tests), verified against both a known-good and a known-bad
  case, required for every deterministic check, added in the same commit
  as the check itself.
- **Behavioral smoke tests**: skill behavior is verified by
  fixture-project smoke scenarios — a minimal installable target project,
  a headless `claude -p "/ardd-<skill>"` run, and deterministic
  assertions on file outcomes (expected files exist, statuses legal per
  `lint-project.sh`, single-writer files untouched) — required for
  state-mutating skill paths. This is a second tier alongside
  fixture-based regression tests: regression tests verify the scripts;
  smoke tests verify the skills invoke them to the right end state. CI
  smoke jobs may run conditionally (path-filtered, secret-gated) but
  must exist.
- **Commit messages** follow Conventional Commits (`feat:`, `fix:`,
  `refactor:`, `chore:`, `docs:`, etc.).
- **Shell scripts target POSIX `sh`**, not bash-specific syntax — they may
  be installed into arbitrary target projects, and `install.sh` itself is
  `#!/usr/bin/env sh`.
- **Pre-commit Enforcement**: a pre-commit hook (`hooks/pre-commit`,
  enabled per clone via `git config core.hooksPath hooks`) runs
  `scripts/lint-docs.sh`, `scripts/lint-project.sh`, and **every**
  `scripts/test-*.sh`, discovered by glob — never an enumerated list —
  before a commit is accepted. A new test script is therefore enforced
  the moment it exists, in the same commit that adds its CI job, with no
  list to remember to extend (v1.0.0 enumerated ten scripts and silently
  fell four behind CI; that pattern is prohibited here for the same reason
  Principle II prohibits it generally). A test too slow for the hook is a
  signal to make it faster, not grounds for an exclusion list; if a
  deliberate exclusion is ever truly needed, it must be an explicit,
  visible opt-out marker, not an omission. Bypassing the hook is
  prohibited except in a documented emergency (e.g. committing a
  deliberate test-first red state, stated in the commit body), and any
  bypass is followed immediately by a commit that re-establishes the
  passing state.
- **Feature register format (standing decision, 2026-07-06)**: the
  feature register is **per-feature files** at
  `.project/features/<slug>.md`, not a single `features.md` — merge and
  parse robustness win over single-file glanceability, especially for
  collaborative mode and tracker sync. Schema per file — frontmatter,
  required: `slug`, `status`
  (`backlogged|planned|tasked|implemented|retired|rejected|subsumed`),
  `logged` (YYYY-MM-DD); optional: `plan` and `tasks` (filenames of the
  binding plan/tasks files), `gh_issue` (issue number), `epic` (a
  free-text slug grouping related features for release-cadence-sized
  bundling — declared and durable, distinct from the computed/ephemeral
  plan-time "defrag" footprint analysis, a separate, unrelated backlog
  idea). A feature's `status` asserts what is true of the system NOW,
  not what was once reached: `retired` is the terminal state for a
  feature that shipped and was then deliberately removed — it never
  flips back out. `rejected` is a distinct terminal state for a
  `backlogged` or `planned` idea the team decides not to pursue and
  that never gets built. `subsumed` is a third terminal state for an
  entry whose scope ended up shipping under a *different* feature/plan
  entry — not independently built under this slug, not removed; a
  `subsumed` entry should record the absorbing plan/feature (via its
  `plan:` field or a body note) so a future reader can trace where the
  scope actually landed. Keep all three distinct: `retired` means it
  shipped once (under this slug) then was removed; `rejected` means it
  never shipped at all; `subsumed` means it shipped, just credited to a
  different entry. `subsumed` is deliberately not named `superseded` —
  that word is already used for a *plan's* status (a newer plan
  replacing an older unapproved one for the *same* feature, a
  same-document one-for-one replacement) and would collide semantically
  with this different-shaped, cross-feature absorption case. Body: a
  one-sentence description, optionally followed by a `Why:` line.
  Register-wide views are produced by enumeration (glob), never by a
  second hand-maintained index file. This decision was made explicitly
  (repo critique, 2026-07-06) — do not re-litigate it when touching
  register tooling; amend it here first if it ever needs to change.
- **No vendored dependency carries a nested `.git`**. If a dependency must
  ever be vendored, its provenance is recorded in a README note and it is
  committed as plain files, or added as a real git submodule. (Currently
  N/A — ArDD vendors nothing — kept as a standing floor.)

## Development Workflow

1. When adding a new deterministic check: decide which install target it
   belongs to (Principle IV), add a CI job, and add a fixture-based
   regression test in the same commit (Principle V).
2. When editing a skill that reads or writes a shared frontmatter field,
   status enum, or `[artifacts: ...]`-style tag, check every other skill
   that touches the same field — handoffs run entirely through files on
   disk, not shared state.
3. Gitignore guidance (this repo's own, or what `install.sh` suggests) is
   re-verified against Principle III whenever a new non-skill directory is
   added under `.claude/skills/`, or a new real (non-regenerated) file is
   added under `.claude/`.

## Governance

This constitution supersedes all other practices documented in the
repository. Amendments require:

1. A written rationale explaining why the current principle is insufficient.
2. An updated Sync Impact Report (prepended as an HTML comment).
3. Version increment per semantic versioning: MAJOR for principle removal or
   redefinition; MINOR for new principle or material expansion; PATCH for
   clarifications or wording fixes.
4. `last_updated` date updated in frontmatter.

**Exception**: any workflow frontmatter field enumerated in
`scripts/lint-project.sh`'s workflow-field enum block (as of this writing:
`workflow_mode`, `next_step_prompt`, `delegation`, `merge_policy`,
`plan_preview`, and `update_check_max_age_days` — that script is the
schema-of-record; consult it directly rather than trusting this list to
stay exhaustive) is not an amendment to this constitution's principles or
standing decisions — each is a per-project operational setting, written by
`ardd-state.sh stamp` on the user's answer to a one-time `/ardd-init` (or
`/ardd-update`) question, or set directly by the user. Changing any of them
does not require a Sync Impact Report or a version increment, and does not
itself update `last_updated`.

**Version**: 1.13.0 | **Ratified**: 2026-07-03 | **Last Amended**: 2026-07-21
