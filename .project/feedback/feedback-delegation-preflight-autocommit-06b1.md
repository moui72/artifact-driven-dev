---
status: open      # open -> planned
created: 2026-07-16
plan: null        # set to the consuming plan's filename once planned
---

# Feedback

## Reconsidered
- [ ] F001 `skills/ardd-implement/SKILL.md`'s delegation pre-flight check
  (step 3, "Pre-flight: verify the chosen tasks file and its bound plan
  are committed before launching") currently reads: on an uncommitted
  plan/tasks file, "offer to commit them now, or block delegation." User
  report: "this happens often" — a delegation attempt failed because
  the plan/tasks files existed only as uncommitted changes on `main`;
  recovery required noticing the failure, committing by hand, and
  re-launching. Reconsidered: in solo mode, on the current (usually
  default) branch, with no other reason to hold the commit back, the
  agent should just commit the uncommitted plan/tasks file(s)
  automatically as part of the pre-flight step — not stop to ask —
  since asking only adds a round-trip for what's almost always the
  obvious right move (these are exactly the files the immediately-prior
  `/ardd-plan` run just wrote). Collaborative mode's existing
  "never push without confirming" rule is a different, separately-owned
  decision and is not in scope here — this is specifically about
  committing locally before delegating, not about pushing.

  **Root cause unconfirmed, flagged before planning (fable review,
  2026-07-16):** the pre-flight check this item wants changed was only
  added two days before this report (commit `54191fb`, 2026-07-14, from
  `feedback-uncommitted-plan-tasks-delegat-a3ff.md`). It's unknown
  whether (a) the check fired and was declined/ignored, (b) the check
  fired but its `plan:`-frontmatter resolution or `git status --short`
  scope missed the files (a latent bug in the check's mechanics, not a
  UX problem), or (c) the failure happened against an older install
  predating the check entirely (which repo/session isn't recorded, and
  there's no way to determine this after the fact). The reporter's
  framing assumes (a); it could equally be (b) or (c). **`/ardd-plan`
  should not plan only the literal "ask → auto-commit" request** —
  it should scope this as two things to address together: the UX change
  requested here, *and* a check of the existing pre-flight mechanics
  (does `plan:` frontmatter resolution and the `git status --short`
  scope actually work as intended?) so a latent scope-miss bug isn't
  left unaddressed. Also carry forward three scoping constraints the
  review surfaced for the UX change itself: auto-commit should announce
  what it committed (paths + hash) rather than commit silently, since an
  uncommitted plan/tasks file at delegation time is no longer the normal
  case now that solo `/ardd-plan` commits its own output — it may signal
  a stale install or a deliberate mid-revision edit, not just the
  ordinary case this item assumes; the `git add` must be scoped to
  exactly the plan/tasks file paths, never a sweep; and the fold path
  (`fold-to-main.sh`, which refuses on `dirty`) runs before the
  pre-flight when `on_default=false` — if the uncommitted plan/tasks
  files are what make the tree dirty, ordering the pre-flight commit
  ahead of the fold may also be needed to avoid an unnecessary refusal.
