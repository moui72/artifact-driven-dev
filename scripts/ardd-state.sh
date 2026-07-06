#!/usr/bin/env sh
# ardd-state.sh — deterministic state mutations for a target project's
# .project/ files (constitution Principle II: skill prose decides *when*
# a transition happens; this script does the *writing*, validating file
# state first and refusing illegal transitions with a nonzero exit).
#
# Installed target-side into .claude/skills/ardd-scripts/ by install.sh.
# POSIX sh only. Every subcommand is idempotent-safe to re-run: a
# transition to the state a file is already in is reported, not applied.
#
# Exit codes: 0 success, 1 validation/transition refusal, 2 usage error.

set -e

usage() {
  cat <<'EOF'
usage: ardd-state.sh <subcommand> [args...]

Deterministic state mutations for .project/ files. Subcommands:
  slug <text>              print a kebab-case slug (<=30 chars) for <text>
  mint plan <slug>         print plan-<slug>-<YYYY-MM-DD>.md
  mint tasks <slug>        print tasks-<slug>-<hex4>.md   (fresh token)
  mint feedback <slug>     print feedback-<slug>-<hex4>.md (fresh token)
  mint research <slug>     print research-<slug>-<YYYY-MM-DD>.md
EOF
}

die()  { echo "ardd-state: $1" >&2; exit 1; }
dieu() { echo "ardd-state: $1" >&2; usage >&2; exit 2; }

# require_kebab <string> — validate an already-sanitized slug argument
require_kebab() {
  case "$1" in
    ''|*[!a-z0-9-]*|-*|*-) die "not a kebab-case slug: '$1'" ;;
  esac
}

hex4() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 2
  else
    od -An -N2 -tx1 /dev/urandom | tr -d ' \n'
  fi
}

cmd_slug() {
  [ -n "${1:-}" ] || dieu "slug: missing input text"
  s="$(printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9' '-' \
    | sed 's/^-*//; s/-*$//')"
  [ -n "$s" ] || die "slug: no alphanumeric characters in input"
  s="$(printf '%s' "$s" | cut -c1-30 | sed 's/-*$//')"
  printf '%s\n' "$s"
}

cmd_mint() {
  kind="${1:-}"; slug="${2:-}"
  [ -n "$kind" ] && [ -n "$slug" ] || dieu "mint: need <kind> <slug>"
  case "$kind" in
    plan|tasks|feedback|research) ;;
    *) dieu "mint: unknown kind '$kind' (plan|tasks|feedback|research)" ;;
  esac
  require_kebab "$slug"
  case "$kind" in
    plan)     printf 'plan-%s-%s.md\n' "$slug" "$(date +%Y-%m-%d)" ;;
    research) printf 'research-%s-%s.md\n' "$slug" "$(date +%Y-%m-%d)" ;;
    tasks)    printf 'tasks-%s-%s.md\n' "$slug" "$(hex4)" ;;
    feedback) printf 'feedback-%s-%s.md\n' "$slug" "$(hex4)" ;;
  esac
}

cmd="${1:-}"
[ -n "$cmd" ] || { usage >&2; exit 2; }
shift

case "$cmd" in
  slug) cmd_slug "$@" ;;
  mint) cmd_mint "$@" ;;
  *)
    echo "ardd-state: unknown subcommand '$cmd'" >&2
    usage >&2
    exit 2
    ;;
esac
