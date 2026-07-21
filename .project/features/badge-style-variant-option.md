---
slug: badge-style-variant-option
status: backlogged
logged: 2026-07-21
---

Flip the install-time dynamic-version-badge offer's default style to shieldcn.dev: the ArDD repo itself uses shieldcn badges, so shieldcn is the default offer, with the shields.io endpoint style offered as the fallback when pre-existing shields.io badges are detected in the consuming repo's README (match the repo's existing visual language). Ship both templates (shieldcn and shields.io) in the ArDD source under templates/, selected/offered per detection, and give agents explicit leeway to offer adapting the shipped templates to whatever badge style is actually detected in the consuming README (e.g. matching variant/theme parameters such as variant=secondary&theme=pink). Consumers using other badge systems should be encouraged, in the offer text and docs, to submit new template designs upstream to the ArDD repo. The generated .github/badges/ardd-version.json already carries the data (including the pre-encoded logoSvg for renderers that take the logo in the URL); only the README snippet's renderer URL differs. Why: observed in yet-another-rank-games (2026-07-21) — the shields.io-styled ArDD badge sits right above a shieldcn sponsor badge with a different visual language. Related: badge-split-variant, badge-brand-color-in-json, badge-icon-logosvg. From inbox capture 2026-07-21.
