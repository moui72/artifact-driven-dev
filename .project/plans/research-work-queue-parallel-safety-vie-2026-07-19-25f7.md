---
topic: single-pane work-queue + parallelization-safety view
date: 2026-07-19
status: complete
---

# Research: Single-pane work-queue + parallelization-safety view

## Question

Proposal vetting: should ArDD grow a "single pane of glass" over pending
work and its parallelization safety — concretely, a Work Queue section in
`/ardd-status` plus an installed `parallel-matrix.sh` computing pairwise
overlap (feature claims, artifact tags, path mentions) among `ready` tasks
files and in-flight worktrees, with the same script feeding
`/ardd-implement`'s multi-select fan-out picker?

## Findings

### What exists today (verified against the skills and scripts)

- **Pending-work data is already all on disk**: `ready` tasks files
  (`.project/tasks/`), register statuses (`.project/features/`), open
  feedback, DEFECTS.md, and `inflight-worktrees.sh` output. STATUS.md
  reports counts and an In Flight section, but as a consistency report,
  not a work queue — there is no per-ready-file listing and no pairwise
  view anywhere.
- **The only parallelization signal today is the same-file claim check**
  in `/ardd-implement` step 1 (hard exclusion: a tasks file claimed
  `in-progress` by a live worktree). Nothing checks whether two *different*
  ready files touch the same feature, artifact, or code paths before the
  multi-select fan-out launches them in parallel.
- **Feature linkage is indirect for tasks files**: a tasks file carries
  `plan:` frontmatter; the plan carries `features:`. So feature-claim
  overlap between two ready files is computable deterministically, but via
  one level of plan indirection (and must degrade gracefully when the plan
  file is missing or predates the `features:` field — older files in this
  very repo lack it).
- **`[artifacts: ...]` tags on task lines** are a structured, lintable
  convention (`lint-project.sh` validates the refs), so artifact-overlap
  intersection is also deterministic.
- **Path mentions in task prose are not structured.** Paths appear in
  backticks, inconsistently, sometimes as directories or globs, sometimes
  omitted entirely. Any grep-based path-intersection is a heuristic with
  meaningful false-negative and false-positive rates.

### Critical lenses (per /ardd-audit)

- **Simplicity / proportionality.** The deterministic core — "which ready
  files share a feature slug; which share an artifact tag" — is a small
  set-intersection over frontmatter and tags, squarely the purpose-built
  deterministic-check pattern (`completion-flip-check.sh`,
  `inflight-worktrees.sh` siblings) and consistent with Principle VI. The
  path-mention tier is the disproportionate part: extracting file paths
  from free prose is judgment-shaped, exactly the kind of thing the
  2026-07-06 mechanization audit declined to script. Scripting it would
  ship a validator-like tool whose output can't be trusted, which (per the
  stale-validator lesson in CLAUDE.md) trains users to ignore it.
- **Failure modes.** (1) Missing/old plan files without `features:` →
  script must report `features=unknown`, never guess. (2) A path heuristic
  that says "independent" when two runs actually collide would create
  false confidence; the merge-time `merge_policy` abort-and-ask remains
  the real safety net regardless, so the matrix must be framed as
  advisory, never as a green light that bypasses it. (3) Queue is usually
  small (this repo: 1 ready file of 61) — the pairwise matrix is O(n²) but
  n is tiny; no scaling concern.
- **Standardness / DRYness.** The script must *consume*
  `inflight-worktrees.sh` output rather than re-enumerate worktrees, and
  must not re-implement the same-file claim check — that hard rule stays
  where it is in `/ardd-implement`. New signal (cross-file feature/artifact
  overlap) is additive, not duplicated. Presentation is duplicated in two
  skills (`ardd-status` report section, `ardd-implement` picker
  annotations) but the computation lives once in the script — the same
  accepted split as `branch-info.sh`.
- **Semantics.** Tiered verdicts need unambiguous names. Recommended:
  `verdict=shared-feature` (strong warning — same feature slug in both
  plans), `verdict=shared-artifact` (advisory), `verdict=independent`
  (meaning only "no declared overlap", not "guaranteed conflict-free" —
  the script's docs and both skills' prose must say so explicitly).
- **Reversed decisions: none.** No committed artifact decision is touched.
  Adjacent standing decisions that constrain the design: single-writer
  ownership (STATUS.md section written only by `/ardd-status` — satisfied);
  the mechanization non-goals list (STATUS.md count assembly stays
  prose-assembled from script byproducts — the matrix output is one more
  such byproduct, consistent); the two-skill `next_step_prompt` scope
  (unaffected); "unit of parallelism is the tasks file" (reinforced, not
  changed).

### Strongest challenges

1. **Is a new report surface needed at all?** No — a *section* in
   STATUS.md plus picker annotations covers it. A separate `/ardd-board`
   skill would, per the naming convention, own a fourth generated report
   file and a new single-writer boundary for no added data. Rejected.
2. **Is the path tier worth it?** Not as a script. As agent judgment at
   presentation time ("skim both files; note likely code contact") it
   costs one sentence of prose in each skill and stays honestly labeled
   as judgment.
3. **Does "independent" invite skipping the merge safety net?** Only if
   worded carelessly — the framing rule above is the mitigation.

## Recommendation

Worth doing, as a scoped-down version of the proposal:

1. New installed script `scripts/parallel-matrix.sh` (+ fixture regression
   test + CI job, same commit): given the set of `ready` tasks files and
   the current `inflight-worktrees.sh` output, emit one line per pair —
   `pair=<a>:<b> verdict=independent|shared-feature|shared-artifact
   features=<slugs|unknown> artifacts=<tags>` — computing feature overlap
   via the tasks→plan→`features:` chain (reporting `unknown`, never
   guessing, when the chain breaks) and artifact overlap via
   `[artifacts: ...]` tag intersection. No path heuristics.
2. `/ardd-status` gains a **Work Queue** section (in its report and
   STATUS.md): each `ready` tasks file with its features/plan and the
   matrix verdicts against other ready files and in-flight worktrees.
3. `/ardd-implement`'s multi-select fan-out picker annotates options from
   the same script and adds one judgment sentence prompting the agent to
   flag likely code-path contact when files look related.
4. Both prose sites state explicitly that `independent` means "no declared
   overlap" and that `merge_policy` conflict handling still governs.

Route: **`/ardd-backlog` work-queue parallel-safety view** — log it and
let `/ardd-plan` design it later.

## Rejected Alternatives

- **Separate `/ardd-board` report-owner skill** — fourth generated report
  file and new ownership boundary for data STATUS.md can carry; the most
  actionable consumption point (the implement picker) can't be fed by a
  skill anyway, only by a shared script.
- **Scripted path-mention intersection tier** — prose paths are
  unstructured; a heuristic verdict would be untrustworthy, and shipping
  an untrustworthy checker degrades trust in the trustworthy tiers.
  Path-contact assessment stays agent judgment at presentation time.
- **Structured `paths:` frontmatter on tasks files** (to make the path
  tier deterministic) — adds an authoring burden to every plan run and a
  new field that goes stale the moment implementation touches an
  unlisted file; deferred unless real fan-out collisions occur.

## Open Questions

- Should `shared-feature` be a hard exclusion in the fan-out multi-select
  (like the same-file claim) or a strong warning? Leaning warning-only,
  since worktree-native state makes even a bad pairing recoverable at
  merge — decide at plan time.
- Whether the matrix should also compare ready files against
  *collaborative-mode* draft PRs (the other in-flight channel) or ship
  solo-mode-first.
