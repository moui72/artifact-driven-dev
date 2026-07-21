---
slug: pre-commit-hook-scoping-expans
status: implemented
logged: 2026-07-21
plan: plan-changelog-precommit-2026-07-21-b716.md
tasks: tasks-changelog-precommit-0966.md
---

Extend hooks/pre-commit's staged-path scoping so workflow-YAML, test-fixture, and no-check-subject commits (CLAUDE.md, dev-notes/, tests/scenarios/, dotfiles) hit a fast path instead of the full ~117s RUN_ALL fallback, and wire scripts/lint-templates-yaml.sh into the hook itself (currently CI-only, so a broken workflow YAML silently passes the hook).
Why: measured in feedback-pre-commit-hook-p90-1e7b.md, full suite ~117s warm vs ~8s for the already-scoped .project/-only path; today any commit touching .github/workflows/*, tests/*, dev-notes/*, or CLAUDE.md still pays the full 117s for zero relevant local coverage. Concrete scope, from a dispatched Fable research agent (2026-07-21): (1) add lint-templates-yaml.sh to the hook's check loop with check_needed mapping .github/workflows/ + templates/ (sub-second, graceful PyYAML skip already built in); (2) map tests/fixtures/ to its only consumers, test-lint-project.sh + test-hook-lint-on-write.sh; (3) recognize CLAUDE.md, dev-notes/*, tests/scenarios/*, mkdocs.yml, .gitignore, .worktreeinclude as no-check paths (nothing in the suite reads them); (4) same commit, add fixture cases to scripts/test-hooks-pre-commit.sh pinning each new mapping. Explicitly rejected by that research pass: splitting test-install-version-badge.sh or test-new.sh (every case in each exercises its one mapped subject, so splitting narrows no hook path); narrowing the skills/* -> install-family test fan-out (correct as-is); mapping .claude/, .agents/, site/ (rarely committed, leave on fail-safe).
