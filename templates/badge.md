<!-- Three badge shapes, all linking to the ArDD source repo.

     A shieldcn.dev-rendered alternative to every shape below lives at
     templates/badge-shieldcn.md. shieldcn is now install.sh's default
     offer (this repo's own README uses shieldcn badges); this
     shields.io form is the fallback, offered instead only when the
     target README already carries a pre-existing, non-ArDD
     img.shields.io badge — matching the repo's existing visual
     language. Both ship in the ArDD source regardless of which one a
     given install run selects.

     1. Static-only (below, ardd-badge-start markers): no workflow, no
        JSON — works everywhere, shows no version.

     2. Split badge (ardd-badge-version-start markers): the recommended
        default for ARDD_VERSION_BADGE=1 repos. ONE shields endpoint
        badge whose JSON supplies both halves — "built with ArDD │
        vX.Y.Z" — plus the brand labelColor and the inlined logoSvg
        mark. Appearance updates ride the sync workflow
        (.github/workflows/ardd-badge.yml regenerating
        .github/badges/ardd-version.json); the README never needs
        re-editing.

     3. Two-badge pair (ardd-badge-pair-start markers): the static mark
        and a separate version badge, for READMEs that want them apart.
        The version half reuses the same JSON with a `label=version`
        query override (endpoint query params beat JSON fields).

     For shapes 2 and 3: replace OWNER/REPO/BRANCH with your repo's own
     coordinates before pasting. Public repos only — shields.io fetches
     raw.githubusercontent.com unauthenticated, so the endpoint badge
     won't render for a private repo.

     Posture: every snippet here is suggestion-only at the script level —
     install.sh never edits a README. An agent relaying the suggestion
     should OFFER to apply the edit: present the exact diff (the snippet
     with its markers, replacing any stale badge block) and ask before
     writing — a confirm-with-diff gate, never a refusal that waits for
     an override. -->

<!-- ardd-badge-start -->
[![built with ArDD](https://img.shields.io/badge/built%20with-ArDD-blue)](https://github.com/moui72/artifact-driven-dev)
<!-- ardd-badge-end -->

<!-- ardd-badge-version-start -->
[![built with ArDD](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/OWNER/REPO/BRANCH/.github/badges/ardd-version.json)](https://github.com/moui72/artifact-driven-dev)
<!-- ardd-badge-version-end -->

<!-- ardd-badge-pair-start -->
[![built with ArDD](https://img.shields.io/badge/built%20with-ArDD-blue)](https://github.com/moui72/artifact-driven-dev)
[![ArDD version](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/OWNER/REPO/BRANCH/.github/badges/ardd-version.json&label=version)](https://github.com/moui72/artifact-driven-dev)
<!-- ardd-badge-pair-end -->

<!-- Renderer caveat (which badge service reads what):

     Endpoint-style readers — shields.io /endpoint, used by every snippet
     above — consume label/message/color/labelColor/logoSvg straight from
     the JSON, so brand colour and mark propagate automatically.

     Dynamic-JSON readers — e.g. shieldcn dynamic/json — take ONLY the
     query-selected field (typically $.message) from the JSON; label,
     colour, and logo must ride the URL as query parameters there. For
     the logo, use the pre-encoded data:image/svg+xml;base64,... form of
     the icon, produced from the source of truth with:

         base64 < templates/ardd-icon.svg

     (in a consumer repo the same file is installed at
     .github/badges/ardd-icon.svg). -->
