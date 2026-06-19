#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'USAGE'
Usage: scripts/cf-rollback.sh --slug <slug> --reason <text> [options]

Options:
  --to <state>         Rollback target state. Defaults to ready_for_implementation.
  --evidence <text>    Extra evidence. Defaults to generated stash message.
  --root <path>        Repository root. Defaults to current directory.
  --help              Show this help.

Safely stashes current work, then records rollback in docs/specs/<slug>.state.json.
Does not run destructive git commands.
USAGE
}

root="$(pwd)"
slug=""
reason=""
to_state="ready_for_implementation"
extra_evidence=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug) slug="${2:-}"; shift 2 ;;
    --reason) reason="${2:-}"; shift 2 ;;
    --to) to_state="${2:-}"; shift 2 ;;
    --evidence) extra_evidence="${2:-}"; shift 2 ;;
    --root) root="${2:-}"; shift 2 ;;
    --help) usage; exit 0 ;;
    *) printf 'ERROR: unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$slug" || -z "$reason" ]]; then
  printf 'ERROR: --slug and --reason are required\n' >&2
  usage >&2
  exit 2
fi

if [[ ! "$slug" =~ ^[A-Za-z0-9._-]+$ ]]; then
  printf 'ERROR: slug may only contain letters, numbers, dot, underscore, and hyphen\n' >&2
  exit 2
fi

if ! git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'ERROR: %s is not inside a git worktree\n' "$root" >&2
  exit 1
fi

status="$(git -C "$root" status --porcelain)"
if [[ -z "$status" ]]; then
  evidence="No worktree changes to stash."
else
  timestamp="$(date -u '+%Y%m%d-%H%M%S')"
  stash_name="controlflow/$slug/rollback-$timestamp"
  git -C "$root" stash push --include-untracked -m "$stash_name" -- . ':(exclude)docs/specs/*.state.json' >/dev/null
  evidence="Current work stashed as $stash_name. Restore with: git stash pop"
fi

if [[ -n "$extra_evidence" ]]; then
  evidence="$evidence $extra_evidence"
fi

"$SCRIPT_DIR/cf-transition.sh" \
  --root "$root" \
  --slug "$slug" \
  --to "$to_state" \
  --type rollback \
  --reason "$reason" \
  --evidence "$evidence"

printf 'controlflow-rollback: %s\n' "$evidence"
