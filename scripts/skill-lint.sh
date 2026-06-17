#!/usr/bin/env bash
set -euo pipefail

root="${1:-$(pwd)}"
failed=0

err() {
  printf 'ERROR: %s\n' "$1" >&2
  failed=1
}

check_file_ref() {
  local from="$1"
  local ref="$2"
  if [[ ! -e "$root/$ref" ]]; then
    err "$from references missing file: $ref"
  fi
}

repo_markdown_roots=()
for path in "$root"/*.md "$root"/skills "$root"/docs "$root"/templates "$root"/references "$root"/agents; do
  [[ -e "$path" ]] && repo_markdown_roots+=("$path")
done

for skill_dir in "$root"/skills/*; do
  [[ -d "$skill_dir" ]] || continue
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  [[ -f "$skill_file" ]] || { err "skills/$skill_name missing SKILL.md"; continue; }

  first_line="$(sed -n '1p' "$skill_file")"
  [[ "$first_line" == "---" ]] || err "skills/$skill_name/SKILL.md missing frontmatter"

  declared_name="$(sed -n 's/^name: *//p' "$skill_file" | head -n 1)"
  [[ "$declared_name" == "$skill_name" ]] || err "skills/$skill_name name mismatch: '$declared_name'"

  description="$(sed -n 's/^description: *//p' "$skill_file" | head -n 1)"
  [[ -n "$description" ]] || err "skills/$skill_name missing description"
  [[ "$description" == *Use* || "$description" == *use* ]] || err "skills/$skill_name description lacks trigger guidance"

  case "$skill_name" in
    cf-build|cf-intake|cf-mr|cf-review|cf-ship|cf-spec|cf-state-machine)
      requires_stage_headings=1
      ;;
    *)
      requires_stage_headings=0
      ;;
  esac

  if [[ "$requires_stage_headings" == 1 ]]; then
    for heading in "When To Use" "When NOT To Use" "Verification" "Integration With Other Skills"; do
      grep -q "^## $heading" "$skill_file" || err "skills/$skill_name missing heading: $heading"
    done
    grep -qE '^## (Process|State Machine)' "$skill_file" || err "skills/$skill_name missing heading: Process or State Machine"
  fi
done

while IFS= read -r ref; do
  check_file_ref "markdown" "$ref"
done < <(
  grep -RhoE '(^|[^.~[:alnum:]_/-])(references/[A-Za-z0-9._/-]+\.md|agents/[A-Za-z0-9._-]+\.md|docs/(state-machine|human-workflow-guide|roadmap)\.md|templates/(launch-template|mr-template|spec-template|test-plan-template)\.md)' "${repo_markdown_roots[@]}" 2>/dev/null \
    | sed -E 's#^.*(references/[A-Za-z0-9._/-]+\.md|agents/[A-Za-z0-9._-]+\.md|docs/(state-machine|human-workflow-guide|roadmap)\.md|templates/(launch-template|mr-template|spec-template|test-plan-template)\.md)$#\1#' \
    | sort -u
)

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

printf 'skill-lint: ok\n'
