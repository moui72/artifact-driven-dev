# Coming from Spec Kit

A translation guide for [Spec Kit](https://github.com/github/spec-kit)
users. (Spec Kit's slash commands are written here without their leading
slash — `specify`, `plan`, `tasks` — to keep them visually distinct from
ArDD's `/ardd-*` commands.)

## The structural difference, in one sentence

**Spec Kit's unit of truth is the per-feature spec directory
(`specs/NNN-feature/`), born with the feature and effectively frozen once
it ships; ArDD has no per-feature specs at all — its unit of truth is a
small set of cross-cutting living documents (the artifacts) that outlive
every feature.** A feature in ArDD is a one-line register entry until you
plan it, at which point its design is written *directly into* the
system-level artifacts (data model, infrastructure, UI, …) as a reviewed,
coordinated edit. There is no spec.md to write, and nothing corresponding
to one to fall out of date.

Everything else follows from that. If your first question is "where do I
put the spec?" — you don't; you put the *decisions* in the artifacts and
the *idea* in the register.

## Command mapping

| Spec Kit | ArDD | Notes |
|---|---|---|
| `specify init` | `curl … new.sh \| sh` (or `--existing`) | [install.md](../install.md) |
| `constitution` / `memory/constitution.md` | `/ardd-refine constitution` / `.project/artifacts/constitution.md` | Same role, same MAJOR/MINOR/PATCH + sync-impact-report machinery — this one maps 1:1 |
| `specify` → `spec.md` | **No equivalent.** `/ardd-backlog <idea>` logs a one-liner; the design work happens later, inside `/ardd-plan <slug>` | The biggest adjustment — see above |
| `clarify` | `[OPEN: <question>]` markers + `/ardd-refine`'s targeted clarifying questions (+ `/ardd-init`'s interview at setup) | Open questions live *in* the documents, not in a Q&A pass |
| `plan` → plan.md, research.md, data-model.md, contracts/ | `/ardd-plan` → one plan file. The data model is the *global* `datamodel.md` artifact; research is a separate skill (`/ardd-research`) | An ArDD plan is a batch execution document — it can span several features plus bug fixes and defect repairs |
| `tasks` → tasks.md | Folded into `/ardd-plan`: approving at its checkpoint generates the tasks file; `--from <plan>` re-tasks | No separate command |
| `[P]` parallel markers | `[parallel]` markers | Same idea |
| `implement` | `/ardd-implement` | Plus things Spec Kit doesn't have: background worktree delegation, fan-out, and reconcile mode for interrupted runs |
| `analyze` | `/ardd-status` | Runs automatically after most state-changing skills |
| — | `/ardd-feedback`, `/ardd-defects`, `/ardd-audit`, `/ardd-tracker`, `/ardd-diagram` | No Spec Kit equivalents: post-ship observation intake, artifact-vs-code drift detection, decision pressure-testing, issue-tracker sync, diagrams |

Two workflow differences that don't fit a table row:

- **Batching.** Spec Kit is one-feature-one-plan. An unscoped `/ardd-plan`
  sweeps *all* open feedback into one plan; you scope it (a feature slug,
  a feedback filename) to keep plans narrow. To work N features in
  parallel, plan them separately — one run per slug — so each gets its own
  tasks file ([parallel-work.md](parallel-work.md)).
- **Branch identity.** Spec Kit welds branch ↔ spec number. ArDD
  deliberately doesn't: a plan records the branch inline work *would* use,
  but the ref may never exist (solo mode plans commit straight to your
  default branch), and delegated runs get worktree branches named at
  creation time.

## Vocabulary collisions

Same words, different meanings — the ones that will trip you:

- **"spec"** — Spec Kit: a concrete per-feature file, the central
  deliverable. ArDD: doesn't exist as a document; the artifacts
  collectively play the role.
- **"artifact"** — Spec Kit usage (loosely): anything the pipeline
  generates. ArDD: a term of art for the living decision documents *only*
  — plans and tasks files are explicitly not artifacts.
- **"plan"** — Spec Kit: per-feature design bundle. ArDD: a possibly
  multi-feature batch execution document with an approval lifecycle
  (`draft → approved → superseded`).
- **"feature"** — Spec Kit: a numbered spec directory plus its branch.
  ArDD: a register file with a one-sentence body and a four-state
  lifecycle.
- **"tasks"** — nearly congruent, except ArDD's tasks *file* is a
  first-class unit with its own status enum and worktree-claiming
  semantics; it's the unit of parallelism.

## What you'll miss, honestly

- **A per-feature acceptance record.** Spec Kit's spec.md carries user
  stories and acceptance criteria you can show a stakeholder. ArDD's
  equivalent record is distributed: the register entry (what and why), the
  plan (how, phased), and the artifact diffs (the design). If a standalone
  per-feature document is load-bearing for your process, that's a real
  gap, not a hidden feature.
- **Agent-agnosticism.** Spec Kit works across Copilot, Cursor, Gemini,
  etc.; ArDD is Claude Code-specific.
- **Requirements discovery.** By design — if you're working from a vague
  brief, use Spec Kit.

## What pulls Spec Kit users over

The execution machinery past the point where Spec Kit's story ends:
interrupted-run recovery (`/ardd-implement`'s reconcile mode), background
delegation with parallel fan-out, state that can't lie (register flips
land atomically with the code, on merge), drift detection
(`/ardd-defects` — specs rot silently; artifacts get audited against the
code), and reversal-safe feedback intake (a reconsidered decision is
confirmed explicitly at planning time, never silently absorbed).

## Migrating a project that has `specs/`

There's no importer, so the honest recipe is manual but short:

1. Run the `--existing` bootstrap and `/ardd-init` — the codebase survey
   captures everything your *shipped* specs described that actually got
   built (that's the point: the code, not the old spec, is the source).
   Accept the offered feature-register extraction to backfill shipped
   capabilities as `implemented` entries.
2. Your Spec Kit constitution's content carries over almost verbatim —
   hand it to `/ardd-refine constitution` as guidance.
3. Each *unshipped* spec becomes a `/ardd-backlog` entry (one line — the
   idea), and its design detail gets pasted into the conversation when you
   eventually run `/ardd-plan <slug>`, which is where that detail belongs.
4. Keep or delete `specs/` as history; nothing in ArDD reads it.
