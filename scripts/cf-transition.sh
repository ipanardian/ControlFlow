#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/cf-transition.sh --slug <slug> --to <state> --reason <text> --evidence <text> [options]

Options:
  --from <state>       Expected current state. Fails if state file has a different state.
  --lane <A|B>         Lane for a new state file. Defaults to "unknown".
  --type <type>        Transition type. Defaults to "transition".
  --root <path>        Repository root. Defaults to current directory.
  --help              Show this help.

Creates or updates docs/specs/<slug>.state.json.
USAGE
}

root="$(pwd)"
slug=""
to_state=""
from_state=""
reason=""
evidence=""
lane="unknown"
transition_type="transition"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug) slug="${2:-}"; shift 2 ;;
    --to) to_state="${2:-}"; shift 2 ;;
    --from) from_state="${2:-}"; shift 2 ;;
    --reason) reason="${2:-}"; shift 2 ;;
    --evidence) evidence="${2:-}"; shift 2 ;;
    --lane) lane="${2:-}"; shift 2 ;;
    --type) transition_type="${2:-}"; shift 2 ;;
    --root) root="${2:-}"; shift 2 ;;
    --help) usage; exit 0 ;;
    *) printf 'ERROR: unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$slug" || -z "$to_state" || -z "$reason" || -z "$evidence" ]]; then
  printf 'ERROR: --slug, --to, --reason, and --evidence are required\n' >&2
  usage >&2
  exit 2
fi

if [[ ! "$slug" =~ ^[A-Za-z0-9._-]+$ ]]; then
  printf 'ERROR: slug may only contain letters, numbers, dot, underscore, and hyphen\n' >&2
  exit 2
fi

if [[ "$lane" != "unknown" && "$lane" != "A" && "$lane" != "B" ]]; then
  printf 'ERROR: --lane must be A or B\n' >&2
  exit 2
fi

state_dir="$root/docs/specs"
state_file="$state_dir/$slug.state.json"
mkdir -p "$state_dir"

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

read_json_string() {
  local key="$1"
  local file="$2"
  sed -nE "s/^[[:space:]]*\"$key\": \"([^\"]*)\",?$/\1/p" "$file" | head -n 1
}

now="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

if [[ ! -f "$state_file" ]]; then
  cat > "$state_file" <<EOF
{
  "schema": "controlflow-state/v1",
  "slug": "$(json_escape "$slug")",
  "lane": "$(json_escape "$lane")",
  "state": "request",
  "created_at": "$(json_escape "$now")",
  "updated_at": "$(json_escape "$now")",
  "transitions": []
}
EOF
fi

current_state="$(read_json_string state "$state_file")"
if [[ -z "$current_state" ]]; then
  printf 'ERROR: could not read current state from %s\n' "$state_file" >&2
  exit 1
fi

if [[ -n "$from_state" && "$current_state" != "$from_state" ]]; then
  printf 'ERROR: current state is %s, expected %s\n' "$current_state" "$from_state" >&2
  exit 1
fi

tmp_file="$(mktemp "${TMPDIR:-/tmp}/cf-transition.XXXXXX")"
transition_json="    {\n      \"at\": \"$(json_escape "$now")\",\n      \"from\": \"$(json_escape "$current_state")\",\n      \"to\": \"$(json_escape "$to_state")\",\n      \"type\": \"$(json_escape "$transition_type")\",\n      \"reason\": \"$(json_escape "$reason")\",\n      \"evidence\": \"$(json_escape "$evidence")\"\n    }"

awk \
  -v new_state="$(json_escape "$to_state")" \
  -v updated_at="$(json_escape "$now")" \
  -v transition="$transition_json" '
  BEGIN { in_transitions = 0; saw_transition = 0 }
  /^[[:space:]]*"state":/ {
    print "  \"state\": \"" new_state "\",";
    next;
  }
  /^[[:space:]]*"updated_at":/ {
    print "  \"updated_at\": \"" updated_at "\",";
    next;
  }
  /^[[:space:]]*"transitions": \[\]/ {
    print "  \"transitions\": [";
    print transition;
    print "  ]";
    next;
  }
  /^[[:space:]]*"transitions": \[/ {
    in_transitions = 1;
    print;
    next;
  }
  in_transitions && /^[[:space:]]*\]/ {
    if (saw_transition) {
      print ",";
    }
    print transition;
    print;
    in_transitions = 0;
    next;
  }
  in_transitions && /}/ { saw_transition = 1 }
  { print }
' "$state_file" > "$tmp_file"

mv "$tmp_file" "$state_file"
printf 'controlflow-transition: %s -> %s (%s)\n' "$current_state" "$to_state" "$state_file"
