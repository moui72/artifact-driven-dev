---
topic: A local-only "coverage/wiring freshness" skill for developing ArDD itself
date: 2026-07-18
status: complete
---

# Research: A source-side freshness sweep for ArDD's own repo

## Question

Should ArDD get a new **local-only** (source-side, never installed via
`install.sh`) skill that catches the drift class shown by two feedback
files logged this session — regression tests written but not wired into
CI (`feedback-ci-migration-tests-unwired-37ee.md`) and features shipped
with no corresponding prerelease scenario
(`feedback-prerelease-sweep-scenario-gaps-95f6.md`)? If so: what does it
check, what is it named, when does it run, and how does it relate to
`scripts/lint-docs.sh`?

## Findings

### The premise had to be corrected: this is *coverage/wiring* drift, not *docs* drift

The task framed this as a "docs-freshness" skill. Direct inspection
contradicts that framing, and the correction matters for the design.

I read the hand-written bodies (below the `generated:end` marker) of the
reference pages for the four most recently-churned skills —
`docs/reference/skills/ardd-plan.md`, `ardd-update.md`, `ardd-backlog.md`,
`ardd-status.md`. All four are **current**, not drifted:

- `ardd-plan.md` documents `--slate` and `--list` (shipped 0a06f67…2e17f40
  this session) in full, including the footprint-grading/relation shape.
- `ardd-update.md` documents `--stable`/`--beta`/`--local` channel flags
  (fad895e).
- `ardd-backlog.md` documents `--assign-epics` (5deec26) and
  `--from-artifacts` (f3c0451).
- `ardd-status.md` documents the "Documented but untracked" section
  (9e1097a).

That is because `scripts/gen-skill-docs.sh` regenerates every reference
page's *header* from frontmatter and `lint-docs.sh --check` fails CI when
a description edit skips regeneration — and the maintainer has kept the
hand-written bodies in step. So reference-page body drift is **not** the
live risk. Naming this "docs-freshness" would aim it at a problem that is
already well-controlled.

The residual, uncaught risk is **coverage and wiring drift**: new
machinery ships without the *supporting surface* that should accompany it
being updated. The two feedback files are exactly this, and they fall on
**opposite sides of this repo's Principle II line** (scripts over prose
wherever a check is genuinely deterministic):

**Mechanizable half — deterministic, belongs in a script.** I reproduced
`feedback-ci-migration-tests-unwired` with a 3-line loop:

```
for t in scripts/test-*.sh; do b=$(basename "$t");
  grep -q "$b" .github/workflows/lint.yml || echo "UNWIRED: $b"; done
```

Output — three test scripts on disk that no CI job runs:

```
UNWIRED: test-migration-critique-to-audit.sh
UNWIRED: test-migration-sync-to-tracker.sh
UNWIRED: test-migration-workflow-table.sh
```

This is a pure structural check (file-on-disk vs. referenced-in-workflow).
Catching it with an LLM skill would be precisely the prose-where-a-script-
belongs that the repo's determinism audit rejects. It wants a lint script.

**Judgment half — belongs in a skill.** "Does feature X (implemented
2026-07-15) warrant a new prerelease scenario, or an extension to an
existing one?" is the content of `feedback-prerelease-sweep-scenario-gaps`
(no S8 fan-out scenario; S3 predates channel-switch; S7 predates `epic:`).
Answering it requires reading each recent feature's blast radius against
the seven scenario briefs in `tests/prerelease/scenarios/` and judging
coverage. No script decides that.

### A crude second-order signal (stated honestly, not overstated)

A naive grep found skills unmentioned in `USAGE.md` (ardd-audit, -diagram,
-lint, -tracker) and `docs/concepts.md` (ardd-diagram, -research, -update).
**These are not necessarily gaps.** `USAGE.md` is a task-oriented "How do
I…?" map (line 32) that deliberately lists only the common verbs and links
to the full reference index; `docs/concepts.md` is a selective mental-model
doc. Neither is meant to enumerate every skill. The valid takeaway is
narrow: **no mechanical guarantee exists that a genuinely new user-facing
capability got reflected anywhere in the prose doc surface** — that gap is
real, but detecting it needs judgment (is this capability user-visible
enough to belong in the map?), so it lives in the judgment skill, not a
lint. I am not asserting the specific listed omissions are bugs.

## Recommendation

**Two deliverables, split along the Principle II line — not one slow
skill.**

### (A) Deterministic lint script — `scripts/lint-coverage.sh` + CI job + regression test

A source-side sibling of `lint-docs.sh`, wired into `hooks/pre-commit` and
`.github/workflows/lint.yml`, shipping with its own fixture-based
regression test in the **same commit** (the repo's stated rule for any new
deterministic check). Concretely mechanizable checks:

1. **Every `scripts/test-*.sh` is referenced in `lint.yml`** (the proven
   gap above). This is the primary, highest-value check.
2. **Every `scripts/*.sh` non-test script has a `test-*.sh`** (the repo's
   own convention — CLAUDE.md pairs each script with a regression test);
   flag scripts that lack one, with a small allowlist for the genuinely
   untested (e.g. pure dispatchers).
3. Optionally: **every `migrations/*.sh` has a matching CI-wired
   `test-migration-*.sh`** — a tighter form of check 1 aimed at the exact
   0006/0007/0008 miss.

This is the inverse of `lint-docs.sh`: lint-docs asserts "every command a
doc *references* exists"; lint-coverage asserts "every test/script that
exists is *wired in*." Same family, complementary, **not a supersede** —
keep both.

### (B) Judgment skill — `coverage-sweep` (source-side, bare name, no `ardd-` prefix)

Modeled directly on `prerelease-sweep`: source-side-only, description
opens `Source-side only (never installed to consumers).`, manual
invocation at prerelease cadence. It reads `git log` since the last stable
tag (or the `.project/features/*.md` `status: implemented` entries dated in
the window), and for each recently-shipped capability judges whether the
**non-doc supporting surfaces** kept up:

- a `tests/prerelease/scenarios/S<n>.md` covering it (or a justified
  extension), producing the S8/S3/S7 recommendations by judgment;
- a mention in the user-facing prose map (`USAGE.md`/`concepts.md`) *if*
  the capability is user-visible enough to warrant one;
- a reference-page body that reflects it (a backstop for the body-drift
  case, even though it is currently clean).

It ends the way `prerelease-sweep` does — a triage table the user
confirms, then `/ardd-feedback` for accepted findings (this repo dogfoods
its own `.project/`). It should **run `scripts/lint-coverage.sh` first**
and report its deterministic findings verbatim before doing any judgment
work, so the cheap mechanical gaps are never re-derived by an LLM.

### Naming rationale

The `ardd-*` naming system (report-owner nouns / lifecycle verbs / capture
skills) governs **installed** skills. A source-side-only skill follows the
`prerelease-sweep` precedent: **bare descriptive name, no `ardd-` prefix**,
description leading with the source-side disclaimer. `coverage-sweep`
mirrors `prerelease-sweep` in both name shape and cadence.

**Not a mode of `/ardd-audit`.** `/ardd-audit` ships to consumers and
operates on a target project's `.project/artifacts/`. Wiring ArDD's own
repo-development concerns (CI jobs, test scripts, this repo's docs) into it
would break the source/target split that CLAUDE.md's Architecture section
makes load-bearing. This work is about developing ArDD itself, which is
categorically source-side.

### Trigger rationale

- **The lint (A) goes in `hooks/pre-commit` + CI** — that is where this
  repo already puts deterministic checks, and it catches wiring drift
  before it reaches `main`/beta. A *new pre-push hook* is unnecessary:
  pre-commit + the CI gate already fire before push, and a git hook is a
  shell script that fundamentally cannot invoke the judgment skill anyway,
  so "pre-push" only ever meant the deterministic half.
- **The skill (B) is manual, prerelease-time**, same as `prerelease-sweep`
  — judgment cadence, human in the loop for the triage.
- **Reject wiring into `/ardd-implement`.** `/ardd-implement` ships to
  consumers; "check ArDD's own docs/CI/scenarios" is meaningless in a
  target project. The trigger for reviewing *ArDD's* coverage belongs to
  ArDD-development cadence, not to an installed lifecycle skill.

### Relationship to `lint-docs.sh`

Complementary, not superseding. `lint-docs.sh` stays as-is (fast,
deterministic, reference-validity + frontmatter + owned-file-gate +
gen-skill-docs `--check`). `lint-coverage.sh` is a *new sibling* covering
the inverse direction (existence → wiring). The judgment skill sits above
both, calling the deterministic checks first and adding only what needs a
human's read of blast radius.

## Rejected Alternatives

- **One monolithic "docs-freshness" LLM skill.** Rejected: (a) it would
  re-derive by LLM the CI-wiring gap that a 3-line script already catches,
  violating Principle II; (b) "docs-freshness" mis-aims — reference bodies
  are currently clean, verified above.
- **A mode of `/ardd-audit`.** Rejected: source/target split (audit is an
  installed, target-`.project/`-facing skill).
- **A new pre-push hook.** Rejected: pre-commit + CI already gate before
  push; a hook can't run the judgment half regardless.
- **Fold the judgment half into `prerelease-sweep` itself** (it already
  runs at prerelease cadence, already ends in triage→`/ardd-feedback`, and
  the scenario-gap feedback is literally about *its* coverage). Genuinely
  tempting and worth the user's consideration. Kept separate because
  coverage/CI-wiring/doc-map drift is broader than *sweep scenario*
  coverage, and `prerelease-sweep`'s SKILL.md is deliberately a "thin
  dispatcher — the briefs are the product; never improvise." Loading a
  coverage-judgment pass into it would thicken exactly what that skill's
  prose says to keep thin. If the user prefers fewer skills, folding B's
  scenario-coverage subset into `prerelease-sweep` and shipping only the
  lint (A) separately is a defensible smaller cut.

## Open Questions

- **B's scope vs. `prerelease-sweep`.** Decide whether `coverage-sweep` is
  its own skill or a pre-flight step folded into `prerelease-sweep`. My
  recommendation is separate (above), but this is the one genuine judgment
  call for the user.
- **lint-coverage check 2 allowlist.** "Every script has a test" needs a
  small documented exemption list (dispatch-only scripts, `release.sh`-era
  retirees). Define it when writing the script, not now.
- **Does B write anything durable?** `prerelease-sweep` writes durable run
  reports under `dev-notes/`. A coverage sweep is lighter; likely just a
  triage table → `/ardd-feedback`, no durable per-run artifact. Confirm at
  implementation time.
