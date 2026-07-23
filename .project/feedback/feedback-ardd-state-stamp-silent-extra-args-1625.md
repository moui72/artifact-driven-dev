---
status: planned
created: 2026-07-23
plan: plan-chore-feedback-status-readines-2026-07-23-a4a4.md
---

# Feedback

## Bugs
- [x] F001 `ardd-state.sh stamp` (`cmd_stamp`, `.claude/skills/ardd-scripts/ardd-state.sh:330-332`) reads only its first three positional args (`file key val`) and silently ignores anything after them — it neither errors on extra args nor supports stamping multiple key/value pairs in one call. A caller that (mistakenly, or by analogy with tools that do support multi-pair updates) invokes `stamp <file> key1 val1 key2 val2` gets a silent partial stamp (only `key1`/`val1` applied) with no indication `key2`/`val2` were dropped. Fix should either (a) make `cmd_stamp` reject unexpected trailing args (`dieu` on `$4` being non-empty), or (b) extend it to loop over `key val` pairs and apply all of them — whichever direction is chosen, the current silent-drop behavior should not remain.
