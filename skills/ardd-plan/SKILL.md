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

Usage: a bare `/ardd-plan` first offers a pick of everything currently
plannable — backlogged features, open feedback, unsurfaced defects (step
1a); an empty selection falls back to planning from artifacts/feedback
only. `/ardd-plan <slug> [<slug> ...]` additionally targets one or more backlogged feature
entries from the feature register (`.project/features/`) — this is where a feature
idea's artifact design work actually happens (`/ardd-backlog` only logs the
idea; it doesn't touch artifacts). Substantial or decision-reversing ideas:
vet with `/ardd-research` first, before planning them.

`/ardd-plan --list` is a **read-only side door**: run
`.claude/skills/ardd-scripts/feature-list.sh` (installed copy; if absent,
fall back to the source repo path `scripts/feature-list.sh`) with no
arguments (its default filter — `backlogged`), print its output verbatim,
and stop. This runs before step 1's branch check and before every other
step — no artifact discovery, no feedback load, no interactive pick, and
no writes of any kind. Use it for a quick "what's actionable to plan
right now" glance without entering the normal flow.

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

`/ardd-plan --slate` is a **read-only advisory mode**: like `--list`, it
runs before step 1's branch check and before every other step — no
artifact discovery, no feedback load, no interactive pick, and no writes
of any kind — but instead of a bare backlog printout it computes a
"defrag" grouping over the open backlog (bundles that should plan
together, parallel sets safe to fan out, solo-deferred items) and reports
a recommended `/ardd-plan <slug> [<slug> ...]` invocation. Entering
`--slate` skips steps 1–15 entirely and runs the separate "Slate mode"
procedure defined at the end of this file. Never combine `--slate` with
any other argument form — it takes no scope.

## Shape of a run

Steps 1–10 draft and write the plan and stop at the **approval checkpoint**
(step 10). Only on explicit approval do steps 11–15 approve the plan and
generate its tasks file. This restores a real approve/revise/stop gate
between planning and tasking — selecting a plan is a decision, not a
keystroke. **Re-task mode (`--from <plan-file>`) skips straight to step 11**
for the named plan; steps 2–10 do not run. **Slate mode (`--slate`) skips
steps 1–15 entirely** and runs the separate procedure in "Slate mode"
below, ending in a report and, optionally, a next-step prompt — it never
drafts or writes a plan.

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
   A worktree still works if the user wants isolation — set one up manually
   and re-run from there; this skill never delegates to a worktree subagent:
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

1a. **Bare-invocation target pick.** Runs ONLY when this run received no
   scope argument of any kind — no feature slug, no `feedback-*.md`
   feedback scope, no `defect:<id>`/`defects` defect scope, and not
   `--list`, `--from`, or `--slate`. Any scoped or side-door invocation
   skips this step entirely; scoped runs already know their target.

   Enumerate the plannable inputs deterministically:
   - **Backlogged features** — run
     `.claude/skills/ardd-scripts/feature-list.sh` (installed copy; if
     absent, fall back to the source repo path `scripts/feature-list.sh`)
     with no arguments (its default filter — `backlogged`).
   - **Open feedback** — glob `.project/feedback/feedback-*.md` and keep
     files whose frontmatter says `status: open`.
   - **Unsurfaced defects** — run
     `.claude/skills/ardd-scripts/defects-unsurfaced.sh` (source fallback
     `scripts/defects-unsurfaced.sh`); its output lines are the
     never-yet-surfaced `DEFECTS.md` entries.

   **Something found:** present ONE `AskUserQuestion` (multiSelect on)
   listing each backlogged slug, each open feedback file, and — only when
   any unsurfaced entries exist — a single "surfaced defects" option.
   Then continue the run scoped to the selection exactly as if those
   arguments had been passed: selected slugs feed step 3, selected
   feedback files become step 4's feedback scope, and the defects option
   puts step 5 in its explicit-selection mode (`--all` over the entries
   just enumerated). Selecting nothing is a legitimate answer: proceed
   with the artifacts/feedback-only drafting a bare run performs today —
   the picker adds options, it doesn't remove the existing path. This is
   a **mid-run gate**, same class as the approval checkpoint (step 10),
   not a terminal next-step prompt — it fires regardless of
   `next_step_prompt` and doesn't count against the one-prompt-per-turn-end
   rule. When the backlog is large, mention `--slate` as the richer
   read-only grouping over the same items before the user picks.

   **Nothing found** (empty backlog, no open feedback, no unsurfaced
   defects): report that in plain prose — there are no plannable inputs —
   and suggest concrete next steps: `/ardd-backlog <idea>` or
   `/ardd-feedback <observation>` to create something plannable, and,
   if `.claude/skills/ardd-scripts/tasks-list.sh` shows a `ready` or
   `in-progress` tasks file, `/ardd-implement` to execute it. Then stop —
   never draft a plan against nothing, and never prompt in this branch
   (there is nothing to pick): plain text, like `--list`'s degenerate
   cases.

2. **Discover artifacts** by listing `.project/artifacts/`. Read every `.md`
   file present. If any are `status: draft`, warn the user and ask whether
   to proceed.

3. **If feature slugs were passed as arguments**, design and apply their
   artifact changes now — this absorbs what `/ardd-backlog` used to do
   eagerly, deferred to the moment the user actually chooses to work an idea:

   a. **Look up each slug** in the feature register — read
      `.project/features/<slug>.md` and its frontmatter `status`. If the
      file doesn't exist, tell the user and stop. If its status isn't
      `backlogged` (e.g. already `planned`/`tasked`/`implemented`/
      `retired`/`rejected`/`subsumed`), tell the user it's already past
      the backlog stage and stop — this skill only designs features
      forward from `backlogged`; to revise a feature already in flight,
      use `/ardd-feedback` (a reconsidered decision) or edit the relevant
      plan/artifact directly. `rejected` and `subsumed` are two of the
      statuses this refusal covers: a `rejected` idea needs a fresh
      backlog entry if reconsidered (never revived under its own slug),
      and a `subsumed` entry's scope should be planned under whichever
      feature actually absorbed it, never revived under its own slug
      either.

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

   Remember which feature slugs were targeted here — the agent records them in
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
   identifier in the `surfaced-defects:` list of the plan being drafted
   (written in step 9) — declining still counts as "surfaced," which is what
   stops it from being re-prompted on every future run. If accepted, the fix
   task is added to the Phase Breakdown in step 8, tagged `[defect:
   <identifier>]`.

6. **Check constitution compliance** if `constitution.md` is present. Read the
   principles it *actually declares* — don't assume any fixed set — and flag any
   planned pattern that violates, or needs justification under, one of those
   declared principles. In particular, only if the constitution declares a
   simplicity / complexity-justification principle (e.g. Simplicity/YAGNI with a
   Complexity Tracking requirement) does the agent flag patterns that would need a
   Complexity Tracking entry; if it declares no such principle, there is nothing
   to flag at that site. Mirror `/ardd-status`'s "act only on the principles
   present" shape rather than presuming a particular principle exists.

7. **Check for existing approved plans.** List `.project/plans/plan-*.md` and
   read frontmatter. If any have `status: approved`, ask the user whether the
   plan about to be drafted supersedes one of them. On confirmation, flip
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

10. **Approval checkpoint.** Present a bounded, faithful skeleton of the
    plan drawn **verbatim from the plan the agent just wrote** — not a freehand
    re-summary. Show exactly these four elements, in order:

    1. **Goal** — reproduce the plan's **Goal** sentence verbatim and
       **bolded**. Never paraphrase it; this is the one line the user is
       approving.
    2. **Phase table** — a markdown table with columns `Phase | Delivers |
       Depends on`, one row per phase in the plan's **Phase Breakdown**
       (`Delivers` = that phase's described increment; `Depends on` = its
       stated dependency, or `—`). This checkpoint runs **before tasking**
       (step 12), so there are **no `T###` IDs or task counts yet** — do
       **not** add a task-count column or invent one. (You may add an
       optional count of a phase's enumerated Phase Breakdown work-items
       *only* where the draft listed them, and label it as plan items,
       never tasks.)
    3. **Open Questions** — reproduce the plan's **Open Questions** list
       verbatim (not summarized); these are exactly what the user weighs
       before approving.
    4. **File pointer** — note the plan is saved at
       `.project/plans/plan-<slug>-<YYYY-MM-DD>-<hex4>.md` as `status: draft`,
       and **invite the user to open that `.md` in their editor or markdown
       preview** for the full plan (Scope, Technical Approach, Complexity
       Tracking, etc.). Frame the terminal view as the decision-relevant
       skeleton and the on-disk file as the full-fidelity source — keep this
       a summary-plus-pointer, never a full inline dump of the plan.

    Before that three-way question, check the constitution's
    `plan_preview` frontmatter field (grep
    `.project/artifacts/constitution.md`; absent = `ask`, the behavior
    below unchanged):
    - **`always-browser`** — skip the preliminary question; always
      publish the plan file
      (`.project/plans/plan-<slug>-<YYYY-MM-DD>-<hex4>.md`, Markdown —
      no HTML skeleton needed) via the `Artifact` tool, open it, and
      display the resulting URL to the user, then proceed straight to
      the three-way question below.
    - **`always-console`** — skip the preliminary question and never
      publish; proceed straight to the three-way question below.
    - **`ask`** (or absent) — ask a one-time preliminary question:
      **view the plan in the browser first?** (use `AskUserQuestion`,
      yes/no). On yes: publish and open as above, then proceed to the
      three-way question. On no: proceed straight to the three-way
      question.

    Either way, this offer (or its `plan_preview`-driven auto-behavior)
    re-fires each time a Revise loop brings the run back to this
    checkpoint — a later redeploy of the same plan file (same path)
    targets the same artifact URL, so the preview always reflects the
    latest draft.

    Then **pause and ask which of three the user wants** (use `AskUserQuestion`):

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

    Phrase a task as *creating* a file/function, not extending or modifying
    it, whenever the target doesn't exist yet — there's nothing to modify.
    This is the common case for a project's very first feature: don't write
    "update `src/index.ts` to add the entry point" when `src/index.ts`
    doesn't exist yet.

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

## Slate mode (`--slate`)

Entered instead of steps 1–15 when the run's sole argument is `--slate`
(see Usage). This is a **read-only advisory mode**: it computes an
ephemeral "defrag" grouping over the open feature backlog — grounded in
real codebase evidence, never free-associated from register prose alone —
and ends in a report plus a recommended next `/ardd-plan` invocation. It
never drafts a plan, never writes a plan or tasks file, and never touches
the feature register. Its own steps:

1. **Enumerate the backlog.** Run
   `.claude/skills/ardd-scripts/feature-list.sh --status backlogged`
   (installed copy; if absent, fall back to the source repo path
   `scripts/feature-list.sh --status backlogged`) and read its tab-separated
   output verbatim — this is the same register-direct-read discipline
   `--list` already uses: never trust `STATUS.md`'s assembled counts, even
   when they happen to already be correct. Let N be the number of lines
   printed.

2. **N=0/N=1 branch.** These are degenerate cases — a slate is a relation
   *between* items, and with N≤1 the relation set is empty by
   construction, so don't manufacture one:
   - **N=0**: report "nothing to defrag — the backlog is empty" and stop.
   - **N=1**: report "nothing to defrag — single open item: `<slug>`" and
     recommend `/ardd-plan <that slug>` directly, then stop.

   Only continue to step 3 when N≥2.

3. **Per-item footprint confidence grading (N≥2).** For each backlogged
   item, read its register entry (the description and any `Why:` line)
   and ground a footprint estimate in real greps/reads of the codebase —
   never free-associated from the register's prose alone. Grade a
   confidence:
   - **`high`** — a concrete existing seam was found (a file, interface,
     or abstraction the feature would extend or plug into). Example:
     `wasm-hunspell-backend` grades `high` because a grep turns up a
     37-line, already-abstracted spellcheck-backend interface the new
     backend would implement — the seam already exists in code.
   - **`medium`** — a seam exists but a real unknown remains (e.g. the
     work is gated on a non-code decision, or the seam only partially
     covers the described scope).
   - **`low`** — greenfield (no seam exists yet), or the item's own
     artifact language explicitly flags it as speculative or a later
     phase. Example: `llm-assistance` grades `low` because
     `infrastructure.md` itself calls it a later phase with an open
     question — there is nothing in the codebase yet to ground a
     footprint against.

   Grading is agent judgment, not a rigid rubric — these two worked
   examples anchor what "grounded in real greps" means in practice; don't
   grade purely from how confident the register's own prose sounds.

4. **Pairwise relations (N≥2), two axes, computed separately.** For every
   pair of backlogged items, determine two independent judgments — never
   collapse them into one:
   - **File-set overlap** — do the two items' footprints share any file?
   - **Ordering dependency** — does one item need to land before the
     other regardless of file overlap (e.g. an interface one item would
     consume that the other edits, or a shared code path one transforms
     and the other reads)?

   Overlap without dependency is a **safe parallel pair**, even when the
   items are topically related. Example: a `project-scoped-personal-
   dictionary` item and a `spellcheck-backend` item might both carry the
   "spellcheck" label, but if their footprints are actually disjoint
   (one touches a dictionary-storage file, the other `speller.ts`), the
   shared label is a false signal — they're safe to plan and implement in
   parallel.

   Dependency without full file overlap still forces sequencing. Example:
   a `smart-typography-substitution` item feeding into `{docx-export,
   epub-pdf-export}` items — they don't necessarily share a file, but
   typography substitution has to land first because both export paths
   read through the same render/export path it transforms. Ordered
   through a shared code *path*, not a shared file set — still a
   dependency edge, not a safe parallel pair.

   Compute both axes for every pair before classifying anything in
   step 5.

5. **Classify and present.** Using the confidence grade (step 3) and the
   two relations (step 4), bucket every backlogged item into exactly one
   of:
   - **Bundle** (reported under "Plan together") — items connected by a
     dependency edge, or sharing files with no safe reordering.
     Sequenced; recommended as one multi-slug
     `/ardd-plan <slug1> <slug2> ...` call, in dependency order.
   - **Parallel set** (reported under "Plan separately, safe to fan
     out") — items that are pairwise file-disjoint, have no dependency
     edge between them, and are *not* `low` confidence. Recommended as
     separate `/ardd-plan <slug>` calls, one per item, safe to fan out
     to worktrees. A `low`-confidence item is never placed in a
     parallel set even when no overlap was found — a wrong "disjoint"
     call is the expensive failure (it green-lights a fan-out that then
     merge-conflicts), so low confidence always routes to solo-deferred
     instead.
   - **Solo-deferred** (reported under "Defer") — `low`/speculative
     confidence, or explicitly gated on a non-code decision per the
     artifact. Recommended as its own single-slug `/ardd-plan <slug>`
     call on its own timeline; never bundled or fanned out.

   **Report format**: lead with the actionable grouping, not the
   rationale — a reader must be able to tell "run together vs.
   independent vs. deferred" from the section headers alone, without
   parsing prose. Use three fixed headings, each naming the call count
   and fan-out safety up front; list every command directly under its
   heading; demote the file-overlap/dependency/confidence rationale to a
   one-line note per item, after the command(s), not before:

   ```
   Plan together (1 call):
     -> /ardd-plan typography-substitution docx-export epub-pdf-export
        (typography-substitution, docx-export, epub-pdf-export —
        typography-substitution must land first; both export items read
        through the same render/export path it transforms)

   Plan separately, safe to fan out (2 calls):
     -> /ardd-plan spellcheck-backend
        (disjoint footprint — speller.ts; high confidence)
     -> /ardd-plan personal-dictionary
        (disjoint footprint — dictionary-storage.ts; high confidence;
        despite sharing the "spellcheck" label with spellcheck-backend,
        no file or dependency overlap)

   Defer (own timeline):
     -> /ardd-plan llm-assistance
        (low confidence — infrastructure.md flags this as a later phase
        with an open question; no seam exists yet to ground a footprint
        against)
   ```

   Omit any of the three headings entirely when its bucket is empty —
   don't print an empty section.

   If `next_step_prompt: true` (see below), the single top-priority
   recommendation is then offered via `AskUserQuestion`; otherwise this
   report is the run's final output and the run stops here.

**Next-step prompt (opt-in).** If `.project/artifacts/constitution.md`
frontmatter has `next_step_prompt: true` (grep the frontmatter block;
absent or `false` = stay plain text, unchanged), offer the single
top-priority recommendation from step 5's report via a one-keypress
`AskUserQuestion` — the same mechanism `/ardd-plan`'s and `/ardd-status`'s
own next-step prompts already use (see step 15 above). "Top-priority"
means: a bundle beats a parallel set beats a solo-deferred item (bundles
resolve an ordering constraint, so they're the most time-sensitive to
act on), and among same-tier buckets, prefer the first one enumerated.
Offer as option 1 "Yes — run `<recommendation>` now", option 2 "No — stop
here" (Esc = option 2); on yes, invoke `/ardd-plan` with the recommended
slug(s) by name (the existing terminal-handoff mechanism, no value passed
back). **Exactly one prompt per user-visible turn end** — slate mode never
hands off to `/ardd-status` (it makes no writes for `/ardd-status` to
reflect), so this is the only prompt in play, never deferred to another
skill. This prompt is wired only for step 5's N≥2 report; the N=0/N=1
degenerate branch (step 2) stops before reaching step 5 and stays
plain-text there, same as `--list`.
