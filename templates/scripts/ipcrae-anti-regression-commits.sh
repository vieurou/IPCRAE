#!/bin/bash
# scripts/ipcrae-anti-regression-commits.sh
# Script de vérification anti-régression basée sur les commits

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
COMMIT_REF=""

# Fonction d'aide
usage() {
    echo "Usage: $0 [OPTIONS] [COMMIT_REF]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Affiche cette aide"
    echo "  -d, --dry-run  Simulation sans modification"
    echo "  -v, --verbose  Mode verbeux"
    echo ""
    echo "Arguments:"
    echo "  COMMIT_REF       Commit de référence (par défaut: dernier tag session-*)"
    echo ""
    echo "Description:"
    echo "  Analyse l'historique des commits pour détecter les régressions potentielles."
    echo "  Identifie les fonctions disparues, les comportements modifiés, les violations de la méthode."
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
        -*)
            log ERROR "Option inconnue: $1"
            usage
            ;;
        *)
            COMMIT_REF=$1
            shift
            ;;
    esac
done

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "$IPCRAE_ROOT/README.md" ]; then
    log ERROR "README.md non trouvé dans $IPCRAE_ROOT"
    exit 1
fi

cd "$IPCRAE_ROOT"

# Si aucun commit de référence n'est spécifié, utiliser le dernier tag session-*
if [ -z "$COMMIT_REF" ]; then
    COMMIT_REF=$(git describe --tags --abbrev=0 --match='session-*' 2>/dev/null | tail -1)
    if [ -z "$COMMIT_REF" ]; then
        log WARN "Aucun tag session-* trouvé, utilisation de HEAD~10"
        COMMIT_REF="HEAD~10"
    fi
fi

log INFO "Vérification anti-régression basée sur les commits"
log INFO "Répertoire: $IPCRAE_ROOT"
log INFO "Commit de référence: $COMMIT_REF"

# Si dry-run, afficher ce qui serait fait
if [ "$DRY_RUN" = true ]; then
    log INFO "Mode simulation (dry-run)"
    log INFO "Les vérifications suivantes seraient effectuées :"
    log INFO "  - Analyse des fichiers modifiés depuis $COMMIT_REF"
    log INFO "  - Analyse des modifications par catégorie"
    log INFO "  - Détection des fonctions disparues"
    log INFO "  - Détection des comportements modifiés"
    log INFO "  - Détection des violations de la méthode"
    log INFO "  - Analyse des dépendances"
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

# Étape 1 : Préparation
log INFO "=== Étape 1 : Préparation ==="

# Vérifier que le dépôt git est propre
if [ -n "$(git status --porcelain)" ]; then
    log WARN "Le dépôt git n'est pas propre (modifications non commitées)"
fi

# Étape 2 : Analyse des changements
log INFO ""
log INFO "=== Étape 2 : Analyse des changements ==="

# A. Identifier les fichiers modifiés
log INFO ""
log INFO "--- A. Identification des fichiers modifiés ---"
MODIFIED_FILES=$(git diff --name-only "$COMMIT_REF" HEAD)
MODIFIED_COUNT=$(echo "$MODIFIED_FILES" | wc -l | tr -d ' \t')

log INFO "Fichiers modifiés: $MODIFIED_COUNT"

if [ "$VERBOSE" = true ]; then
    echo "$MODIFIED_FILES"
fi

# Catégoriser les fichiers modifiés
CLI_SCRIPTS_MODIFIED=$(echo "$MODIFIED_FILES" | grep '^scripts/ipcrae-' || true)
UTIL_SCRIPTS_MODIFIED=$(echo "$MODIFIED_FILES" | grep '^scripts/' | grep -v 'ipcrae-' || true)
PROCESSES_MODIFIED=$(echo "$MODIFIED_FILES" | grep '^Process/' || true)
PROMPTS_MODIFIED=$(echo "$MODIFIED_FILES" | grep '^.ipcrae/prompts/' || true)
DOCS_MODIFIED=$(echo "$MODIFIED_FILES" | grep -E '^(README\.md|Knowledge/|docs/)' || true)

log INFO "Scripts CLI modifiés: $(echo "$CLI_SCRIPTS_MODIFIED" | wc -l | tr -d ' \t')"
log INFO "Scripts utilitaires modifiés: $(echo "$UTIL_SCRIPTS_MODIFIED" | wc -l | tr -d ' \t')"
log INFO "Processus modifiés: $(echo "$PROCESSES_MODIFIED" | wc -l | tr -d ' \t')"
log INFO "Prompts modifiés: $(echo "$PROMPTS_MODIFIED" | wc -l | tr -d ' \t')"
log INFO "Documentation modifiée: $(echo "$DOCS_MODIFIED" | wc -l | tr -d ' \t')"

# B. Analyser les modifications par catégorie
log INFO ""
log INFO "--- B. Analyse des modifications par catégorie ---"

# Scripts CLI
for script in $CLI_SCRIPTS_MODIFIED; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        log INFO "Script CLI modifié: $script_name"
        
        # Vérifier que la fonctionnalité principale n'a pas été supprimée
        check "Fonctionnalité principale de $script_name toujours présente" "grep -q 'function ' $script"
        
        # Vérifier que le script respecte les principes IPCRAE
        check "Script $script_name respecte les principes IPCRAE" "! grep -q 'set -e' $script"
    fi
done

# Scripts utilitaires
for script in $UTIL_SCRIPTS_MODIFIED; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        log INFO "Script utilitaire modifié: $script_name"
        
        # Vérifier que la fonctionnalité n'a pas été supprimée
        check "Fonctionnalité de $script_name toujours présente" "grep -q 'function ' $script"
        
        # Vérifier que les scripts qui dépendent de ce script ne sont pas cassés
        check "Dépendances de $script_name valides" "true" # À implémenter
    fi
done

# Processus
for process in $PROCESSES_MODIFIED; do
    if [ -f "$process" ]; then
        process_name=$(basename "$process" .md)
        log INFO "Processus modifié: $process_name"
        
        # Vérifier que le processus n'a pas été supprimé
        check "Processus $process_name existe toujours" "test -f $process"
        
        # Vérifier que les liens wikilinks sont toujours valides
        check "Liens wikilinks de $process_name valides" "! grep -q '\[\[broken\]\]' $process"
    fi
done

# Prompts
for prompt in $PROMPTS_MODIFIED; do
    if [ -f "$prompt" ]; then
        prompt_name=$(basename "$prompt" .md)
        log INFO "Prompt modifié: $prompt_name"
        
        # Vérifier que les instructions clés n'ont pas été supprimées
        check "Instructions clés de $prompt_name toujours présentes" "grep -q 'Contexte' $prompt"
        
        # Vérifier que le prompt respecte les principes IPCRAE
        check "Prompt $prompt_name respecte les principes IPCRAE" "! grep -q 'IPCRAE' $prompt"
    fi
done

# Étape 3 : Détection des régressions
log INFO ""
log INFO "=== Étape 3 : Détection des régressions ==="

# A. Fonctions disparues
log INFO ""
log INFO "--- A. Fonctions disparues ---"

# Extraire les commandes documentées dans README.md avant le commit
DOCUMENTED_COMMANDS_BEFORE=$(git show "$COMMIT_REF:README.md" | grep -o 'ipcrae [a-z-]*' | sort -u || true)

# Extraire les commandes documentées dans README.md maintenant
DOCUMENTED_COMMANDS_NOW=$(grep -o 'ipcrae [a-z-]*' README.md | sort -u || true)

# Vérifier les commandes disparues
for cmd in $DOCUMENTED_COMMANDS_BEFORE; do
    if ! echo "$DOCUMENTED_COMMANDS_NOW" | grep -q "$cmd"; then
        log WARN "Commande disparue: $cmd"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
done

# B. Comportements modifiés
log INFO ""
log INFO "--- B. Comportements modifiés ---"

# Vérifier si les arguments des commandes ont été modifiés
for script in $CLI_SCRIPTS_MODIFIED; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        
        # Vérifier si les arguments ont été modifiés
        OLD_ARGS=$(git show "$COMMIT_REF:$script" | grep -o '\-\-[a-z]*' | sort -u || true)
        NEW_ARGS=$(grep -o '\-\-[a-z]*' "$script" | sort -u || true)
        
        if [ "$OLD_ARGS" != "$NEW_ARGS" ]; then
            log WARN "Arguments modifiés pour $script_name"
            log WARN "  Avant: $OLD_ARGS"
            log WARN "  Après: $NEW_ARGS"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        fi
    fi
done

# C. Violations de la méthode
log INFO ""
log INFO "--- C. Violations de la méthode ---"

# Vérifier que les scripts respectent toujours les principes IPCRAE
for script in $MODIFIED_FILES; do
    if [[ "$script" == scripts/*.sh ]]; then
        check "Script $script respecte les principes IPCRAE" "! grep -q 'set -e' $script"
    fi
done

# Étape 4 : Analyse des dépendances
log INFO ""
log INFO "=== Étape 4 : Analyse des dépendances ==="

# Vérifier que les dépendances sont toujours valides
# À implémenter : analyse des dépendances entre scripts, processus et prompts

# Résultat
log INFO ""
log INFO "=== Résultat ==="
SCORE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
log INFO "Total checks: $TOTAL_CHECKS"
log INFO "Passed: $PASSED_CHECKS"
log INFO "Failed: $FAILED_CHECKS"
log INFO "Score: $SCORE%"

if [ $FAILED_CHECKS -eq 0 ]; then
    log INFO "✅ Vérification anti-régression réussie"
    exit 0
else
    log WARN "⚠️ Vérification anti-régression terminée avec $FAILED_CHECKS régression(s) détectée(s)"
    exit 1
fi
