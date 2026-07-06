# 0002 — The .gitignore suggestion ceiling: `.claude/skills/ardd-*/`

_Recorded 2026-07-06 (events July 2026). Source-repo history only._

The same mistake happened twice, at two nested levels, in our own
dogfooding. First: `install.sh` suggested a blanket `.claude/` ignore
(correct at the time — nothing else was tracked yet), which would have
silently blocked `.claude/settings.json` — real, team-shared config for
the PostToolUse lint hook added later — from ever being tracked without
`git add -f`. Narrowed to `.claude/skills/`. Then this repo's own
`.gitignore` hit the identical problem one level down: `.claude/skills/`
isn't entirely ARDD-owned either — only the `ardd-*` subdirectories are;
a hand-written custom skill can live alongside them. Narrowed again to
`.claude/skills/ardd-*/`, now the permanent ceiling (Constitution
Principle III).

Two standing warnings in install.sh cover targets that already
over-broadly ignore: one checks whether `.claude/settings.json` would be
blocked, the other whether a synthetic custom-skill path would be — both
fire independently (a blanket `.claude/` triggers both; a blanket
`.claude/skills/` only the second). Don't drop either: without them the
check goes silent forever once anything under `.claude/` is ignored.
