#!/usr/bin/env sh
# Migration 0004: rewrite bracket-tags that name the removed `features`
# artifact (migration 0003 deleted .project/artifacts/features.md; tags
# that referenced it as an artifact now fail lint's reference check —
# found live in the first downstream upgrade, feedback b959).
#
# In .project/tasks/*.md and .project/feedback/*.md:
#   [artifacts: features]            -> tag removed entirely
#   [artifacts: a, features, b]      -> features dropped from the list
# Every other tag and all other text untouched. Idempotent.

TARGET="${1:-.}"

for f in "$TARGET"/.project/tasks/*.md "$TARGET"/.project/feedback/*.md; do
  [ -f "$f" ] || continue
  grep -q '\[artifacts: [^]]*\]' "$f" || continue
  # Only rewrite when a tag actually contains the bare name `features`.
  awk '
    {
      line = $0
      while (match(line, /\[artifacts: [^\]]*\]/)) {
        tag = substr(line, RSTART, RLENGTH)
        inner = substr(tag, 13, length(tag) - 13)   # between ": " and "]"
        n = split(inner, parts, /,[ ]*/)
        kept = ""
        for (i = 1; i <= n; i++) {
          gsub(/^[ ]+|[ ]+$/, "", parts[i])
          if (parts[i] != "features" && parts[i] != "") {
            kept = kept (kept == "" ? "" : ", ") parts[i]
          }
        }
        if (kept == inner) {
          # nothing to change in this tag — mask it so the loop advances
          done = done substr(line, 1, RSTART + RLENGTH - 1)
          line = substr(line, RSTART + RLENGTH)
          continue
        }
        if (kept == "") {
          newtag = ""
          # also swallow one leading space to avoid a double space
          prefix = substr(line, 1, RSTART - 1)
          if (substr(prefix, length(prefix), 1) == " ") prefix = substr(prefix, 1, length(prefix) - 1)
          done = done prefix
        } else {
          newtag = "[artifacts: " kept "]"
          done = done substr(line, 1, RSTART - 1) newtag
        }
        line = substr(line, RSTART + RLENGTH)
      }
      print done line
      done = ""
    }
  ' "$f" > "$f.arddtmp" && mv "$f.arddtmp" "$f"
  echo "  - retagged $(basename "$f")"
done
exit 0
