---
name: ardd-plan
tier: core
description: Draft a phased plan from artifacts, feedback, and backlogged features, pause at an approval checkpoint, then generate its ordered task list; --from <plan> re-tasks an approved plan without re-planning.
---

# /ardd-plan

Generate an implementation plan from the current artifacts, any open
feedback (`/ardd-feedback`), and optionally one or more backlogged features
(`/ardd-backlog`); pause at an explicit approval checkpoint; then, on
approval, generate the ordered task list the plan implies. One skill spans
the whole plan→approve→task arc — there is no separate task-generation command.
Run `/ardd-status` first — do not plan over unresolved conflicts.

Usage: `/ardd-plan` plans from artifacts/feedback only. `/ardd-plan
<slug> [<slug> ...]` additionally targets one or more backlogged feature
entries from the feature register (`.project/features/`) — this is where a feature
idea's artifact design work actually happens (`/ardd-backlog` only logs the
idea; it doesn't touch artifacts). Substantial or decision-reversing ideas:
vet with `/ardd-research` first, before planning them.

`/ardd-plan --from <plan-file>` is the **re-task mode**: it skips planning
entirely and re-enters at the tasking half (step 11) for the named,
already-written plan — regenerating a fresh tasks file without re-drafting the
plan. Use it to re-task an approved plan (e.g. after abandoning a stale tasks
file, or to split tasks differently). The `<plan-file>` is a
`.project/plans/plan-*.md` filename, with or without its path.

Any argument that looks like a feedback filename (`feedback-*.md`, with or
without its `.project/feedback/` path) is a **feedback scope** instead of a
feature slug: step 4 then consumes only the named feedback file(s), and
every other open feedback file is neither presented nor marked — it stays
`status: open`, untouched, for a later run. Without a feedback-scope
argument, step 4 loads all open feedback files as before. This is how two
open feedback files feed two separate plans without one run accidentally
binding (or `[-]`-declining) the other's items.

Arguments of the form `defect:<id>` name specific `DEFECTS.md` entries
(the 8-char identifiers `/ardd-defects` and `defects-unsurfaced.sh`
compute), and the literal argument `defects` names all current entries —
these are **defect scopes**: step 5 then runs in explicit-selection mode
and re-offers the named entries even if a prior plan already surfaced
them. The `defect:` prefix (and the bare literal `defects`) is what
disambiguates a defect scope from feature slugs and feedback filenames in
the same argument list — a plain kebab-case argument is always a feature
slug, `feedback-*.md` is always a feedback scope.

## Shape of a run

Steps 1–10 draft and write the plan and stop at the **approval checkpoint**
(step 10). Only on explicit approval do steps 11–15 approve the plan and
generate its tasks file. This restores a real approve/revise/stop gate
between planning and tasking — selecting a plan is a decision, not a
keystroke. **Re-task mode (`--from <plan-file>`) skips straight to step 11**
for the named plan; steps 2–10 do not run.

## Steps

1. **Check branch.** Run `.claude/skills/ardd-scripts/branch-info.sh` for
   `current`, `default`, and `on_default`, and grep
   `.project/artifacts/constitution.md` frontmatter for `workflow_mode`
   (absent = `solo`). (Applies in both normal and `--from` mode.)

   If `on_default` is `false` (either mode), skip to step 2 and derive
   `<slug>` from `current` via
   `.claude/skills/ardd-scripts/ardd-state.sh slug "<current>"`
   (deterministic kebab sanitization — don't hand-derive it).

   **Solo mode has no branch gate.** If `on_default` is `true` and
   `workflow_mode` is `solo` (or absent), do not prompt — proceed on the
   current branch (normally the default branch) and commit the plan and
   tasks files there: a `ready` tasks file on the default branch is planned
   truth, already accepted there (decision record 0005). Set `<slug>` to the
   first feature-slug argument if any were passed, else a freshly generated
   short arbitrary slug (4 hex chars, e.g. `openssl rand -hex 2` → `f2ed`).
   A worktree still works if you want isolation — set one up yourself and
   re-run from there; this skill never delegates to a worktree subagent:
   the draft plan and tasks file this run produces are themselves the state
   the next steps need to see, and isolating them in a worktree would trap
   them there until a manual merge.

   **Collaborative mode keeps the gate.** If `on_default` is `true` and
   `workflow_mode` is `collaborative`, suggest a branch name — a semantic
   kebab-case slug derived from the conversation/artifacts if the topic is
   clear, otherwise a short arbitrary slug (4 hex chars, as above). If one
   or more feature slugs were passed as arguments, prefer the first feature
   slug as the suggested branch name instead of generating one. Ask the
   user:
   - "Yes, create `<suggested-name>`"
   - "Yes, create a branch, but name it: ___"
   - "No, continue on default" (a worktree works too — set one up yourself
     and re-run from there; this gate never delegates to a worktree
     subagent, for the same trapped-state reason as above.)

   On yes, run `git checkout -b <name>` and set `<slug>` to `<name>`. On no,
   set `<slug>` to a freshly generated short arbitrary hex token (same
   generation as above) and proceed on the default branch without asking
   again this run.

   Either way, the plan's `branch: <slug>` frontmatter (step 9) records the
   branch name `/ardd-implement`'s inline path *would* create for this
   plan's work — when no branch was created here (the solo no-gate path,
   or a collaborative "No"), that ref may never come to exist, and that's
   fine: `completion-flip-check.sh` treats a nonexistent ref as not-merged
   and stays silent.

   If this run discovers it started on a stale branch and merges or
   rebases the default branch in before proceeding: single-writer report
   files (STATUS.md, DEFECTS.md, TRACKER.md, audit.md) are disposable at
   merge/rebase — take either side without deliberation, never
   hand-reconcile, never re-apply; the owning skill regenerates from
   disk. Conflict markers in a generated report are noise, not data
   loss.

   **Collaborative-mode note.** If `workflow_mode: collaborative` in
   `.project/artifacts/constitution.md` frontmatter (grep it; absent =
   `solo`), remember that a delegated `/ardd-implement` worktree branches
   from `origin/<default>` and can only see files that have reached the
   remote. So the plan *and* tasks file this run writes must reach
   `origin/<default>` — via a merged PR or a push — before delegated
   implementation can pick them up. Solo mode needs nothing extra here:
   `worktree-align.sh` fast-forwards the local default branch's unpushed
   commits into the delegated worktree, so both are visible without pushing.

   **Re-task mode:** if invoked with `--from <plan-file>`, do step 1, then
   skip directly to step 11 with `<plan-file>` as the chosen plan. Steps
   2–10 do not run.

2. **Discover artifacts** by listing `.project/artifacts/`. Read every `.md`
   file present. If any are `status: draft`, warn the user and ask whether
   to proceed.

3. **If feature slugs were passed as arguments**, design and apply their
   artifact changes now — this absorbs what `/ardd-backlog` used to do
   eagerly, deferred to the moment you actually choose to work an idea:

   a. **Look up each slug** in the feature register — read
      `.project/features/<slug>.md` and its frontmatter `status`. If the
      file doesn't exist, tell the user and stop. If its status isn't
      `backlogged` (e.g. already `planned`/`tasked`/`implemented`), tell the
      user it's already past the backlog stage and stop — this skill only
      designs features forward from `backlogged`; to revise a feature already
      in flight, use `/ardd-feedback` (a reconsidered decision) or edit the
      relevant plan/artifact directly.

      Also run `.claude/skills/ardd-scripts/inflight-worktrees.sh`. For each
      in-flight tasks file it reports in another worktree, read that file's
      `plan:` frontmatter (from that worktree's copy) and the named plan's
      `features:` list — if a targeted slug appears there, print an advisory
      (never blocking): the slug already has work in flight on that
      worktree/branch, and planning it again here may produce conflicting
      designs. The register visible on this branch can't show that —
      under worktree-native state, in-flight status rides the other
      worktree's branch until merge.

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
        to `DEFECTS.md`/`/ardd-defects` for known code-vs-artifact violations
        instead of narrating them into the artifact body).
      - Update frontmatter on each changed artifact via
        `.claude/skills/ardd-scripts/ardd-state.sh stamp <file> ...`:
        `last_updated <today>`, and `diagram_status stale` for renderable
        artifacts (unless currently `unrendered`). The `status` field
        (`draft` if new open questions were introduced, else `stable`) is
        a judgment call — set it while editing the artifact body.

   e. **Run a scoped cross-artifact check** — the same checks as
      `/ardd-status` steps 2–4, scoped to the artifacts just changed: verify
      new concepts are defined wherever referenced, flag new constitution
      violations, report new `[OPEN: ...]` items. This keeps the artifact set
      internally consistent before the plan itself is drafted against it.

   Remember which feature slugs were targeted here — you'll record them in
   the plan's frontmatter (step 9). Their `Status` flips from `backlogged`
   to `planned` at the tasking half (step 11), when this plan is approved —
   not here.

4. **Load open feedback.** Glob `.project/feedback/feedback-*.md` and read
   frontmatter. If feedback-scope argument(s) were passed (see Usage),
   restrict everything in this step — loading, presenting, marking,
   `feedback-planned` — to the named file(s); other open files are
   invisible to this run. Load every (in-scope) file with `status: open`
   as planning input —
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
   way to recover their declined marking later. The decision of *what* to
   accept or decline is judgment; the marking itself is script-performed
   (constitution Principle II). For each item, by its `F###` ID:

   ```
   .claude/skills/ardd-scripts/ardd-state.sh feedback-mark <file> <F-id> x   # incorporated
   .claude/skills/ardd-scripts/ardd-state.sh feedback-mark <file> <F-id> -   # declined
   ```

   Once every item in a file is resolved, flip it and stamp the consuming
   plan in one validated step (it refuses if anything is still unresolved):

   ```
   .claude/skills/ardd-scripts/ardd-state.sh feedback-planned <file> <plan-filename>
   ```

   The plan filename is already known at this point — mint it now (step 9
   reuses it): `.claude/skills/ardd-scripts/ardd-state.sh mint plan <slug>`.
   Planned feedback files are not edited further and become a historical
   record of what prompted the plan. If any item is still unresolved (e.g.
   the user wants to think about a declined override more), skip
   `feedback-planned` — the file stays `open` and the next `/ardd-plan` run
   picks up the remainder.

5. **Check for unsurfaced defects.** Run
   `.claude/skills/ardd-scripts/defects-unsurfaced.sh` — it computes each
   `DEFECTS.md` entry's stable identifier, unions every plan's
   `surfaced-defects:` frontmatter list, and prints only the
   `<id>\t<claim>` pairs never yet surfaced by a prior `/ardd-plan` run
   (silent when there's nothing new).

   If defect-scope argument(s) were passed (see Usage), run the
   explicit-selection modes instead of the default: `defects-unsurfaced.sh
   --id <id>` (once per `defect:<id>` argument, or one call with repeated
   `--id` flags) for named entries, or `defects-unsurfaced.sh --all` for
   the literal `defects` argument. Both bypass the surfaced-union filter,
   deliberately re-offering entries even if their ids already appear in
   some plan's `surfaced-defects:` list — this is how the user pulls a
   previously-declined defect back into a plan. An unknown id makes
   `--id` error; relay that to the user rather than guessing. Everything
   downstream is identical to the default mode: present each entry,
   ask accept/decline, tag accepted fix tasks `[defect: <identifier>]`,
   and record every presented id in this draft plan's
   `surfaced-defects:` list.

   For each printed defect: present it
   to the user and ask whether to include a fix task for it in this plan. Whether accepted or declined, record its
   identifier in the `surfaced-defects:` list of the plan you're drafting
   (written in step 9) — declining still counts as "surfaced," which is what
   stops it from being re-prompted on every future run. If accepted, the fix
   task is added to the Phase Breakdown in step 8, tagged `[defect:
   <identifier>]`.

6. **Check constitution compliance** if `constitution.md` is present. Read the
   principles it *actually declares* — don't assume any fixed set — and flag any
   planned pattern that violates, or needs justification under, one of those
   declared principles. In particular, only if the constitution declares a
   simplicity / complexity-justification principle (e.g. Simplicity/YAGNI with a
   Complexity Tracking requirement) do you flag patterns that would need a
   Complexity Tracking entry; if it declares no such principle, there is nothing
   to flag at that site. Mirror `/ardd-status`'s "act only on the principles
   present" shape rather than presuming a particular principle exists.

7. **Check for existing approved plans.** List `.project/plans/plan-*.md` and
   read frontmatter. If any have `status: approved`, ask the user whether the
   plan you're about to draft supersedes one of them. On confirmation, flip
   that plan's status to `superseded` immediately via `.claude/skills/ardd-scripts/ardd-state.sh plan-flip <file> superseded`. A
   superseded-by-a-draft-that's-never-approved plan is an acceptable outcome,
   not a bug: `/ardd-status`/`STATUS.md` surface open draft counts either
   way, so an abandoned replacement doesn't go unnoticed.

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
   - **Complexity Tracking** — table of justified deviations, included *only if*
     the constitution declares a principle requiring complexity to be justified
     (e.g. a Simplicity/YAGNI principle). Omit the section entirely when no such
     principle is declared, rather than emitting an empty table.
   - **Open Questions** — anything that must be resolved before or during
     implementation
   - **Production Annotation Summary** — list of known production shortcuts to
     annotate during implementation, included *only if* the constitution declares
     a production-annotations principle (the same condition `/ardd-status`
     step 3 applies). Omit the section entirely when no such principle is
     declared.

9. **Write the plan** to `.project/plans/plan-<slug>-<YYYY-MM-DD>-<hex4>.md` with
   frontmatter. As in step 3d, run `.claude/skills/ardd-scripts/project-
   lock.sh check ardd-plan` first (surface any warning, don't block on it),
   and `... touch ardd-plan` after writing:

   ```yaml
   ---
   status: draft        # draft -> approved -> superseded (schema-of-record: scripts/lint-project.sh)
   branch: <slug>       # the branch inline implementation would use; may never be created (see step 1)
   created: YYYY-MM-DD
   features: [<slug>, ...]   # feature slugs targeted in step 3; omit or [] if none
   surfaced-defects: [<id>, ...]   # DEFECTS.md identifiers surfaced in step 5; omit or [] if none
   ---
   ```

10. **Approval checkpoint.** Present a summary to the user — phases, key
    decisions, open questions — and note the plan is saved at
    `.project/plans/plan-<slug>-<YYYY-MM-DD>-<hex4>.md` as `status: draft`. Then
    **pause and ask which of three the user wants** (use `AskUserQuestion`):

    - **Approve** — proceed to step 11: approve the plan and generate its
      tasks file, in this same run.
    - **Revise** — the user wants changes to the plan first. Make them
      (loop back through steps 8–9 as needed, rewriting the same plan file),
      then return to this checkpoint. The plan stays `draft`; nothing is
      approved or tasked until the user approves.
    - **Stop** — leave the plan at `status: draft` and end the run without
      tasking. This is a legitimate outcome: the plan is a durable artifact
      a later `/ardd-plan --from <this plan>` (or a fresh run) can pick up.
      Skip to the report (step 15), which recommends `/ardd-status`.

    Do **not** approve or generate tasks without an explicit approve here —
    approval is a decision, not a default. (`--from` mode entered at step 11
    is itself that explicit decision: the user named the plan to task.)

--- tasking half (steps 11–15): reached on Approve, or entered directly by `--from` ---

11. **Approve the plan and flip its features to `planned`.** Run
    `.claude/skills/ardd-scripts/project-lock.sh check ardd-plan` first —
    surface any warning but proceed (advisory, never a block).

    First, check for existing tasks files bound to the chosen plan: run
    `.claude/skills/ardd-scripts/tasks-list.sh --all` and match its
    plan-binding column against the plan's filename. If one already exists at
    `ready`, `in-progress`, or `completed`, surface that explicitly and ask
    for confirmation before continuing ("plan-auth-flow already has
    tasks-auth-flow-9f3c.md at in-progress, 4/12 complete — generate a new
    tasks file for this plan anyway?"). Proceeding creates a *new* file, never
    overwrites an existing one — this is a deliberate fork, not silent data
    loss. On confirmation, also ask whether to mark each existing
    non-`completed` tasks file for this plan `abandoned` (skip any already
    `completed` — a more informative terminal state, and the
    sibling-completion check treats a `completed` sibling as done). For each
    the user confirms: `ardd-state.sh tasks-flip <file> abandoned`; leave the
    rest (e.g. still legitimately worked in parallel). In the normal (fresh)
    path a plan just written this run has no tasks files, so this is a no-op;
    it matters in `--from` re-task mode.

    Then, if the plan's `status` is `draft`, approve it and advance its
    features (all mutations script-performed — constitution Principle II):

    ```
    ardd-state.sh plan-flip <plan file> approved
    # then, for each slug in the plan's features: frontmatter list:
    ardd-state.sh feature-flip <slug> planned
    ardd-state.sh feature-field <slug> plan <plan filename>
    ```

    If the chosen plan is already `status: approved` (e.g. a `--from` re-task,
    or a second tasks-file run against the same plan), skip the flips —
    nothing to approve. Either way, run `... touch ardd-plan` once this step's
    writes (if any) are done.

12. **Generate tasks** ordered by dependency. Each task MUST:
    - Have a unique ID: `T001`, `T002`, etc.
    - State which artifacts must be loaded before execution, e.g.
      `[artifacts: datamodel, infrastructure]` — omitting the bracket-tag
      entirely when no artifact applies; never write a placeholder name
      like `none`
    - Be atomic enough that an agent can complete it in one focused session
    - Be concrete enough to execute without reading the plan (embed necessary
      context in the task description)
    - Include a test requirement where applicable, following whatever testing
      paradigm `constitution.md` declares (Quality Standards or Core
      Principles) — TDD, test-after, coverage threshold, or none. Tasks are
      paradigm-agnostic by default; don't assume TDD or any specific
      principle number if the constitution doesn't state one

    Mark parallelism with `[parallel]` on tasks that touch different files and
    have no shared dependencies.

13. **Write the tasks file.** Mint its filename from the chosen plan's
    slug — `.claude/skills/ardd-scripts/ardd-state.sh mint tasks <slug>` —
    minted at write time so the name is always unique even when
    regenerating tasks for the same plan; write to
    `.project/tasks/<that filename>`. Run `.claude/skills/ardd-scripts/project-lock.sh check
    ardd-plan` before this first write (surface any warning, don't block on
    it). Write the frontmatter immediately, before generating task
    content, with `status: generating` — this is what makes an interrupted
    generation visibly incomplete rather than silently mistaken for `ready`:

    ```yaml
    ---
    plan: plan-<slug>-YYYY-MM-DD-<hex4>.md   # exact filename of the source plan — authoritative binding
    generated: YYYY-MM-DD
    status: generating   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
                         # (or -> abandoned, if superseded by a new tasks
                         # file generated for the same plan)
                         # completed is terminal — post-completion failures
                         # become new feedback (/ardd-feedback), never a
                         # status edit.
    # worktree_branch: <branch>  — legacy field from the old design; nothing
    # writes it anymore (completion-flip-check.sh still reads it from files
    # that predate worktree-native state); not written here at generation time.
    ---

    # Tasks

    ## Phase 1: <Name>
    - [ ] T001 [artifacts: constitution] <description>
    - [ ] T002 [artifacts: datamodel, infrastructure] [parallel] <description>

    ## Phase 2: <Name>
    - [ ] T003 [artifacts: datamodel] <description>
    ```

    Once all tasks are written, flip the file to ready —
    `.claude/skills/ardd-scripts/ardd-state.sh tasks-flip <file> ready` —
    then run `... touch ardd-plan`.

14. **Flip bound features to `tasked`.** Read the chosen plan's frontmatter
    `features:` list (if any). For each slug:

    ```
    ardd-state.sh feature-flip <slug> tasked
    ardd-state.sh feature-field <slug> tasks <this tasks filename>
    ```

15. **Report** what happened: if a plan was drafted, its phases, key
    decisions, and open questions; if tasks were generated, the total task
    count and phase breakdown, any tasks that embed a test requirement, which
    features (if any) were flipped to `tasked`, and — if step 11 approved the
    plan — that it's now `approved`. If the run stopped at the checkpoint
    (step 10, "Stop"), say the plan is saved as `draft` and can be tasked
    later with `/ardd-plan --from <plan file>`.

    Then run `/ardd-status` now to refresh `STATUS.md` — artifacts, the
    feature register, plan approval, and/or the feature-backlog flips in this
    run leave it stale otherwise. Don't wait for the user to ask.

    **Next-step prompt (opt-in).** If `.project/artifacts/constitution.md`
    frontmatter has `next_step_prompt: true` (grep the frontmatter block;
    absent or `false` = the plain-text behavior above, unchanged), the
    recommended next step is offered as a one-keypress AskUserQuestion. The
    recommendation depends on how the run ended: if tasks were generated,
    it's `/ardd-implement` (to execute the tasks file just written); if the
    run stopped at the checkpoint with the plan left `draft`, it's
    `/ardd-plan --from <plan file>` (to task it later) — but a bare re-task
    with no new decision is rarely the immediate next step, so prefer plain
    text there unless the user clearly intends to continue. Offer as option 1
    "Yes — run `<recommendation>` now", option 2 "No — stop here" (Esc =
    option 2); on yes, invoke by name (the existing terminal-handoff
    mechanism, no value passed back). **Exactly one prompt per user-visible
    turn end**: this step already ends by running `/ardd-status`, which
    carries its own next-step prompt — so when the analyze handoff happens as
    instructed, the offer belongs to `/ardd-status` (whichever skill
    actually ends the turn owns the prompt) and `/ardd-plan` must not prompt
    first. Only if this run ends the turn itself without handing off to
    analyze does the offer fire here. Recommendations that are not a concrete
    runnable `/ardd-*` invocation always stay plain text.
