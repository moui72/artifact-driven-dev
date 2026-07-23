---
status: planned
created: 2026-07-23
plan: plan-chore-feedback-status-readines-2026-07-23-a4a4.md
---

# Feedback

## Bugs
- [x] F001 `/ardd-implement`'s delegation pre-flight (`.claude/skills/ardd-implement/SKILL.md`, "Pre-flight: verify the chosen tasks file and its bound plan are committed before launching") only `git add`s and commits the two exact paths `<plan-file> <tasks-file>` before handing off to a worktree subagent. But a single `/ardd-plan` run that targeted feature slugs, resolved feedback, or surfaced defects also edits `.project/artifacts/*.md` (step 3d), flips entries in `.project/features/*.md` (steps 3d's register status, step 11, step 14), and marks/flips `.project/feedback/feedback-*.md` files (step 4) — none of those paths are covered by the pre-flight's two-file `git add`. Since a delegated worktree only sees state that has reached local `<default>` (via `worktree-align.sh`'s fast-forward), any of those uncommitted sibling edits are invisible to the subagent exactly the same way an uncommitted plan/tasks file would be — the pre-flight closes the gap for two of the files a plan run can produce, not all of them. Fix should extend the pre-flight's dirty-check (and, in solo mode, its auto-commit) to cover every path the plan's own frontmatter/content implies it touched — the plan's `features:` list resolves to `.project/features/<slug>.md` files, and the consuming feedback files are discoverable via each `.project/feedback/feedback-*.md`'s `plan:` frontmatter pointing at this plan — rather than the current fixed two-path list.
