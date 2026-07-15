---
topic: Codex CLI de-risking spike — exact-name skill invocation and skill-to-skill chaining (go/no-go gates for codex-second-harness-support)
date: 2026-07-15
status: complete
---

# Research: Codex CLI de-risking spike — invocation & chaining gates

## Question

The `codex-second-harness-support` feature (backlogged 2026-07-15) is gated
on a de-risking spike before any install work. Two go/no-go questions,
carried over from the accepted recommendation in
`research-codex-cli-second-harness-2026-07-15-2d3d.md` (Open Questions 1–2):

- **(a) Exact-name invocation parity** — can a Codex skill be invoked by
  exact name (the `/ardd-plan` UX), or is it only model-triggered by
  description-match?
- **(b) Skill-to-skill chaining reliability** — does one skill's prose
  reliably trigger another skill by name on Codex, the way ArDD's terminal
  handoffs ("run `/ardd-status`") assume on Claude Code?

Plus a coordinator-added lens: vet the proposed single-source +
install-time-substitution architecture against how GitHub's **Spec Kit**
(`github/spec-kit`) already ships multi-agent (incl. Codex) support from one
source.

Scope caveat: this spike is **documentation- and prior-art-based**, not a
run against a live Codex CLI on a throwaway ArDD install. It can close gate
(a) with high confidence and de-risk gate (b), but a residual live check on
(b) remains — called out in Open Questions.

## Findings

### Gate (a): Exact-name invocation — SUPPORTED (via `$`, not `/`)

The feared failure mode — skills being *only* description-triggered with no
deterministic exact-name channel — **did not materialize.** Codex CLI
supports explicit, literal-name skill invocation. Three independent points:

- Codex's own skills docs (now at `learn.chatgpt.com/docs/build-skills`,
  redirected from `developers.openai.com/codex/skills`): "In CLI/IDE, run
  `/skills` or type `$` to mention a skill," alongside implicit invocation —
  "Codex can choose a skill when your task matches the skill `description`."
  So both channels exist; explicit is `$<name>`.
- The sigil differs from Claude Code and is a hard fact, not a doc gap:
  Codex issue **#11817** ("CLI: `/<skill>` unrecognized while `$<skill>`
  invocation works") reports `/prd` returns "Unrecognized command" while
  `$prd` works; **closed as not planned**. Companion request #13893 ("Add
  custom slash commands from SKILL.md") closed with no maintainer action.
  Codex's `/`-commands are a fixed built-in set (`/model`, `/permissions`,
  `/plan`, …); **users cannot define custom `/`-commands.** The exact-name
  channel for user skills is `$`.
- **Strongest evidence — prior art in production.** GitHub's Spec Kit ships
  Codex support today and invokes its skills as **`$speckit-<command>`**
  (e.g. `$speckit-plan`) — the direct analogue of Claude Code's
  `/speckit-<command>`. Exact-name, deterministic, one skill per command
  directory.

**Verdict (a): GO.** `/ardd-plan` maps cleanly to `$ardd-plan`. This is a
deterministic literal-name invocation, functionally equivalent to Claude's
slash dispatch — only the sigil changes.

Implication the prior research under-counted: the `/ardd-X` → `$ardd-X`
**invocation-sigil rewrite is a fifth install-time substitution**, on top of
the ~4 already inventoried (AskUserQuestion, Agent worktree delegation,
`.worktreeinclude`, `next_step_prompt`). It touches (i) any user-facing
invocation hint in skill/description prose and (ii) every terminal-handoff
line ("run `/ardd-status`" → "run `$ardd-status`"). Mechanical, but it must
be on the substitution list explicitly or the handoff UX silently breaks on
Codex.

### Gate (b): Skill-to-skill chaining — PLAUSIBLE, one residual live check

ArDD's terminal handoffs work on Claude Code because a skill's prose ("run
`/ardd-status`") reliably causes the model to invoke that named skill. On
Codex the mechanism is the same *class* (model reads instruction prose,
invokes a named skill), and Codex documents both explicit (`$name`) and
implicit (description-match) invocation — so a handoff phrased as "use the
`ardd-status` skill" / "run `$ardd-status`" has a supported path.

What is **not** documented anywhere found: a reliability guarantee that a
skill mid-execution auto-invokes another named skill from its own
instructions. Neither Codex's docs nor the `frr.dev` write-up
("In Codex, a Skill Is Not a /Command") address inter-skill chaining, and
Spec Kit's per-agent structure (each command a self-contained `SKILL.md`
under `.agents/skills`, dirs prefixed `speckit-`) does **not lean on
chaining** — its commands are single-shot spec steps a human invokes in
sequence, so its production success does not prove ArDD's handoff chains
work on Codex.

`frr.dev` also flags a design nuance worth heeding: Codex draws a sharper
line than Claude Code between a *command* (predictable, immediate control
action) and a *skill* (a taught way of working, reasoning-mediated). ArDD's
handoffs are the reasoning-mediated kind, which is where they belong — but
it means the handoff is a model decision, not a mechanical guarantee, on
Codex just as on Claude.

**Verdict (b): SOFT-GO.** Mechanism is present and same-class; no evidence
against it. But because ArDD's whole flow leans on handoff chains
(`/ardd-plan` → analyze → `/ardd-status`, and the `next_step_prompt`
offers), this is the one gate that only a **live throwaway-install smoke
test** can fully close. It is cheap and must be the first implementation
task, not deferred.

### Spec Kit comparison — the proposed architecture is trodden ground

`github/spec-kit` is direct, production prior art for exactly ArDD's
proposed shape, and it validates the approach:

- **Single source, per-agent install-time transformation.** One spec/command
  source; at install a `CommandRegistrar` applies **agent-specific
  transformations** and writes into per-agent directories. This is
  precisely ArDD's "single-source + install-time substitution" (option c),
  proven at ~30+ agents — evidence *for* the approach and against a forked
  prose tree.
- **Per-agent directories, not a shared physical dir.** Codex →
  **`.agents/skills`** with `$speckit-<command>`; Claude Code →
  **`.claude/skills`** with `/speckit-<command>`. Same `SKILL.md` format,
  same `$ARGUMENTS` placeholder, directories prefixed per tool. This
  matches the prior research's target-path plan (`.agents/skills` for
  Codex) — confirmed, not guessed.
- **Skills mode is a first-class, opt-in install variant.** Spec Kit exposes
  `specify init <proj> --integration codex` and
  `--integration-options="--skills"`. Analogue for ArDD:
  `install.sh --harness codex` — the same "declare the harness at install
  time" ergonomics.

**Patterns worth adopting:**
1. A single install-time transformer (Spec Kit's `CommandRegistrar` role)
   that owns *all* per-harness substitutions in one place — including the
   new `/`→`$` sigil rewrite — rather than scattering harness conditionals
   through skill prose. Keeps Principle I's single-prose-surface intact.
2. Shared `$ARGUMENTS` placeholder convention already works on both harnesses
   — ArDD skill args need no per-harness handling.
3. Separate physical install dirs per harness (`.agents/skills` vs
   `.claude/skills`); don't try to make one directory serve both.

**Pitfalls worth avoiding:**
1. Spec Kit notes Claude-only frontmatter niceties (e.g. `argument-hint`)
   that other agents ignore. ArDD's Claude-specific frontmatter/tool
   references (`AskUserQuestion`, `Agent` `isolation:"worktree"`) must be
   *stripped or degraded* for Codex, not merely emitted-and-ignored —
   emitting Claude tool calls Codex can't honor would produce broken
   behavior, not graceful degradation.
2. Spec Kit's commands are single-shot and don't chain, so it gives ArDD
   **no free evidence on gate (b)**. Don't read Spec Kit's success as
   proof ArDD's handoff chains work on Codex — that still needs the live
   smoke test.

## Recommendation

**GO — proceed with `codex-second-harness-support` as specced (option c,
single-source + install-time substitution), with a mandatory live
chaining smoke test as its first implementation step.**

Both gates clear the bar this spike set: (a) is a firm GO — Codex has
deterministic exact-name invocation (`$ardd-plan`), and Spec Kit ships this
exact pattern in production; the only delta is the `/`→`$` sigil, which
becomes one more mechanical install-time substitution. (b) is a soft GO —
the chaining mechanism is present and same-class, with no evidence against
it, but ArDD leans on handoff chains heavily enough that a cheap live check
must confirm reliability before the substitution work is trusted end-to-end.

The feature is already backlogged, so the route is **keep it and let
`/ardd-plan codex-second-harness-support` design it** — folding in three
spike outputs the current feature record doesn't yet capture:
1. Add the **`/ardd-X` → `$ardd-X` invocation-sigil rewrite** as a fifth
   install-time substitution (invocation hints + terminal-handoff prose).
2. Make the plan's **first task a live throwaway-install smoke test** of
   skill-to-skill chaining on a real Codex CLI (the one gate docs can't
   close); its result is the true final go/no-go, and a failure still
   falls back to option (d) don't-do-it.
3. Adopt Spec Kit's **single install-time transformer** pattern (one place
   owns every per-harness substitution) and its per-agent-directory layout;
   avoid emitting Claude-only tool calls to Codex (strip/degrade, don't
   emit-and-ignore).

The fallback remains unchanged: if the live chaining smoke test comes back
hostile, the UX degradation tips the verdict to (d).

## Rejected Alternatives

- **No-go / drop now.** Rejected: the feared blocker (no exact-name
  invocation) is disproven, and mature prior art (Spec Kit) ships the exact
  architecture for Codex. Declining now would forgo a de-risked, cheap port.
- **Proceed straight to implementation without a live chaining test.**
  Rejected: gate (b) is genuinely unclosed by docs; ArDD's flow is
  chaining-dependent, so skipping the live check risks building the whole
  substitution layer on an unverified assumption. The test is cheap; do it
  first.
- **Treat Spec Kit's production success as sufficient proof for both gates.**
  Rejected: Spec Kit validates (a) and the single-source architecture, but
  its commands don't chain, so it says nothing about (b).

## Open Questions

1. **Live chaining reliability (the one residual gate).** On a real Codex
   CLI against a throwaway ArDD `--harness codex` install, does a skill's
   terminal-handoff prose ("run `$ardd-status`") reliably invoke the named
   skill, across the handoffs ArDD depends on? This is a plan task, and its
   answer is the final go/no-go. Docs can't close it.
2. **Does the `$`-invocation accept trailing arguments** the way ArDD skills
   expect (`$ardd-plan <slug>`)? Spec Kit shares the `$ARGUMENTS`
   placeholder, which is encouraging, but confirm ArDD's arg-passing on
   Codex during the same smoke test.
3. Carried forward from the parent research (unchanged by this spike):
   Codex worktree gitignored-file copy behavior; `codex_hooks` stability;
   and the MINOR-vs-MAJOR constitution-amendment framing — all decided when
   the feature is planned, not now.
