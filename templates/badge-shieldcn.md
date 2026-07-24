<!-- Three badge shapes, all linking to the ArDD source repo — the
     shieldcn.dev-rendered counterpart to templates/badge.md. See that
     file's own header and "Renderer caveat" comment for the full
     three-shape rationale and the dynamic-JSON-reader background; this
     file only restates what differs for shieldcn.dev's own renderer.

     Default/fallback rule (install.sh, install-time only): shieldcn.dev
     is the default offer — this repo's own README badges (e.g.
     README.md:13's sponsor badge) already use shieldcn, so it's the
     house style. install.sh falls back to templates/badge.md's
     shields.io form only when the target README already carries a
     pre-existing, non-ArDD img.shields.io badge outside ArDD's own
     marker blocks (matching the target's existing visual language
     beats imposing a new one). Both templates ship in the ArDD source
     under templates/ regardless of which one install.sh selects for a
     given run.

     VERIFIED (2026-07-21, live test render — see feedback-badge-style-
     variant-followups-dbff.md F001, T009): the `dynamic/json` query-
     string shape below (url + a $.message-style query selector, with
     label/color/logo riding the URL rather than the JSON) is confirmed
     against shieldcn.dev's own API reference and a real render, grounded
     in this repo's static shieldcn badge at README.md:13
     (https://shieldcn.dev/badge/sponsor-%E2%9D%A4-ea4aaa.svg?variant=secondary&theme=pink)
     for the static-badge URL shape and the `variant=secondary&theme=pink`
     query-param form. The `url`/`query` (JSONPath selector, e.g.
     $.message)/`label`/`color`/`labelColor`/`logo`/`variant`/`theme`
     param names are all documented appearance params.

     RE-VERIFIED (2026-07-24, live render): `logo` DOES now accept a
     base64 `data:image/svg+xml;base64,...` URI — the 2026-07-21 finding
     that it was silently ignored no longer holds. But shieldcn.dev's
     satori-based renderer flattens the SVG hard: strokes are dropped
     (a stroked circle renders as a solid filled disc), per-element
     `transform` attributes are discarded (elements stamp at their
     untransformed coordinates), and per-element fills are replaced by
     one uniform monochrome fill. An icon passed here must therefore be
     plain filled <path> elements with baked-in absolute coordinates,
     designed to read as a single-color silhouette —
     templates/ardd-icon.svg satisfies this by construction; produce the
     value for PLACEHOLDER with `base64 < templates/ardd-icon.svg` (in a
     consumer repo the same file sits at .github/badges/ardd-icon.svg).
     Named slugs (e.g. `logo=github`) also still work.

     For shapes 2 and 3: replace OWNER/REPO/BRANCH with your repo's own
     coordinates before pasting. Public repos only — the endpoint fetches
     raw.githubusercontent.com unauthenticated, so it won't render for a
     private repo.

     Every snippet's variant/theme query params default to plain values
     below. An agent relaying this suggestion should also offer to adapt
     them to whatever badge styling is already visible in the target
     README (e.g. variant=secondary&theme=pink) rather than pasting the
     shipped defaults unexamined.

     Posture: every snippet here is suggestion-only at the script level —
     install.sh never edits a README. An agent relaying the suggestion
     should OFFER to apply the edit: present the exact diff (the snippet
     with its markers, replacing any stale badge block) and ask before
     writing — a confirm-with-diff gate, never a refusal that waits for
     an override.

     Using a different badge system than shields.io/shieldcn? Submit a
     new template design upstream to the ArDD repo (templates/) rather
     than hand-rolling one in your own README — future installs benefit
     too. -->

<!-- ardd-badge-start -->
[![built with ArDD](https://shieldcn.dev/badge/built%20with-ArDD-7C3AED.svg?variant=secondary&theme=pink)](https://github.com/moui72/artifact-driven-dev)
<!-- ardd-badge-end -->

<!-- ardd-badge-version-start -->
[![built with ArDD](https://shieldcn.dev/badge/dynamic/json.svg?url=https://raw.githubusercontent.com/OWNER/REPO/BRANCH/.github/badges/ardd-version.json&query=$.message&label=built%20with%20ArDD&color=7C3AED&logo=data:image/svg+xml;base64,PLACEHOLDER&variant=secondary&theme=pink)](https://github.com/moui72/artifact-driven-dev)
<!-- ardd-badge-version-end -->

<!-- ardd-badge-pair-start -->
[![built with ArDD](https://shieldcn.dev/badge/built%20with-ArDD-7C3AED.svg?variant=secondary&theme=pink)](https://github.com/moui72/artifact-driven-dev)
[![ArDD version](https://shieldcn.dev/badge/dynamic/json.svg?url=https://raw.githubusercontent.com/OWNER/REPO/BRANCH/.github/badges/ardd-version.json&query=$.message&label=version&color=7C3AED&logo=data:image/svg+xml;base64,PLACEHOLDER&variant=secondary&theme=pink)](https://github.com/moui72/artifact-driven-dev)
<!-- ardd-badge-pair-end -->

<!-- Renderer caveat (which badge service reads what):

     shieldcn.dev's dynamic/json endpoint (used by the split/pair
     snippets above), like shields.io's own /dynamic/json, takes ONLY
     the query-selected field ($.message) from the JSON; label, color,
     and logo must ride the URL as query parameters here — the same gap
     templates/badge.md's own "Dynamic-JSON readers" note documents for
     shieldcn specifically. Custom-icon-via-data:-URI works (re-verified
     2026-07-24, superseding the 2026-07-21 ignored-param finding), with
     the monochrome/filled-paths-only renderer constraint described in
     the VERIFIED note above — fill PLACEHOLDER with
     `base64 < templates/ardd-icon.svg`. -->
