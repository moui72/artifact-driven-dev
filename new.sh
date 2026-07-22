#!/usr/bin/env sh
# Install artifact-driven-dev in one command — a new project, or an existing one.
#
#   curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/release/new.sh \
#     | sh -s -- my-project                                    # new project (stable)
#   cd my-existing-project && curl -fsSL …/release/new.sh | sh -s -- --existing  # existing project
#
# The `release` branch is the stable raw-URL base (two-channel decision,
# constitution v1.8.0): under beta-on-push, `main` explicitly serves the
# beta channel, so fetch this script from …/main/new.sh only when you want
# the beta/dev edge. Which *base* served the script doesn't set the
# channel — the --beta flag does; resolution goes through tags in
# ~/.ardd/source either way, so both bases work even before the release
# branch's first stable is cut.
#
# Usage: new.sh [--kickoff|--no-kickoff] [--beta] [--harness claude|codex] [--source <path>] <target-dir>
#        new.sh --existing [--kickoff|--no-kickoff] [--beta] [--harness claude|codex] [--source <path>] [<project-dir>]
#
# This is an *acquisition* channel, nothing more. It resolves an ArDD source
# checkout, prepares the target (creating a new one, or accepting an existing
# populated project under --existing), and then hands off to that checkout's
# install.sh — the only real install/upgrade entry point (constitution,
# Project Scope & Intent). It never reimplements any part of install.sh, and
# must never grow a bridge skill: it simply invokes the installer directly.
#
# Two rules bound its interactivity (constitution v1.2.4). It *refuses* rather
# than asks wherever writing into a directory it doesn't own is at stake — a
# non-empty target, or a --source that isn't an ArDD checkout — because those
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
# Release channel (constitution v1.8.0, two-channel standing decision):
# the owned checkout is pinned to the latest release tag after every
# clone/refresh — consumers install from releases, never from a live tip.
# Default channel is stable (strict vX.Y.Z tags); --beta admits
# vX.Y.Z-beta.N prereleases too, ordered under versionsort.suffix=-beta.
# so a newer stable still beats an older beta (git's default version sort
# gets that wrong — the pinned ordering trap). The chosen channel is
# handed to install.sh as $ARDD_CHANNEL, which records it in the target's
# ardd-version.md for /ardd-update to honor. The selection logic is
# deliberately duplicated (minimally) from scripts/source-resolve.sh:
# new.sh runs with no checkout of its own, so it cannot source
# ardd-scripts. An offline refresh warns and proceeds with the checkout
# as it stands; a source with no releases yet stays on the default
# branch, noted. --source/$ARDD_SOURCE remains dev-mode: used exactly as
# given (--beta still records the channel, but never moves that checkout).

set -e

REPO_URL="https://github.com/moui72/artifact-driven-dev"
DEFAULT_SOURCE="$HOME/.ardd/source"

kickoff=""          # "" = ask; 1 = always; 0 = never
source_arg=""
target=""
existing=0          # 1 = install into an existing, already-populated project
channel="stable"    # stable | beta (--beta); recorded via $ARDD_CHANNEL
harness=""          # claude | codex; absent prompts when a tty is available

usage() {
  cat >&2 <<EOF
Usage: new.sh [--kickoff|--no-kickoff] [--beta] [--harness claude|codex] [--source <path>] <target-dir>
       new.sh --existing [--kickoff|--no-kickoff] [--beta] [--harness claude|codex] [--source <path>] [<project-dir>]

  --existing       Install ArDD into an existing, already-populated project
                   (<project-dir> defaults to the current directory). Without
                   it, new.sh creates a *new* project and refuses a non-empty
                   target.
  --kickoff        Open Claude Code on the first step without asking
                   (/ardd-init, which detects greenfield vs existing code;
                   /ardd-status instead if the project is already set up).
  --no-kickoff     Install, then print the next step instead of opening Claude Code.
                   With neither flag, you're asked — unless there's no terminal
                   to ask on, in which case this is the default.
  --beta           Track the beta channel: install the latest release
                   *including* vX.Y.Z-beta.N prereleases (published on every
                   push to main), and record the channel for /ardd-update.
                   Default is stable — tagged full releases only.
  --harness <name> Install for claude (.claude/skills, slash commands) or
                   codex (.agents/skills, dollar-prefixed skills). If omitted
                   and a terminal is available, new.sh asks; without a
                   terminal it preserves the historical Claude default.
  --source <path>  Use an existing ArDD checkout (also settable as \$ARDD_SOURCE).
                   Read, never modified. Without it, ~/.ardd/source is cloned
                   and kept up to date.

Examples (stable base = the release branch; use main for the beta edge):
  curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/release/new.sh | sh -s -- my-project
  cd my-existing-project && curl -fsSL https://raw.githubusercontent.com/moui72/artifact-driven-dev/release/new.sh | sh -s -- --existing
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
    --beta)       channel="beta"; shift ;;
    --harness)    [ $# -ge 2 ] || { echo "Error: --harness requires claude or codex" >&2; usage; }
                  harness="$2"; shift 2 ;;
    --harness=*)  harness="${1#--harness=}"; shift ;;
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

# Actually open the tty rather than testing its permission bits: `[ -r /dev/tty ]`
# passes on a CI runner with no controlling terminal, where the open then fails
# with ENXIO. Only a real open answers "can I interact with a human here?"
tty_ok() { (exec 3< /dev/tty) 2>/dev/null; }

ask_harness() {
  attempt=0
  while [ "$attempt" -lt 3 ]; do
    printf 'Install ArDD skills for which harness? [claude/codex] ' > /dev/tty
    if ! IFS= read -r reply < /dev/tty; then
      echo "" > /dev/tty
      return 1   # EOF
    fi
    case "$reply" in
      [Cc][Ll][Aa][Uu][Dd][Ee]) harness="claude"; return 0 ;;
      [Cc][Oo][Dd][Ee][Xx])     harness="codex"; return 0 ;;
      *) echo "Please answer claude or codex." > /dev/tty ;;
    esac
    attempt=$((attempt + 1))
  done
  echo "No clear answer after 3 tries — using Claude harness." > /dev/tty
  return 1
}

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
    echo "This command creates a *new* project. To add ArDD to an existing one," >&2
    echo "rerun with --existing from inside it:" >&2
    echo "  cd $target && curl … | sh -s -- --existing" >&2
    exit 1
  fi
fi

if [ -z "$harness" ]; then
  if tty_ok; then
    ask_harness || harness="claude"
  else
    harness="claude"
  fi
fi

case "$harness" in
  claude|codex) ;;
  *) echo "Error: --harness must be 'claude' or 'codex' (got '$harness')" >&2; usage ;;
esac

# --- Resolve the source checkout ---------------------------------------
# An explicit --source/$ARDD_SOURCE is the user's checkout: verify, use as-is.
# The default path is ours: clone it if absent, keep it current if present.

is_ardd_checkout() { [ -f "$1/install.sh" ] && [ -d "$1/skills" ]; }

# Pin the owned checkout to its latest release tag on the chosen channel
# (same rules as source-resolve.sh --channel, duplicated minimally because
# new.sh has no checkout to source it from). stable: strict vX.Y.Z only.
# beta: prereleases count too, under versionsort.suffix=-beta. — the
# suffix is load-bearing (default version sort puts vX.Y.Z-beta.N after
# vX.Y.Z, so a stale beta would shadow a newer stable without it). No
# releases yet is a note, not a failure: install from the default branch
# as it stands.
pin_release() {
  if [ "$channel" = "beta" ]; then
    release_tag="$(git -C "$SRC" -c versionsort.suffix=-beta. tag --list 'v[0-9]*' --sort=v:refname \
      | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+(-beta\.[0-9]+)?$' | tail -n 1 || true)"
  else
    release_tag="$(git -C "$SRC" tag --list 'v[0-9]*' --sort=v:refname \
      | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1 || true)"
  fi
  if [ -n "$release_tag" ]; then
    git -C "$SRC" checkout --quiet "$release_tag"
    echo "Using ArDD release $release_tag ($channel channel)."
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
    echo "Updating ArDD source at $SRC ..."
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
  echo "Cloning ArDD source into $SRC ..."
  mkdir -p "$(dirname "$SRC")"
  git clone --quiet "$REPO_URL" "$SRC"
  pin_release
fi

SRC="$(cd "$SRC" && pwd)"

# --- Create the target -------------------------------------------------

mkdir -p "$target"
TARGET="$(cd "$target" && pwd -P)"

# install.sh runs its .gitignore guidance through `git -C "$TARGET"`, so the
# repo must exist before it is called or those suggestions silently never fire.
# Must confirm $TARGET itself is a repo root, not merely nested under one --
# `rev-parse --is-inside-work-tree` is true for any directory under an
# enclosing .git, which would silently skip init and inherit that outer
# repo's identity instead of giving $TARGET its own.
target_toplevel="$(git -C "$TARGET" rev-parse --show-toplevel 2>/dev/null || true)"
if [ "$target_toplevel" != "$TARGET" ]; then
  git init --quiet "$TARGET"
  echo "Initialized empty git repository in $TARGET"
fi

# --- Converge on install.sh -------------------------------------------
# Its output (migrations, gitignore guidance, warnings) is the user's only
# view of install-time housekeeping. Relay it verbatim; never summarize.
# $ARDD_CHANNEL tells it which channel to record in ardd-version.md.

ARDD_CHANNEL="$channel" "$SRC/install.sh" --harness "$harness" "$TARGET"

# --- Hand off to the first session -------------------------------------
# Both new and existing projects initialize with /ardd-init — the skill
# itself detects greenfield vs existing-code and confirms with the user.
# A project that already carries ArDD artifacts just gets checked
# (/ardd-status). install.sh only ever creates .project/ardd-version.md,
# never .project/artifacts/, so that dir's presence reliably distinguishes
# an already-set-up project from a first install.
if [ "$existing" -eq 1 ] && [ -d "$TARGET/.project/artifacts" ]; then
  handoff_name="ardd-status"
else
  handoff_name="ardd-init"
fi

case "$harness" in
  codex)
    handoff_tool="codex"
    handoff_tool_name="Codex"
    handoff_cmd="\$$handoff_name"
    ;;
  *)
    handoff_tool="claude"
    handoff_tool_name="Claude Code"
    handoff_cmd="/$handoff_name"
    ;;
esac

print_handoff_command() {
  case "$harness" in
    codex) echo "  $handoff_tool '$handoff_cmd'" ;;
    *)     echo "  $handoff_tool \"$handoff_cmd\"" ;;
  esac
}

next_steps() { # $1 = optional reason line
  [ -n "$1" ] && echo "$1"
  echo "Start the first session with:"
  echo ""
  echo "  cd $target"
  print_handoff_command
  echo ""
}

launch() {
  echo "Opening $handoff_tool_name in $target — $handoff_cmd is your first step."
  echo ""
  cd "$TARGET"
  # Claude Code vs Codex need opposite stdin handling here, even though both
  # are launched under `curl | sh` with the curl pipe on stdin:
  #
  # - Claude Code: do NOT redirect stdin. It checks
  #   `process.stdin.isTTY && process.stdout.isTTY` and only falls back to
  #   opening /dev/tty itself — read-write, which is what its TUI needs —
  #   when that check fails. Feeding it `< /dev/tty` (read-only) passes the
  #   check, so it uses that fd instead and silently accepts no keystrokes;
  #   `<> /dev/tty` makes it exit outright. An EOF'd pipe on stdin is the
  #   input it handles correctly, so leave it alone.
  # - Codex: it has no such isTTY-checked fallback at all — it errors
  #   immediately when stdin isn't a terminal, confirmed empirically
  #   (`echo "" | codex '...' </dev/null` reproduces
  #   `Error: stdin is not a terminal`). So it needs stdin explicitly
  #   connected to a real terminal via `<> /dev/tty` (read-write).
  case "$harness" in
    codex) exec "$handoff_tool" "$handoff_cmd" <> /dev/tty ;;
    *)     exec "$handoff_tool" "$handoff_cmd" ;;
  esac
}

# Ask on /dev/tty — never stdin, which is the curl pipe. Bare Enter means yes.
# EOF (a readable but closed tty) means no, matching the no-tty default: never
# block, never guess. An unrecognized answer re-asks, but only three times, so
# a wedged terminal can't spin forever.
ask_kickoff() {
  attempt=0
  while [ "$attempt" -lt 3 ]; do
    printf 'Open %s now and run %s? [Y/n] ' "$handoff_tool_name" "$handoff_cmd" > /dev/tty
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

if ! command -v "$handoff_tool" >/dev/null 2>&1; then
  next_steps "$handoff_tool_name isn't on your PATH, so I can't open the first session for you."
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
