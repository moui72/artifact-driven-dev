---
status: planned
created: 2026-07-21
plan: plan-multi-harness-2026-07-21-76ba.md
---

# Feedback

## Bugs
- [x] F001 docs/reference/skills/ardd-update.md hand-written body, "What a run does" step 4, is stale against the post-v1.0.3 SKILL.md: it says the reinstall just runs `<source>/install.sh` with no mention of harness preservation — reading `HARNESS=` from `harness-capabilities.env`, passing `--harness <harness>`, and refusing to reinstall a Codex install from a source whose install.sh lacks the `--harness` option.
- [x] F002 docs/reference/skills/ardd-update.md step 4 still claims "Your README is never edited; the snippet is yours to paste" — contradicting the skill's new confirm-with-diff posture (SKILL.md "Dynamic version-badge offer" / suggestion-apply sections: offer to apply, show the exact diff, ask before writing). The general "Suggestions are yours to accept" sentence should carry the same framing.
- [x] F003 install.sh's `--harness codex` option (commit e4f6226) appears nowhere in human-facing docs — no mention in docs/install.md, USAGE.md, or README.md. Document the flag in docs/install.md; consider a USAGE.md routing line if the capability warrants one.
