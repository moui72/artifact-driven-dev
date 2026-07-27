---
topic: "proposal: CI regenerates STATUS.md on main post-merge in collaborative mode"
date: 2026-07-27
status: complete
---

# Research: CI STATUS.md Refresh on Main (Collaborative Mode)

## Question

Should a CI job on the default branch regenerate `STATUS.md` post-merge in
collaborative mode, so feature branches stop committing regenerated report
files (the stated motivation: PR diff noise)? Feature under vet:
`.project/features/ci-status-refresh-on-main-coll.md` (backlogged
2026-07-24).

## Findings

### What STATUS.md actually is

- `skills/ardd-status/SKILL.md`: the report is a *cross-artifact judgment
  product* — it reads every artifact, plan, tasks file, the register,
  in-flight worktrees, draft PRs, `parallel-matrix.sh` verdicts, and reports
  gaps, contradictions, and implied-but-undefined decisions. Only narrow
  slices (counts, work queue, in-flight lines) are deterministic byproducts
  of existing scripts.
- The 2026-07-06 determinism audit (CLAUDE.md, "Mechanization non-goals")
  explicitly rejected scripting "STATUS.md count assembly". A deterministic
  status-lite generator would overturn a recorded decision without new
  evidence — the counts were judged byproducts, and the judgment sections
  can't be scripted at all.
- Single-writer rule: `/ardd-status` is STATUS.md's only writer, and the
  skill itself says "run only from the primary checkout" — writes must land
  on the default branch. A CI writer would be a *second* writer identity and
  a second copy of the skill's procedure to keep in sync.

### Does the motivation survive recent changes?

- **merge=ours** (`.project/.gitattributes` + `merge.ours.driver true`)
  already removes report-file *conflicts*; verified shipped. It does not
  remove *diff noise* — that part of the motivation is real but narrow.
- **status_history_keep pruning** (`scripts/status-prune.sh`, wired into
  `/ardd-status` step 6) bounds STATUS.md to the newest N `_Updated:`
  blocks. Post-prune, a typical STATUS.md refresh diff is one prepended
  block plus one dropped tail block — small and mechanically skimmable, not
  the unbounded churn the feature was logged against.
- Critically, the noise exists only because branches *choose* to run
  `/ardd-status` and commit the result. Collaborative mode's design already
  tolerates a stale STATUS.md on main: the file is declared **disposable**
  at merge time, and every state-changing skill regenerates it on its next
  interactive run. Nothing downstream reads STATUS.md as machine input — it
  is a human re-entry report. A lagging STATUS.md on main is a cosmetic
  staleness, not a correctness problem.

### The CI-writer options, against the audit lenses

**(a) Headless `claude -p "/ardd-status"` in CI.**
Fails proportionality and robustness badly: requires an Anthropic API key
as a repo secret (cost per merge, auth to manage, and ArDD targets are
arbitrary consumer repos — this repo can't provision their keys); output is
nondeterministic LLM judgment running unreviewed and auto-committing to a
protected branch; the harness/CLI may not even be installable on a
consumer's runners. It also inverts the trust model: everywhere else, LLM
output lands via a human-attended session or a reviewed PR.

**(b) Deterministic status-lite script (counts/queue/in-flight only).**
Directly re-proposes the mechanization non-goal with no new evidence.
Worse, it creates a *split-brain* STATUS.md: CI-written mechanical sections
interleaved with stale LLM judgment sections, or a second file — either way
two writers and a semantics muddle ("is this report current?" now has two
answers per section).

**(c) Branch protection mechanics.**
`.github/workflows/ardd-badge.yml` shows what CI-writes-to-main costs here:
short-lived branch + PR + best-effort auto-merge, with a manual-approval
fallback when auto-merge can't fire. Acceptable for a 5-line JSON badge; for
a per-merge STATUS.md refresh it means a bot PR after *every* merge —
replacing in-PR diff noise with PR-list noise, and stalling silently on
repos without auto-merge. On consumer repos (where this feature would
actually ship, via a skill that installs a workflow) the variance is worse:
ArDD has no precedent for installing workflows into targets at all.

**(d) Stop committing report refreshes on feature branches.**
The cheapest fix, and it attacks the stated problem directly: in
collaborative mode, skills running on a feature branch skip (or make
optional) the terminal `/ardd-status` STATUS.md write, leaving main's copy
untouched until the next primary-checkout run. Zero infrastructure, no new
writer, no reversed decisions. This is already *almost* the design: the
skill says to run only from the primary checkout, and delegated subagents
are told not to invoke it. The residual gap is the collaborative inline
path (working on a branch in the primary checkout), where a
`--view`-style read-only report at branch end would give the human the
same information without the commit.

### Reversed decisions this proposal would touch

1. "STATUS.md count assembly — deliberately NOT scripted" (determinism
   audit 2026-07-06, CLAUDE.md Mechanization non-goals) — option (b).
2. Single-writer ownership of STATUS.md by `/ardd-status` (CLAUDE.md,
   `templates/dot-project-readme.md`) — options (a) and (b).
3. "Only lint/test scripts run in CI... that's the full extent of
   automation, deliberately" (CLAUDE.md Commands section) — any CI writer.

## Recommendation

**Drop the feature as specified** (a CI job regenerating STATUS.md on
main). It reverses two recorded decisions, needs per-repo API keys or a
non-goal script, fights branch protection with bot PRs per merge, and the
problem it targets has shrunk to near-cosmetic since status_history_keep and
merge=ours landed.

The kernel worth keeping is option (d), and it is skill-prose-sized, not
CI-sized: in collaborative mode on a feature branch, prefer the existing
`--view` read-only path (or skip the terminal STATUS.md write) so report
refreshes simply never enter PRs; main's STATUS.md refreshes on the next
primary-checkout `/ardd-status`, which the post-merge flow already
triggers. If that residual annoyance is felt in practice, route it as:

**`/ardd-backlog` — "collaborative mode: terminal ardd-status on a feature
branch defaults to --view (no STATUS.md commit in PRs)"** — a reshaped,
much smaller feature replacing `ci-status-refresh-on-main-coll`, which
should be dropped.

## Rejected Alternatives

- **Headless `claude -p` in CI** — cost, secrets on arbitrary consumer
  repos, unreviewed nondeterministic output auto-merged to a protected
  branch, uncertain harness availability.
- **Deterministic status-lite CI script** — re-proposes the 2026-07-06
  mechanization non-goal without new evidence; creates split-brain
  authorship of one report file.
- **Badge-workflow-style PR + auto-merge for STATUS.md** — the mechanics
  exist (ardd-badge.yml) but per-merge bot PRs trade diff noise for PR
  noise and stall without auto-merge; disproportionate for a disposable,
  human-only report.
- **Do nothing at all** — viable (the problem is mostly solved), but the
  --view reshape is nearly free and removes the last of the PR noise.

## Open Questions

- Should collaborative-mode branch runs *always* skip the STATUS.md write,
  or offer it (some teams may want the report riding the PR as review
  context)? Suggest: default to --view, one-line note that main's copy will
  refresh post-merge.
- If ArDD ever does install workflows into target repos (no precedent
  today), that decision should be made on its own merits first — not
  smuggled in via this feature.
