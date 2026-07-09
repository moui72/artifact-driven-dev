---
slug: npx-skills-install
status: implemented
logged: 2026-07-09
plan: plan-npx-skills-install-2026-07-09.md
tasks: tasks-npx-skills-install-568d.md
---

ARDD can be installed into a target project via npx using the vercel-labs skills CLI (https://github.com/vercel-labs/skills), as an alternative entry point to cloning this repo and running ./install.sh.
Why: removes the clone-first requirement for new consumers; design must reconcile the skills CLI's install model with what install.sh does beyond copying skills (non-skill reference dirs, migrations, .ardd-applied, ardd-version.md, .worktreeinclude, gitignore checks) — decide at plan time whether npx wraps install.sh or the repo just becomes skills-CLI-compatible.
