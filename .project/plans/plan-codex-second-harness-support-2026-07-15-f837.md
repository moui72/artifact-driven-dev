---
status: superseded
branch: codex-second-harness-support
created: 2026-07-15
last_updated: 2026-07-20
features: [codex-second-harness-support]
surfaced-defects: []
---

# Plan: Codex second-harness support (current capability baseline)

## Goal

Ship `install.sh --harness codex` for OpenAI Codex with one canonical ArDD
skill source. The Codex install writes skills to `.agents/skills/`, preserves
the durable `.project/` workflow and deterministic scripts, and degrades only
where a tested Codex capability cannot provide the required user outcome.

This revision supersedes the July 15 plan's assumptions that Codex lacks
`.worktreeinclude`, stable hooks, and usable subagent workflows. It also
replaces the brittle "exactly five substitutions" commitment with explicit,
tested harness clauses: a token replacement cannot safely translate a
branching workflow.

## Scope

**In scope:**

- A fresh, live Codex capability matrix for explicit skill invocation,
  arguments, sequential handoffs, prompts, managed worktrees and
  `.worktreeinclude`, subagents, and hooks.
- A Codex install target at `.agents/skills/`, including the installed script
  and template reference directories and narrow `.gitignore` guidance for
  regenerated `ardd-*` content.
- A single-source skill representation with small, explicitly delimited
  harness clauses where behavior genuinely differs. Mechanical rewrites may
  handle paths and the `/ardd-*` to `$ardd-*` invocation sigil; they may not
  infer control flow from arbitrary prose.
- Direct smoke coverage for every state-mutating skill and a documented manual
  next step when Codex does not reliably perform an automatic terminal
  handoff.
- Documentation and generated target material that accurately describes both
  harnesses without overwriting a consumer's own `AGENTS.md`.

**Out of scope:**

- A general multi-harness adapter framework or a forked Codex prose tree.
- Requiring automatic skill-to-skill chaining as a prerequisite for Codex
  support. It is an optimization, not the workflow's source of truth.
- Shipping a Codex hook by default. Hooks are now a stable capability to
  evaluate, but porting the source-repository lint hook remains a separately
  scoped decision.
- Claiming Claude-equivalent delegation until the live capability matrix proves
  that ArDD's branch, worktree, and report-back contract can be met.

## Technical Approach

The `.project/` model, POSIX scripts, artifact schemas, and task lifecycle are
harness-neutral. The port should therefore preserve their paths and semantics
where possible, rather than reproduce Claude Code's user interface.

`install.sh` gains `--harness <claude|codex>` with `claude` as the unchanged
default. The Codex branch installs skills in `.agents/skills/<name>/`, where
Codex discovers repository skills, and gives every installed skill a valid path
to the shared ArDD scripts and templates. It retains the same narrow ownership
and gitignore ceiling for ArDD-regenerated directories. Codex's documented
`.worktreeinclude` support means the installation and its worktree behavior
must be tested, not suppressed by default.

Keep the source skill body canonical. When an interaction truly needs distinct
harness behavior, express it through a compact, named clause with a Codex
fallback whose outcome is explicit: for example, present a numbered question
and wait for the user's response when a structured choice UI is unavailable.
The install transform selects these clauses and performs only mechanically
verifiable path/sigil substitutions. Tests must fail if a Claude-only tool
reference leaks into the Codex output or if a Codex clause is omitted.

Codex's explicit `$ardd-*` invocation and arguments are required. Automatic
handoff is tested as an enhancement: if it is unreliable, a completed skill
reports the next explicit `$ardd-*` invocation while preserving the same
on-disk outcome. Similarly, implementation begins inline unless the capability
matrix proves that Codex subagents can meet ArDD's isolation and state-landing
contract; this is a supported fallback, not a platform claim.

## Phase Breakdown

### Phase 1: Establish the live compatibility baseline

1. Build a throwaway target with two minimal `.agents/skills/` skills and
   verify explicit `$skill-a` invocation, `$skill-a argument` handling, and a
   terminal-handoff attempt at least three times. Record automatic chaining as
   reliable, unreliable, or unavailable; a direct/manual next step is the
   fallback, not a no-go.
2. Verify Codex-managed worktrees with a gitignored `.agents/skills/ardd-*/`
   path listed in `.worktreeinclude`; confirm an installed skill and script are
   available in the new worktree.
3. Verify the available subagent/worktree behavior against ArDD's actual
   contract: isolation, branch identity, result reporting, and safe state
   landing. Decide whether Codex v1 supports delegated implementation or uses
   inline execution.
4. Verify hooks only to classify them for future work. Do not expand this
   feature's scope unless a concrete target-side enforcement need emerges.

### Phase 2: Define and test the portable skill surface

1. Inventory the current skill set before coding. This includes all seven
   `AskUserQuestion` users (`ardd-backlog`, `ardd-feedback`, `ardd-init`,
   `ardd-plan`, `ardd-refine`, `ardd-status`, and `ardd-update`), every
   `.claude/skills` reference, every `/ardd-*` handoff, and the implementation
   delegation path.
2. Introduce the smallest explicit clause convention needed for the verified
   differences. Keep ordinary judgment steps shared; do not create a parallel
   Codex skill tree or a general adapter framework.
3. Add deterministic transformer tests using both synthetic clauses and all
   shipped skills. Assert valid Codex paths, `$ardd-*` invocations, no leaked
   Claude-only calls, correct plain-text prompt fallback, and correct
   `next_step_prompt` behavior for `false`, `true`, and `auto`.

### Phase 3: Implement the install target and workflow behavior

1. Add and validate `install.sh --harness codex`; preserve no-flag Claude
   behavior byte-for-byte where practical and reject unknown harness values.
2. Install skills, `ardd-scripts`, artifact templates, and constitution data
   into the Codex layout. Apply only the tested transform and maintain the
   narrow regenerated-content/gitignore guidance for both layouts.
3. Implement the Phase 1 delegation decision. If inline-only, state that as a
   capability fallback in Codex output; if delegated mode is proven, test the
   full worktree-to-landing lifecycle before exposing it.
4. Retain `.worktreeinclude` only after the Phase 1 fixture proves the exact
   Codex-managed behavior. Test the installed ignored skill directories in a
   fresh worktree, rather than assuming either copy or absence.

### Phase 4: Consumer-facing documentation and governance correction

1. Update the README, usage/install/concepts guides, generated `WORKFLOW.md`,
   and `.project` reviewer guide for harness-specific commands, paths, and
   fallbacks. Audit install output and `new.sh` separately; neither may offer
   a Claude-only launch after a Codex-target install.
2. Provide Codex `AGENTS.md` guidance as optional documentation or a merge-safe
   template. Never overwrite a consumer's existing agent guidance.
3. Correct the constitution's present-tense claim that Codex is already
   installable before this feature ships. Preserve the historical decision
   record, but make current scope truthful; apply the required Sync Impact
   Report and versioning decision when the actual supported surface is known.

### Phase 5: End-to-end acceptance

1. Run the full deterministic suite plus new two-harness installation,
   transformer, gitignore, and worktree fixtures.
2. Run direct Codex smoke scenarios against an installed throwaway project for
   initialization, planning/tasking, inline implementation, status refresh,
   and one prompt fallback. Validate resulting `.project/` state with
   `lint-project.sh`.
3. Run the existing Claude smoke/regression path to demonstrate that Codex
   support did not alter the primary harness's behavior.

## Decisions and Open Questions

- Codex support remains worth pursuing: its `SKILL.md` format, `.agents/skills`
  discovery, explicit `$` invocation, `.worktreeinclude`, hooks, and subagent
  workflows are documented current capabilities.
- Automatic chaining and full delegated implementation remain empirical
  compatibility questions, not architecture gates. Their absence must produce
  an explicit, user-operable fallback.
- The final supported delegation level, whether to ship a Codex hook, and the
  exact `AGENTS.md` delivery are decided from the Phase 1 evidence before the
  installation behavior is finalized.
