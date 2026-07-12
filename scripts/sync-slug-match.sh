#!/usr/bin/env sh
# Decides whether any issue-search candidate already carries a given
# feature slug's ardd-sync marker (historic name, persisted in issue bodies). GitHub's search endpoint is lexical, not
# exact, so `/ardd-tracker` Push step 2's `gh issue list --search` call can
# return a false-positive candidate (e.g. a similar-but-different slug); this
# script does the exact check that decides whether to reuse a candidate's
# issue number or fall through to creating a new one.
#
# Usage: ./scripts/sync-slug-match.sh <slug>
# Reads candidates on stdin, one per line, tab-separated: <number>\t<body>
# (caller flattens each issue's body to a single line, e.g. via
# `gh issue list --json number,body --jq '.[] | "\(.number)\t\(.body)"'`).
# Prints the first candidate's number whose body contains the exact marker
# `<!-- ardd-sync-slug-<slug> -->`, or nothing if none match.

set -e

SLUG="$1"
MARKER="<!-- ardd-sync-slug-${SLUG} -->"

while IFS="$(printf '\t')" read -r number body; do
  [ -z "$number" ] && continue
  case "$body" in
    *"$MARKER"*)
      echo "$number"
      exit 0
      ;;
  esac
done

exit 0
