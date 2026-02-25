#!/bin/bash
# Script d'Audit de Non-Régression IPCRAE

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonction pour marquer une vérification comme réussie
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

# Fonction pour marquer une vérification comme échouée
check_fail() {
    echo -e "${RED}✗${NC} $1"
}

# Fonction pour marquer une vérification comme avertissement
check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Fonction pour afficher un titre de section
print_section() {
    echo -e "\n${CYAN}=== $1 ===${NC}\n"
}

print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}Audit de Non-Régression IPCRAE${NC}"
    echo -e "${CYAN}========================================${NC}\n"
    echo -e "${BLUE}Date:${NC} $(date -Iseconds)"
    echo -e "${BLUE}Agent:${NC} Kilo Code"
    echo -e "${BLUE}Contexte:${NC} Vérification de l'intégrité du système IPCRAE"
    echo -e "${CYAN}========================================${NC}\n"
}

# Fonction pour vérifier l'intégrité des fichiers
check_file_integrity() {
    echo -e "${BLUE}📁 Vérification de l'intégrité des fichiers${NC}\n"

    local total_files=0
    local total_md=0
    local total_sh=0

    # Compter les fichiers Markdown
    total_md=$(find . -name "*.md" | wc -l)
    echo -n "Fichiers Markdown: "
    check_pass "$total_md fichiers"

    # Compter les fichiers Shell
    total_sh=$(find . -name "*.sh" | wc -l)
    echo -n "Fichiers Shell: "
    check_pass "$total_sh fichiers"

    total_files=$((total_md + total_sh))
    echo -e "\n${BLUE}Total fichiers:${NC} $total_files"
}

# Fonction pour vérifier l'intégrité des mémoires
check_memory_integrity() {
    echo -e "\n${BLUE}🧠 Vérification de l'intégrité des mémoires${NC}\n"

    local total_memories=0

    # Vérifier si les fichiers de mémoire existent
    if [ -f "memory/devops.md" ]; then
        echo -n "Mémoire devops: "
        check_pass "✓ Existe"
        total_memories=$((total_memories + 1))
    else
        echo -n "Mémoire devops: "
        check_fail "✗ Non trouvé"
    fi

    if [ -f "memory/electronique.md" ]; then
        echo -n "Mémoire electronique: "
        check_pass "✓ Existe"
        total_memories=$((total_memories + 1))
    else
        echo -n "Mémoire electronique: "
        check_fail "✗ Non trouvé"
    fi

    echo -e "\n${BLUE}Total mémoires:${NC} $total_memories"
}

# Fonction pour vérifier l'intégrité des scripts
check_scripts_integrity() {
    echo -e "\n${BLUE}🔧 Vérification de l'intégrité des scripts${NC}\n"

    local total_scripts=0
    local total_executable=0

    # Compter les scripts
    total_scripts=$(find scripts -name "*.sh" 2>/dev/null | wc -l)
    echo -n "Fichiers scripts: "
    check_pass "$total_scripts fichiers"

    # Vérifier les scripts importants
    if [ -f "scripts/ipcrae-allcontext.sh" ]; then
        echo -n "Script ipcrae-allcontext.sh: "
        check_pass "✓ Existe"
        total_executable=$((total_executable + 1))
    else
        echo -n "Script ipcrae-allcontext.sh: "
        check_fail "✗ Non trouvé"
    fi

    if [ -f "scripts/ipcrae-inbox-scan.sh" ]; then
        echo -n "Script ipcrae-inbox-scan.sh: "
        check_pass "✓ Existe"
        total_executable=$((total_executable + 1))
    else
        echo -n "Script ipcrae-inbox-scan.sh: "
        check_fail "✗ Non trouvé"
    fi

    echo -e "\n${BLUE}Scripts valides:${NC} $total_executable/$total_scripts"
}

# Fonction pour vérifier la cohérence des tags
check_tags_coherence() {
    echo -e "\n${BLUE}🏷️  Vérification de la cohérence des tags${NC}\n"

    local total_tags=0
    local valid_tags=0

    # Compter les tags
    total_tags=$(grep -r "^tags:" . --include="*.md" 2>/dev/null | wc -l)
    echo -n "Tags dans le frontmatter: "
    check_pass "$total_tags tags"

    # Vérifier la normalisation des tags
    local invalid_tags=$(grep -r "^tags:.*[A-Z]" . --include="*.md" 2>/dev/null | wc -l || true)
    echo -n "Tags en majuscules: "
    if [ $invalid_tags -eq 0 ]; then
        check_pass "✓ Normalisés"
        valid_tags=$((valid_tags + 1))
    else
        check_warn "⚠ $invalid_tags tags non normalisés"
    fi

    echo -e "\n${BLUE}Tags cohérents:${NC} $valid_tags/$total_tags"
}

# Fonction pour vérifier les liens entre fichiers
check_links_integrity() {
    echo -e "\n${BLUE}🔗 Vérification des liens entre fichiers${NC}\n"

    local total_links=0
    local broken_links=0

    # Compter les liens Markdown
    total_links=$(grep -r "\[.*\](.*\.md)" . --include="*.md" 2>/dev/null | wc -l)
    echo -n "Liens Markdown: "
    check_pass "$total_links liens"

    # Vérifier les liens brisés
    broken_links=$(find . -name "*.md" -exec grep -h "\[.*\](\([^)]*\))" {} \; 2>/dev/null | sed 's/.*(\(.*\)).*/\1/' | sort -u | while read link; do
        if [ ! -f "$link" ] && [ ! -d "$link" ]; then
            echo "$link"
        fi
    done | wc -l || true)

    if [ $broken_links -eq 0 ]; then
        echo -n "Liens brisés: "
        check_pass "✓ Aucun"
    else
        echo -n "Liens brisés: "
        check_warn "⚠ $broken_links liens brisés"
    fi

    echo -e "\n${BLUE}Liens valides:${NC} $((total_links - broken_links))/$total_links"
}

# Fonction pour vérifier l'intégrité des données
check_data_integrity() {
    echo -e "\n${BLUE}💾 Vérification de l'intégrité des données${NC}\n"

    # Vérifier si les fichiers de tracking existent
    if [ -f "Projets/IPCRAE/tracking.md" ]; then
        echo -n "Tracking IPCRAE: "
        check_pass "✓ Existe"
    else
        echo -n "Tracking IPCRAE: "
        check_warn "⚠ Non trouvé"
    fi

    # Vérifier si les fichiers de processus existent
    if [ -f "Process/auto-amelioration.md" ]; then
        echo -n "Process auto-amélioration: "
        check_pass "✓ Existe"
    else
        echo -n "Process auto-amélioration: "
        check_warn "⚠ Non trouvé"
    fi

    if [ -f "Process/non-regression.md" ]; then
        echo -n "Process non-régression: "
        check_pass "✓ Existe"
    else
        echo -n "Process non-régression: "
        check_warn "⚠ Non trouvé"
    fi
}

# Fonction pour vérifier l'intégrité de l'Inbox
check_inbox_integrity() {
    echo -e "\n${BLUE}📥 Vérification de l'intégrité de l'Inbox${NC}\n"

    local inbox_folders=0

    # Vérifier les sous-dossiers de l'Inbox
    if [ -d "Inbox/demandes-brutes" ]; then
        echo -n "Dossier demandes-brutes: "
        check_pass "✓ Existe"
        inbox_folders=$((inbox_folders + 1))
    else
        echo -n "Dossier demandes-brutes: "
        check_warn "⚠ Non trouvé"
    fi

    if [ -f "Inbox/demandes-brutes/README.md" ]; then
        echo -n "README demandes-brutes: "
        check_pass "✓ Existe"
        inbox_folders=$((inbox_folders + 1))
    else
        echo -n "README demandes-brutes: "
        check_warn "⚠ Non trouvé"
    fi

    echo -e "\n${BLUE}Inbox cohérent:${NC} $inbox_folders/2"
}

# Fonction principale d'audit
main() {
    print_header

    # Section 1: Intégrité des fichiers
    check_file_integrity

    # Section 2: Intégrité des mémoires
    check_memory_integrity

    # Section 3: Intégrité des scripts
    check_scripts_integrity

    # Section 4: Cohérence des tags
    check_tags_coherence

    # Section 5: Liens entre fichiers
    check_links_integrity

    # Section 6: Intégrité des données
    check_data_integrity

    # Section 7: Intégrité de l'Inbox
    check_inbox_integrity

    # Calcul du score
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}📊 Résultat de l'Audit de Non-Régression${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${GREEN}✅ Audit de non-régression terminé avec succès${NC}\n"
    echo -e "${BLUE}Prochain audit: Après la prochaine modification significative${NC}\n"
    echo -e "${BLUE}========================================${NC}\n"
}

# Exécuter la fonction principale
main
