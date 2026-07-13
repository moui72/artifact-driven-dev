---
name: ardd-status
tier: core
description: "Full cross-artifact consistency check — reads every artifact, plan, tasks file, and the register — and writes STATUS.md (its single writer); auto-runs after most state-changing skills."
---

# /ardd-status

Non-destructive cross-artifact consistency and quality check. Discovers and
reads all artifacts present in `.project/artifacts/`, then reports gaps,
contradictions, and implied-but-undefined decisions.

`/ardd-backlog`, `/ardd-plan`,
`/ardd-refine` (including its create path, when relevant),
`/ardd-feedback`, `/ardd-implement` (on tasks-file completion, in both
execution and reconcile mode), and
`/ardd-defects` invoke this skill automatically as their final step, since
each of those changes state `STATUS.md` should reflect. This is the
canonical list — other docs referencing which skills auto-trigger analyze
point back here rather than re-enumerating, so it's the one place to update
when that set changes.

Manual invocation is still the right call after `/ardd-init`
(deliberately deferred until after a `/ardd-refine` pass — running it
immediately would just report a wall of expected draft-state noise) or
anytime you want a fresh check outside those flows.

**Run only from the primary checkout, never inside a delegated worktree.**
`/ardd-status` is the sole writer of `STATUS.md`; running it inside a
worktree would trap that write on the worktree's branch instead of the
default branch. Delegated `/ardd-implement` subagents are
told explicitly not to invoke it — the terminal analyze handoff belongs to
the coordinator or the inline path.

## Steps

1. **Discover artifacts** by listing `.project/artifacts/`. Read every `.md`
   file present. Note which are `status: draft` and which are referenced by
   other artifacts but missing.

   Also run `.claude/skills/ardd-scripts/inflight-worktrees.sh` to enumerate
   every *other* worktree of this repo — its branch and any `tasks-*.md` at
   `in-progress`/`completed` with checkbox progress (`tasks=none` when
   clean). This is the coarse in-flight-truth channel: work happening in a
   sibling worktree hasn't merged yet, so the default branch (and everything
   else this skill reads) doesn't reflect it. If `workflow_mode:
   collaborative` in `.project/artifacts/constitution.md` frontmatter and
   `gh` is available, also run `gh pr list --draft` — a pushed draft PR is
   collaborative mode's in-flight channel. Collect both for the In-flight
   report section and STATUS.md line below (omit when nothing is in flight).

   Additionally run `.claude/skills/ardd-scripts/worktree-reap.sh --dry-run`
   (installed copy; absolute-path fallback, same present-or-fallback rule).
   Any `candidate=` line is a worktree whose branch has fully merged into
   the default branch with a clean tree — list each in the In Flight
   section as "merged, reapable". **Visibility only: `/ardd-status` never
   mutates worktrees** — the reap itself belongs to `/ardd-implement`'s
   post-merge coordinator step (or the user).

   Also check for `.project/DEFECTS.md`. If present, read its last-verified
   date and defect count — this is read-only: `/ardd-status` never
   regenerates, edits, or appends to `DEFECTS.md` (that file belongs solely to
   `/ardd-defects`). If absent, note that verify has never run.

   Also run `.claude/skills/ardd-scripts/ardd-update-check.sh` (the
   installed copy; coordinator's absolute path as fallback, same
   present-or-fallback rule as other ardd-scripts calls). On
   `behind installed=<x> source-tip=<y>`, the report and STATUS.md each
   gain one line: "ARDD update available: installed <x>, source at <y> —
   run /ardd-update." On `source-missing`, a gentler line: "ARDD source
   checkout not found at its recorded path — run /ardd-update to
   re-record it." `no-version-file`, `no-source-path`, `up-to-date`, and
   `self-hosted` (this repo is its own ARDD source — the tip comparison
   is meaningless there) stay silent.

   Also glob `.project/feedback/feedback-*.md` and read frontmatter. Count
   files with `status: open` — this is read-only visibility; `/ardd-status`
   never writes to feedback files (that belongs solely to `/ardd-feedback`
   and `/ardd-plan`).

   Also glob `.project/features/*.md` (the per-feature register) if
   present. Count entries by frontmatter `status`
   (`backlogged`/`planned`/`tasked`/`implemented`) — read-only visibility;
   `/ardd-status` never writes to the register except the one narrow,
   explicit exception in step 5a below.

   Also glob `.project/tasks/tasks-*.md` for files at `status: completed`.
   For each, run `.claude/skills/ardd-scripts/completion-flip-check.sh
   <file>` — detects the orphaned-completion-flip failure mode: a plan
   whose branch has already merged into the default branch, but whose bound
   features are still `tasked` in the register rather than
   `implemented`. This happens because `/ardd-implement`'s post-merge flip step assumes a live coordinating
   conversation checks back after the worktree branch merges — but merge is
   manual/async, so in the common case that conversation is gone before it
   happens and the flip never lands. Collect any printed slugs.

2. **Check cross-artifact consistency** for every pair of artifacts:
   - Any entity, field, endpoint, or concept mentioned in one artifact must be
     defined in the artifact that owns it. Flag anything referenced but
     undefined.
   - Decisions that span artifacts must be consistent — e.g., a storage choice
     in `infrastructure.md` must match assumptions in `datamodel.md`.
   - If a view/UI artifact exists, every field it displays or uses for logic
     must exist in the data model artifact.

3. **Check against `constitution.md`** if present:
   - Flag decisions in any artifact that violate a stated principle.
   - Flag shortcuts that lack a production annotation entry (if the constitution
     includes a production annotation principle).

4. **Check within each artifact:**
   - Unresolved `[OPEN: ...]` placeholders or TODOs
   - Vague language where a concrete decision is needed
   - `status: draft` artifacts that would block planning

5. **Produce a report:**

   ```
   ## Artifacts Found
   - <name>.md — stable ✅ / draft ⚠️
   - <name>.md — missing ❌ (referenced by <other artifact>)

   ## Cross-Artifact Issues
   - [CONFLICT] <description> — <artifact A> says X, <artifact B> says Y
   - [GAP] <description> — <artifact A> implies X but <artifact B> doesn't define it

   ## Within-Artifact Issues
   ### <artifact>
   - [OPEN] <unresolved item>
   - [VAGUE] <item needing a concrete decision>

   ## Constitution Compliance
   - [VIOLATION] <description>
   - [ANNOTATION MISSING] <shortcut without a production annotation>

   ## Diagrams
   - <name>.md — current ✅ / stale ⚠️ (run /ardd-diagram <name>) / unrendered ⚠️ (never generated — run /ardd-diagram <name>)
   (Only list renderable artifacts: datamodel, infrastructure, ui. Read each
   one's `diagram_status` frontmatter field directly — do not infer from
   whether a README section merely exists.)

   ## Code-vs-Artifact Defects
   - <N> known defects — see DEFECTS.md, last checked YYYY-MM-DD. Run
     /ardd-defects to refresh.
   (Or, if DEFECTS.md is absent: "Never checked — run /ardd-defects to compare
   artifacts against the codebase." This section is visibility only —
   `/ardd-status` does not read code itself and does not regenerate
   DEFECTS.md.)

   ## Feedback
   - <N> open feedback file(s) — see `.project/feedback/`, will be picked up
     by the next `/ardd-plan`. (Omit this section if none are open.)

   ## Feature Backlog
   - <N> backlogged · <N> planned · <N> tasked · <N> implemented — see
     `.project/features/`. Target a backlogged slug with
     `/ardd-plan <slug>`. (Omit this section if the register doesn't exist.)

   ## Orphaned Completion Flips
   - Slug `<slug>` — tasks file `<file>`'s plan branch `<branch>` is merged
     into the default branch, but the register still says `status: tasked`.
     (Omit this section entirely if step 1 found none.)

   ## In Flight
   - Worktree `<path>` (branch `<branch>`) — `<tasks-file>` <status>, <x/y>.
   - Worktree `<path>` (branch `<branch>`) — merged, reapable (from
     `worktree-reap.sh --dry-run`'s `candidate=` lines).
   - Draft PR #<n> `<title>` (collaborative mode only).
     (State that lives on a branch/worktree or an open draft PR, not yet
     merged to the default branch. Omit this section if step 1 found none.)

   ## Summary
   <N> issues found. Safe to /plan: yes/no. Recommended next step: ...
   ```

6. **Write `.project/STATUS.md`** from the analysis results. Use the same
   structure defined in `/ardd-init`:
   - Artifact status table (name, stable ✅ / draft ⚠️, open question count or —)
   - Open questions grouped by artifact (omit artifacts with none)
   - A line surfacing `DEFECTS.md`'s summary (count + last-checked date, or
     "never checked") drawn from step 1 — read-only, not regenerated here
   - A line surfacing the open feedback count from step 1 (omit if zero)
   - A line surfacing the feature backlog counts from step 1 (omit if
     the register doesn't exist)
   - A line surfacing any orphaned completion flips found in step 1 (omit
     if none)
   - An "In flight" line/section surfacing the `inflight-worktrees.sh`
     output from step 1 (any `worktree-reap.sh --dry-run` candidates as
     "merged, reapable", and the draft-PR list, in collaborative mode) —
     per-worktree branch + tasks file + progress; omit if nothing is in
     flight. This is how a re-entering session sees work that lives on a
     sibling worktree or open PR and hasn't merged yet.
   - Recommended next step drawn from the Summary
   - Update the `_Updated:` date to today

   STATUS.md is the single re-entry point after any interruption. `/ardd-status`
   is its only writer — other skills prompt the user to run it rather than
   writing STATUS.md themselves.

7. **If step 1 found any orphaned completion flips**, ask the user whether
   to perform the flip for each one now via
   `.claude/skills/ardd-scripts/ardd-state.sh feature-flip <slug>
   implemented`. This is `/ardd-status`'s one narrow,
   explicit exception to never writing the register — mirroring the
   tasks-file-completion exception already documented for
   `/ardd-implement` — since the whole reason this check
   exists is that no other skill run is left to catch it. On confirmation,
   flip the entry and note it in the report already written; on decline,
   leave it — the same orphaned slug will be reported again on the next
   `/ardd-status` run, since `completion-flip-check.sh` re-derives it from
   disk state every time rather than remembering a prior decline.

8. **Next-step prompt (opt-in).** After step 6's STATUS.md write (and step 7,
   if it ran), check `.project/artifacts/constitution.md` frontmatter for
   `next_step_prompt: true` (grep the frontmatter block; absent or `false`
   means the plain-text behavior above is unchanged — stop here). When it is
   `true` AND the Summary's "Recommended next step" is a concrete runnable
   `/ardd-*` invocation (e.g. `/ardd-plan <slug>`, `/ardd-defects`), end by
   presenting it via AskUserQuestion:
   - Option 1: "Yes — run `/ardd-<next>` now"
   - Option 2: "No — stop here" (Esc counts as option 2)

   On yes, invoke that skill by name — the existing terminal-handoff
   mechanism, no value passed back. On no/Esc, stop. Recommendations that
   are not a skill invocation ("merge and push", "provision the key") always
   stay plain text, never prompted. Delegated/scripted contexts are
   unaffected: a project that never opted in has no `next_step_prompt`
   field, and absent = false.
