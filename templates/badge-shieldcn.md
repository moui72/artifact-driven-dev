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
     param names are all documented appearance params — but `logo` does
     **NOT** accept a base64 `data:image/svg+xml;base64,...` URI the way
     shields.io's `logo` param does: a live A/B render (same query,
     `logo=` present vs. absent vs. set to a `data:` URI) came back
     byte-for-byte identical, meaning the data: URI form is silently
     ignored, not an error — you'd ship a badge that looks fine and
     simply never shows the custom icon. `logo=<named-slug>` (e.g.
     `logo=github`, a simple-icons-style slug) DOES render — confirmed by
     the same test producing a visibly larger, icon-bearing SVG — so
     shieldcn.dev's dynamic/json logo param supports named icon slugs
     only, not arbitrary custom SVGs via data: URI. The `PLACEHOLDER`
     token below is therefore left in place deliberately, not an
     oversight: there is no confirmed way to render the custom ArDD icon
     via this badge type today. If shieldcn.dev adds data: URI support
     later, re-verify with the same A/B byte-comparison technique before
     replacing PLACEHOLDER. The static form (shape 1, grounded in this
     repo's own working badge) remains the safest of the three to trust
     as-is; it carries no logo param at all.

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
     shieldcn specifically. Custom-icon-via-data:-URI does NOT work here
     (verified 2026-07-21, live A/B render): shieldcn.dev's `logo` param
     silently ignores a `data:image/svg+xml;base64,...` value — the
     rendered badge comes back byte-for-byte identical with the param
     present or absent, so it fails silent rather than loud. Only a
     named logo slug (simple-icons-style, e.g. `logo=github`) actually
     renders. Until shieldcn.dev adds data: URI support, the PLACEHOLDER
     token above stays in place — there is no working substitute
     (`base64 < templates/ardd-icon.svg` would produce a value shieldcn.dev
     accepts syntactically but silently drops). -->
