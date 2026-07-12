#!/usr/bin/env sh
# upsert-section.sh — deterministically replace or append one "## <header>"
# section of a markdown file. The new body is read from stdin. Replaces
# from the exact header line to (not including) the next "## " line or
# EOF; appends "## <header>" + body at EOF when the section is absent.
# Never touches any other line — this is the text surgery /ardd-diagram
# step 6 previously described in prose, where an LLM slip could eat
# unrelated README content (constitution Principle II).
#
# Usage: upsert-section.sh <file> <header-text-without-##>   < body
# Exit 0 success, 1 bad input.

set -e

FILE="${1:-}"; HEADER="${2:-}"
[ -n "$FILE" ] && [ -n "$HEADER" ] || { echo "usage: upsert-section.sh <file> <header>" >&2; exit 1; }
[ -f "$FILE" ] || { echo "upsert-section: no such file: $FILE" >&2; exit 1; }

BODY_TMP="$(mktemp)"
OUT_TMP="$(mktemp)"
trap 'rm -f "$BODY_TMP" "$OUT_TMP"' EXIT
cat > "$BODY_TMP"

awk -v header="## $HEADER" -v bodyfile="$BODY_TMP" '
  function emit_body(   line) {
    print header
    print ""
    while ((getline line < bodyfile) > 0) print line
    close(bodyfile)
    print ""
  }
  $0 == header { found = 1; skipping = 1; emit_body(); next }
  skipping && /^## / { skipping = 0 }
  skipping { next }
  { print }
  END {
    if (!found) {
      print ""
      emit_body()
    }
  }
' "$FILE" > "$OUT_TMP"

mv "$OUT_TMP" "$FILE"
trap 'rm -f "$BODY_TMP"' EXIT
echo "upsert-section: $FILE — section '## $HEADER' updated" >&2
