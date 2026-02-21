#!/bin/bash
# Auto-Audit IPCRAE - Script principal pour le mode auto-amélioration

# Résolution du répertoire d'installation
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IPCRAE_AUDIT_CHECK="${SELF_DIR}/ipcrae-audit-check"
IPCRAE_AUTO_APPLY="${SELF_DIR}/ipcrae-auto-apply"

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
AGENT="kilo-code"
FREQUENCY="quotidien"
VERBOSE="false"
FORCE="false"

# Parser les arguments
COMMAND=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent)
            AGENT="$2"
            shift 2
            ;;
        --frequency)
            FREQUENCY="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE="true"
            shift
            ;;
        --force)
            FORCE="true"
            shift
            ;;
        -h|--help)
            COMMAND="--help"
            shift
            ;;
        status|activate|deactivate|history|report)
            COMMAND="$1"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Répertoire d'état (dans le vault IPCRAE, jamais dans le repo DEV)
IPCRAE_AUTO_DIR="${IPCRAE_ROOT:-$HOME/IPCRAE}/.ipcrae/auto"
mkdir -p "$IPCRAE_AUTO_DIR"

# Fichiers de configuration
CONFIG_FILE="$IPCRAE_AUTO_DIR/agent_auto_amelioration_config.md"
HISTORY_FILE="$IPCRAE_AUTO_DIR/agent_auto_amelioration_history.md"
LAST_AUDIT_FILE="$IPCRAE_AUTO_DIR/last_audit_${AGENT}.txt"

# Fonction pour retirer les codes ANSI
strip_ansi() {
    sed -r 's/\x1B\[[0-9;]*[A-Za-z]//g'
}

# Fonction pour extraire le score global depuis une sortie d'audit
extract_score_from_output() {
    strip_ansi | grep -Eo 'Score Global: [0-9]+/[0-9]+' | tail -1 | awk '{print $3}'
}

# Fonction pour afficher l'en-tête
print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}Mode d'Auto-Amélioration IPCRAE${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

# Fonction pour afficher l'état
print_status() {
    echo -e "${BLUE}Agent:${NC} $AGENT"
    echo -e "${BLUE}Fréquence:${NC} $FREQUENCY"
    echo -e "${BLUE}Verbose:${NC} $VERBOSE"
}

# Fonction pour vérifier si le mode est activé
check_mode_active() {
    if [ ! -f "$LAST_AUDIT_FILE" ]; then
        echo -e "${YELLOW}⚠ Mode non activé pour l'agent $AGENT${NC}\n"
        echo -e "${YELLOW}Pour activer le mode, utilisez:${NC}"
        echo -e "  ipcrae auto-activate --agent $AGENT"
        return 1
    fi
    return 0
}

# Fonction pour vérifier si un nouvel audit est nécessaire
check_new_audit_needed() {
    # Si force est activé, on force l'audit
    if [ "$FORCE" = "true" ]; then
        return 0
    fi

    local last_audit=$(cat "$LAST_AUDIT_FILE" 2>/dev/null || echo "0")
    local current_time=$(date +%s)
    local interval=0

    case "$FREQUENCY" in
        quotidien)
            interval=86400  # 24 heures
            ;;
        hebdomadaire)
            interval=604800  # 7 jours
            ;;
        mensuel)
            interval=2592000  # 30 jours
            ;;
        *)
            interval=86400
            ;;
    esac

    if [ "$((current_time - last_audit))" -gt "$interval" ]; then
        return 0
    else
        echo -e "${YELLOW}⏳ Audit récent détecté. Dernier audit: $(date -d @$last_audit '+%Y-%m-%d %H:%M')${NC}\n"
        return 1
    fi
}

# Fonction pour lancer un audit
run_audit() {
    echo -e "${BLUE}📊 Lancement de l'audit IPCRAE...${NC}\n"

    local audit_output_file
    audit_output_file=$(mktemp)

    # Exécuter le script d'audit
    if [ "$VERBOSE" = "true" ]; then
        "$IPCRAE_AUDIT_CHECK" | tee "$audit_output_file"
    else
        "$IPCRAE_AUDIT_CHECK" | tee "$audit_output_file" | grep -E "^(📊|🔴|🟡|🟢|Score|Critiques|Importants|Mineurs|RECOMMANDATIONS)"
    fi

    # Sauvegarder le résultat
    local audit_score
    audit_score=$(extract_score_from_output < "$audit_output_file")
    audit_score=${audit_score:-0/40}
    local current_time=$(date +%s)

    echo "$current_time" > "$LAST_AUDIT_FILE"
    echo "$audit_score" > "$LAST_AUDIT_FILE.score"

    # Ajouter à l'historique
    if [ -f "$HISTORY_FILE" ]; then
        echo -e "\n--- Audit $(date -d @$current_time '+%Y-%m-%d %H:%M') ---" >> "$HISTORY_FILE"
        echo "Score Global: $audit_score" >> "$HISTORY_FILE"
    else
        echo -e "\n--- Audit $(date -d @$current_time '+%Y-%m-%d %H:%M') ---" > "$HISTORY_FILE"
        echo "Score Global: $audit_score" >> "$HISTORY_FILE"
    fi

    rm -f "$audit_output_file"

    echo -e "\n${GREEN}✓ Audit terminé et sauvegardé${NC}\n"
}

# Fonction pour appliquer les corrections
apply_corrections() {
    echo -e "${BLUE}🔧 Application des corrections...${NC}\n"

    # Appliquer les corrections critiques
    echo -e "${YELLOW}1. Corrections critiques...${NC}"
    "$IPCRAE_AUTO_APPLY"

    # Appliquer les corrections importantes
    echo -e "\n${YELLOW}2. Corrections importantes...${NC}"
    # Script spécifique pour les corrections importantes (à créer)

    # Appliquer les corrections mineures
    echo -e "\n${YELLOW}3. Corrections mineures...${NC}"
    # Script spécifique pour les corrections mineures (à créer)

    echo -e "\n${GREEN}✓ Corrections appliquées${NC}\n"
}

# Fonction pour générer un rapport
generate_report() {
    echo -e "${BLUE}📄 Génération du rapport d'auto-amélioration...${NC}\n"

    local last_audit=$(cat "$LAST_AUDIT_FILE" 2>/dev/null || echo "0")
    local last_audit_date=$(date -d @$last_audit '+%Y-%m-%d %H:%M')
    local current_time=$(date +%s)
    local interval=0

    case "$FREQUENCY" in
        quotidien)
            interval=86400
            ;;
        hebdomadaire)
            interval=604800
            ;;
        mensuel)
            interval=2592000
            ;;
        *)
            interval=86400
            ;;
    esac

    local days_since_last=$(( (current_time - last_audit) / 86400 ))

    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Rapport d'Auto-Amélioration - $AGENT${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo -e "${BLUE}Date du rapport:${NC} $(date -d @$current_time '+%Y-%m-%d %H:%M')"
    echo -e "${BLUE}Dernier audit:${NC} $last_audit_date"
    echo -e "${BLUE}Fréquence:${NC} $FREQUENCY"
    echo -e "${BLUE}Écarts depuis le dernier audit:${NC} $days_since_last jours"
    echo -e "${CYAN}========================================${NC}\n"

    # Afficher le score
    if [ -f "$LAST_AUDIT_FILE.score" ]; then
        local last_score=$(cat "$LAST_AUDIT_FILE.score")
        local current_score
        current_score=$("$IPCRAE_AUDIT_CHECK" 2>/dev/null | extract_score_from_output)
        current_score=${current_score:-0/40}

        echo -e "${BLUE}Score initial:${NC} $last_score"
        echo -e "${GREEN}Score actuel:${NC} $current_score"

        if [ "$last_score" != "0/40" ]; then
            local points=$(( $(echo "$current_score" | grep -oP '\d+' | head -1) - $(echo "$last_score" | grep -oP '\d+' | head -1) ))
            local percentage=$(( points * 100 / 40 ))
            echo -e "${GREEN}Amélioration:${NC} ${points} points (${percentage}%)"
        fi
    fi

    echo -e "\n${CYAN}========================================${NC}\n"
}

# Fonction pour afficher l'aide
print_help() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Mode d'Auto-Amélioration IPCRAE${NC}"
    echo -e "${CYAN}========================================${NC}\n"
    echo -e "${BLUE}Utilisation:${NC}"
    echo -e "  ipcrae auto-audit [agent] [frequence] [verbose]"
    echo -e "\n${BLUE}Arguments:${NC}"
    echo -e "  agent        Agent à auditer (par défaut: kilo-code)"
    echo -e "  frequence    Fréquence: quotidien, hebdomadaire, mensuel (par défaut: quotidien)"
    echo -e "  verbose      Afficher tous les détails (par défaut: false)"
    echo -e "\n${BLUE}Commandes:${NC}"
    echo -e "  auto-activate    Activer le mode pour un agent"
    echo -e "  auto-deactivate  Désactiver le mode pour un agent"
    echo -e "  auto-status      Vérifier l'état du mode"
    echo -e "  auto-history     Voir l'historique des audits"
    echo -e "  auto-report      Générer un rapport d'auto-amélioration"
    echo -e "\n${BLUE}Exemples:${NC}"
    echo -e "  ipcrae auto-audit"
    echo -e "  ipcrae auto-audit --agent claude"
    echo -e "  ipcrae auto-audit --agent codex --frequency hebdomadaire"
    echo -e "  ipcrae auto-audit --agent kilo-code --verbose"
    echo -e "\n${CYAN}========================================${NC}\n"
}

# Fonction principale
main() {
    print_header

    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        status)
            print_status
            check_mode_active
            if [ $? -eq 0 ]; then
                local last_audit=$(cat "$LAST_AUDIT_FILE" 2>/dev/null || echo "0")
                local last_audit_date=$(date -d @$last_audit '+%Y-%m-%d %H:%M')
                echo -e "\n${BLUE}Dernier audit:${NC} $last_audit_date"
            fi
            ;;
        activate)
            echo -e "${BLUE}Activation du mode auto-amélioration pour $AGENT...${NC}\n"
            date +%s > "$LAST_AUDIT_FILE"
            echo -e "${GREEN}✓ Mode activé pour $AGENT${NC}\n"
            echo -e "${BLUE}Prochain audit: $(date -d '+1 day' '+%Y-%m-%d')${NC}\n"
            ;;
        deactivate)
            echo -e "${BLUE}Désactivation du mode auto-amélioration pour $AGENT...${NC}\n"
            rm -f "$LAST_AUDIT_FILE" "$LAST_AUDIT_FILE.score"
            echo -e "${GREEN}✓ Mode désactivé pour $AGENT${NC}\n"
            ;;
        history)
            if [ -f "$HISTORY_FILE" ]; then
                echo -e "${CYAN}========================================${NC}"
                echo -e "${CYAN}Historique des Audits - $AGENT${NC}"
                echo -e "${CYAN}========================================${NC}\n"
                cat "$HISTORY_FILE"
            else
                echo -e "${YELLOW}Aucun historique disponible${NC}\n"
            fi
            ;;
        report)
            generate_report
            ;;
        *)
            # Mode auto-audit principal
            if ! check_mode_active; then
                exit 1
            fi

            if ! check_new_audit_needed; then
                echo -e "${YELLOW}⏳ Audit non nécessaire. Utilisez --force pour forcer l'audit.${NC}\n"
                exit 0
            fi

            # Exécuter le cycle d'auto-amélioration
            run_audit
            apply_corrections
            generate_report

            echo -e "${GREEN}✓ Cycle d'auto-amélioration terminé${NC}\n"
            echo -e "${BLUE}Prochain audit: $(date -d '+1 day' '+%Y-%m-%d')${NC}\n"
            ;;
    esac
}

# Exécuter la fonction principale
main "$COMMAND"
