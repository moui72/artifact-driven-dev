#!/usr/bin/env sh
# Keep-last-N prune of a STATUS.md's `_Updated:` chronology. STATUS.md is
# prepend-ordered (newest block on top), and full history is preserved in git,
# so bounding the live file to its most recent N blocks keeps it slim without
# losing anything recoverable. Called by /ardd-status step 6 after its
# prepend-and-preserve write, only when the constitution's `status_history_keep`
# field is set.
#
# It preserves the head matter (everything before the first `^_Updated:` line —
# the title and any non-chronology sections) and the newest N `_Updated:`
# blocks, byte-for-byte, and drops the older tail. It NEVER summarizes,
# condenses, or rewrites a kept block: the only change it ever makes is
# removing whole older blocks from the end.
#
# Refuses (never corrupts) on a missing/unreadable file or a keep value that
# is not a positive integer — matching the refuse-don't-resolve discipline of
# the other worktree/state scripts. A no-op (block count <= N) is a success.
#
# Usage: ./scripts/status-prune.sh <file> --keep <N>
#
# Prints, one per line, then exits:
#   pruned=true blocks=<total> kept=<k> removed=<r>   (exit 0; r=0 is a no-op)
#   pruned=false reason=usage                         (exit 2; bad arguments)
#   pruned=false reason=not-a-file                    (exit 1)
#   pruned=false reason=unreadable                    (exit 1)
#   pruned=false reason=bad-keep                      (exit 1; not a positive int)

file=""
keep=""

while [ $# -gt 0 ]; do
  case "$1" in
    --keep) keep="$2"; shift 2 || { keep=""; break; } ;;
    --keep=*) keep="${1#--keep=}"; shift ;;
    -*) echo "pruned=false"; echo "reason=usage"; exit 2 ;;
    *)
      if [ -n "$file" ]; then echo "pruned=false"; echo "reason=usage"; exit 2; fi
      file="$1"; shift ;;
  esac
done

if [ -z "$file" ] || [ -z "$keep" ]; then
  echo "pruned=false"; echo "reason=usage"; exit 2
fi

# keep must be a positive integer
case "$keep" in
  ''|*[!0-9]*) echo "pruned=false"; echo "reason=bad-keep"; exit 1 ;;
esac
if [ "$keep" -lt 1 ]; then
  echo "pruned=false"; echo "reason=bad-keep"; exit 1
fi

if [ ! -f "$file" ]; then
  echo "pruned=false"; echo "reason=not-a-file"; exit 1
fi
if [ ! -r "$file" ] || [ ! -w "$file" ]; then
  echo "pruned=false"; echo "reason=unreadable"; exit 1
fi

# Total number of chronology blocks.
total=$(grep -c '^_Updated:' "$file" 2>/dev/null)

if [ "$total" -le "$keep" ]; then
  # Nothing to remove — head matter and every block stay untouched.
  echo "pruned=true"
  echo "blocks=$total"
  echo "kept=$total"
  echo "removed=0"
  exit 0
fi

# Cut just before the (keep+1)th `_Updated:` line: that keeps the head matter
# plus the newest `keep` blocks, verbatim, and drops everything after.
cutline=$(grep -n '^_Updated:' "$file" | sed -n "$((keep + 1))p" | cut -d: -f1)

tmp="$file.prune.$$"
head -n "$((cutline - 1))" "$file" > "$tmp" && mv "$tmp" "$file"

echo "pruned=true"
echo "blocks=$total"
echo "kept=$keep"
echo "removed=$((total - keep))"
exit 0
