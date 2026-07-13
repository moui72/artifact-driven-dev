---
name: ardd-backlog
tier: core
description: "Log a feature idea to the per-feature register (.project/features/) — no artifact edits yet; bugs and UX problems with existing behavior belong in /ardd-feedback instead."
---

# /ardd-backlog

Log a feature idea to the backlog — a new file in `.project/features/`
(the per-feature register; constitution standing decision 2026-07-06). This
skill only records the idea — it does not touch artifacts. Design work
(identifying affected artifacts, proposing and applying changes) happens
later, when the idea is targeted by slug in `/ardd-plan <slug>`. This lets
you accumulate a backlog of ideas and work them in whatever order you like,
rather than committing to design-and-apply the moment you think of one.

Not to be confused with `/ardd-init`'s feature-register extraction — that's
the one-time bulk backfill of a whole register from an existing codebase (an
offered step of `/ardd-init`'s existing-codebase path). `/ardd-backlog` logs a single new idea at a
time, going forward.

Usage: `/ardd-backlog <description>` where description is a plain-language
statement of the feature (e.g., "octokit fallback for GitHub similar to the
existing GitLab REST fallback"). Substantial or decision-reversing ideas:
vet with `/ardd-research` first — its proposal-vetting mode pressure-tests
the idea against the current artifacts before it earns a backlog entry.

## Steps

1. **Understand the feature.** Parse the user's description. If the intent is
   genuinely unclear (not just under-specified — backlog entries don't need
   full design detail), ask one clarifying question. Do not ask questions
   answerable by reading the artifacts.

   **Mirror check:** if the description is actually a complaint about
   *existing* behavior — a bug, a UX problem, something that works but
   shouldn't work that way — it belongs in a feedback file, not the
   register. Offer to capture it as `/ardd-feedback <the observation>`
   instead; only log it here if the user confirms it really is a new
   capability.

2. **Derive a slug.** Choose the wording (judgment — prefer a short
   capability-level noun phrase), then sanitize it deterministically:
   `.claude/skills/ardd-scripts/ardd-state.sh slug "<text>"`. Check for a
   collision against existing files in `.project/features/` — if taken,
   append a freshly generated 4-char hex token.

3. **Create the register entry.** Before writing, run
   `.claude/skills/ardd-scripts/project-lock.sh check ardd-backlog` — if it
   warns, surface the warning to the user (another invocation touched
   `.project/` recently) but proceed regardless; this is advisory, never a
   block. Then create the file (script-performed; it refuses a duplicate
   slug), with the body on stdin:

   ```
   printf '%s\n' "<one-sentence description>" "Why: <optional context>" \
     | .claude/skills/ardd-scripts/ardd-state.sh feature-create <slug>
   ```

   The body is one sentence on what the capability does from the user or
   caller's perspective, plus an optional `Why:` line for context that
   won't be obvious from code or artifacts later — omit it when the
   motivation is already obvious. The script writes the frontmatter
   (`slug`, `status: backlogged`, `logged: <today>`). After writing, run
   `.claude/skills/ardd-scripts/project-lock.sh touch ardd-backlog`.

4. **Legacy note.** If the project still has a single-file
   `.project/artifacts/features.md`, the register predates migration
   0003-per-feature-files — tell the user to re-run `install.sh` (which
   applies the migration) before logging new entries; don't append to the
   legacy file.

5. **Report** the slug and a one-line confirmation. Remind the user: run
   `/ardd-plan <slug>` (any time, in any order relative to other backlog
   items) when ready to design and plan this feature — that's when affected
   artifacts get identified, proposed, and applied.

6. Run `/ardd-status` now to refresh `STATUS.md`'s Feature Backlog count —
   the entry appended in step 4 leaves it stale otherwise.
