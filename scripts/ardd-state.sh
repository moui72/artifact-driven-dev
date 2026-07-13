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
  mint plan <slug>         print plan-<slug>-<YYYY-MM-DD>-<hex4>.md (fresh token)
  mint tasks <slug>        print tasks-<slug>-<hex4>.md   (fresh token)
  mint feedback <slug>     print feedback-<slug>-<hex4>.md (fresh token)
  mint research <slug>     print research-<slug>-<YYYY-MM-DD>-<hex4>.md (fresh token)
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
  feedback-mark <file> <Fnnn> <x|->
                           resolve a feedback item: x = incorporated,
                           - = declined; only unresolved items may be marked
  feedback-planned <file> <plan-filename>
                           flip a feedback file open->planned and stamp
                           plan:; refuses while any item is unresolved
  feature-create <slug>    create .project/features/<slug>.md (CWD-relative)
                           as status: backlogged; body read from stdin
  feature-flip <slug> <status>
                           advance a feature one stage along
                           backlogged->planned->tasked->implemented->retired
                           (retired = shipped then deliberately removed;
                           terminal — no arc out of it)
  feature-field <slug> <plan|tasks|gh_issue> <value>
                           set an optional frontmatter field (add or replace)
  stamp <file> last_updated <YYYY-MM-DD>
  stamp <file> diagram_status <unrendered|stale|current>
  stamp <file> next_step_prompt <true|false>
  stamp <file> delegation <eager|ask|inline>
  stamp <file> merge_policy <auto|ask>
  stamp <file> update_check_max_age_days <positive integer>
                           set an artifact frontmatter field (add or replace)
EOF
}

# set_frontmatter <file> <key> <value> — replace, or insert before closing ---
set_frontmatter() {
  if grep -q "^$2:" "$1"; then
    sed -i.arddbak "s|^$2:.*|$2: $3|" "$1" && rm -f "$1.arddbak"
  else
    awk -v k="$2" -v v="$3" '
      /^---$/ { c++; if (c == 2) { print k ": " v } }
      { print }
    ' "$1" > "$1.arddtmp" && mv "$1.arddtmp" "$1"
  fi
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
    plan)     printf 'plan-%s-%s-%s.md\n' "$slug" "$(date +%Y-%m-%d)" "$(hex4)" ;;
    research) printf 'research-%s-%s-%s.md\n' "$slug" "$(date +%Y-%m-%d)" "$(hex4)" ;;
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

cmd_feedback_mark() {
  file="${1:-}"; id="${2:-}"; mark="${3:-}"
  [ -n "$file" ] && [ -n "$id" ] && [ -n "$mark" ] || dieu "feedback-mark: need <file> <item-id> <x|->"
  case "$mark" in x|-) ;; *) dieu "feedback-mark: mark must be x or -, got '$mark'" ;; esac
  [ -f "$file" ] || die "no such file: $file"
  if grep -q "^- \[[x-]\] $id " "$file"; then
    die "feedback-mark: $id already resolved in $file — unresolve manually if this is a genuine reversal"
  fi
  grep -q "^- \[ \] $id " "$file" || die "feedback-mark: no unresolved item '$id' in $file"
  sed -i.arddbak "s/^- \[ \] $id /- [$mark] $id /" "$file" && rm -f "$file.arddbak"
  echo "feedback-mark: $id -> [$mark] in $file"
}

cmd_feedback_planned() {
  file="${1:-}"; plan="${2:-}"
  [ -n "$file" ] && [ -n "$plan" ] || dieu "feedback-planned: need <file> <plan-filename>"
  from="$(read_status "$file")"
  [ "$from" = "open" ] || die "feedback-planned: status is '$from', expected open, in $file"
  if grep -q '^- \[ \] ' "$file"; then
    die "feedback-planned: unresolved items remain in $file — mark each x or - first"
  fi
  write_status "$file" open planned
  sed -i.arddbak "s|^plan:[[:space:]]*null.*|plan: $plan|" "$file" && rm -f "$file.arddbak"
  echo "feedback-planned: $file -> planned, plan: $plan"
}

FEATURES_DIR=".project/features"

feature_file() {
  require_kebab "$1"
  printf '%s/%s.md' "$FEATURES_DIR" "$1"
}

cmd_feature_create() {
  slug="${1:-}"
  [ -n "$slug" ] || dieu "feature-create: need <slug>"
  f="$(feature_file "$slug")"
  [ ! -e "$f" ] || die "feature-create: $f already exists"
  [ -d ".project" ] || die "feature-create: no .project/ under current directory"
  mkdir -p "$FEATURES_DIR"
  body="$(cat)"
  {
    printf -- '---\nslug: %s\nstatus: backlogged\nlogged: %s\n---\n\n' "$slug" "$(date +%Y-%m-%d)"
    [ -n "$body" ] && printf '%s\n' "$body"
  } > "$f"
  echo "feature-create: $f (backlogged)"
}

cmd_feature_flip() {
  slug="${1:-}"; to="${2:-}"
  [ -n "$slug" ] && [ -n "$to" ] || dieu "feature-flip: need <slug> <status>"
  case "$to" in
    planned|tasked|implemented|retired) ;;
    *) dieu "feature-flip: target must be planned|tasked|implemented|retired, got '$to'" ;;
  esac
  f="$(feature_file "$slug")"
  [ -f "$f" ] || die "feature-flip: no such feature: $f"
  from="$(read_status "$f")"
  if [ "$from" = "$to" ]; then
    echo "feature-flip: $slug already $to (no-op)"
    return 0
  fi
  case "$from-$to" in
    backlogged-planned|planned-tasked|tasked-implemented|implemented-retired) ;;
    *) die "feature-flip: illegal transition $from -> $to for $slug (one stage at a time; retired is terminal)" ;;
  esac
  write_status "$f" "$from" "$to"
  echo "feature-flip: $slug $from -> $to"
}

cmd_feature_field() {
  slug="${1:-}"; key="${2:-}"; val="${3:-}"
  [ -n "$slug" ] && [ -n "$key" ] && [ -n "$val" ] || dieu "feature-field: need <slug> <key> <value>"
  case "$key" in
    plan|tasks|gh_issue) ;;
    *) dieu "feature-field: key must be plan|tasks|gh_issue, got '$key'" ;;
  esac
  f="$(feature_file "$slug")"
  [ -f "$f" ] || die "feature-field: no such feature: $f"
  set_frontmatter "$f" "$key" "$val"
  echo "feature-field: $slug $key = $val"
}

cmd_stamp() {
  file="${1:-}"; key="${2:-}"; val="${3:-}"
  [ -n "$file" ] && [ -n "$key" ] && [ -n "$val" ] || dieu "stamp: need <file> <key> <value>"
  [ -f "$file" ] || die "stamp: no such file: $file"
  case "$key" in
    last_updated)
      case "$val" in
        [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
        *) die "stamp: last_updated must be YYYY-MM-DD, got '$val'" ;;
      esac
      ;;
    diagram_status)
      case "$val" in
        unrendered|stale|current) ;;
        *) dieu "stamp: diagram_status must be unrendered|stale|current, got '$val'" ;;
      esac
      ;;
    next_step_prompt)
      case "$val" in
        true|false) ;;
        *) dieu "stamp: next_step_prompt must be true|false, got '$val'" ;;
      esac
      ;;
    delegation)
      case "$val" in
        eager|ask|inline) ;;
        *) dieu "stamp: delegation must be eager|ask|inline, got '$val'" ;;
      esac
      ;;
    merge_policy)
      case "$val" in
        auto|ask) ;;
        *) dieu "stamp: merge_policy must be auto|ask, got '$val'" ;;
      esac
      ;;
    update_check_max_age_days)
      case "$val" in
        0*|*[!0-9]*|'') dieu "stamp: update_check_max_age_days must be a positive integer (1, 2, ...), got '$val'" ;;
      esac
      ;;
    *) dieu "stamp: key must be last_updated|diagram_status|next_step_prompt|delegation|merge_policy|update_check_max_age_days, got '$key'" ;;
  esac
  set_frontmatter "$file" "$key" "$val"
  echo "stamp: $file $key = $val"
}

cmd="${1:-}"
[ -n "$cmd" ] || { usage >&2; exit 2; }
shift

case "$cmd" in
  slug) cmd_slug "$@" ;;
  feature-create) cmd_feature_create "$@" ;;
  feature-flip) cmd_feature_flip "$@" ;;
  feature-field) cmd_feature_field "$@" ;;
  stamp) cmd_stamp "$@" ;;
  feedback-mark) cmd_feedback_mark "$@" ;;
  feedback-planned) cmd_feedback_planned "$@" ;;
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
