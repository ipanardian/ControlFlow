#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_CONFIG="$SCRIPT_DIR/install-targets.conf"
WORKFLOW_FILES=(
  "references/lane-classification.md|references/lane-classification.md"
  "references/production-readiness-checklist.md|references/production-readiness-checklist.md"
  "references/review-checklist.md|references/review-checklist.md"
  "references/security-checklist.md|references/security-checklist.md"
  "references/stage-handoff.md|references/stage-handoff.md"
  "references/subagent-dispatch-checklist.md|references/subagent-dispatch-checklist.md"
  "references/testing-patterns.md|references/testing-patterns.md"
  "templates/launch-template.md|launch-template.md"
  "templates/mr-template.md|mr-template.md"
  "templates/spec-template.md|spec-template.md"
  "templates/test-plan-template.md|test-plan-template.md"
)

# Skill directories are discovered from skills/ at runtime so the install
# list cannot drift from the actual skill set. To add or remove a managed
# skill, create or delete its directory under skills/. The list is sorted
# for deterministic output and consistent install order.
discover_skills() {
  local d
  for d in "$SCRIPT_DIR"/skills/*/; do
    [[ -d "$d" ]] || continue
    d="${d%/}"
    d="${d##*/}"
    printf '%s\n' "$d"
  done | sort
}
DEFAULT_MODE="copy"
REPO_VERSION="$(git -C "$SCRIPT_DIR" describe --tags --always 2>/dev/null || echo unknown)"
INSTALL_TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

MODE="$DEFAULT_MODE"
ALL=0
DRY_RUN=0
FORCE=0
UNINSTALL=0
CUSTOM_DEST=""
TARGETS=()

usage() {
  cat <<'EOF'
Install AI workflow and skills into agent config directories.

Usage:
  ./install.sh --target TARGET [options]
  ./install.sh --all [options]
  ./install.sh --dest PATH [options]

Options:
  -h, --help              Show this help.
  -t, --target TARGET     Install to target agent. Can be repeated.
  -a, --all               Install to all built-in targets.
  -d, --dest PATH         Install to custom destination path.
  -m, --mode MODE         Install mode: copy or symlink. Default: copy.
      --config PATH       Target config file. Default: ./install-targets.conf.
      --dry-run           Print actions without changing files.
  -f, --force             Replace existing managed files/directories/symlinks.
      --uninstall         Remove installed path instead of installing.
      --list-skills       Print the discovered skill directories and exit.

Targets are loaded from install-targets.conf:
  target|skills_dest|workflow_docs_dest

Examples:
  ./install.sh --all
  ./install.sh --target agents --mode copy
  ./install.sh --target claude --mode symlink
  ./install.sh --target agents --mode copy --force
  ./install.sh --dest ~/.config/my-agent --dry-run
  ./install.sh --target agents --uninstall
  ./install.sh --config ./my-targets.conf --target my-agent

Notes:
  copy mode creates a snapshot and needs rerun after repo changes.
  symlink mode keeps destinations live-linked to this repo. Agents may
    write through the symlink and modify the repository; use only when
    you trust the agent.
  unrelated files and skill directories are not managed or removed.
EOF
  print_targets
}

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

info() {
  printf '%s\n' "$1"
}

expand_path() {
  local path="$1"
  if [[ "$path" == "~" ]]; then
    printf '%s\n' "$HOME"
  elif [[ "${path:0:2}" == "~/" ]]; then
    printf '%s/%s\n' "$HOME" "${path:2}"
  else
    printf '%s\n' "$path"
  fi
}

ensure_config() {
  [[ -f "$TARGET_CONFIG" ]] || die "target config not found: $TARGET_CONFIG"
}

list_targets() {
  ensure_config
  while IFS='|' read -r target skills_dest workflow_dest; do
    [[ -z "$target" || "${target#\#}" != "$target" ]] && continue
    printf '%s\n' "$target"
  done < "$TARGET_CONFIG"
}

target_field() {
  local wanted="$1"
  local field="$2"

  ensure_config
  while IFS='|' read -r target skills_dest workflow_dest; do
    [[ -z "$target" || "${target#\#}" != "$target" ]] && continue
    if [[ "$target" == "$wanted" ]]; then
      case "$field" in
        workflow) expand_path "$workflow_dest" ;;
        skills) expand_path "$skills_dest" ;;
        *) die "unknown target field '$field'" ;;
      esac
      return 0
    fi
  done < "$TARGET_CONFIG"

  die "unknown target '$wanted'. Add it to $TARGET_CONFIG or use --dest."
}

print_targets() {
  ensure_config
  info ""
  info "Configured targets:"
  while IFS='|' read -r target skills_dest workflow_dest; do
    [[ -z "$target" || "${target#\#}" != "$target" ]] && continue
    info "  $target"
    [[ -n "$skills_dest" ]] && info "    skills                $skills_dest"
    [[ -n "$workflow_dest" ]] && info "    workflows             $workflow_dest"
  done < "$TARGET_CONFIG"
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'dry-run:'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi

  "$@"
}

remove_path() {
  local dest="$1"

  if [[ ! -e "$dest" && ! -L "$dest" ]]; then
    info "skip missing: $dest"
    return 0
  fi

  if [[ "$FORCE" -ne 1 && "$UNINSTALL" -ne 1 ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      info "dry-run: would fail: destination exists: $dest (use --force to replace)"
      return 0
    fi
    die "destination exists: $dest (use --force to replace)"
  fi

  run rm -rf "$dest"
}

install_one() {
  local label="$1"
  local source="$2"
  local dest="$3"
  local parent
  parent="$(dirname "$dest")"

  if [[ "$UNINSTALL" -eq 1 ]]; then
    info "uninstall $label: $dest"
    remove_path "$dest"
    return 0
  fi

  info "install $label ($MODE): $source -> $dest"
  info "  repo version: $REPO_VERSION"
  info "  installed at: $INSTALL_TIMESTAMP"
  run mkdir -p "$parent"

  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ -L "$dest" ]]; then
      local current
      current="$(readlink "$dest")"
      if [[ "$current" == "$source" ]]; then
        info "already linked: $dest"
        return 0
      fi
    fi

    if [[ "$FORCE" -ne 1 ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        info "dry-run: would fail: destination exists: $dest (use --force to replace)"
        return 0
      fi
      die "destination exists: $dest (use --force to replace)"
    fi

    remove_path "$dest"
  fi

  case "$MODE" in
    symlink)
      run ln -s "$source" "$dest"
      ;;
    copy)
      run cp -R "$source" "$dest"
      ;;
    *)
      die "invalid mode '$MODE'. Use symlink or copy."
      ;;
  esac
}

install_workflows() {
  local label="$1"
  local dest="$2"

  if [[ "$UNINSTALL" -eq 1 ]]; then
    info "uninstall $label: managed skill directories -> $dest"
    remove_path "$dest"
    return 0
  fi

  info "install $label ($MODE): workflow files -> $dest"
  run mkdir -p "$dest"

  local entry source dest_name
  for entry in "${WORKFLOW_FILES[@]}"; do
    source="${entry%%|*}"
    dest_name="${entry##*|}"
    if [[ ! -f "$SCRIPT_DIR/$source" ]]; then
      die "missing workflow file in repo: $source (expected at $SCRIPT_DIR/$source)"
    fi
    install_one "$label/$dest_name" "$SCRIPT_DIR/$source" "$dest/$dest_name"
  done
}

install_skills() {
  local label="$1"
  local dest="$2"

  if [[ "$UNINSTALL" -eq 1 ]]; then
    info "uninstall $label: managed skill directories -> $dest"
  else
    info "install $label ($MODE): managed skill directories -> $dest"
    run mkdir -p "$dest"
  fi

  local skill
  while IFS= read -r skill; do
    [[ -n "$skill" ]] || continue
    install_one "$label/$skill" "$SCRIPT_DIR/skills/$skill" "$dest/$skill"
  done < <(discover_skills)
}

install_target() {
  local target="$1"
  local workflow_dest
  local skills_dest
  workflow_dest="$(target_field "$target" workflow)"
  skills_dest="$(target_field "$target" skills)"

  [[ -n "$workflow_dest" ]] && install_workflows "$target workflows" "$workflow_dest"
  [[ -n "$skills_dest" ]] && install_skills "$target skills" "$skills_dest"
}

install_custom() {
  local dest="$1"

  install_workflows "custom workflows" "$dest/controlflow"
  install_skills "custom skills" "$dest/skills"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -t|--target)
      [[ $# -ge 2 ]] || die "--target requires value"
      TARGETS+=("$2")
      shift 2
      ;;
    -a|--all)
      ALL=1
      shift
      ;;
    -d|--dest)
      [[ $# -ge 2 ]] || die "--dest requires value"
      CUSTOM_DEST="$(expand_path "$2")"
      shift 2
      ;;
    -m|--mode)
      [[ $# -ge 2 ]] || die "--mode requires value"
      MODE="$2"
      shift 2
      ;;
    --config)
      [[ $# -ge 2 ]] || die "--config requires value"
      TARGET_CONFIG="$(expand_path "$2")"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -f|--force)
      FORCE=1
      shift
      ;;
    --uninstall)
      UNINSTALL=1
      shift
      ;;
    --list-skills)
      discover_skills
      exit 0
      ;;
    *)
      die "unknown option '$1'. Use --help."
      ;;
  esac
done

case "$MODE" in
  symlink|copy) ;;
  *) die "invalid mode '$MODE'. Use symlink or copy." ;;
esac

if [[ "$ALL" -eq 1 ]]; then
  while IFS= read -r target; do
    TARGETS+=("$target")
  done < <(list_targets)
fi

if [[ "${#TARGETS[@]}" -eq 0 && -z "$CUSTOM_DEST" ]]; then
  usage
  exit 1
fi

for target in ${TARGETS[@]+"${TARGETS[@]}"}; do
  install_target "$target"
done

if [[ -n "$CUSTOM_DEST" ]]; then
  install_custom "$CUSTOM_DEST"
fi
