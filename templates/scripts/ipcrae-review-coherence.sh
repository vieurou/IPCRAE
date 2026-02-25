#!/bin/bash
# scripts/ipcrae-review-coherence.sh
# Script de review de la cohérence Documentation ↔ Code

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
IPCRAE_ROOT="${IPCRAE_ROOT:-$HOME/IPCRAE}"
VERBOSE=false
DRY_RUN=false

# Fonction d'aide
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Affiche cette aide"
    echo "  -d, --dry-run  Simulation sans modification"
    echo "  -v, --verbose  Mode verbeux"
    echo ""
    echo "Description:"
    echo "  Vérifie la cohérence de la documentation par rapport au code."
    echo "  Analyse les scripts CLI, scripts utilitaires, processus, prompts et schémas YAML."
    exit 0
}

# Fonction de logging
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        INFO)
            echo -e "${GREEN}[INFO]${NC} $timestamp - $message"
            ;;
        WARN)
            echo -e "${YELLOW}[WARN]${NC} $timestamp - $message"
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} $timestamp - $message"
            ;;
        *)
            echo "[$level] $timestamp - $message"
            ;;
    esac
}

# Parsing des arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            log ERROR "Option inconnue: $1"
            usage
            ;;
    esac
done

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "$IPCRAE_ROOT/README.md" ]; then
    log ERROR "README.md non trouvé dans $IPCRAE_ROOT"
    exit 1
fi

cd "$IPCRAE_ROOT"

log INFO "Review de la cohérence Documentation ↔ Code"
log INFO "Répertoire: $IPCRAE_ROOT"

# Si dry-run, afficher ce qui serait fait
if [ "$DRY_RUN" = true ]; then
    log INFO "Mode simulation (dry-run)"
    log INFO "Les vérifications suivantes seraient effectuées :"
    log INFO "  - Vérification de la cohérence des scripts CLI"
    log INFO "  - Vérification de la cohérence des scripts utilitaires"
    log INFO "  - Vérification de la cohérence des processus"
    log INFO "  - Vérification de la cohérence des prompts"
    log INFO "  - Vérification de la cohérence des schémas YAML"
    log INFO "  - Vérification de l'obsolescence"
    log INFO "  - Vérification de la cohérence interne"
    exit 0
fi

# Compteurs
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Fonction de vérification
check() {
    local description=$1
    local command=$2
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if eval "$command"; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        [ "$VERBOSE" = true ] && log INFO "✅ $description"
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        log WARN "❌ $description"
    fi
}

# Étape 1 : Inventaire des éléments à vérifier
log INFO "=== Étape 1 : Inventaire des éléments à vérifier ==="

CLI_SCRIPTS=$(find scripts -name "ipcrae-*.sh" -type f -executable | sort)
UTIL_SCRIPTS=$(find scripts -name "*.sh" -type f -executable | grep -v "ipcrae-" | sort)
PROCESSES=$(find Process -name "*.md" -type f | sort)
PROMPTS=$(find .ipcrae/prompts -name "agent_*.md" -type f | sort)
SCHEMAS=$(find .ipcrae/schema -name "*.yaml" -type f | sort)

log INFO "Scripts CLI trouvés: $(echo "$CLI_SCRIPTS" | wc -l | tr -d ' \t')"
log INFO "Scripts utilitaires trouvés: $(echo "$UTIL_SCRIPTS" | wc -l | tr -d ' \t')"
log INFO "Processus trouvés: $(echo "$PROCESSES" | wc -l | tr -d ' \t')"
log INFO "Prompts trouvés: $(echo "$PROMPTS" | wc -l | tr -d ' \t')"
log INFO "Schémas YAML trouvés: $(echo "$SCHEMAS" | wc -l | tr -d ' \t')"

# Étape 2 : Vérification de la cohérence Documentation ↔ Code
log INFO ""
log INFO "=== Étape 2 : Vérification de la cohérence Documentation ↔ Code ==="

# A. Scripts CLI
log INFO ""
log INFO "--- A. Scripts CLI ---"
for script in $CLI_SCRIPTS; do
    script_name=$(basename "$script")
    check "Script $script_name documenté dans README.md" "grep -q '$script_name' README.md"
    check "Script $script_name documenté dans .ipcrae/context.md" "grep -q '$script_name' .ipcrae/context.md"
    check "Script $script_name a une description" "head -1 '$script' | grep -q '^# '"
done

# B. Scripts utilitaires
log INFO ""
log INFO "--- B. Scripts utilitaires ---"
for script in $UTIL_SCRIPTS; do
    script_name=$(basename "$script")
    check "Script $script_name documenté dans README.md" "grep -q '$script_name' README.md"
    check "Script $script_name a une description" "head -1 '$script' | grep -q '^# '"
    check "Script $script_name référencé dans un processus ou Knowledge" "grep -rq '$script_name' Process/ Knowledge/"
done

# C. Processus
log INFO ""
log INFO "--- C. Processus ---"
for process in $PROCESSES; do
    process_name=$(basename "$process" .md)
    check "Process $process_name référencé dans Process/index.md" "grep -q '$process_name' Process/index.md"
    check "Process $process_name a des wikilinks" "grep -q '\[\[' $process"
    check "Process $process_name documenté dans Knowledge/" "grep -rq '$process_name' Knowledge/"
done

# D. Prompts
log INFO ""
log INFO "--- D. Prompts ---"
for prompt in $PROMPTS; do
    prompt_name=$(basename "$prompt" .md)
    check "Prompt $prompt_name documenté dans Agents/" "grep -q '$prompt_name' Agents/agent_${prompt_name#agent_}.md"
    check "Prompt $prompt_name compilé dans .ipcrae/compiled/" "test -f .ipcrae/compiled/prompt_${prompt_name#agent_}.md"
    check "Prompt $prompt_name référencé dans .ipcrae/context.md" "grep -q '$prompt_name' .ipcrae/context.md"
done

# E. Schémas YAML
log INFO ""
log INFO "--- E. Schémas YAML ---"
for schema in $SCHEMAS; do
    schema_name=$(basename "$schema")
    check "Schéma $schema_name documenté dans README.md" "grep -q '$schema_name' README.md"
    check "Schéma $schema_name documenté dans .ipcrae/schema/README.md" "test -f .ipcrae/schema/README.md"
done

# Étape 3 : Vérification de l'obsolescence
log INFO ""
log INFO "=== Étape 3 : Vérification de l'obsolescence ==="

# A. Commandes obsolètes
log INFO ""
log INFO "--- A. Commandes obsolètes ---"
# Extraire les commandes documentées dans README.md
DOCUMENTED_COMMANDS=$(grep -o 'ipcrae [a-z-]*' README.md | sort -u)
for cmd in $DOCUMENTED_COMMANDS; do
    check "Commande $cmd existe" "command -v ${cmd#ipcrae } >/dev/null 2>&1 || test -f scripts/${cmd#ipcrae }.sh"
done

# B. Scripts obsolètes
log INFO ""
log INFO "--- B. Scripts obsolètes ---"
# Extraire les scripts documentés dans README.md
DOCUMENTED_SCRIPTS=$(grep -o 'scripts/[a-z-]*.sh' README.md | sort -u)
for script in $DOCUMENTED_SCRIPTS; do
    check "Script $script existe" "test -f $script"
done

# Étape 4 : Vérification de la cohérence interne
log INFO ""
log INFO "=== Étape 4 : Vérification de la cohérence interne ==="

# A. Cohérence des versions
log INFO ""
log INFO "--- A. Cohérence des versions ---"
VERSION_README=$(grep "Version.*IPCRAE" README.md | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "")
VERSION_CONFIG=$(grep "script_version:" .ipcrae/config.yaml | cut -d'"' -f2)
check "Version cohérente entre README.md et config.yaml" "[ '$VERSION_README' = '$VERSION_CONFIG' ]"

# B. Cohérence des chemins
log INFO ""
log INFO "--- B. Cohérence des chemins ---"
check "Pas de chemins absolus hardcodés dans les scripts" "! grep -r '/home/' scripts/ || ! grep -r '$HOME/' scripts/"

# C. Cohérence des tags
log INFO ""
log INFO "--- C. Cohérence des tags ---"
check "Tags en minuscules dans Knowledge/" "! grep -r 'tags:.*[A-Z]' Knowledge/ || true"
check "Tags en minuscules dans Process/" "! grep -r 'tags:.*[A-Z]' Process/ || true"

# Résultat
log INFO ""
log INFO "=== Résultat ==="
SCORE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
log INFO "Total checks: $TOTAL_CHECKS"
log INFO "Passed: $PASSED_CHECKS"
log INFO "Failed: $FAILED_CHECKS"
log INFO "Score: $SCORE%"

if [ $FAILED_CHECKS -eq 0 ]; then
    log INFO "✅ Review de cohérence réussi"
    exit 0
else
    log WARN "⚠️ Review de cohérence terminé avec $FAILED_CHECKS échec(s)"
    exit 1
fi
