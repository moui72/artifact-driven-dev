---
topic: Should ArDD support OpenAI Codex (Codex CLI) as a second harness, and in what architecture?
date: 2026-07-15
status: complete
---

# Research: Codex CLI as a second harness for ArDD

## Question

Vet the proposal: should ArDD support OpenAI Codex (Codex CLI) as a second
harness alongside Claude Code, and if so, in what architecture? Assess
effort, degradation, and long-term maintenance cost — weighing honestly
that skill *behavior* is not CI-testable, so drift between two prose
surfaces is the dominant risk ("skill files are the product", Constitution
Principle I).

## Findings

### What ArDD is today, and where it couples to the harness

ArDD is defined in `constitution.md` (Project Scope & Intent) as "a Claude
Code skill pack." Nearly all of its value lives in a **harness-neutral
core**, and only a thin surface is Claude Code-specific. The split:

**Harness-neutral (ports for free — no harness API in sight):**
- The entire `.project/` state layer: artifacts, per-feature register,
  plans/tasks files, the four single-writer reports, all frontmatter status
  enums and `[artifacts: ...]` / `plan:` / `features:` handoff fields.
- Every POSIX shell script — `ardd-state.sh`, `lint-project.sh`,
  `branch-info.sh`, `completion-flip-check.sh`, and the four
  worktree-native-state scripts (`worktree-align.sh`, `fold-to-main.sh`,
  `worktree-reap.sh`, `inflight-worktrees.sh`). These are plain `git` +
  POSIX `sh`; they know nothing about which agent invokes them.
- The git discipline itself: state-rides-the-branch, merge-as-atomic-event,
  worktree-native truth. All of it is git mechanism, not harness mechanism.
- The bulk of each `SKILL.md`'s prose — the *judgment* steps (negotiate
  intake, draft a phased plan, name a branch, apply audit lenses). Prose an
  LLM executes is portable to any competent coding agent.

**Claude Code-specific coupling inventory** (which skill uses which
feature, verified by grep over `skills/`):

| Coupling | Skills that use it | What it does |
|---|---|---|
| `AskUserQuestion` structured prompt | `ardd-status`, `ardd-init`, `ardd-plan`, `ardd-feedback` (+ `next_step_prompt` in status/plan) | Multiple-choice user prompts; the `next_step_prompt` terminal handoff |
| `Agent` tool w/ `isolation:"worktree"` + background delegation + fan-out | `ardd-implement` (delegation engine), `ardd-plan` (references why it must NOT delegate) | Launch a subagent in a fresh isolated worktree; multi-select fan-out; the branch name is only known from the subagent's report-back |
| `.worktreeinclude` | `ardd-implement`, `install.sh` (maintains it) | Makes Claude Code copy gitignored `.claude/skills/ardd-*/` into every new worktree |
| `.claude/settings.json` `PostToolUse` hook | `.claude/settings.json` → `hook-lint-on-write.sh` (source-side dogfood only; not installed into targets today) | Lints `.project/` writes on `Write|Edit` |
| Skill invocation + skill-to-skill chaining | all skills (`/ardd-*`), terminal handoffs ("run `/ardd-status`") | Named slash-command invocation; a skill's prose triggers another by name |
| `.claude/skills/` install layout | `install.sh`, every skill's fixed reference paths (`ardd-scripts`, `ardd-constitution-data`, `ardd-artifact-templates`) | Where installed skills + reference dirs live |

### What Codex CLI can actually do today (verified against current docs)

- **Skills — the load-bearing discovery.** Codex CLI now natively supports
  the **same `SKILL.md` format** as Claude Code: a directory with a
  `SKILL.md` carrying YAML frontmatter (`name`, `description`) plus
  natural-language instructions and optional script/reference subdirs.
  Codex scans **`.agents/skills`** from cwd up to the repo root (plus user
  / admin / system locations). OpenAI's docs state skills "built for Codex
  CLI work in Claude Code … and can be copied between them." This means the
  *skill body* is a near-clean port, not a rewrite.
  [Build skills](https://developers.openai.com/codex/skills)
- **Custom prompts** (`~/.codex/prompts/*.md`, invoked `/prompts:<name>`,
  with `$1`–`$9` / `$ARGUMENTS` / named `KEY=value` args) exist but are now
  **deprecated in favor of skills**.
  [Custom Prompts](https://developers.openai.com/codex/custom-prompts)
- **AGENTS.md** is the project-instruction file (the CLAUDE.md analogue):
  `~/.codex/AGENTS.md` global, repo-root and subdir overrides.
  [AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
- **MCP** via `~/.codex/config.toml` (stdio or streamable-HTTP servers).
- **Subagents** exist: Codex "handles orchestration across agents,
  including spawning new subagents … waiting for results, and closing agent
  threads," and can run them in parallel. **But invocation is
  natural-language or skill-instruction driven** ("ask for subagents
  directly"), not a structured tool call that returns a handle. The only
  structured API found is `spawn_agents_on_csv` (batch/CSV fan-out) — not a
  general "launch one subagent in a named worktree and get its branch back"
  primitive. `/agent` inspects/switches threads interactively.
  [Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- **Worktrees + Handoff:** every new thread / background agent / automation
  creates a git worktree sharing `.git`; "Handoff" moves a thread between
  Local (foreground) and Worktree (background) mode. `codex exec` is the
  scriptable single-shot counterpart.
  [Worktrees](https://developers.openai.com/codex/app/worktrees)
- **Hooks:** a `codex_hooks` **feature flag** enables lifecycle hooks on
  session start, pre-tool-use, post-tool-use, prompt submission, agent
  stop. So a PostToolUse-equivalent exists, but feature-flagged (i.e. not
  yet a stable contract).
- **Structured user-prompting:** **no `AskUserQuestion` equivalent found.**
  Codex's built-in slash commands and docs describe no structured
  multiple-choice prompting primitive.

### Coupling → Codex translation map

| Coupling | Codex translation | Verdict |
|---|---|---|
| `SKILL.md` definition + install layout | Same format; install to `.agents/skills/`; reference dirs re-rooted; MCP via `config.toml`; project instructions via `AGENTS.md` | **Clean port** (mechanical install-path change) |
| Named slash invocation | Deprecated `/prompts:` gave literal-name invocation; **skills are description-triggered by the model**, not guaranteed exact-name callable. Direct `/ardd-plan`-style UX parity is **unverified** | **Degraded / open question** |
| Skill-to-skill chaining ("run `/ardd-status`") | Model-triggers-skill-by-name works in principle (same mechanism as Claude Code's prose handoff), reliability unproven on Codex | **Degraded equivalent** |
| `AskUserQuestion` / `next_step_prompt` | No structured primitive → fall back to plain-text numbered questions in prose | **Degraded** (functional, less crisp; `next_step_prompt` becomes a text offer) |
| `Agent` isolation:"worktree" + delegation + fan-out | Worktrees + subagents + Handoff exist, but **no skill-callable structured launch that returns the branch name**. The four worktree scripts still run. What's missing is the *launch-and-report-back* primitive | **Impossible-as-designed today** → degrade to **inline-only** implementation (drop delegation/fan-out on Codex) |
| `.worktreeinclude` | Codex worktrees share `.git`; whether they copy gitignored skill files is unverified. If not, skills must be tracked or re-resolved per worktree | **Degraded / open question** |
| `.claude/settings.json` PostToolUse hook | `codex_hooks` post-tool-use hook (feature-flagged); this hook is source-side dogfood only and **not installed into targets today**, so it's not on the port's critical path | **Degraded equivalent, non-blocking** |

Net: **~4 localized Claude-specific primitives** (structured prompting,
worktree-delegation launch, `.worktreeinclude` copy, the hook) sit on top
of an already-neutral core. Only one — worktree-delegation launch — has no
adequate Codex equivalent, and its fallback (inline execution) is a
first-class supported ArDD path, not a broken state.

### Critical lenses (per `/ardd-audit`, applied to the proposal)

- **Simplicity / Proportionality (Principle VI, YAGNI):** the *strongest*
  challenge. Principle VI says introduce an abstraction "only once
  duplication across three or more concrete cases makes it unambiguous" and
  "do not design for hypothetical future requirements." A general
  per-harness adapter *build system* at **two** harnesses (Claude Code +
  Codex) is exactly the premature abstraction the principle forbids. This
  is decisive against option (b)-as-first-move.
- **DRYness / Robustness — the dominant risk:** skill behavior is not
  CI-testable (only structural lint + fixture smoke tests exist). Two prose
  surfaces that must stay behaviorally identical will drift, silently,
  because nothing checks them. Any architecture that **forks the prose** is
  therefore disqualified on ArDD's own terms. The mitigating fact: Codex's
  adoption of `SKILL.md` means we do **not** need a fork — the same skill
  file can serve both, with the handful of harness-specific clauses handled
  at install time.
- **Failure modes:** `codex_hooks` and worktree gitignore-copy behavior are
  unverified/feature-flagged; building on them risks a moving target. The
  inline-only fallback avoids depending on either.
- **Standardness:** `SKILL.md` and `AGENTS.md` are becoming cross-agent
  standards — a point *for* neutrality, and against anything Claude-only.
- **Semantics:** "Claude Code skill pack" is baked into the constitution's
  definition of ArDD; a second harness materially changes the project's
  scope.

### Committed decisions this proposal would touch/reverse

- **`constitution.md` Project Scope & Intent** — "artifact-driven-dev
  (ArDD) is a Claude Code skill pack" (§Project Scope & Intent, and echoed
  in `docs/concepts.md` line 142 "currently Claude Code-specific" and the
  README credits). Supporting a second harness **materially expands** this
  scope → at minimum a **MINOR constitution amendment** (SIR + version
  bump), not a silent change.
- **Principle IV (Two Install Targets)** — a Codex install path is a new
  target-side surface; the source/target discipline extends but the "only
  `install.sh` entry point" standing decision must absorb `--harness`.
- **Principle VI (YAGNI)** — governs *how much* architecture is justified
  now (see lenses). It does not forbid the port; it forbids the adapter
  build system as a first move.
- **Principle I (Skill Files Are the Product)** — the reason a fork is
  unacceptable and single-source is mandatory.

## Recommendation

**Worth doing — but only as a single-source, degraded, spike-first
increment. Route: `/ardd-backlog`.**

Codex's adoption of the identical `SKILL.md` format collapses what would
otherwise be a fork into a mostly-mechanical port. The right architecture
is **option (c) reframed as "the minimal first step *toward* (b), with no
parallel prose"**: keep one set of skill files, install them to Codex's
`.agents/skills/` via `install.sh --harness codex`, substitute the handful
of Claude-specific tool references at install time (or gate them in prose
with explicit actor/harness conditionals), and accept a **degraded Codex
v1**: inline-only implementation (no worktree delegation/fan-out),
plain-text questions instead of `AskUserQuestion`, no lint-on-write hook.
Crucially, the *degradation lives in behavior, not in duplicated prose* —
so Principle I's drift risk is contained.

Do **not** build the general adapter build system yet (Principle VI): with
only two harnesses, factor out just the ~4 localized Claude-specific
clauses, not a speculative plugin architecture. If a third harness ever
arrives, *that's* the concrete third case that justifies generalizing.

**Effort sizing and maintenance cost of each option:**

| Option | Effort | Long-term maintenance cost |
|---|---|---|
| (a) Forked `codex-prompts/` tree | **L** | **Prohibitive** — doubles the product surface with zero CI to catch behavioral drift; violates Principle I. Reject outright. |
| (b) Full harness-neutral core + generated per-harness adapters (build step) | **L** | Low *per-harness* once built, but the build system itself is unjustified at two harnesses (Principle VI). Right destination, wrong first move. |
| (c) Single-source + install-time substitution + degraded inline-only Codex v1 | **M** | Low — one prose surface; the only ongoing cost is keeping the small install-time substitution set current. **Recommended.** |
| (d) Don't do it | **S** (none) | Zero, but forgoes a now-cheap port and cedes the emerging cross-agent-skills standard. Only correct if the spike's open questions come back hostile. |

**Backlog entry scope:** "Single-source Codex CLI support — a
harness-neutrality audit of skill prose plus a degraded, inline-only Codex
install path (`install.sh --harness codex` → `.agents/skills/`,
`config.toml` MCP, `AGENTS.md`), delegation/fan-out and the lint hook
explicitly deferred; no parallel prose tree."

**First step (de-risking spike, before any install work):** verify the
open questions below on a real Codex CLI against a throwaway ArDD install —
they are the go/no-go gates. If exact-name skill invocation and
skill-to-skill chaining don't hold on Codex, the UX degradation may push
the verdict toward (d); the spike decides that cheaply before committing to
`M`-sized work.

## Rejected Alternatives

- **(a) Forked prose tree** — disqualified by Principle I: two
  behaviorally-coupled prose surfaces with no CI to check them is the exact
  drift trap ArDD is built to avoid. The `SKILL.md`-sharing discovery makes
  a fork not just risky but unnecessary.
- **(b) Full adapter build system now** — the correct long-term shape, but
  premature at two harnesses (Principle VI, YAGNI). Deferred until a
  concrete third case exists.
- **(d) Don't do it** — kept as the live fallback, not chosen: the port is
  now cheap enough (shared format) and the cross-agent skills standard real
  enough that a spike is worth spending before declining. Becomes the
  answer only if the spike's gates fail.

## Open Questions

1. **Exact-name invocation parity:** are Codex skills invocable by exact
   name (the `/ardd-plan` UX), or only model-triggered by
   description-match? The deprecated `/prompts:` channel gave literal
   invocation; skills may not. Go/no-go gate.
2. **Skill-to-skill chaining reliability:** does a skill's prose reliably
   trigger another skill by name on Codex, the way Claude Code's terminal
   handoffs assume? Go/no-go gate.
3. **Worktree file-copy:** do Codex worktrees carry gitignored
   `.agents/skills/` content in, or must ardd skills/scripts be tracked (or
   re-resolved) per worktree? Affects whether even inline-degraded runs see
   their scripts.
4. **`codex_hooks` stability:** is the lifecycle-hook feature flag a stable
   enough contract to eventually port `hook-lint-on-write.sh`, or should
   the hook stay Claude-only indefinitely?
5. **Constitution amendment framing:** does a second harness stay a MINOR
   scope expansion, or does redefining "Claude Code skill pack" to
   "multi-harness skill pack" rise to a redefinition (MAJOR)? Decide when
   the backlog item is planned, not now.
