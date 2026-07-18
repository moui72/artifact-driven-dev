---
topic: A local-only skill keeping human-facing docs (README, USAGE, docs/ site) current and complete
date: 2026-07-18
status: complete
---

# Research: a source-side docs-freshness sweep for ArDD's human-facing documentation

## Question

Design a **local-only** skill (source-side, never installed via
`install.sh` — same class as `prerelease-sweep`) whose job is the user's
stated goal, verbatim: *"I want to make sure human-facing documentation
(README, everything that renders on the docs site) stay current and
complete."* Target surface: `README.md`, `USAGE.md`, `CONTRIBUTING.md`,
and everything under `docs/` that MkDocs renders
(`docs/concepts.md`, `docs/guides/*`, `docs/reference/**`, `docs/index.md`,
`docs/install.md`, `docs/troubleshooting.md`, `docs/example.md`).

> Supersedes in spirit (not on disk) the earlier report
> `.project/plans/research-docs-freshness-skill-2026-07-18.md`, which
> reframed the request as CI/test-wiring and prerelease-scenario coverage
> drift. That is a real but **different** concern (deterministic hygiene)
> and is explicitly out of scope here.

## What exists today, and what it can't see

Two deterministic checks already guard this surface — both structural,
neither about content:

- `scripts/lint-docs.sh` — verifies every `/ardd-*` command token in the
  human-facing docs names a real skill directory, catches bare-name and
  legacy-owned-filename references, and validates SKILL.md frontmatter
  (lines 33–115). It answers "does this name exist?", never "is this
  description of behavior still true or complete?".
- `scripts/gen-skill-docs.sh` — regenerates the README Skills table, the
  reference index, and each `docs/reference/skills/<name>.md` **header**
  from SKILL.md frontmatter, with `--check` wired into lint-docs
  (lint-docs.sh:150–153). But everything below the `generated:end` marker
  is hand-written and preserved verbatim (gen-skill-docs.sh:8–11,
  119–126) — precisely the surface that drifts silently.

So the gap is exactly: **hand-written prose vs. actual current skill
behavior**, plus **narrative docs (concepts, guides, USAGE routing table)
vs. the current capability set**.

## Evidence: real drift, right now (2026-07-18, HEAD b3c5cbb)

Checked recently-changed skills (`git log --oneline -30 -- skills/`)
against their doc surfaces:

1. **Epics are a documented-in-skills, invisible-in-docs concept.**
   - `skills/ardd-status/SKILL.md:95–102,189` — by-epic breakdown in
     STATUS.md's Feature Backlog section. `docs/reference/skills/ardd-status.md`
     (87 lines): **zero** occurrences of "epic".
   - `skills/ardd-tracker/SKILL.md:123–132` — push creates GitHub
     milestones from `epic:` and assigns issues (deliberately one-way).
     `docs/reference/skills/ardd-tracker.md` (78 lines): zero occurrences
     of "milestone" or "epic".
   - The `epic:` register field itself appears nowhere in
     `docs/reference/project-files.md`, `docs/concepts.md`, or any guide —
     the only human-facing mention of the whole feature family is
     `docs/reference/skills/ardd-backlog.md:14,32–40` (`--assign-epics`).
     A docs-site reader cannot discover that epics exist.

2. **`/ardd-plan --slate` is reference-page-only.** Defined at
   `skills/ardd-plan/SKILL.md:58–76` and described in
   `docs/reference/skills/ardd-plan.md`, but absent from `USAGE.md`'s
   "How do I…?" routing table and from `docs/guides/core-loop.md` — yet it
   is exactly the kind of "I want to…" entry (defrag/organize my backlog)
   USAGE.md's table exists to route.

3. **USAGE.md's routing table lags new modes generally.** Of the recent
   flag additions (`--slate`, `--list` on plan/implement,
   `--assign-epics`, `--from-artifacts`, `--reconfigure`,
   `--local/--beta/--stable`), only `/ardd-refine constitution --review`
   made it into USAGE.md (lines 51, 79). The others exist only on
   reference pages — some intentionally (not every flag deserves a
   routing row), but nothing ever *asks the question*, which is the point.

This confirms the drift class is live and that catching it requires
reading prose against behavior — not token matching.

## Design proposal

### 1. What it checks — and why it can't be (fully) a script

Working definition of "stale or incomplete", per surface:

- **Reference page bodies** (`docs/reference/skills/*.md` below the
  marker): for each skill, does the body describe every usage form /
  flag / mode in the SKILL.md, accurately? Does it describe behavior the
  skill no longer has? Are reads/writes and routing clauses current?
- **USAGE.md**: does the "How do I…?" table route to every user-facing
  capability worth a row? Does the "short version of the workflow" block
  and the documentation map still match reality?
- **docs/concepts.md**: does the mental model cover every *concept* a
  current user encounters (e.g. epics, slate mode, the two release
  channels), not just every command?
- **Guides** (`docs/guides/*`): does each guide's narrative still match
  the flow the skills actually execute (e.g. parallel-work.md vs. the
  current fan-out/fold/reap behavior)?
- **README.md**: pitch, quickstart, workflow description, and any
  behavior claims outside the generated Skills table still accurate.
- **project-files.md / configuration.md / scripts.md**: every frontmatter
  field, workflow knob, and installed script that exists is documented;
  nothing documented has been removed.

Why this is a judgment skill, not a lint (Principle II says script what's
mechanizable — this mostly isn't): the check is *semantic equivalence
between prose and behavior*. "Does ardd-tracker.md's body adequately
describe milestone assignment?" has no token-level oracle — grep can tell
you the word "milestone" is absent (a useful heuristic the skill should
use), but not that a paragraph describing push behavior is subtly wrong,
that a guide's narrative contradicts a decision record, or that a new
mode *deserves* a USAGE.md row versus staying reference-only. The one
genuinely mechanizable slice — command-name existence and frontmatter
headers — is already scripted (`lint-docs.sh`, `gen-skill-docs.sh`).
Where the sweep discovers a *newly* mechanizable slice (e.g. "every
`Usage:` form in a SKILL.md must appear verbatim somewhere on its
reference page" — plausible, token-level), the skill should propose
extending `lint-docs.sh` rather than absorbing the check itself, per the
repo's add-check-with-test convention.

### 2. Scope

**In scope:** `README.md`, `USAGE.md`, `CONTRIBUTING.md`, and every
MkDocs-rendered file under `docs/` — with two carve-outs:
`docs/decisions/*` are historical narratives, checked only for a missing
*index* entry or a standing decision that later docs contradict (never
"updated" — same exemption lint-docs.sh gives them, line 15–16), and
`docs/release-notes.md` is a log, checked only for being behind the
latest tag. Generated regions (README Skills table, reference headers,
reference index) are read as ground truth, never edited by hand — flagged
drift there means "run gen-skill-docs.sh", nothing more.

**Out of scope:** this repo's own `.project/` files (owned by the ArDD
skills themselves), CI/test wiring, prerelease-sweep scenario coverage
(the prior report's tangent — a separate hygiene concern), SKILL.md files
themselves (they're the *source of truth* the docs are checked against;
if a SKILL.md is wrong that's an `/ardd-feedback` matter, not a docs
finding), and consumer-installed surfaces (`templates/WORKFLOW.md` is
generated; target-project docs are not this repo's).

### 3. Naming: a new local-only skill, `docs-sweep`

- New skill, not a mode of an existing one. `/ardd-status`'s
  "Documented but untracked" section is the inverted, wrong-target
  neighbor: it compares a *target project's* `.project/artifacts/`
  against the *feature register* (artifact→register gap). This skill
  compares *this source repo's* skill behavior against its *published
  docs* (behavior→doc gap), runs only here, and must never ship via
  `install.sh` — grafting it onto an installed skill would either leak
  source-side steps into consumers or need a "am I the source repo?"
  branch, both worse than a separate skill. `/ardd-defects` is closer in
  spirit (docs-vs-reality drift) but is likewise an installed,
  target-project skill writing DEFECTS.md.
- Name: **`docs-sweep`** — bare name, no `ardd-` prefix, following the
  `prerelease-sweep` precedent for source-side-only skills (its
  description even opens "Source-side only (never installed to
  consumers)" — copy that clause). Lives where prerelease-sweep lives
  (`.claude/skills/docs-sweep/SKILL.md`, outside `skills/`, which is what
  structurally guarantees install.sh never picks it up). The `-sweep`
  suffix fits the naming system's spirit: named for what it does
  (sweep the docs), manual, with a triage ending.

### 4. When to run

**Manual, at release cadence — with the stable-release dispatch as the
canonical trigger point.** Reasoning: pushing `main` publishes only to
beta; dispatching `stable-release.yml` is "the act that publishes skill
changes to stable consumers" (CLAUDE.md), and `docs.yml` publishes the
site from `main` continuously — so the honest freshness contract is
"docs are re-audited at least once per stable release". Concretely:

- Primary: run `/docs-sweep` before dispatching the stable workflow
  (and after any large skill-editing session, at the user's option).
- Cheap reinforcement: one sentence in `CONTRIBUTING.md` (or the
  stable-release section of the docs) naming it as a pre-stable step,
  and a matching line in `prerelease-sweep`'s triage ending ("if this
  sweep precedes a stable release, run /docs-sweep too").
- **No new reminder mechanism.** The repo has no `/ardd-implement`-
  triggered source-side reminder hook today, and building one for this
  would be per-commit nagging for a per-release concern — the wrong
  cadence — plus new machinery for a two-line prose reminder. If drift
  outruns release cadence in practice, revisit then with evidence.

The skill can scope itself cheaply: diff `skills/` (and `scripts/`,
`install.sh`, `new.sh`) since the last stable tag
(`git describe --tags --match 'v*.*.*' --exclude '*-beta*'`), sweep the
doc surfaces owned by the changed skills in depth, and give unchanged
skills a lighter pass — full-corpus mode on request.

### 5. Skill shape (sketch — structural template: prerelease-sweep)

1. Resolve scope: `full` | default (changed-since-last-stable) |
   explicit file/skill list.
2. Build the behavior inventory: for each in-scope skill, extract usage
   forms, flags/modes, reads/writes, terminal handoffs from SKILL.md.
3. Sweep each doc surface against the inventory (reference bodies →
   USAGE routing → concepts → guides → README → reference/*.md),
   collecting findings with file:line citations, each graded
   **wrong** (says something false) / **missing** (capability or concept
   undocumented) / **judgment** (arguably fine, flag for the user).
4. Present the findings list; for each, the user picks: fix now (small
   prose edits applied directly, `docs:` commit), log to this repo's
   `/ardd-feedback` (larger rewrites — the repo dogfoods `.project/`),
   or dismiss. Never auto-edit without the triage step.
5. If any finding is mechanizable, propose the `lint-docs.sh` extension
   (script + fixture test, per convention) as a separate suggestion.

No report file of its own and no lifecycle state — findings either become
edits or feedback entries, matching prerelease-sweep's triage-and-done
pattern and avoiding a new single-writer ownership entry.

## Recommendation

Create **`docs-sweep`**, a local-only skill at
`.claude/skills/docs-sweep/SKILL.md`: manual, default-scoped to
skills changed since the last stable tag, judgment-based
prose-vs-behavior comparison across README/USAGE/CONTRIBUTING/docs-site,
ending in a fix-now / feedback / dismiss triage. Add one pre-stable
reminder sentence to CONTRIBUTING.md and to prerelease-sweep's ending;
build no new reminder machinery. The three drift findings above (epics
invisible on the docs site; ardd-tracker milestones and ardd-status
by-epic breakdown undocumented; `--slate` unrouted in USAGE.md) are
ready-made first inputs for its inaugural run.
