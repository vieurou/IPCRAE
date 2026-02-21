#!/bin/bash
# Commande IPCRAE pour le mode auto-amélioration

# Résolution du répertoire d'installation (fonctionne depuis ~/bin comme depuis scripts/)
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IPCRAE_AUTO_CORE="${SELF_DIR}/ipcrae-auto-core"

# Vérification que ipcrae-auto-core est disponible
if [ ! -x "$IPCRAE_AUTO_CORE" ]; then
  echo "Erreur: ipcrae-auto-core introuvable ou non exécutable dans $SELF_DIR" >&2
  exit 1
fi

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonction pour afficher l'aide
print_help() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Commandes IPCRAE - Mode Auto-Amélioration${NC}"
    echo -e "${CYAN}========================================${NC}\n"
    echo -e "${BLUE}Commandes disponibles:${NC}"
    echo -e "\n${BLUE}1. Activation du mode:${NC}"
    echo -e "   ipcrae auto-activate [agent] [frequence]"
    echo -e "   Exemple: ipcrae auto-activate --agent claude --frequency quotidien"
    echo -e "\n${BLUE}2. Désactivation du mode:${NC}"
    echo -e "   ipcrae auto-deactivate [agent]"
    echo -e "   Exemple: ipcrae auto-deactivate --agent claude"
    echo -e "\n${BLUE}3. Vérifier l'état du mode:${NC}"
    echo -e "   ipcrae auto-status [agent]"
    echo -e "   Exemple: ipcrae auto-status --agent claude"
    echo -e "\n${BLUE}4. Voir l'historique des audits:${NC}"
    echo -e "   ipcrae auto-history [agent]"
    echo -e "   Exemple: ipcrae auto-history --agent claude"
    echo -e "\n${BLUE}5. Générer un rapport:${NC}"
    echo -e "   ipcrae auto-report [agent]"
    echo -e "   Exemple: ipcrae auto-report --agent claude"
    echo -e "\n${BLUE}6. Lancer un audit manuel:${NC}"
    echo -e "   ipcrae auto-audit [agent] [frequence] [verbose]"
    echo -e "   Exemple: ipcrae auto-audit --agent claude --verbose"
    echo -e "\n${CYAN}========================================${NC}\n"
}

# Fonction pour activer le mode
activate_mode() {
    local agent="claude"
    local frequency="quotidien"

    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --agent)
                agent="$2"
                shift 2
                ;;
            --frequency)
                frequency="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Activation du Mode Auto-Amélioration${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${BLUE}Agent:${NC} $agent"
    echo -e "${BLUE}Fréquence:${NC} $frequency"
    echo -e "${BLUE}Date:${NC} $(date -Iseconds)\n"

    # Activer le mode
    "$IPCRAE_AUTO_CORE" activate --agent "$agent" --frequency "$frequency"

    echo -e "\n${GREEN}✓ Mode auto-amélioration activé pour $agent${NC}\n"
    echo -e "${BLUE}Informations importantes:${NC}"
    echo -e "  - L'agent s'auto-évaluera selon la fréquence définie"
    echo -e "  - Les corrections seront appliquées automatiquement"
    echo -e "  - Vous pouvez désactiver le mode à tout moment avec: ipcrae auto-deactivate --agent $agent"
    echo -e "  - Vous pouvez voir l'historique avec: ipcrae auto-history --agent $agent\n"
}

# Fonction pour désactiver le mode
deactivate_mode() {
    local agent="claude"

    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --agent)
                agent="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Désactivation du Mode Auto-Amélioration${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${BLUE}Agent:${NC} $agent"
    echo -e "${BLUE}Date:${NC} $(date -Iseconds)\n"

    # Désactiver le mode
    "$IPCRAE_AUTO_CORE" deactivate --agent "$agent"

    echo -e "\n${GREEN}✓ Mode auto-amélioration désactivé pour $agent${NC}\n"
    echo -e "${BLUE}Informations importantes:${NC}"
    echo -e "  - L'agent ne s'auto-évaluera plus automatiquement"
    echo -e "  - Vous pouvez réactiver le mode à tout moment avec: ipcrae auto-activate --agent $agent\n"
}

# Fonction pour vérifier l'état
check_status() {
    local agent="claude"

    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --agent)
                agent="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}État du Mode Auto-Amélioration${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${BLUE}Agent:${NC} $agent"
    echo -e "${BLUE}Date:${NC} $(date -Iseconds)\n"

    # Vérifier l'état
    "$IPCRAE_AUTO_CORE" status --agent "$agent"
}

# Fonction pour voir l'historique
show_history() {
    local agent="claude"

    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --agent)
                agent="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Historique des Audits - $agent${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    # Voir l'historique
    "$IPCRAE_AUTO_CORE" history --agent "$agent"
}

# Fonction pour générer un rapport
generate_report() {
    local agent="claude"

    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --agent)
                agent="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Rapport d'Auto-Amélioration - $agent${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${BLUE}Date du rapport:${NC} $(date -Iseconds)\n"

    # Générer le rapport
    "$IPCRAE_AUTO_CORE" report --agent "$agent"
}

# Fonction principale
main() {
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        auto-activate)
            activate_mode "${@:2}"
            ;;
        auto-deactivate)
            deactivate_mode "${@:2}"
            ;;
        auto-status)
            check_status "${@:2}"
            ;;
        auto-history)
            show_history "${@:2}"
            ;;
        auto-report)
            generate_report "${@:2}"
            ;;
        auto-audit)
            "$IPCRAE_AUTO_CORE" "${@:2}"
            ;;
        *)
            print_help
            exit 1
            ;;
    esac
}

# Exécuter la fonction principale
main "$@"
