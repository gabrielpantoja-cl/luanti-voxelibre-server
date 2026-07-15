#!/usr/bin/env bash
#
# setup-ai-shims.sh — replace .claude/{agents,commands,skills}/ with symlinks
# pointing at the canonical .opencode/{agents,commands,skills}/ so Claude Code
# keeps working while OpenCode reads the canonical files.
#
# Idempotent. Safe-by-default. Backs up anything it touches before replacing.
#
# Usage:
#   ./scripts/setup-ai-shims.sh [--dry-run] [--yes]
#
# Flags:
#   --dry-run   print what would happen without making changes
#   --yes       run every shim replacement without prompting (default: prompt)
#   --help      show this message
#
# Effects on each pair (.claude/<dir> ↔ .opencode/<dir>):
#   - if .claude/<dir> is already a symlink/junction to .opencode/<dir>: skip
#   - if .opencode/<dir> does not exist: skip with warning
#   - else: backup .claude/<dir> → .claude/<dir>.bak-<timestamp>, then
#           `rm -rf .claude/<dir>` + `ln -s ../.opencode/<dir> .claude/<dir>`
#
# Rollback (per shim):
#   rm .claude/<dir>                                  # remove the symlink
#   mv .claude/<dir>.bak-* .claude/<dir>              # restore the backup
#
# Requires: bash, ln, find. Tested on Linux.
set -euo pipefail

DRY_RUN=0
ASSUME_YES=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --yes|-y)  ASSUME_YES=1 ;;
    --help|-h)
      sed -n '2,28p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

# Resolve repo root (directory containing this script's parent's parent)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

PAIRS=( "agents" "commands" "skills" )
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"

run_step() {
  local label="$1"; shift
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[DRY-RUN] %s\n' "$label"
    printf '         %s\n' "$*"
  else
    printf '[STEP]    %s\n' "$label"
    "$@"
  fi
}

confirm() {
  local prompt="$1"
  if [ "$ASSUME_YES" -eq 1 ]; then
    printf '%s [auto-yes]\n' "$prompt"
    return 0
  fi
  read -r -p "$prompt [y/N] " reply
  case "$reply" in
    y|Y|yes|YES) return 0 ;;
    *)           return 1 ;;
  esac
}

backup_if_needed() {
  local target="$1"
  if [ -L "$target" ]; then
    echo "  $target is already a symlink (skipped backup)"
    return 0
  fi
  if [ -d "$target" ] || [ -f "$target" ]; then
    local backup="${target}.bak-${TIMESTAMP}"
    if [ -e "$backup" ]; then
      echo "  backup already exists: $backup (skipping to avoid overwrite)"
      return 1
    fi
    run_step "backup $target → $backup" cp -R "$target" "$backup"
    return 0
  fi
  echo "  $target does not exist (nothing to back up)"
  return 1
}

for dir in "${PAIRS[@]}"; do
  claude_path=".claude/$dir"
  opencode_path=".opencode/$dir"

  printf '\n========== %s ↔ %s ==========\n' "$claude_path" "$opencode_path"

  if [ ! -e "$opencode_path" ]; then
    printf '  [SKIP] %s does not exist — run Phase 4 first.\n' "$opencode_path"
    continue
  fi

  if [ -L "$claude_path" ]; then
    target="$(readlink -f "$claude_path" || true)"
    canon_target="$(cd "$claude_path" && cd .. && cd "$(basename "$target")" 2>/dev/null && pwd || true)"
    printf '  [SKIP] %s already a symlink → %s\n' "$claude_path" "$target"
    continue
  fi

  if ! confirm "Replace $claude_path with symlink to ../$opencode_path?"; then
    echo "  [SKIP] user declined"
    continue
  fi

  if ! backup_if_needed "$claude_path"; then
    echo "  [ABORT] backup step failed for $claude_path"
    continue
  fi

  run_step "remove $claude_path" rm -rf "$claude_path"
  run_step "create symlink $claude_path → ../$opencode_path" \
    ln -s "../$opencode_path" "$claude_path"

  # Verify
  if [ -L "$claude_path" ] && [ -d "$claude_path" ]; then
    cnt=$(find "$claude_path" -mindepth 1 -maxdepth 5 2>/dev/null | wc -l)
    printf '  [OK]    symlink resolves, %s entries reachable through it\n' "$cnt"
  else
    printf '  [FAIL]  symlink did not resolve — manual rollback required\n' >&2
  fi
done

printf '\nDone. Verify with: ls -la .claude/{agents,commands,skills}\n'
printf 'Rollback any single pair: rm .claude/<dir> && mv .claude/<dir>.bak-* .claude/<dir>\n'
