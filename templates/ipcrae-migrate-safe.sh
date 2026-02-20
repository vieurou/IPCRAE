#!/usr/bin/env bash
set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_TEMPLATES_DIR="${IPCRAE_ROOT}/templates"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${IPCRAE_ROOT}/.ipcrae/backups"
REPORT="${IPCRAE_ROOT}/.ipcrae/backups/migration-${TS}.md"

log() { printf '→ %s\n' "$*"; }
warn() { printf '⚠ %s\n' "$*"; }

require_root() {
  [ -d "$IPCRAE_ROOT" ] || { echo "IPCRAE_ROOT introuvable: $IPCRAE_ROOT" >&2; exit 1; }
  mkdir -p "$BACKUP_DIR"
}

backup_vault() {
  local archive="${BACKUP_DIR}/vault-${TS}.tar.gz"
  log "Backup du vault (hors .git) vers ${archive}"
  tar -C "$IPCRAE_ROOT" --exclude='.git' -czf "$archive" .
}

ensure_config_key() {
  local key="$1" value="$2" cfg="${IPCRAE_ROOT}/.ipcrae/config.yaml"
  mkdir -p "${IPCRAE_ROOT}/.ipcrae"
  [ -f "$cfg" ] || touch "$cfg"
  if grep -qE "^${key}:" "$cfg"; then
    return 0
  fi
  printf '%s: %s\n' "$key" "$value" >> "$cfg"
}

sync_prompt_file() {
  local src="$1" dst="$2"
  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    return 0
  fi
  if ! cmp -s "$src" "$dst"; then
    cp "$src" "${dst}.new-${TS}"
  fi
}

sync_prompts_non_destructive() {
  local src_dir="" dst_dir="${IPCRAE_ROOT}/.ipcrae/prompts"
  if [ -d "${REPO_TEMPLATES_DIR}/prompts" ]; then
    src_dir="${REPO_TEMPLATES_DIR}/prompts"
  elif [ -d "${SCRIPT_DIR}/prompts" ]; then
    src_dir="${SCRIPT_DIR}/prompts"
  else
    warn "Dossier prompts source introuvable, sync prompts ignorée."
    return 0
  fi
  mkdir -p "$dst_dir"
  for src in "$src_dir"/*.md; do
    [ -e "$src" ] || continue
    sync_prompt_file "$src" "$dst_dir/$(basename "$src")"
  done
}

install_bins_with_backup() {
  mkdir -p "$HOME/bin"
  for pair in "ipcrae-launcher.sh:ipcrae" "ipcrae-addProject.sh:ipcrae-addProject" "ipcrae-migrate-safe.sh:ipcrae-migrate-safe"; do
    local src="" dst="$HOME/bin/${pair##*:}"
    if [ -f "${REPO_TEMPLATES_DIR}/${pair%%:*}" ]; then
      src="${REPO_TEMPLATES_DIR}/${pair%%:*}"
    elif [ -f "${SCRIPT_DIR}/${pair%%:*}" ]; then
      src="${SCRIPT_DIR}/${pair%%:*}"
    fi
    [ -n "$src" ] || continue
    if [ -f "$dst" ]; then
      cp "$dst" "${dst}.bak-${TS}"
    fi
    cp "$src" "$dst"
    chmod +x "$dst"
  done
}

write_report() {
  cat > "$REPORT" <<'RPT'
# IPCRAE Safe Migration Report

- Date: __DATE__
- Vault: __VAULT__
- Backup: __BACKUP__

## Actions
- Backup vault créé avant migration.
- Config enrichie sans écrasement (`default_provider`, `auto_git_sync`).
- Scripts CLI mis à jour avec backup local dans ~/bin.
- Prompts synchronisés en mode non destructif:
  - fichier absent => créé
  - fichier différent => écrit en `*.new-<timestamp>`

## Next step
- Examiner les fichiers `.new-<timestamp>` dans `__PROMPTS__` puis merger manuellement.
RPT
  sed -i "s|__DATE__|$(date +'%Y-%m-%d %H:%M:%S')|" "$REPORT"
  sed -i "s|__VAULT__|${IPCRAE_ROOT}|" "$REPORT"
  sed -i "s|__BACKUP__|${BACKUP_DIR}/vault-${TS}.tar.gz|" "$REPORT"
  sed -i "s|__PROMPTS__|${IPCRAE_ROOT}/.ipcrae/prompts/|" "$REPORT"
  log "Rapport: $REPORT"
}

main() {
  require_root
  backup_vault
  ensure_config_key "default_provider" "claude"
  ensure_config_key "auto_git_sync" "true"
  install_bins_with_backup
  sync_prompts_non_destructive
  write_report
  log "Migration safe terminée ✅"
}

main "$@"
