#!/bin/bash

# IPCRAE Audit Check
#
# Scanne le vault IPCRAE et retourne un score de santé.
# Process: Process/auto-amelioration.md

set -euo pipefail

# --- Variables & Constantes ---
if [[ -z "${IPCRAE_ROOT:-}" ]]; then
  IPCRAE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

SCORE=0
MAX_SCORE=0

# Couleurs
C_GREEN="\033[0;32m"
C_RED="\033[0;31m"
C_YELLOW="\033[0;33m"
C_BLUE="\033[0;34m"
C_RESET="\033[0m"

# --- Fonctions de Check ---

# $1: Message
# $2: Commande à évaluer (doit retourner 0 pour succès)
# $3: Points pour le succès
check() {
  local msg="$1"
  local cmd="$2"
  local points="$3"
  
  ((MAX_SCORE+=points))
  
  echo -n -e "${C_BLUE}CHECK:${C_RESET} $msg... "
  if eval "$cmd" &>/dev/null; then
    echo -e "${C_GREEN}✓ OK${C_RESET}"
    ((SCORE+=points))
  else
    echo -e "${C_RED}✗ FAIL${C_RESET}"
  fi
}

# --- Exécution des Checks ---

echo "--- Audit du Vault IPCRAE ---"

# 1. Santé Git
check "Aucun fichier non commité" "! (cd "${IPCRAE_ROOT}" && git status --porcelain | grep -q .)" 5
check "Branche 'main' à jour avec l'origine" "! (cd "${IPCRAE_ROOT}" && git fetch --quiet && git log HEAD..origin/main | grep -q .)" 3

# 2. Santé de l'Inbox
check "Inbox/demandes-brutes est vide" "[ \$(find "${IPCRAE_ROOT}/Inbox/demandes-brutes" -type f ! -name 'README.md' ! -path '*/traites/*' | wc -l) -eq 0 ]" 5
check "Inbox/ Zettelkasten est vide" "[ \$(find "${IPCRAE_ROOT}/Zettelkasten/_inbox" -type f | wc -l) -eq 0 ]" 5

# 3. Santé du Journal
check "Note journalière du jour existe" "[ -f "${IPCRAE_ROOT}/Journal/Daily/$(date +%Y)/$(date +%Y-%m-%d).md" ]" 5

# 4. Santé du Cache
check "L'index des tags est récent (< 24h)" "[ \$(find "${IPCRAE_ROOT}/.ipcrae/cache/tag-index.json" -mtime -1 | wc -l) -eq 1 ]" 2

# --- Résultat ---
echo "---------------------------"
if [ "$SCORE" -eq "$MAX_SCORE" ]; then
    echo -e "Résultat: ${C_GREEN}Excellent${C_RESET}"
else
    echo -e "Résultat: ${C_YELLOW}Gaps détectés${C_RESET}"
fi

echo "Score: ${SCORE}/${MAX_SCORE}"
echo "---------------------------"

if [ "$SCORE" -lt "$MAX_SCORE" ]; then
  exit 1
else
  exit 0
fi