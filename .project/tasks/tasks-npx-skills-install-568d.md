---
plan: plan-npx-skills-install-2026-07-09.md
generated: 2026-07-09
status: in-progress   # generating -> ready -> in-progress -> completed (schema-of-record: scripts/lint-project.sh)
                     # (or -> abandoned, if superseded by a new tasks
                     # file generated for the same plan)
                     # completed is terminal — post-completion failures
                     # become new feedback (/ardd-feedback), never a
                     # status edit.
---

# Tasks

## Phase 1: CLI compatibility (test-first)

- [x] T001 Make every `skills/*/SKILL.md` discoverable by the vercel-labs skills CLI, which requires frontmatter `name` and `description`. First audit all skill files for missing `name:`/`description:` fields and add any gaps (name = the directory/skill name, e.g. `ardd-plan`). Then extend `scripts/lint-docs.sh` (source-side check, Principle IV) to fail when any `skills/*/SKILL.md` lacks either field. Test-first (Principle V): add the failing case to `scripts/test-lint-docs.sh` (or create a fixture-based case if the test currently only runs against the real repo) and confirm red before the lint change. Same commit.

## Phase 2: /ardd-setup skill [feature: npx-skills-install]

- [x] T002 [artifacts: constitution] Write `skills/ardd-setup/SKILL.md` — the bridge that makes an npx-acquired skill set into a real install, per the constitution v1.2.2 standing decision (install.sh is the only real install/upgrade entry point; never reimplement any of it). Steps the skill must contain: (1) detect install completeness — `.claude/skills/ardd-scripts/` present AND `.project/ardd-version.md` present means complete: report that and defer to `/ardd-update`, stop; (2) otherwise ask the user for an existing ARDD source checkout path, offering to clone `https://github.com/<owner>/artifact-driven-dev` to `~/.ardd/source` as the default — never clone or overwrite without explicit confirmation; if the offered directory exists but isn't an ARDD checkout, stop and ask rather than guessing; (3) run `./install.sh <absolute path to this project>` from the source checkout and relay its output verbatim, including any gitignore suggestions and warnings; (4) end by telling the user to run `/ardd-bootstrap` (no `.project/` yet) or `/ardd-analyze` (existing `.project/`) — plain-text pointer, not a skill invocation, since which one applies is the user's call. Prose only, no script test; `./scripts/lint-docs.sh` must pass.
- [x] T003 Register `ardd-setup` in `scripts/gen-skill-docs.sh` (README's skill sections and WORKFLOW.md are generated from it — a hand-edit to README would fail lint-docs' drift check) with a one-line description ("complete an npx-acquired install by locating/cloning the ARDD source and running install.sh"), placed in the setup tier alongside bootstrap/codify. Regenerate README.md/WORKFLOW.md via the generator and confirm `./scripts/lint-docs.sh` passes (its `--check` mode is the drift test).
- [ ] T004 `install.sh`: before copying, if an existing `.claude/skills/ardd-*` entry in the target is a symlink (the skills CLI's symlink mode pointing into its cache), print a warning naming the problem (regeneration would write through the symlink into the CLI cache, not the project) and the fix (remove the symlinks and re-add with the CLI's copy mode, or let install.sh replace them), replace the symlink with a real copied directory, and continue — warn, never fail. Test-first: add a case to `scripts/test-install.sh` (or the existing install regression test file) that pre-creates a symlinked `ardd-*` skill dir in a throwaway target, asserts the warning is printed and the result is a real directory, not a symlink; confirm red before implementing. Same commit.

## Phase 3: Docs + live verification

- [ ] T005 README.md + USAGE.md: add the npx quick start — `npx skills add <owner>/artifact-driven-dev` (choose copy mode, not symlink) followed by `/ardd-setup` in Claude Code — alongside the existing clone-first instructions, stating plainly that npx is an acquisition channel only and `install.sh` (via `/ardd-setup`) is the installer. README's generated sections must be edited via `scripts/gen-skill-docs.sh` (see T003), hand-edit only the non-generated prose. `./scripts/lint-docs.sh` must pass.
- [ ] T006 Live verification (manual, network-dependent — no CI job, same gating rationale as the smoke-test tier): in a throwaway directory with `git init`, run `npx skills add` against this repo (copy mode), confirm the ardd skills land under `.claude/skills/`; then simulate `/ardd-setup`'s steps end-to-end (point it at this checkout as the source, run `./install.sh <throwaway>`), confirm the non-skill reference dirs exist, `.project/ardd-version.md` is recorded, `.worktreeinclude` contains `.claude/skills/ardd-*/`, and `ardd-update-check.sh` reports a sensible outcome there. Append a dated findings note to this tasks file (notes only — never touch DEFECTS.md; if a real code-vs-artifact violation surfaces, report it and point at /ardd-verify).
