# /ardd-plan

Generate an implementation plan from the current artifacts, any research
docs, any open feedback (`/ardd-feedback`), and optionally one or more
backlogged features (`/ardd-feature`). Run `/ardd-analyze` first — do not
plan over unresolved conflicts.

Usage: `/ardd-plan` plans from artifacts/research/feedback only. `/ardd-plan
<slug> [<slug> ...]` additionally targets one or more backlogged feature
entries from `.project/artifacts/features.md` — this is where a feature
idea's artifact design work actually happens (`/ardd-feature` only logs the
idea; it doesn't touch artifacts).

## Steps

1. **Check branch.** Run `.claude/skills/ardd-scripts/branch-info.sh` for
   `current`, `default`, and `on_default`.

   If `on_default` is `false`, skip to step 2 and derive `<slug>` from
   `current` (lowercase, non-alphanumeric runs → `-`, truncate to ~30 chars).

   If `on_default` is `true`, suggest a branch name — a semantic kebab-case slug derived
   from the conversation/artifacts if the topic is clear, otherwise a short
   arbitrary slug (4 hex chars, e.g. `openssl rand -hex 2` → `f2ed`). If one
   or more feature slugs were passed as arguments, prefer the first feature
   slug as the suggested branch name instead of generating one. Ask the
   user:
   - "Yes, create `<suggested-name>`"
   - "Yes, create a branch, but name it: ___"
   - "No, continue on default" (a worktree works too — set one up yourself
     and re-run from there; this gate doesn't automate worktree creation
     since it's environment-specific)

   On yes, run `git checkout -b <name>` and set `<slug>` to `<name>`. On no,
   set `<slug>` to a freshly generated short arbitrary hex token (same
   generation as above) and proceed on the default branch without asking
   again this run.

2. **Discover artifacts** by listing `.project/artifacts/`. Read every `.md`
   file present. If any are `status: draft`, warn the user and ask whether
   to proceed.

3. **If feature slugs were passed as arguments**, design and apply their
   artifact changes now — this absorbs what `/ardd-feature` used to do
   eagerly, deferred to the moment you actually choose to work an idea:

   a. **Look up each slug** in `.project/artifacts/features.md`. If a slug
      isn't found, tell the user and stop. If a slug's `Status` isn't
      `backlogged` (e.g. already `planned`/`tasked`/`implemented`), tell the
      user it's already past the backlog stage and stop — this skill only
      designs features forward from `backlogged`; to revise a feature already
      in flight, use `/ardd-feedback` (a reconsidered decision) or edit the
      relevant plan/artifact directly.

   b. **For each targeted feature, identify affected artifacts.** Use the
      feature's one-sentence description (and `Why:` line, if present) plus
      this table:

      | Artifact | Change if... |
      |---|---|
      | `constitution.md` | Feature introduces a new principle, exception, or production shortcut |
      | `datamodel.md` | New entities, fields, relationships, or normalization rules |
      | `infrastructure.md` | New integration, storage concern, sync strategy, or env var |
      | `adapters.md` | New external data source or changes to an existing adapter's fetch pattern |
      | `api.md` | New routes, changed response shapes, new env vars, or auth changes |
      | `ui.md` | New views, components, states, or interaction patterns |

      If the feature clearly doesn't touch an artifact, skip it — do not make
      cosmetic or precautionary edits.

   c. **Propose changes.** For each affected artifact, describe the specific
      additions or modifications as a summary (not full artifact text) so the
      user can review scope before anything is written:

      ```
      ## Proposed artifact changes — <feature slug>

      ### <artifact name>
      - <what changes and why>
      ```

      If a feature reveals a conflict with an existing decision, surface it
      here rather than silently working around it. Wait for confirmation
      across all targeted features before proceeding to (d).

   d. **Apply the confirmed changes** to every affected artifact. Before
      writing, run `.claude/skills/ardd-scripts/project-lock.sh check
      ardd-plan` — if it warns, surface the warning to the user (another
      invocation touched `.project/` recently) but proceed regardless; this
      is advisory, never a block. After writing, run `... touch ardd-plan`.
      - Apply changes consistently — if the same concept appears in multiple
        artifacts, use the same name, type, and shape everywhere.
      - Preserve all existing content not touched by this feature.
      - Add `[OPEN: ...]` items for decisions the feature introduces but
        doesn't resolve (genuine undecided-design-question gaps only — point
        to `DEFECTS.md`/`/ardd-verify` for known code-vs-artifact violations
        instead of narrating them into the artifact body).
      - Update frontmatter on each changed artifact: `last_updated`,
        `status` (`draft` if new open questions were introduced, else
        `stable`), and `diagram_status: stale` for renderable artifacts
        (unless currently `unrendered`).

   e. **Run a scoped cross-artifact check** — the same checks as
      `/ardd-analyze` steps 2–4, scoped to the artifacts just changed: verify
      new concepts are defined wherever referenced, flag new constitution
      violations, report new `[OPEN: ...]` items. This keeps the artifact set
      internally consistent before the plan itself is drafted against it.

   Remember which feature slugs were targeted here — you'll record them in
   the plan's frontmatter (step 8). Their `Status` flips from `backlogged`
   to `planned` later, in `/ardd-tasks`, when this plan is selected and
   approved — not here.

4. **Load any research documents** from `.project/plans/research-*.md` relevant
   to the current work.

5. **Load open feedback.** Glob `.project/feedback/feedback-*.md` and read
   frontmatter. Load every file with `status: open` as planning input —
   these came from the user manually inspecting the implementation (bugs,
   UX issues, reconsidered decisions). For each `## Reconsidered` item tagged
   with an artifact, diff it against that artifact's current text and surface
   the specific discrepancy to the user (what the artifact says vs. what the
   feedback says), asking them to confirm the override before proceeding —
   this is a decision reversal, not a routine update, so don't assume intent
   silently. On confirmation, the feedback wins and the plan includes a task
   to bring the artifact back in line; if the user declines, drop that item
   from the plan — it gets marked declined per the bookkeeping below, not
   incorporated, and the artifact is left untouched.

   **Finalize feedback bookkeeping now, not at plan approval** — the
   negotiation above is the only place the accept/decline decision for each
   item exists; a plan document only ever records *accepted* items (as
   tasks), so deferring this to approval would lose declined items with no
   way to recover their `[-]` marking later. For each loaded file: mark each
   item `[x]` if it was incorporated into the plan, or `[-]` if the user
   declined an override — mirroring `critique.md`'s resolution convention.
   Once every item in a file is `[x]` or `[-]`, flip that file's `status` to
   `planned` and set its `plan:` field to the plan filename you'll write in
   step 9 (`plan-<slug>-<today's date>.md` — both already known at this
   point). Planned feedback files are not edited further and become a
   historical record of what prompted the plan. If any item is still
   unresolved (e.g. the user wants to think about a declined override more),
   leave the file's `status` as `open` so the next `/ardd-plan` run picks up
   the remainder.

6. **Check constitution compliance** if `constitution.md` is present. Flag any
   planned patterns that require a Complexity Tracking entry per the simplicity
   principle.

7. **Check for existing approved plans.** List `.project/plans/plan-*.md` and
   read frontmatter. If any have `status: approved`, ask the user whether the
   plan you're about to draft supersedes one of them. On confirmation, flip
   that plan's `status` to `superseded` immediately — don't wait for this
   new plan's own approval, which now happens later, when `/ardd-tasks`
   selects it. A superseded-by-a-draft-that's-never-used plan is
   an acceptable outcome, not a bug: `/ardd-analyze`/`STATUS.md` surface
   open draft counts either way, so an abandoned replacement doesn't go
   unnoticed.

8. **Draft the plan** covering:
   - **Goal** — what this plan delivers (one sentence)
   - **Scope** — what is and is not included
   - **Technical Approach** — how the system will be built; reference artifact
     decisions rather than repeating them
   - **Phase Breakdown** — ordered phases with dependencies called out; each
     phase produces a testable, demonstrable increment. Feedback items tagged
     with an artifact become artifact-revision tasks (`[artifacts: name]`);
     untagged feedback items become ordinary code-change tasks. Reference
     which feedback item each such task addresses. Tasks implementing a
     feature targeted in step 3 reference that feature's slug.
   - **Complexity Tracking** — table of justified deviations from the simplicity
     principle (if a constitution is present)
   - **Open Questions** — anything that must be resolved before or during
     implementation
   - **Production Annotation Summary** — list of known production shortcuts to
     annotate during implementation

9. **Write the plan** to `.project/plans/plan-<slug>-<YYYY-MM-DD>.md` with
   frontmatter. As in step 3d, run `.claude/skills/ardd-scripts/project-
   lock.sh check ardd-plan` first (surface any warning, don't block on it),
   and `... touch ardd-plan` after writing:

   ```yaml
   ---
   status: draft        # draft -> approved -> superseded
   branch: <slug>
   created: YYYY-MM-DD
   features: [<slug>, ...]   # feature slugs targeted in step 3; omit or [] if none
   ---
   ```

10. **Present a summary** to the user: phases, key decisions, open questions.
    The plan is saved at `.project/plans/plan-<slug>-<YYYY-MM-DD>.md` as
    `status: draft` — there's no separate approval step here. Running
    `/ardd-tasks` and selecting this plan is what approves it (flips it to
    `approved`, and flips its targeted `features:` slugs from `backlogged`
    to `planned`) and generates its tasks, in one step.

    Run `/ardd-analyze` now to refresh `STATUS.md`'s recommended next step —
    artifacts and/or `features.md` changed in this run, so don't wait for the
    user to ask for it.
