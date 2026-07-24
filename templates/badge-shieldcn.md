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
     templates/ardd-icon.svg satisfies this by construction. The shape-2/
     shape-3 snippets below carry that icon's URL-safe base64 inline;
     after an icon change, regenerate the `logo=` value with

         base64 < templates/ardd-icon.svg | tr -d '\n' | jq -sRr @uri

     (in a consumer repo the same file sits at
     .github/badges/ardd-icon.svg). Raw `base64` output alone is NOT
     URL-safe — it wraps lines and emits `+`/`/`/`=`, which break the
     query string; the `tr`+`jq @uri` steps are required, not cosmetic.
     Named slugs (e.g. `logo=github`) also still work.

     Two more verified renderer facts (2026-07-24, same A/B byte-compare
     technique): shieldcn.dev ignores `mode=` — `mode=dark`, `mode=light`,
     and no mode at all return byte-identical SVGs, so wrapping the badge
     in `<picture>`/prefers-color-scheme markup for it is dead weight.
     And its dynamic/json endpoint reads ONLY the query-selected field
     from the JSON — the sync workflow's computed per-channel `color`
     (yellow beta / blue stable) and `labelColor` in
     .github/badges/ardd-version.json are consumed by shields.io
     /endpoint renders only. In these snippets color rides the URL as a
     static param, so a channel-color change must be mirrored by editing
     `color=` here by hand (or use templates/badge.md's shields.io
     endpoint form, which does consume the JSON's colors and logoSvg).

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
[![built with ArDD](https://shieldcn.dev/badge/dynamic/json.svg?url=https://raw.githubusercontent.com/OWNER/REPO/BRANCH/.github/badges/ardd-version.json&query=$.message&label=built%20with%20ArDD&color=2F4858&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIiByb2xlPSJpbWciIGFyaWEtbGFiZWw9IkFyREQiPgo8IS0tIFNvdXJjZSBvZiB0cnV0aCBmb3IgdGhlIEFyREQgYmFkZ2UgbWFyazogdGhlIGJhZGdlIHdvcmtmbG93IGlubGluZXMgdGhpcyBmaWxlIHZlcmJhdGltIGFzIHRoZSBlbmRwb2ludCBKU09OJ3MgbG9nb1N2ZywgYW5kIGl0cyBiYXNlNjQgZm9ybSByaWRlcyBzaGllbGRjbi5kZXYgYmFkZ2UgVVJMcyBhcyB0aGUgbG9nbyBwYXJhbS4gUmVuZGVyZXIgY29uc3RyYWludCAodmVyaWZpZWQgMjAyNi0wNy0yNCBhZ2FpbnN0IGEgbGl2ZSBzaGllbGRjbiByZW5kZXIpOiBzYXRvcmktYmFzZWQgYmFkZ2UgcmVuZGVyZXJzIGRyb3Agc3Ryb2tlcywgcGVyLWVsZW1lbnQgdHJhbnNmb3JtcywgYW5kIHBlci1lbGVtZW50IGZpbGxzIOKAlCBldmVyeXRoaW5nIGhlcmUgbXVzdCBzdGF5IHBsYWluIGZpbGxlZCA8cGF0aD4gZWxlbWVudHMgd2l0aCBiYWtlZC1pbiBhYnNvbHV0ZSBjb29yZGluYXRlcywgb25lIGNvbG9yLiBUaGUgbWFyazogYSBicm9rZW4gcmluZyB3aXRoIGEgdGFuZ2VudGlhbCBhcnJvd2hlYWQgKHRoZSBpdGVyYXRlIGxvb3ApIGFyb3VuZCBhIGRvZy1lYXJlZCBkb2N1bWVudCAodGhlIGFydGlmYWN0KS4gV2hpdGUgPSBkYXJrLWJhY2tncm91bmQgKGJhZGdlIGxhYmVsIHNpZGUpIHZhcmlhbnQuIC0tPgo8cGF0aCBmaWxsPSIjZmZmZmZmIiBkPSJNNjAuODggOS40M0E0MiA0MiAwIDEgMCA5MC41NyAzOS4xMkw3OC45OCA0Mi4yM0EzMCAzMCAwIDEgMSA1Ny43NyAyMS4wMloiLz4KPHBhdGggZmlsbD0iI2ZmZmZmZiIgZD0iTTc5LjYgMjEuNEw3Mi4yIDQ0LjBMOTcuMyAzNy4zWiIvPgo8cGF0aCBmaWxsPSIjZmZmZmZmIiBkPSJNMzggMzFINTdMNjUgMzlWNjlIMzhaIi8%2BCjwvc3ZnPgo%3D&variant=secondary&theme=pink)](https://github.com/moui72/artifact-driven-dev)
<!-- ardd-badge-version-end -->

<!-- ardd-badge-pair-start -->
[![built with ArDD](https://shieldcn.dev/badge/built%20with-ArDD-7C3AED.svg?variant=secondary&theme=pink)](https://github.com/moui72/artifact-driven-dev)
[![ArDD version](https://shieldcn.dev/badge/dynamic/json.svg?url=https://raw.githubusercontent.com/OWNER/REPO/BRANCH/.github/badges/ardd-version.json&query=$.message&label=version&color=2F4858&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIiByb2xlPSJpbWciIGFyaWEtbGFiZWw9IkFyREQiPgo8IS0tIFNvdXJjZSBvZiB0cnV0aCBmb3IgdGhlIEFyREQgYmFkZ2UgbWFyazogdGhlIGJhZGdlIHdvcmtmbG93IGlubGluZXMgdGhpcyBmaWxlIHZlcmJhdGltIGFzIHRoZSBlbmRwb2ludCBKU09OJ3MgbG9nb1N2ZywgYW5kIGl0cyBiYXNlNjQgZm9ybSByaWRlcyBzaGllbGRjbi5kZXYgYmFkZ2UgVVJMcyBhcyB0aGUgbG9nbyBwYXJhbS4gUmVuZGVyZXIgY29uc3RyYWludCAodmVyaWZpZWQgMjAyNi0wNy0yNCBhZ2FpbnN0IGEgbGl2ZSBzaGllbGRjbiByZW5kZXIpOiBzYXRvcmktYmFzZWQgYmFkZ2UgcmVuZGVyZXJzIGRyb3Agc3Ryb2tlcywgcGVyLWVsZW1lbnQgdHJhbnNmb3JtcywgYW5kIHBlci1lbGVtZW50IGZpbGxzIOKAlCBldmVyeXRoaW5nIGhlcmUgbXVzdCBzdGF5IHBsYWluIGZpbGxlZCA8cGF0aD4gZWxlbWVudHMgd2l0aCBiYWtlZC1pbiBhYnNvbHV0ZSBjb29yZGluYXRlcywgb25lIGNvbG9yLiBUaGUgbWFyazogYSBicm9rZW4gcmluZyB3aXRoIGEgdGFuZ2VudGlhbCBhcnJvd2hlYWQgKHRoZSBpdGVyYXRlIGxvb3ApIGFyb3VuZCBhIGRvZy1lYXJlZCBkb2N1bWVudCAodGhlIGFydGlmYWN0KS4gV2hpdGUgPSBkYXJrLWJhY2tncm91bmQgKGJhZGdlIGxhYmVsIHNpZGUpIHZhcmlhbnQuIC0tPgo8cGF0aCBmaWxsPSIjZmZmZmZmIiBkPSJNNjAuODggOS40M0E0MiA0MiAwIDEgMCA5MC41NyAzOS4xMkw3OC45OCA0Mi4yM0EzMCAzMCAwIDEgMSA1Ny43NyAyMS4wMloiLz4KPHBhdGggZmlsbD0iI2ZmZmZmZiIgZD0iTTc5LjYgMjEuNEw3Mi4yIDQ0LjBMOTcuMyAzNy4zWiIvPgo8cGF0aCBmaWxsPSIjZmZmZmZmIiBkPSJNMzggMzFINTdMNjUgMzlWNjlIMzhaIi8%2BCjwvc3ZnPgo%3D&variant=secondary&theme=pink)](https://github.com/moui72/artifact-driven-dev)
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
     the RE-VERIFIED note above — the snippets carry the icon's URL-safe
     base64 inline; regenerate after an icon change with
     `base64 < templates/ardd-icon.svg | tr -d '\n' | jq -sRr @uri`.
     `mode=` is ignored (byte-identical output either way), and the
     JSON's computed channel color is not read here — see the same note
     above for both. -->
