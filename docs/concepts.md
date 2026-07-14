# Concepts — the ArDD mental model

Everything ArDD does follows from a handful of ideas. This page is the
one place they're all laid out; the guides and reference pages assume
them.

## Artifacts: a declared set of living documents

Artifacts (`.project/artifacts/*.md`) are the system's actual state — the
decisions you've made, written down and kept current. They are **captured,
not generated**: ArDD assumes you arrive with clarity and need a system to
record, cross-check, and execute against it, not one that discovers
requirements for you.

There is no fixed set. A constitution (principles, quality standards,
non-negotiables) exists nearly always; `infrastructure`, `datamodel`,
`ui`, `api`, `adapters`, or anything custom exists only if the project has
that concern. `/ardd-init` proposes a set; `/ardd-refine <new-name>`
creates more anytime. This repo's own dogfooded `.project/` carries only a
constitution.

Two properties gate everything downstream:

- **`status: draft` vs `stable`** — draft means open questions remain and
  the artifact isn't safe to plan against. `/ardd-status` warns before
  planning over drafts.
- **`[OPEN: <question>]`** — an honest open question beats an invented
  decision, everywhere in the system. Nothing ever resolves one by
  picking something plausible.

## The feature register: ideas with a lifecycle

`.project/features/` holds one file per feature idea, advancing
`backlogged → planned → tasked → implemented`. Logging is deliberately
cheap (`/ardd-backlog` writes one file and nothing else); the design work
happens later, when `/ardd-plan <slug>` targets the idea. The register is
what `/ardd-tracker` mirrors to an issue tracker.

## Three intake streams, one consumer

Work enters ArDD three ways, and all three converge on the next
`/ardd-plan` run:

| Stream | Skill | What it is |
|---|---|---|
| Features | `/ardd-backlog` | New capabilities, logged for later design |
| Feedback | `/ardd-feedback` | What *you* observed using the built thing — bugs, UX, reconsidered decisions |
| Defects | `/ardd-defects` | What *the code* says vs. what the artifacts claim |

The plan run negotiates each item (incorporate or decline, with explicit
confirmation for decision reversals), drafts a phased plan, pauses at an
approval checkpoint, and — on approval — generates the ordered task list
that `/ardd-implement` executes.

## Handoffs run through files on disk

Skills never share in-memory state. Every handoff is a file: frontmatter
`status` fields, `[artifacts: ...]` tags on task lines, `plan:` /
`features:` frontmatter linking tasks back to plans and features. A
consequence: any skill can pick up exactly where another left off, in a
different session, after a crash, or on a different branch — the disk is
the conversation. (Schemas: [reference/project-files.md](reference/project-files.md).)

A related division of labor, applied everywhere: **skills decide *when*
(judgment); scripts do the writing (determinism)**. Deciding a feature is
implemented takes judgment; flipping its status field is
`ardd-state.sh feature-flip`, which validates state and refuses illegal
transitions. (The scripts: [reference/scripts.md](reference/scripts.md).)

## State rides the work branch

All state a run produces — checkbox marks, tasks-file status flips, the
register's `tasked → implemented` flip — is committed on the branch the
work happens on and lands on the default branch **only when that branch
merges, atomically with the code**. The default branch means *merged
truth*; worktrees and feature branches mean *in-flight truth*; and the
register can never claim work is done before the code has landed. The
full model, including delegation and fan-out:
[guides/parallel-work.md](guides/parallel-work.md).

## Single-writer report files

Four generated reports each have exactly one writing skill:

| File | Writer |
|---|---|
| `.project/STATUS.md` | `/ardd-status` |
| `.project/DEFECTS.md` | `/ardd-defects` |
| `.project/TRACKER.md` | `/ardd-tracker` |
| `.project/audit.md` | `/ardd-audit` |

Everything else treats them as read-only, which makes them **disposable
at merge**: take either side of any conflict and re-run the owning skill —
it regenerates from disk. `STATUS.md` doubles as the single re-entry point
after any interruption: it always says where things stand and names the
recommended next step.

## Checking happens at four layers

Structural validity (`/ardd-lint`), cross-artifact consistency
(`/ardd-status`), artifact-vs-code drift (`/ardd-defects`), and the
quality of the decisions themselves (`/ardd-audit`). They don't overlap —
[guides/checking.md](guides/checking.md) compares them.

## Two operating modes

`workflow_mode` in the constitution frontmatter (`solo` | `collaborative`,
absent = `solo`) governs where in-progress work lives: solo commits
inline work to the local default branch and merges delegated worktrees
eagerly; collaborative never touches the local default branch and moves
everything through pushed branches and draft PRs. Details — and the other
workflow knobs (`next_step_prompt`, `delegation`, `merge_policy`) — in
[reference/configuration.md](reference/configuration.md).

## When artifacts earn their keep

An agent in an existing codebase normally infers conventions by
pattern-matching nearby code — usually enough, with a good `CLAUDE.md`
covering the rest. Artifacts pay for their overhead when the codebase
*can't* serve as that implicit spec:

- **Greenfield** — no code to pattern-match yet; artifacts are the only
  explicit source of truth until enough code exists to become one.
- **A major pivot** — the code reflects patterns you're moving away from;
  an agent copying it faithfully reproduces what you're escaping.
  Artifacts declare the target state independent of what the code does
  (though you still refine them there yourself — `/ardd-init` captures
  the *current* patterns as a starting draft).

Where the codebase is already a trustworthy implicit spec — mature,
consistent, following the conventions you want — ArDD's overhead buys you
less than a solid `CLAUDE.md`. The secondary benefit that remains (code
shows *how*, artifacts record *why*) rarely justifies the process alone.

## vs. Spec Kit

ArDD is in the same lineage as
[Spec Kit](https://github.com/github/spec-kit), which aims at
*discovering* requirements — structured elicitation, user stories, a full
spec-to-implementation pipeline, agent-agnostic. ArDD assumes the
decisions already exist and need capturing and executing — narrower in
scope, not lighter in absolute terms, and currently Claude Code-specific.
If you're working from a vague brief, Spec Kit is the right tool.
Migrating, or just fluent in Spec Kit's vocabulary?
[guides/from-spec-kit.md](guides/from-spec-kit.md) is the command-by-command
translation.
