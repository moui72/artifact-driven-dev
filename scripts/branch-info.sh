#!/usr/bin/env sh
# Deterministic half of the "check branch" step duplicated (by design, per
# CLAUDE.md) across ardd-plan and ardd-implement: which branch
# are we on, and what's the repo's default branch. The interactive half
# (suggesting a semantic name, asking the user, creating the branch) stays
# in each skill's prose — it requires judgment this script doesn't have.
#
# Usage: ./scripts/branch-info.sh
# Prints, one per line:
#   current=<branch>
#   default=<branch>
#   on_default=true|false
# Exits 1 if not inside a git work tree.

set -e

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "error: not inside a git work tree" >&2
  exit 1
fi

current="$(git branch --show-current)"

default="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's#^refs/remotes/origin/##')"
if [ -z "$default" ]; then
  if git show-ref --verify --quiet refs/heads/main; then
    default=main
  else
    default=master
  fi
fi

echo "current=$current"
echo "default=$default"
if [ "$current" = "$default" ]; then
  echo "on_default=true"
else
  echo "on_default=false"
fi
