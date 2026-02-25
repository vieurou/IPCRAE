#!/bin/bash

# IPCRAE Inbox Scanner
#
# Scanne et traite les fichiers de l'inbox selon le processus défini.
# Process: Process/inbox-scan.md

set -euo pipefail
# set -x # Décommenter pour le debug

# --- Variables & Constantes ---
# Assurer que IPCRAE_ROOT est défini, sinon utiliser le parent du script
if [[ -z "${IPCRAE_ROOT:-}" ]]; then
  IPCRAE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
  echo "WARN: IPCRAE_ROOT non défini. Utilisation de: ${IPCRAE_ROOT}" >&2
fi

INBOX_PATH="${IPCRAE_ROOT}/Inbox"
ARCHIVE_SUBDIR="traites"
DATE_FORMAT=$(date +%Y-%m-%d)

# Couleurs pour les logs
C_BLUE="\033[0;34m"
C_GREEN="\033[0;32m"
C_YELLOW="\033[0;33m"
C_RED="\033[0;31m"
C_RESET="\033[0m"

# --- Fonctions ---

log_info() {
  echo -e "${C_BLUE}INFO: $1${C_RESET}"
}

log_success() {
  echo -e "${C_GREEN}SUCCESS: $1${C_RESET}"
}

log_warn() {
  echo -e "${C_YELLOW}WARN: $1${C_RESET}"
}

log_error() {
  echo -e "${C_RED}ERROR: $1${C_RESET}" >&2
  exit 1
}

show_help() {
  cat << EOF
Utilisation: $(basename "$0") [--folder <nom>] [--dry-run] [--domain <domaine>]
Scan et traitement automatique de l'Inbox IPCRAE.

Options:
  --folder <nom>    Limite le scan à un sous-dossier de l'Inbox (ex: 'demandes-brutes').
  --domain <domaine> Force le domaine pour l'analyse des fichiers.
  --dry-run         Affiche le plan de traitement sans exécuter les actions.
  -h, --help        Affiche cette aide.
EOF
}

# --- Parsing des Arguments ---
FOLDER_FILTER=""
DRY_RUN=0
FORCED_DOMAIN=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --folder)
      FOLDER_FILTER="$2"
      shift 2
      ;;
    --domain)
      FORCED_DOMAIN="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      log_error "Argument non reconnu: $1"
      ;;
  esac
done

# --- Logique Principale ---

log_info "Lancement du scan de l'Inbox..."
if [[ ${DRY_RUN} -eq 1 ]]; then
  log_warn "Mode --dry-run activé. Aucune modification ne sera effectuée."
fi

# Étape 0: Inventaire
shopt -s nullglob # Ne pas échouer si aucun fichier n'est trouvé
folders_to_scan=()
if [[ -n "${FOLDER_FILTER}" ]]; then
    if [[ -d "${INBOX_PATH}/${FOLDER_FILTER}" ]]; then
        folders_to_scan=("${INBOX_PATH}/${FOLDER_FILTER}")
    else
        log_error "Le dossier spécifié n'existe pas: ${INBOX_PATH}/${FOLDER_FILTER}"
    fi
else
    # Exclure les répertoires qui commencent par '_' ou qui sont des archives
    mapfile -d '' folders_to_scan < <(find "${INBOX_PATH}" -mindepth 1 -maxdepth 1 -type d ! -name "_*" ! -name "${ARCHIVE_SUBDIR}" ! -path "*/${ARCHIVE_SUBDIR}" -print0)
fi

if [[ ${#folders_to_scan[@]} -eq 0 ]]; then
    log_success "Aucun dossier à scanner dans l'Inbox. Terminé."
    exit 0
fi

log_info "Dossiers à scanner: ${folders_to_scan[*]}"

files_to_process=()
for folder in "${folders_to_scan[@]}"; do
    # find ... -print0 | sort -z | while read -d '' ...
    # Est plus robuste pour les noms de fichiers avec espaces
    while IFS= read -r -d '' file; do
        files_to_process+=("$file")
    done < <(find "$folder" -type f -name "*.md" ! -name "README.md" -print0 | sort -z)
done

if [[ ${#files_to_process[@]} -eq 0 ]]; then
  log_success "Aucun fichier à traiter dans l'Inbox. Terminé."
  exit 0
fi

log_info "Trouvé ${#files_to_process[@]} fichier(s) à traiter."

# Étape 1 & 2: Analyse et Traitement
for file_path in "${files_to_process[@]}"; do
    log_info "--- Traitement de: $(basename "$file_path") ---"

    #
    # !!! POINT D'APPEL A L'IA !!!
    # Ici, on appellerait l'agent IA pour analyser le contenu.
    # L'agent déterminerait le type, le domaine, et la destination.
    #
    # Exemple de prompt pour l'agent:
    # "Analyse ce contenu et retourne un JSON avec: {type: '...', domaine: '...', destination_path: '...', action: '...'}"
    #
    
    # Pour ce script, nous simulons la réponse de l'IA basée sur le nom du fichier.
    # Ceci est une SIMULATION et devra être remplacé par un appel réel.
    
    ACTION_PLAN="ARCHIVE" # Action par défaut
    DESTINATION_COMMENT="Action non définie (simulation)"

    if [[ $(basename "$file_path") == *knowledge* ]]; then
        ACTION_PLAN="KNOWLEDGE"
        DESTINATION_COMMENT="Déplacé vers Knowledge/howto/"
    elif [[ $(basename "$file_path") == *tache* ]]; then
        ACTION_PLAN="TASK"
        DESTINATION_COMMENT="Ajouté à Projets/IPCRAE/tracking.md"
    fi

    log_info "Plan d'action détecté (simulation): ${ACTION_PLAN}"

    # Étape 4: Archivage (et autres actions)
    archive_dir="$(dirname "$file_path")/${ARCHIVE_SUBDIR}"
    archive_filename="${DATE_FORMAT}-$(basename "$file_path")"
    archive_path="${archive_dir}/${archive_filename}"

    if [[ ${DRY_RUN} -eq 1 ]]; then
        log_warn "[DRY-RUN] Fichier '${file_path}' serait traité."
        log_warn "[DRY-RUN] Action: ${ACTION_PLAN}"
        log_warn "[DRY-RUN] Serait archivé dans: ${archive_path}"
    else
        log_info "Exécution de l'action: ${ACTION_PLAN}"
        
        # Créer le dossier d'archive si nécessaire
        mkdir -p "$archive_dir"

        # Ajouter la note de traitement avant de déplacer
        echo -e "\n<!-- traité: ${DATE_FORMAT} → ${DESTINATION_COMMENT} -->" >> "$file_path"
        
        # Déplacer le fichier
        mv "$file_path" "$archive_path"
        log_success "Fichier archivé dans: ${archive_path}"
    fi
done

# Étape 5: Commit vault
if [[ ${DRY_RUN} -eq 0 ]]; then
    log_info "Commit des changements dans le vault..."
    if git -C "${IPCRAE_ROOT}" status --porcelain | grep -qE '^( M| A| D| R| C)'; then
        git -C "${IPCRAE_ROOT}" add -A
        git -C "${IPCRAE_ROOT}" commit -m "feat(inbox): scan et traitement automatique du ${DATE_FORMAT}"
        log_success "Vault commité avec succès."
    else
        log_info "Aucun changement à commiter."
    fi
else
    log_warn "[DRY-RUN] Un commit aurait été créé."
fi

log_success "Scan de l'Inbox terminé."