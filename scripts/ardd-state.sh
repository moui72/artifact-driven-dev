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
  plan-flip <file> <approved|superseded>
                           flip a plan's frontmatter status; refuses
                           illegal transitions (legal: draft->approved,
                           draft->superseded, approved->superseded)
  tasks-flip <file> <ready|in-progress|completed|abandoned>
                           flip a tasks file's status along
                           generating->ready->in-progress->completed;
                           abandoned allowed from generating/ready/in-progress
  task-check <file> <Tnnn> flip that task's checkbox [ ] -> [x]
  next-task <file>         print the first unchecked task line; exit 1 if none
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

# read_status <file> — print the frontmatter `status:` value (sans comment)
read_status() {
  [ -f "$1" ] || die "no such file: $1"
  s="$(sed -n 's/^status:[[:space:]]*\([a-z-]*\).*/\1/p' "$1" | head -1)"
  [ -n "$s" ] || die "no frontmatter status field in $1"
  printf '%s\n' "$s"
}

# write_status <file> <old> <new> — in-place, preserves spacing + comment
write_status() {
  sed -i.arddbak "s/^status:\([[:space:]]*\)$2/status:\1$3/" "$1" && rm -f "$1.arddbak"
}

cmd_plan_flip() {
  file="${1:-}"; to="${2:-}"
  [ -n "$file" ] && [ -n "$to" ] || dieu "plan-flip: need <file> <status>"
  case "$to" in
    approved|superseded) ;;
    *) dieu "plan-flip: target must be approved|superseded, got '$to'" ;;
  esac
  from="$(read_status "$file")"
  if [ "$from" = "$to" ]; then
    echo "plan-flip: $file already $to (no-op)"
    return 0
  fi
  case "$from-$to" in
    draft-approved|draft-superseded|approved-superseded) ;;
    *) die "plan-flip: illegal transition $from -> $to in $file" ;;
  esac
  write_status "$file" "$from" "$to"
  echo "plan-flip: $file $from -> $to"
}

cmd_tasks_flip() {
  file="${1:-}"; to="${2:-}"
  [ -n "$file" ] && [ -n "$to" ] || dieu "tasks-flip: need <file> <status>"
  case "$to" in
    ready|in-progress|completed|abandoned) ;;
    *) dieu "tasks-flip: target must be ready|in-progress|completed|abandoned, got '$to'" ;;
  esac
  from="$(read_status "$file")"
  if [ "$from" = "$to" ]; then
    echo "tasks-flip: $file already $to (no-op)"
    return 0
  fi
  case "$from-$to" in
    generating-ready|ready-in-progress|in-progress-completed) ;;
    generating-abandoned|ready-abandoned|in-progress-abandoned) ;;
    *) die "tasks-flip: illegal transition $from -> $to in $file" ;;
  esac
  write_status "$file" "$from" "$to"
  echo "tasks-flip: $file $from -> $to"
}

cmd_task_check() {
  file="${1:-}"; id="${2:-}"
  [ -n "$file" ] && [ -n "$id" ] || dieu "task-check: need <file> <task-id>"
  [ -f "$file" ] || die "no such file: $file"
  if grep -q "^- \[x\] $id " "$file"; then
    echo "task-check: $id already checked in $file (no-op)"
    return 0
  fi
  grep -q "^- \[ \] $id " "$file" || die "task-check: no unchecked task '$id' in $file"
  sed -i.arddbak "s/^- \[ \] $id /- [x] $id /" "$file" && rm -f "$file.arddbak"
  echo "task-check: $id checked in $file"
}

cmd_next_task() {
  file="${1:-}"
  [ -n "$file" ] || dieu "next-task: need <file>"
  [ -f "$file" ] || die "no such file: $file"
  line="$(grep -m1 '^- \[ \] ' "$file" || true)"
  [ -n "$line" ] || { echo "next-task: no unchecked tasks in $file" >&2; exit 1; }
  printf '%s\n' "$line"
}

cmd="${1:-}"
[ -n "$cmd" ] || { usage >&2; exit 2; }
shift

case "$cmd" in
  slug) cmd_slug "$@" ;;
  mint) cmd_mint "$@" ;;
  plan-flip) cmd_plan_flip "$@" ;;
  tasks-flip) cmd_tasks_flip "$@" ;;
  task-check) cmd_task_check "$@" ;;
  next-task) cmd_next_task "$@" ;;
  *)
    echo "ardd-state: unknown subcommand '$cmd'" >&2
    usage >&2
    exit 2
    ;;
esac
