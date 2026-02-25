#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${RED}⚠️  ATTENTION : Procédure de désinstallation complète d'IPCRAE ⚠️${NC}"
echo -e "Cette action va purger le cerveau global (IPCRAE) ainsi que tous les binaires IPCRAE de votre machine."
echo ""

IPCRAE_ROOT="${IPCRAE_ROOT:-$HOME/IPCRAE}"

echo -e "Chemin du cerveau cible : ${YELLOW}${IPCRAE_ROOT}${NC}"
echo -e "Limites de binaires   : ${YELLOW}$HOME/bin/ipcrae*${NC}"
echo ""

read -r -p "Voulez-vous vraiment TOUT DÉTRUIRE ? Tapez 'OUI' pour confirmer : " confirm

if [ "$confirm" != "OUI" ]; then
    echo "Annulation de la désinstallation."
    exit 0
fi

echo -e "\n${YELLOW}-> Suppression du cerveau global...${NC}"
if [ -d "$IPCRAE_ROOT" ]; then
    rm -rf "$IPCRAE_ROOT"
    echo -e "${GREEN}✓ Cerveau $IPCRAE_ROOT supprimé.${NC}"
else
    echo "Le cerveau n'existait pas à cet emplacement."
fi

echo -e "\n${YELLOW}-> Suppression des exécutables IPCRAE...${NC}"
rm -f "$HOME"/bin/ipcrae*
echo -e "${GREEN}✓ Binaires supprimés.${NC}"

echo -e "\n${GREEN}🎉 IPCRAE a été purgé de votre système avec succès.${NC}"
