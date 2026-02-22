#!/bin/bash
# ===========================================================================
# ipcrae-inbox-scan — IPCRAE Inbox Scanner (100% bash, zéro IA)
# ===========================================================================
# Scanne tous les sous-dossiers de Inbox/, détecte les fichiers non traités,
# génère un rapport .ipcrae/auto/inbox-pending.md et un flag.
#
# Usage : ipcrae-inbox-scan [--verbose] [--dry-run] [IPCRAE_ROOT]
# Exit  : 0 = rien en attente | 1 = fichiers en attente détectés
#
# Intégration :
#   - Appelé par cmd_start (ipcrae start)
#   - Appelé par cron/ipcrae-auto (quotidien)
#   - Manuel : ~/bin/ipcrae-inbox-scan
# ===========================================================================

set -euo pipefail

# ── Couleurs ──────────────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BLUE='\033[0;34m'; NC='\033[0m'

# ── Options ───────────────────────────────────────────────────────────────
VERBOSE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose|-v) VERBOSE=true; shift ;;
    --dry-run|-n) DRY_RUN=true; shift ;;
    -*) echo "Option inconnue: $1" >&2; exit 2 ;;
    *) IPCRAE_ROOT="$1"; shift ;;
  esac
done

IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
INBOX_DIR="${IPCRAE_ROOT}/Inbox"
AUTO_DIR="${IPCRAE_ROOT}/.ipcrae/auto"
PENDING_FILE="${AUTO_DIR}/inbox-pending.md"
FLAG_FILE="${AUTO_DIR}/inbox-needs-processing"
AGENT_PREFS="${AUTO_DIR}/inbox-agent-prefs.yaml"
MAX_AGE_WARN=3  # jours avant alerte "stale"

# ── Fonctions ─────────────────────────────────────────────────────────────
log()     { $VERBOSE && echo -e "${CYAN}[inbox-scan]${NC} $*" >&2 || true; }
logwarn() { echo -e "${YELLOW}[inbox-scan] ⚠${NC} $*" >&2; }
logok()   { echo -e "${GREEN}[inbox-scan] ✓${NC} $*"; }

# ── Vérifications ─────────────────────────────────────────────────────────
if [[ ! -d "$INBOX_DIR" ]]; then
  logwarn "Inbox non trouvée: $INBOX_DIR"
  exit 0
fi

mkdir -p "$AUTO_DIR"

# ── Charger les préférences d'agent (ou créer les défauts) ────────────────
if [[ ! -f "$AGENT_PREFS" ]]; then
  cat > "$AGENT_PREFS" << 'PREFS'
# Préférences d'agent IPCRAE pour le traitement Inbox
# Format: folder_name: agent_name
default_agent: claude
folder_agents:
  "infos à traiter": claude
  idees: claude
  taches: claude
  liens: claude
  projets-entrants: claude
  media: claude
  snippets: claude
  demandes-brutes: claude
PREFS
  log "Fichier de préférences créé: $AGENT_PREFS"
fi

# Lire l'agent par défaut depuis les préfs
DEFAULT_AGENT=$(grep '^default_agent:' "$AGENT_PREFS" 2>/dev/null | awk '{print $2}' || echo "claude")

# ── Scan de l'Inbox ───────────────────────────────────────────────────────
declare -A PENDING_BY_FOLDER
TOTAL_PENDING=0
SCAN_DATE=$(date +%Y-%m-%d\ %H:%M:%S)

log "Scan de $INBOX_DIR..."

while IFS= read -r -d '' folder; do
  folder_name=$(basename "$folder")

  # Ignorer les dossiers de traitement
  [[ "$folder_name" == "traites" ]] && continue

  # Compter les fichiers non traités
  pending_count=0
  pending_files=()
  stale_count=0

  while IFS= read -r -d '' f; do
    fname=$(basename "$f")
    # Ignorer README.md et fichiers dans traites/
    [[ "$fname" == "README.md" ]] && continue
    [[ "$f" == */traites/* ]] && continue

    pending_files+=("$f")
    ((pending_count++)) || true

    # Vérifier l'âge du fichier
    if [[ -n "$(find "$f" -mtime +"$MAX_AGE_WARN" 2>/dev/null)" ]]; then
      ((stale_count++)) || true
    fi
  done < <(find "$folder" -maxdepth 1 -name "*.md" -type f -print0 2>/dev/null)

  if [[ $pending_count -gt 0 ]]; then
    PENDING_BY_FOLDER["$folder_name"]="$pending_count"
    ((TOTAL_PENDING += pending_count)) || true

    if $VERBOSE; then
      log "  📁 $folder_name: $pending_count fichier(s)"
      [[ $stale_count -gt 0 ]] && logwarn "     $stale_count fichier(s) > ${MAX_AGE_WARN}j"
    fi
  fi
done < <(find "$INBOX_DIR" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)

# ── Traitement du résultat ────────────────────────────────────────────────
if [[ $TOTAL_PENDING -eq 0 ]]; then
  log "Inbox propre — aucun fichier en attente"
  # Nettoyer les fichiers de flag si plus rien en attente
  [[ -f "$FLAG_FILE" ]] && rm -f "$FLAG_FILE" "$PENDING_FILE"
  exit 0
fi

# ── Générer le rapport inbox-pending.md ───────────────────────────────────
if ! $DRY_RUN; then
  {
    echo "# Inbox Pending — Rapport de scan"
    echo ""
    echo "**Généré** : $SCAN_DATE"
    echo "**Total** : $TOTAL_PENDING fichier(s) en attente"
    echo "**Agent recommandé** : $DEFAULT_AGENT"
    echo ""
    echo "## Fichiers par sous-dossier"
    echo ""

    for folder_name in "${!PENDING_BY_FOLDER[@]}"; do
      count="${PENDING_BY_FOLDER[$folder_name]}"
      # Lire agent spécifique depuis prefs si disponible
      agent=$(grep -A 20 'folder_agents:' "$AGENT_PREFS" 2>/dev/null \
        | grep "\"$folder_name\"\|^  ${folder_name}:" \
        | awk '{print $NF}' | head -1 || echo "$DEFAULT_AGENT")
      [[ -z "$agent" ]] && agent="$DEFAULT_AGENT"

      echo "### 📁 $folder_name ($count fichier(s))"
      echo "**Agent** : \`$agent\`"
      echo ""

      while IFS= read -r -d '' f; do
        fname=$(basename "$f")
        [[ "$fname" == "README.md" ]] && continue
        [[ "$f" == */traites/* ]] && continue
        age_days=$(( ( $(date +%s) - $(stat -c %Y "$f" 2>/dev/null || echo 0) ) / 86400 ))
        stale=""
        [[ $age_days -gt $MAX_AGE_WARN ]] && stale=" ⚠ ${age_days}j"
        echo "- \`$fname\`${stale}"
      done < <(find "${INBOX_DIR}/${folder_name}" -maxdepth 1 -name "*.md" -type f -print0 2>/dev/null)

      echo ""
    done

    echo "## Instructions pour l'agent"
    echo ""
    echo "Traiter chaque fichier selon \`Process/inbox-scan.md\`."
    echo "Commande : \`ipcrae inbox scan\` (quand implémenté)"
    echo ""
    echo "---"
    echo "*Généré par ipcrae-inbox-scan — ne pas éditer manuellement*"
  } > "$PENDING_FILE"

  # Créer le flag
  echo "$SCAN_DATE" > "$FLAG_FILE"

  log "Rapport écrit: $PENDING_FILE"
  log "Flag créé: $FLAG_FILE"
fi

# ── Affichage résumé ──────────────────────────────────────────────────────
echo -e "${YELLOW}📥 Inbox: $TOTAL_PENDING fichier(s) en attente${NC}"
for folder_name in "${!PENDING_BY_FOLDER[@]}"; do
  count="${PENDING_BY_FOLDER[$folder_name]}"
  echo -e "   ${BLUE}→${NC} ${folder_name}: ${count} fichier(s)"
done
echo -e "${CYAN}   Rapport: $PENDING_FILE${NC}"

exit 1
