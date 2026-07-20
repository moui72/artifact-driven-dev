---
slug: badge-icon-logosvg
status: backlogged
logged: 2026-07-20
---

Ship an ArDD mark as templates/ardd-icon.svg (single-colour, legible at 14px) and have the badge sync workflow inline it into ardd-version.json as logoSvg — never escaped SVG in a shell heredoc — plus a pre-encoded data:image/svg+xml;base64 form for renderers that take the logo in the URL (e.g. shieldcn). simple-icons namedLogo is a later nice-to-have (notability requirements), not a dependency. From assisted-review PRs #107/#108; reporter offers working versions. Related: badge-split-variant, badge-brand-color-in-json.
