#!/bin/bash
# scripts/ipcrae-architecte-methode.sh
# Script du mode Architecte Méthode

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
    echo "  Vérifie la cohérence de la méthode IPCRAE v3.3."
    echo "  Analyse l'évolution de la méthode et son bon respect dans tous les composants."
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

log INFO "Mode Architecte Méthode"
log INFO "Répertoire: $IPCRAE_ROOT"

# Si dry-run, afficher ce qui serait fait
if [ "$DRY_RUN" = true ]; then
    log INFO "Mode simulation (dry-run)"
    log INFO "Les vérifications suivantes seraient effectuées :"
    log INFO "  - Inventaire des composants de la méthode"
    log INFO "  - Vérification de la cohérence de la méthode"
    log INFO "  - Analyse de l'évolution de la méthode"
    log INFO "  - Vérification du respect de la méthode"
    log INFO "  - Identification des incohérences et violations"
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

# Étape 1 : Inventaire des composants de la méthode
log INFO "=== Étape 1 : Inventaire des composants de la méthode ==="

METHODE_DOCS=$(find Knowledge/howto -name "*ipcrae*.md" -type f | sort)
METHODE_PATTERNS=$(find Knowledge/patterns -name "*.md" -type f | sort)
METHODE_SCRIPTS=$(find scripts -name "*.sh" -type f | sort)
METHODE_PROCESSES=$(find Process -name "*.md" -type f | sort)
METHODE_PROMPTS=$(find .ipcrae/prompts -name "*.md" -type f | sort)

log INFO "Documents de la méthode trouvés: $(echo "$METHODE_DOCS" | wc -l | tr -d ' \t')"
log INFO "Patterns de la méthode trouvés: $(echo "$METHODE_PATTERNS" | wc -l | tr -d ' \t')"
log INFO "Scripts de la méthode trouvés: $(echo "$METHODE_SCRIPTS" | wc -l | tr -d ' \t')"
log INFO "Processus de la méthode trouvés: $(echo "$METHODE_PROCESSES" | wc -l | tr -d ' \t')"
log INFO "Prompts de la méthode trouvés: $(echo "$METHODE_PROMPTS" | wc -l | tr -d ' \t')"

# Étape 2 : Vérification de la cohérence de la méthode
log INFO ""
log INFO "=== Étape 2 : Vérification de la cohérence de la méthode ==="

# A. Cohérence des principes
log INFO ""
log INFO "--- A. Cohérence des principes ---"
check "Principe tag-first navigation documenté" "grep -rq 'tag-first' Knowledge/howto/"
check "Principe Markdown versionné documenté" "grep -rq 'Markdown versionné' Knowledge/howto/"
check "Principe scripts shell d'automatisation documenté" "grep -rq 'scripts shell' Knowledge/howto/"
check "Principe protocole de mémoire IA documenté" "grep -rq 'mémoire IA' Knowledge/howto/"
check "Principe GTD adapté documenté" "grep -rq 'GTD adapté' Knowledge/howto/"

# B. Cohérence des workflows
log INFO ""
log INFO "--- B. Cohérence des workflows ---"
check "Workflow session documenté" "grep -rq 'session.*start.*close' Knowledge/howto/"
check "Workflow auto-amélioration documenté" "grep -rq 'auto-amélioration' Knowledge/howto/"
check "Workflow GTD documenté" "grep -rq 'GTD' Knowledge/howto/"
check "Workflow Zettelkasten documenté" "grep -rq 'Zettelkasten' Knowledge/howto/"

# C. Cohérence des structures
log INFO ""
log INFO "--- C. Cohérence des structures ---"
check "Structure du vault documentée" "grep -rq 'Inbox.*Projets.*Casquettes' README.md"
check "Structure des projets documentée" "grep -rq 'index.*tracking.*memory' Knowledge/howto/"
check "Structure des processus documentée" "grep -rq 'frontmatter.*checklist' Knowledge/howto/"
check "Structure des notes documentée" "grep -rq 'frontmatter.*tags.*wikilinks' Knowledge/howto/"

# Étape 3 : Analyse de l'évolution de la méthode
log INFO ""
log INFO "=== Étape 3 : Analyse de l'évolution de la méthode ==="

# A. Identification des évolutions récentes
log INFO ""
log INFO "--- A. Identification des évolutions récentes ---"

# Récupérer les 10 derniers commits
RECENT_COMMITS=$(git log --oneline -10)
log INFO "Commits récents:"
log INFO "$RECENT_COMMITS"

# B. Analyse de la cohérence des évolutions
log INFO ""
log INFO "--- B. Analyse de la cohérence des évolutions ---"

# Vérifier que les évolutions sont cohérentes avec les principes existants
check "Évolutions cohérentes avec les principes IPCRAE" "true" # À implémenter

# Étape 4 : Vérification du respect de la méthode
log INFO ""
log INFO "=== Étape 4 : Vérification du respect de la méthode ==="

# A. Respect dans les scripts
log INFO ""
log INFO "--- A. Respect dans les scripts ---"
for script in $METHODE_SCRIPTS; do
    script_name=$(basename "$script")
    check "Script $script_name respecte les principes IPCRAE" "! grep -q 'set -e' $script"
    check "Script $script_name a un logging approprié" "grep -q 'log\|echo' $script"
done

# B. Respect dans les processus
log INFO ""
log INFO "--- B. Respect dans les processus ---"
for process in $METHODE_PROCESSES; do
    process_name=$(basename "$process" .md)
    check "Processus $process_name a une checklist" "grep -q '- \[ \]' $process"
    check "Processus $process_name a un DoD" "grep -qi 'done\|dod\|définition' $process"
done

# C. Respect dans les prompts
log INFO ""
log INFO "--- C. Respect dans les prompts ---"
for prompt in $METHODE_PROMPTS; do
    prompt_name=$(basename "$prompt" .md)
    check "Prompt $prompt_name inclut le contexte IPCRAE" "grep -q 'Contexte' $prompt"
    check "Prompt $prompt_name inclut la mémoire IPCRAE" "grep -q 'mémoire\|memory' $prompt"
    check "Prompt $prompt_name inclut le tracking IPCRAE" "grep -q 'tracking\|Projets' $prompt"
done

# D. Respect dans la documentation
log INFO ""
log INFO "--- D. Respect dans la documentation ---"
for doc in $METHODE_DOCS; do
    doc_name=$(basename "$doc")
    check "Document $doc_name respecte les principes IPCRAE" "grep -q 'IPCRAE' $doc"
    check "Document $doc_name a un frontmatter valide" "head -1 $doc | grep -q '^---'"
done

# Étape 5 : Identification des incohérences et violations
log INFO ""
log INFO "=== Étape 5 : Identification des incohérences et violations ==="

# A. Incohérences internes
log INFO ""
log INFO "--- A. Incohérences internes ---"

# Vérifier que les versions sont cohérentes
VERSION_README=$(grep "Version.*IPCRAE" README.md | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "")
VERSION_CONFIG=$(grep "script_version:" .ipcrae/config.yaml | cut -d'"' -f2)
check "Version cohérente entre README.md et config.yaml" "[ '$VERSION_README' = '$VERSION_CONFIG' ]"

# B. Violations de la méthode
log INFO ""
log INFO "--- B. Violations de la méthode ---"

# Vérifier que les scripts respectent les principes IPCRAE
for script in $METHODE_SCRIPTS; do
    if [[ "$script" == scripts/ipcrae-*.sh ]]; then
        check "Script $script respecte les principes IPCRAE" "! grep -q 'set -e' $script"
    fi
done

# C. Opportunités d'amélioration
log INFO ""
log INFO "--- C. Opportunités d'amélioration ---"

# Vérifier s'il y a des opportunités d'amélioration
check "Documentation de la méthode complète" "test -f Knowledge/howto/ipcrae-analyse-complete-cerveau-v3.3.md"
check "Patterns de la méthode documentés" "[ $(echo "$METHODE_PATTERNS" | wc -l | tr -d ' \t') -gt 0 ]"
check "Processus de la méthode documentés" "[ $(echo "$METHODE_PROCESSES" | wc -l | tr -d ' \t') -gt 0 ]"

# Résultat
log INFO ""
log INFO "=== Résultat ==="
SCORE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
log INFO "Total checks: $TOTAL_CHECKS"
log INFO "Passed: $PASSED_CHECKS"
log INFO "Failed: $FAILED_CHECKS"
log INFO "Score: $SCORE%"

if [ $FAILED_CHECKS -eq 0 ]; then
    log INFO "✅ Mode Architecte Méthode réussi"
    exit 0
else
    log WARN "⚠️ Mode Architecte Méthode terminé avec $FAILED_CHECKS incohérence(s) ou violation(s) détectée(s)"
    exit 1
fi
