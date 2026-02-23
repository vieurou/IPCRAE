#!/usr/bin/env bash
# ipcrae-agent-bootstrap — Bannière règles critiques IPCRAE + log session
# Usage:
#   ipcrae-agent-bootstrap [--auto] [--project <slug>] [--domain <domaine>]
#
# Mode --auto  : non-interactif (log + bannière seulement)
# Mode défaut  : affiche bannière + attend la saisie "IPCRAE:VALIDATED"

set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
AUTO=false
PROJECT=""
DOMAIN=""

# --- Parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --auto)              AUTO=true ;;
    --project)           PROJECT="${2:-}"; shift ;;
    --domain)            DOMAIN="${2:-}" ; shift ;;
    *)                   ;;
  esac
  shift
done

# --- Couleurs ---
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Bannière règles critiques ---
show_banner() {
  echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${CYAN}  IPCRAE — Règles Agent (bootstrap)${NC}"
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  echo -e "\n${BOLD}${RED}🔴 RÈGLES CRITIQUES — NON NÉGOCIABLES${NC}"

  echo -e "\n  ${BOLD}Tags frontmatter${NC}"
  echo -e "    ${GREEN}✅ TOUJOURS${NC} minuscules : \`tags: [devops, bash, ipcrae]\`"
  echo -e "    ${RED}❌ JAMAIS${NC}   majuscules : \`tags: [DevOps, Bash]\`"

  echo -e "\n  ${BOLD}Workflow GTD — capture${NC}"
  echo -e "    ${GREEN}✅ TOUJOURS${NC} nouvelles notes → \`Inbox/\` ou \`Zettelkasten/_inbox/\`"
  echo -e "    ${RED}❌ JAMAIS${NC}   créer directement dans \`Zettelkasten/permanents/\`"

  echo -e "\n  ${BOLD}Pattern grep en bash${NC}"
  echo -e "    ${GREEN}✅ TOUJOURS${NC} : \`grep \"pattern\" | wc -l | tr -d ' \\t'\`"
  echo -e "    ${RED}❌ JAMAIS${NC}   : \`grep -c pattern || echo 0\` (produit \"0\\n0\")"

  echo -e "\n${BOLD}${YELLOW}🟠 RÈGLES OBLIGATOIRES${NC}"

  echo -e "\n  ${BOLD}3 fichiers à mettre à jour en fin de session${NC}"
  echo -e "    1. \`memory/<domaine>.md\`  — décisions datées \`### YYYY-MM-DD — titre\`"
  echo -e "    2. \`Projets/<slug>/tracking.md\`  — tâches cochées \`[x]\`"
  echo -e "    3. \`Journal/Daily/<YYYY>/<YYYY-MM-DD>.md\`  — session documentée"

  echo -e "\n  ${BOLD}Clôture session${NC}"
  echo -e "    Toujours : \`ipcrae close <domaine> --project <slug>\`"
  echo -e "    Fallback  : \`git -C \$IPCRAE_ROOT add -A && git commit\`"

  echo -e "\n${BOLD}${CYAN}🟡 RÈGLES IMPORTANTES${NC}"
  echo -e "    • Chargement sélectif : lire \`session-context.md\` en premier si présent"
  echo -e "    • Knowledge notes : créer une note pour tout pattern réutilisable découvert"
  echo -e "    • Recherche par tags : \`ipcrae tag <tag>\` avant de parcourir les dossiers"

  echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# --- Log session ---
write_log() {
  local log_dir="${IPCRAE_ROOT}/.ipcrae/auto"
  local log_file="${log_dir}/bootstrap-log.txt"
  mkdir -p "$log_dir"
  local ts
  ts=$(date '+%Y-%m-%d %H:%M:%S')
  local mode="interactive"
  [[ "$AUTO" == "true" ]] && mode="auto"
  printf '%s | project=%s | domain=%s | mode=%s\n' \
    "$ts" "${PROJECT:-unset}" "${DOMAIN:-unset}" "$mode" >> "$log_file"
}

# --- Main ---
show_banner
write_log

if [[ "$AUTO" == "true" ]]; then
  echo -e "${GREEN}[bootstrap] Session loggée (mode auto) — règles chargées.${NC}\n"
  exit 0
fi

# Mode interactif : attendre confirmation
echo -e "${BOLD}Pour confirmer la prise en compte des règles, taper :${NC}"
echo -e "  ${CYAN}IPCRAE:VALIDATED${NC}"
echo ""

read -r -p "> " input
if [[ "$input" == "IPCRAE:VALIDATED" ]]; then
  echo -e "${GREEN}✓ Contexte validé — session démarrée.${NC}\n"
  exit 0
else
  echo -e "${YELLOW}⚠ Confirmation non reçue (\"${input}\") — session loggée quand même.${NC}\n"
  exit 0
fi
