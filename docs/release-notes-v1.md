# ArDD v0.9.0 release notes

The first tagged release finalizes the public skill surface.

The skill surface was finalized for v0.9.0: six renames and four skills
folded into surviving ones. Old commands are gone (install.sh prunes them
and points at the replacement); files they owned are migrated
automatically.

| Before v0.9.0 | Now |
|---|---|
| `ardd-analyze` | `/ardd-status` |
| `ardd-critique` | `/ardd-audit` (legacy owned file `critique.md` → `audit.md`) |
| `ardd-verify` | `/ardd-defects` (DEFECTS.md keeps its name) |
| `ardd-sync` | `/ardd-tracker` (legacy owned file `SYNC.md` → `TRACKER.md`) |
| `ardd-feature` | `/ardd-backlog` (`.project/features/` keeps its name) |
| `ardd-render` | `/ardd-diagram` |
| `ardd-converge` | folded into `/ardd-implement` (reconcile mode — offered on pick, or `--reconcile <file>`) |
| `ardd-add-artifact` | folded into `/ardd-refine` (naming a new artifact enters its create path) |
| `ardd-bootstrap` | merged into `/ardd-init` (greenfield path) |
| `ardd-codify` | merged into `/ardd-init` (existing-codebase path) |
