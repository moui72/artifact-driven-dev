# /ardd-plan

Generate an implementation plan from the current artifacts, any open
feedback (`/ardd-feedback`), and optionally one or more backlogged features
(`/ardd-feature`). Run `/ardd-analyze` first — do not plan over unresolved
conflicts.

Usage: `/ardd-plan` plans from artifacts/feedback only. `/ardd-plan
<slug> [<slug> ...]` additionally targets one or more backlogged feature
entries from `.project/artifacts/features.md` — this is where a feature
idea's artifact design work actually happens (`/ardd-feature` only logs the
idea; it doesn't touch artifacts).

## Steps

1. **Check branch.** Run `.claude/skills/ardd-scripts/branch-info.sh` for
   `current`, `default`, and `on_default`.

   If `on_default` is `false`, skip to step 2 and derive `<slug>` from
   `current` (lowercase, non-alphanumeric runs → `-`, truncate to ~30 chars).

   If `on_default` is `true`, suggest a branch name — a semantic kebab-case
   slug derived from the conversation/artifacts if the topic is clear,
   otherwise a short arbitrary slug (4 hex chars, e.g. `openssl rand -hex 2`
   → `f2ed`). If one or more feature slugs were passed as arguments, prefer
   the first feature slug as the suggested branch name instead of generating
   one. Ask the user:
   - "Yes, create `<suggested-name>`"
   - "Yes, create a branch, but name it: ___"
   - "No, continue on default" (a worktree works too — set one up yourself
     and re-run from there; this gate deliberately doesn't delegate to a
     worktree subagent the way `/ardd-implement`/`/ardd-converge` do — the
     draft plan this run produces (step 9) is itself the state
     `/ardd-tasks` needs to see on the default branch, and there's no
     separate coarse marker to pre-commit the way a tasks file's
     `ready→in-progress` flip provides; isolating the plan in a worktree
     would just trap it there until a manual merge, severing the
     plan→tasks handoff. Same reasoning that already keeps `/ardd-tasks`
     gate-free.)

   On yes, run `git checkout -b <name>` and set `<slug>` to `<name>`. On no,
   set `<slug>` to a freshly generated short arbitrary hex token (same
   generation as above) and proceed on the default branch without asking
   again this run.

   **Collaborative-mode note.** If `workflow_mode: collaborative` in
   `.project/artifacts/constitution.md` frontmatter (grep it; absent =
   `solo`), remember that a delegated `/ardd-implement` worktree branches
   from `origin/<default>` and can only see files that have reached the
   remote. So the plan this run writes (and, later, the tasks file
   `/ardd-tasks` generates from it) must reach `origin/<default>` — via a
   merged PR or a push — before delegated implementation can pick it up.
   Solo mode needs nothing extra here: `worktree-align.sh` fast-forwards the
   local default branch's unpushed commits into the delegated worktree, so
   the plan is visible without pushing.

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

4. **Load open feedback.** Glob `.project/feedback/feedback-*.md` and read
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
   step 8 (`plan-<slug>-<today's date>.md` — both already known at this
   point). Planned feedback files are not edited further and become a
   historical record of what prompted the plan. If any item is still
   unresolved (e.g. the user wants to think about a declined override more),
   leave the file's `status` as `open` so the next `/ardd-plan` run picks up
   the remainder.

5. **Check `.project/DEFECTS.md` for unaddressed defects**, if present. Each
   listed defect gets a stable identifier — a short hash of its description
   text (e.g. `printf '%s' "<description>" | shasum | cut -c1-8`) — used to
   track whether it's already been surfaced to the user by a prior
   `/ardd-plan` run, so the same defect isn't re-prompted every time. Glob
   `.project/plans/plan-*.md` and collect the union of every plan's
   `surfaced-defects:` frontmatter list (if present) into an
   "already-surfaced" set. For each `DEFECTS.md` entry whose identifier
   isn't in that set: present it to the user and ask whether to include a
   fix task for it in this plan. Whether accepted or declined, record its
   identifier in the `surfaced-defects:` list of the plan you're drafting
   (written in step 9) — declining still counts as "surfaced," which is what
   stops it from being re-prompted on every future run. If accepted, the fix
   task is added to the Phase Breakdown in step 8, tagged `[defect:
   <identifier>]`.

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
     feature targeted in step 3 reference that feature's slug. Tasks fixing a
     defect accepted in step 5 reference that defect's identifier.
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
   surfaced-defects: [<id>, ...]   # DEFECTS.md identifiers surfaced in step 5; omit or [] if none
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
