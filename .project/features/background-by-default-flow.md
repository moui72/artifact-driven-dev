---
slug: background-by-default-flow
status: tasked
logged: 2026-07-11
plan: plan-background-by-default-flow-2026-07-12.md
tasks: tasks-background-by-default-flow-8e91.md
---

In solo mode /ardd-plan defaults to committing plan and tasks files straight to the local default branch (no branch gate), and two new constitution frontmatter knobs — delegation: eager|ask|inline and merge: auto|ask (absent = ask, enums in lint-project.sh same commit) — let /ardd-implement//ardd-converge delegate and eager-merge without prompting, demoting fold-to-main.sh to a recovery path.
Why: today the common solo chain creates a branch in plan only to immediately ff-fold it back before delegating, and pauses for a human at the delegate and merge gates even when the answer is always yes; removing the detour and the two prompts makes background execution the default one-keypress arc from plan's next-step prompt through merge and analyze. Follows the workflow_mode/next_step_prompt precedent (asked once at bootstrap, stamped via ardd-state.sh).
