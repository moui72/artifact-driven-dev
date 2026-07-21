#!/usr/bin/env sh
# release-notes.sh — regenerate docs/release-notes.md from this repo's real
# GitHub releases (feature: changelog-from-github-releases). Source-side
# only: not installed into target projects, called by maintainers and by
# stable-release.yml right after a release is cut.
#
# Usage: release-notes.sh
#   No arguments. Runs `gh api repos/:owner/:repo/releases` (paginated) to
#   fetch every release for the repo at the current working directory,
#   sorts them newest-first (the order GitHub's releases API already
#   returns), and writes docs/release-notes.md: a `# ArDD release notes`
#   top-level title followed by one `## <tag>` section per release (its
#   publish date, then its body verbatim below). Full re-render every run
#   (idempotent) — never a partial/append edit.
#
# Prints nothing but the regenerated file's path on success. Exits
# non-zero with a clear message on `gh` auth/rate-limit/API failure, or
# when not run from inside a GitHub-hosted repo checkout `gh` can resolve.

set -e

OUT="docs/release-notes.md"
mkdir -p "$(dirname "$OUT")"

if ! command -v gh >/dev/null 2>&1; then
  echo "release-notes: 'gh' not found on PATH" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "release-notes: 'jq' not found on PATH" >&2
  exit 1
fi

# Paginate repos/:owner/:repo/releases (gh api --paginate concatenates each
# page's JSON array response); newest-first is already the API's default
# order, so no client-side sort is needed. `gh api` fails non-zero on
# auth/rate-limit errors, which `set -e` propagates.
if ! releases_json="$(gh api --paginate 'repos/{owner}/{repo}/releases' 2>&1)"; then
  echo "release-notes: failed to fetch releases via 'gh api' — auth or rate-limit error:" >&2
  echo "$releases_json" >&2
  exit 1
fi

# --paginate emits one JSON array per page, concatenated back-to-back —
# slurp and flatten them into a single array, drop drafts, then render.
# Zero releases -> the map produces no output, leaving a valid file with
# just the top-level title (near-empty, not an error).
{
  echo "# ArDD release notes"
  echo
  printf '%s' "$releases_json" | jq -s '
    add | map(select(.draft == false))
  ' | jq -r '
    .[]
    | "## " + .tag_name,
      "",
      "_Published " + (.published_at // .created_at // "unknown") + "_",
      "",
      (.body // ""),
      ""
  '
} > "$OUT"

echo "$OUT"
