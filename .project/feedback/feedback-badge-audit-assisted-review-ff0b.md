---
status: open
created: 2026-07-24
plan: null
---

# Feedback

Source: badge audit in consumer repo moui72/assisted-review after /ardd-update
v1.1.1-beta.3 → v1.2.1-beta.1 (beta channel). All items verified against the
source at ~/.ardd/source and by live A/B badge renders on 2026-07-24.

## Bugs
- [ ] F001 install.sh never refreshes badge assets once they exist, so a rebrand never reaches consumers: `.github/badges/ardd-icon.svg` and `.github/workflows/ardd-badge.yml` are skipped with "already exists, left untouched", leaving the consumer on the old 24x24 triangle mark and the old `labelColor: #7C3AED` (current templates emit `#2F4858`) with no drift indication. Icon is declared "source of truth … inlined verbatim" — refresh it in place or at least detect and report that a managed asset differs from the current template. (install.sh badge-asset section, ~L787-794)
- [ ] F002 templates/badge-shieldcn.md is internally inconsistent with the workflow it pairs with: shape-2/shape-3 snippets pass `color=7C3AED` while templates/ardd-badge-workflow.yml and templates/ardd-badge.json emit `#2F4858`.
- [ ] F003 install.sh records a stable Source-Ref on a beta-channel install: the ALL_REFS_AT_HEAD block (~L574-576) unconditionally prefers a non-`-beta.` tag and orders with plain `sort -V` (missing the `versionsort.suffix=-beta.` ordering source-resolve.sh:156 applies, despite the comment claiming to match it). On a commit carrying v1.2.0 + v1.2.1-beta.1 (e.g. 20d8960) a Channel: beta install cannot record a beta ref, and ardd-badge.yml then publicly advertises a stable version string. Fix: pick the highest tag under suffix ordering, filtered to the channel being recorded.
- [ ] F004 scripts/completion-flip-check.sh fails silent once the merged branch is deleted (GitHub's default post-merge action): `git merge-base --is-ancestor "$branch" "$default" 2>/dev/null` on a missing ref errors, the error is swallowed, and the script exits 0 as if nothing were orphaned. Observed live: tasks-1a23-cc11.md completed, plan branch `1a23` merged then deleted, all three bound features still `tasked`, script printed nothing. Distinguish "branch missing" from "branch not merged" and report the former loudly, or fall back to locating the squash/merge commit.
- [ ] F005 /ardd-update (step 4, dynamic version-badge offer) and install.sh disagree about when the badge can be produced: the skill gates on the README lacking `ardd-badge-version-start`, but install.sh's BADGE_FAMILY guard (~L729-737) classifies a README with only `ardd-badge-start` as "static" and refuses even with ARDD_VERSION_BADGE=1. Hit live: offer made, accepted, unfulfillable. Both guards should test the same condition.
- [ ] F006 templates/badge-shieldcn.md's PLACEHOLDER caveat is stale: shieldcn.dev's dynamic/json `logo=` param now DOES render a `data:image/svg+xml;base64,...` URI (A/B re-verified 2026-07-24: SVG grows 3929→4133 bytes, width 190→212, added path is the ArDD mark), contradicting the 2026-07-21 verification the template ships. Drop PLACEHOLDER and inline the real base64 icon. (Renderer constraint discovered alongside: satori drops strokes/per-element transforms/fills — icon must be monochrome filled paths; the mark itself was replaced satori-safe in PR #25, prose caveat still stale.)
- [ ] F008 templates/ardd-badge-workflow.yml computes a per-channel color (yellow beta / blue stable) into the endpoint JSON that is inert under the default-offered shieldcn renderer: dynamic/json ignores the JSON's `color` and a `colorQuery=$.color` selector (verified). Either document the manual `color=` URL-param mirroring, or default to a shields.io /endpoint render, which does consume the JSON's color/labelColor/logoSvg.

## UX
- [ ] F007 templates/badge-shieldcn.md should document that shieldcn.dev ignores `mode=`: `mode=dark`, `mode=light`, and no mode return byte-identical SVGs (verified), so adopters invent dead `<picture>`/prefers-color-scheme markup around the badge. One line in the renderer caveat prevents it.
