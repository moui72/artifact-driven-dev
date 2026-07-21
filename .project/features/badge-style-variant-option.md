---
slug: badge-style-variant-option
status: backlogged
logged: 2026-07-21
---

Install-time dynamic-version-badge offer accepts a style/variant option: alongside the default shields.io endpoint badge, let the user point the snippet at shieldcn.dev (matching variant/theme, e.g. variant=secondary&theme=pink) so the ArDD badge visually matches a README's existing shieldcn badges. The generated .github/badges/ardd-version.json already carries the data (including the pre-encoded logoSvg for renderers that take the logo in the URL); only the README snippet's renderer URL differs. Why: observed in yet-another-rank-games (2026-07-21) — the shields.io-styled ArDD badge sits right above a shieldcn sponsor badge with a different visual language. Related: badge-split-variant, badge-brand-color-in-json, badge-icon-logosvg. From inbox capture 2026-07-21.
