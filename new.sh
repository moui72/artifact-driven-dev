#!/usr/bin/env sh
# Install artifact-driven-dev in one command — a new project, or an existing one.
#
#   curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/main/new.sh \
#     | sh -s -- my-project                                    # new project
#   cd my-existing-project && curl -fsSL …/new.sh | sh -s -- --existing   # existing project
#
# Usage: new.sh [--kickoff|--no-kickoff] [--source <path>] <target-dir>
#        new.sh --existing [--kickoff|--no-kickoff] [--source <path>] [<project-dir>]
#
# This is an *acquisition* channel, nothing more. It resolves an ARDD source
# checkout, prepares the target (creating a new one, or accepting an existing
# populated project under --existing), and then hands off to that checkout's
# install.sh — the only real install/upgrade entry point (constitution,
# Project Scope & Intent). It never reimplements any part of install.sh, and
# must never grow a bridge skill: it simply invokes the installer directly.
#
# Two rules bound its interactivity (constitution v1.2.4). It *refuses* rather
# than asks wherever writing into a directory it doesn't own is at stake — a
# non-empty target, or a --source that isn't an ARDD checkout — because those
# aren't decisions worth offering. And it *never blocks on a question it
# cannot ask*: with no readable /dev/tty it takes the safe default instead of
# hanging a pipeline forever.
#
# Between those bounds it may ask, and the Claude Code handoff does. The prompt
# reads from /dev/tty, not stdin — under `curl | sh` stdin carries this script's
# own source text, while stdout and the tty are still the terminal. The exec,
# by contrast, must leave stdin alone and let Claude Code open the tty itself;
# see launch().
#
# Source ownership: the default checkout at ~/.ardd/source belongs to this
# script — it clones it and keeps it current. A checkout named explicitly via
# --source or $ARDD_SOURCE belongs to the user; it is read and never mutated.
#
# Release channel (constitution, standing decision 2026-07-12): the owned
# checkout is pinned to the latest semver release tag after every
# clone/refresh — consumers install from releases, never from a live tip.
# The selection logic is deliberately duplicated (minimally) from
# scripts/source-resolve.sh: new.sh runs with no checkout of its own, so it
# cannot source ardd-scripts. An offline refresh warns and proceeds with
# the checkout as it stands; a source with no releases yet stays on the
# default branch, noted. --source/$ARDD_SOURCE remains dev-mode: used
# exactly as given.

set -e

REPO_URL="https://github.com/moui72/artifact-driven-dev"
DEFAULT_SOURCE="$HOME/.ardd/source"

kickoff=""          # "" = ask; 1 = always; 0 = never
source_arg=""
target=""
existing=0          # 1 = install into an existing, already-populated project

usage() {
  cat >&2 <<EOF
Usage: new.sh [--kickoff|--no-kickoff] [--source <path>] <target-dir>
       new.sh --existing [--kickoff|--no-kickoff] [--source <path>] [<project-dir>]

  --existing       Install ARDD into an existing, already-populated project
                   (<project-dir> defaults to the current directory). Without
                   it, new.sh creates a *new* project and refuses a non-empty
                   target.
  --kickoff        Open Claude Code on the first step without asking
                   (/ardd-init, which detects greenfield vs existing code;
                   /ardd-status instead if the project is already set up).
  --no-kickoff     Install, then print the next step instead of opening Claude Code.
                   With neither flag, you're asked — unless there's no terminal
                   to ask on, in which case this is the default.
  --source <path>  Use an existing ARDD checkout (also settable as \$ARDD_SOURCE).
                   Read, never modified. Without it, ~/.ardd/source is cloned
                   and kept up to date.

Examples:
  curl -fsSL $REPO_URL/raw/main/new.sh | sh -s -- my-project
  cd my-existing-project && curl -fsSL $REPO_URL/raw/main/new.sh | sh -s -- --existing
EOF
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
    # Contradictory flags are a usage error, not last-flag-wins: silently
    # guessing which of two opposite intents was meant is worse than asking.
    --kickoff)    [ "$kickoff" != "0" ] || { echo "Error: --kickoff and --no-kickoff are mutually exclusive" >&2; usage; }
                  kickoff=1; shift ;;
    --no-kickoff) [ "$kickoff" != "1" ] || { echo "Error: --kickoff and --no-kickoff are mutually exclusive" >&2; usage; }
                  kickoff=0; shift ;;
    --source)     [ $# -ge 2 ] || usage; source_arg="$2"; shift 2 ;;
    --source=*)   source_arg="${1#--source=}"; shift ;;
    --existing)   existing=1; shift ;;
    -h|--help)    usage ;;
    -*)           echo "Error: unknown option '$1'" >&2; usage ;;
    *)            [ -z "$target" ] || { echo "Error: unexpected argument '$1'" >&2; usage; }
                  target="$1"; shift ;;
  esac
done

# In --existing mode a missing target means "here" — the natural invocation is
# `cd my-project && curl … | sh -s -- --existing`. New-project mode requires
# an explicit target to create.
if [ -z "$target" ]; then
  [ "$existing" -eq 1 ] && target="." || usage
fi

# --- Validate the target, before touching the network -------------------
# Cheap checks first: a typo'd target must not cost a clone of ~/.ardd/source.
# Non-empty means any entry other than .git — `git init && curl … | sh` is a
# natural order and refusing it would be a papercut, but writing into a
# directory that already holds real content never is.

if [ "$existing" -eq 1 ]; then
  # Existing-project mode inverts the guard: a populated project is exactly the
  # target we want, and the explicit --existing flag is the consent to write
  # into a directory already holding content. We still refuse a target that is
  # missing or empty — that is new-project mode, so send the user back to it.
  [ -d "$target" ] || {
    echo "Error: --existing needs an existing project directory" >&2
    echo "       ('$target' is missing or is not a directory)." >&2
    echo "       For a brand-new project, drop --existing and name a target to create." >&2
    exit 1
  }
  if [ -z "$(find "$target" -mindepth 1 -maxdepth 1 ! -name .git | head -n 1)" ]; then
    echo "Error: '$target' is empty — --existing is for an already-populated project." >&2
    echo "       For a brand-new project, drop --existing." >&2
    exit 1
  fi
elif [ -e "$target" ]; then
  [ -d "$target" ] || { echo "Error: '$target' exists and is not a directory." >&2; exit 1; }
  leftovers="$(find "$target" -mindepth 1 -maxdepth 1 ! -name .git | head -n 1)"
  if [ -n "$leftovers" ]; then
    echo "Error: '$target' already exists and is not empty." >&2
    echo "" >&2
    echo "This command creates a *new* project. To add ARDD to an existing one," >&2
    echo "rerun with --existing from inside it:" >&2
    echo "  cd $target && curl … | sh -s -- --existing" >&2
    exit 1
  fi
fi

# --- Resolve the source checkout ---------------------------------------
# An explicit --source/$ARDD_SOURCE is the user's checkout: verify, use as-is.
# The default path is ours: clone it if absent, keep it current if present.

is_ardd_checkout() { [ -f "$1/install.sh" ] && [ -d "$1/skills" ]; }

# Pin the owned checkout to its latest release tag (strict vX.Y.Z; ordering
# via v:refname — same rule as source-resolve.sh, duplicated minimally
# because new.sh has no checkout to source it from). No releases yet is a
# note, not a failure: install from the default branch as it stands.
pin_release() {
  release_tag="$(git -C "$SRC" tag --list 'v[0-9]*' --sort=v:refname \
    | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1 || true)"
  if [ -n "$release_tag" ]; then
    git -C "$SRC" checkout --quiet "$release_tag"
    echo "Using ARDD release $release_tag."
  else
    echo "  ! no releases tagged yet — installing from the default branch as it stands."
  fi
}

if [ -n "$source_arg" ]; then
  SRC="$source_arg"; owned=0
elif [ -n "${ARDD_SOURCE:-}" ]; then
  SRC="$ARDD_SOURCE"; owned=0
else
  SRC="$DEFAULT_SOURCE"; owned=1
fi

if [ -e "$SRC" ]; then
  if ! is_ardd_checkout "$SRC"; then
    echo "Error: '$SRC' exists but is not an artifact-driven-dev checkout" >&2
    echo "       (expected install.sh and skills/ at its top level)." >&2
    echo "" >&2
    echo "Refusing to write into a directory this script doesn't own." >&2
    echo "Point --source (or \$ARDD_SOURCE) at a real checkout, or clear that path." >&2
    exit 1
  fi
  if [ "$owned" -eq 1 ]; then
    echo "Updating ARDD source at $SRC ..."
    # Fetch tags first (the owned checkout may sit detached at a release,
    # where a pull has nothing to merge onto); offline is a warning, never
    # a failure — install from the checkout as it stands on disk.
    git -C "$SRC" fetch --tags --quiet \
      || echo "  ! fetch failed — continuing with the checkout as it stands on disk."
    pin_release
    if [ -z "$release_tag" ] && [ -n "$(git -C "$SRC" branch --show-current)" ]; then
      # No releases and still on a branch: stay current the old way.
      git -C "$SRC" pull --ff-only --quiet \
        || echo "  ! pull failed — continuing with the checkout as it stands on disk."
    fi
  fi
else
  if [ "$owned" -eq 0 ]; then
    echo "Error: source checkout '$SRC' does not exist." >&2
    exit 1
  fi
  echo "Cloning ARDD source into $SRC ..."
  mkdir -p "$(dirname "$SRC")"
  git clone --quiet "$REPO_URL" "$SRC"
  pin_release
fi

SRC="$(cd "$SRC" && pwd)"

# --- Create the target -------------------------------------------------

mkdir -p "$target"
TARGET="$(cd "$target" && pwd)"

# install.sh runs its .gitignore guidance through `git -C "$TARGET"`, so the
# repo must exist before it is called or those suggestions silently never fire.
if ! git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init --quiet "$TARGET"
  echo "Initialized empty git repository in $TARGET"
fi

# --- Converge on install.sh -------------------------------------------
# Its output (migrations, gitignore guidance, warnings) is the user's only
# view of install-time housekeeping. Relay it verbatim; never summarize.

"$SRC/install.sh" "$TARGET"

# --- Hand off to the first session -------------------------------------
# Both new and existing projects initialize with /ardd-init — the skill
# itself detects greenfield vs existing-code and confirms with the user.
# A project that already carries ARDD artifacts just gets checked
# (/ardd-status). install.sh only ever creates .project/ardd-version.md,
# never .project/artifacts/, so that dir's presence reliably distinguishes
# an already-set-up project from a first install.
if [ "$existing" -eq 1 ] && [ -d "$TARGET/.project/artifacts" ]; then
  handoff_cmd="/ardd-status"
else
  handoff_cmd="/ardd-init"
fi

next_steps() { # $1 = optional reason line
  [ -n "$1" ] && echo "$1"
  echo "Start the first session with:"
  echo ""
  echo "  cd $target"
  echo "  claude \"$handoff_cmd\""
  echo ""
}

# Actually open the tty rather than testing its permission bits: `[ -r /dev/tty ]`
# passes on a CI runner with no controlling terminal, where the open then fails
# with ENXIO. Only a real open answers "can I interact with a human here?"
tty_ok() { (exec 3< /dev/tty) 2>/dev/null; }

launch() {
  echo "Opening Claude Code in $target — $handoff_cmd is your first step."
  echo ""
  cd "$TARGET"
  # Do NOT redirect stdin here, even though under `curl | sh` it's the curl
  # pipe. Claude Code checks `process.stdin.isTTY && process.stdout.isTTY` and
  # only falls back to opening /dev/tty itself — read-write, which is what its
  # TUI needs — when that check fails. Feeding it `< /dev/tty` (read-only)
  # passes the check, so it uses that fd instead and silently accepts no
  # keystrokes; `<> /dev/tty` makes it exit outright. An EOF'd pipe on stdin is
  # the input it handles correctly.
  exec claude "$handoff_cmd"
}

# Ask on /dev/tty — never stdin, which is the curl pipe. Bare Enter means yes.
# EOF (a readable but closed tty) means no, matching the no-tty default: never
# block, never guess. An unrecognized answer re-asks, but only three times, so
# a wedged terminal can't spin forever.
ask_kickoff() {
  attempt=0
  while [ "$attempt" -lt 3 ]; do
    printf 'Open Claude Code now and run %s? [Y/n] ' "$handoff_cmd" > /dev/tty
    if ! IFS= read -r reply < /dev/tty; then
      echo "" > /dev/tty
      return 1   # EOF
    fi
    case "$reply" in
      ""|[Yy]|[Yy][Ee][Ss]) return 0 ;;
      [Nn]|[Nn][Oo])        return 1 ;;
      *) echo "Please answer y or n." > /dev/tty ;;
    esac
    attempt=$((attempt + 1))
  done
  echo "No clear answer after 3 tries — not launching." > /dev/tty
  return 1
}

echo ""

# The install genuinely succeeded by this point. Every path below exits 0;
# declining to launch is an outcome, not a failure.
if [ "$kickoff" = "0" ]; then
  next_steps ""
  exit 0
fi

if ! command -v claude >/dev/null 2>&1; then
  next_steps "Claude Code isn't on your PATH, so I can't open the first session for you."
  exit 0
fi

if [ "$kickoff" = "1" ]; then
  launch
fi

if ! tty_ok; then
  next_steps "No terminal available, so I can't open the first session for you."
  exit 0
fi

if ! ask_kickoff; then
  next_steps ""
  exit 0
fi

launch
