#!/usr/bin/env sh
# parallel-matrix.sh: pairwise overlap verdicts among the work queue — the
# deterministic half of "what is safe to launch in parallel with what".
#
# Participants: every .project/tasks/tasks-*.md at `status: ready` in the
# current checkout, plus every in-flight tasks file reported by the sibling
# inflight-worktrees.sh (each claim read from that worktree's own copy,
# including its plan file). For every pair, prints one tab-separated line:
#
#   pair=<a>:<b>	verdict=claimed|shared-feature|shared-artifact|independent	features=<slugs|unknown|none>	artifacts=<tags|none>
#
# Verdict precedence: claimed > shared-feature > shared-artifact >
# independent. `claimed` means the pair's two sides resolve to the SAME
# repo-relative tasks filename — ready in the primary checkout and claimed by
# an in-flight worktree; comparing a file with itself is meaningless, so
# feature/artifact comparison is skipped (both columns print `none`).
#
# Feature overlap comes from the existing binding chain: tasks `plan:`
# frontmatter -> plan file `features:` list. A broken chain (missing plan
# file, no features: list) makes that side `features=unknown` — never a
# guess, and never a `shared-feature` verdict. An intact chain whose plan
# carries an explicitly empty `features: []` is `none`, not `unknown`.
# Artifact overlap is the intersection of `[artifacts: ...]` tags across the
# two files' task lines. `shared-feature` wins over `shared-artifact` when
# both hold.
#
# `verdict=independent` means NO DECLARED OVERLAP ONLY — no shared feature
# slug and no shared artifact tag. It is not a conflict-free guarantee; two
# "independent" files can still touch the same code paths, and merge_policy
# conflict handling still governs at merge time. No path heuristics here —
# path-contact assessment stays agent judgment at presentation time.
#
# Prints nothing and exits 0 when fewer than two participants exist. Exits 1
# only if not inside a git repo.

set -e

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "error: not inside a git work tree" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
top="$(git rev-parse --show-toplevel)"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

frontmatter_field() {
  file="$1"
  field="$2"
  awk '/^---$/{n++; next} n==1' "$file" \
    | grep -E "^${field}:" \
    | head -1 \
    | sed -E "s/^${field}:[[:space:]]*//; s/[[:space:]]*(#.*)?\$//"
}

# features_of <tasks-file> <checkout-root> -> writes sorted slugs to stdout,
# or the word "unknown" alone when the plan chain is broken (missing plan
# file or missing features: field). An intact chain with an explicitly empty
# features list writes nothing — that side is "none", not "unknown".
features_of() {
  tf="$1"
  root="$2"
  plan="$(frontmatter_field "$tf" plan)"
  if [ -z "$plan" ]; then echo unknown; return 0; fi
  pf="$root/.project/plans/$plan"
  if [ ! -f "$pf" ]; then echo unknown; return 0; fi
  raw="$(frontmatter_field "$pf" features)"
  if [ -z "$raw" ]; then echo unknown; return 0; fi
  feats="$(printf '%s\n' "$raw" \
    | sed -E 's/^\[//; s/\]$//' \
    | tr ',' '\n' \
    | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
    | grep -v '^$' | sort -u)" || feats=""
  if [ -n "$feats" ]; then printf '%s\n' "$feats"; fi
}

# artifacts_of <tasks-file> -> sorted unique [artifacts: ...] tags.
artifacts_of() {
  grep -oE '\[artifacts: [^]]+\]' "$1" 2>/dev/null \
    | sed -E 's/^\[artifacts: //; s/\]$//' \
    | tr ',' '\n' \
    | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
    | grep -v '^$' | sort -u || true
}

n=0
add_participant() { # <display-id> <file> <checkout-root> <repo-relative-path>
  n=$((n + 1))
  printf '%s' "$1" > "$TMP/id.$n"
  printf '%s' "$4" > "$TMP/rel.$n"
  features_of "$2" "$3" > "$TMP/feat.$n"
  artifacts_of "$2" > "$TMP/art.$n"
  if [ "$(cat "$TMP/feat.$n")" = "unknown" ]; then
    : > "$TMP/unknown.$n"
    : > "$TMP/feat.$n"
  fi
}

# 1. Local ready tasks files.
for tf in "$top"/.project/tasks/tasks-*.md; do
  [ -f "$tf" ] || continue
  [ "$(frontmatter_field "$tf" status)" = "ready" ] || continue
  add_participant "${tf#"$top"/}" "$tf" "$top" "${tf#"$top"/}"
done

# 2. In-flight worktree claims, from the sibling script (branch-info.sh
# consumer pattern) — file and plan both read from that worktree's copy.
inflight="$(sh "$SCRIPT_DIR/inflight-worktrees.sh" 2>/dev/null)" || inflight=""
old_ifs="$IFS"
IFS='
'
for line in $inflight; do
  IFS="$old_ifs"
  wt="$(printf '%s\n' "$line" | tr '\t' '\n' | sed -n 's/^worktree=//p')"
  rel="$(printf '%s\n' "$line" | tr '\t' '\n' | sed -n 's/^tasks=//p')"
  [ -n "$wt" ] && [ -n "$rel" ] && [ "$rel" != "none" ] || { IFS='
'; continue; }
  [ -f "$wt/$rel" ] || { IFS='
'; continue; }
  add_participant "$wt/$rel" "$wt/$rel" "$wt" "$rel"
  IFS='
'
done
IFS="$old_ifs"

[ "$n" -ge 2 ] || exit 0

join_lines() { # newline list on stdin -> comma-joined
  awk 'NR>1{printf ","} {printf "%s", $0} END{print ""}'
}

i=1
while [ "$i" -lt "$n" ]; do
  j=$((i + 1))
  while [ "$j" -le "$n" ]; do
    # Same repo-relative tasks filename on both sides (ready in primary +
    # claimed by an in-flight worktree): the pair IS one file. Precedence:
    # claimed > shared-feature > shared-artifact > independent; comparison
    # of a file with itself is skipped.
    if [ "$(cat "$TMP/rel.$i")" = "$(cat "$TMP/rel.$j")" ]; then
      printf 'pair=%s:%s\tverdict=claimed\tfeatures=none\tartifacts=none\n' \
        "$(cat "$TMP/id.$i")" "$(cat "$TMP/id.$j")"
      j=$((j + 1))
      continue
    fi
    shared_feat=""
    if [ ! -e "$TMP/unknown.$i" ] && [ ! -e "$TMP/unknown.$j" ]; then
      shared_feat="$(comm -12 "$TMP/feat.$i" "$TMP/feat.$j" | join_lines)"
    fi
    shared_art="$(comm -12 "$TMP/art.$i" "$TMP/art.$j" | join_lines)"

    if [ -n "$shared_feat" ]; then
      verdict="shared-feature"
      feats="$shared_feat"
    else
      if [ -n "$shared_art" ]; then verdict="shared-artifact"; else verdict="independent"; fi
      if [ -e "$TMP/unknown.$i" ] || [ -e "$TMP/unknown.$j" ]; then
        feats="unknown"
      else
        feats="none"
      fi
    fi
    [ -n "$shared_art" ] || shared_art="none"

    printf 'pair=%s:%s\tverdict=%s\tfeatures=%s\tartifacts=%s\n' \
      "$(cat "$TMP/id.$i")" "$(cat "$TMP/id.$j")" "$verdict" "$feats" "$shared_art"
    j=$((j + 1))
  done
  i=$((i + 1))
done
