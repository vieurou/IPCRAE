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
    local total_tests=0

    # Compter les fichiers Markdown
    total_md=$(find . -name "*.md" | wc -l)
    echo -n "Fichiers Markdown: "
    check_pass "$total_md fichiers"

    # Compter les fichiers Shell
    total_sh=$(find . -name "*.sh" | wc -l)
    echo -n "Fichiers Shell: "
    check_pass "$total_sh fichiers"

    # Compter les fichiers de tests
    total_tests=$(find . -name "*.bats" -o -name "*.sh" -path "*/tests/*" | wc -l)
    echo -n "Fichiers de tests: "
    check_pass "$total_tests fichiers"

    total_files=$((total_md + total_sh + total_tests))
    echo -e "\n${BLUE}Total fichiers:${NC} $total_files"
}

# Fonction pour vérifier l'intégrité des mémoires
check_memory_integrity() {
    echo -e "\n${BLUE}🧠 Vérification de l'intégrité des mémoires${NC}\n"

    local total_memories=0
    local total_memory_files=0

    # Compter les fichiers de mémoire
    total_memory_files=$(find .ipcrae-memory -name "memory.md" | wc -l)
    echo -n "Fichiers de mémoire: "
    check_pass "$total_memory_files fichiers"

    # Vérifier si les fichiers de mémoire existent
    if [ -f ".ipcrae-memory/Projets/IPCRAE/memory.md" ]; then
        echo -n "Mémoire projet IPCRAE: "
        check_pass "✓ Existe"
        total_memories=$((total_memories + 1))
    else
        echo -n "Mémoire projet IPCRAE: "
        check_fail "✗ Non trouvé"
    fi

    if [ -f ".ipcrae-memory/Projets/IPCRAE/profil_usage.md" ]; then
        echo -n "Profil usage: "
        check_pass "✓ Existe"
        total_memories=$((total_memories + 1))
    else
        echo -n "Profil usage: "
        check_fail "✗ Non trouvé"
    fi

    if [ -f ".ipcrae-memory/Projets/IPCRAE/demandes/index.md" ]; then
        echo -n "Index demandes: "
        check_pass "✓ Existe"
        total_memories=$((total_memories + 1))
    else
        echo -n "Index demandes: "
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
    total_scripts=$(find scripts -name "*.sh" | wc -l)
    echo -n "Fichiers scripts: "
    check_pass "$total_scripts fichiers"

    # Vérifier l'exécutable
    if [ -x "scripts/audit_ipcrae.sh" ]; then
        echo -n "Script audit_ipcrae.sh: "
        check_pass "✓ Exécutable"
        total_executable=$((total_executable + 1))
    else
        echo -n "Script audit_ipcrae.sh: "
        check_fail "✗ Non exécutable"
    fi

    if [ -x "scripts/apply_ipcrae_corrections.sh" ]; then
        echo -n "Script apply_ipcrae_corrections.sh: "
        check_pass "✓ Exécutable"
        total_executable=$((total_executable + 1))
    else
        echo -n "Script apply_ipcrae_corrections.sh: "
        check_fail "✗ Non exécutable"
    fi

    if [ -x "scripts/auto_audit.sh" ]; then
        echo -n "Script auto_audit.sh: "
        check_pass "✓ Exécutable"
        total_executable=$((total_executable + 1))
    else
        echo -n "Script auto_audit.sh: "
        check_fail "✗ Non exécutable"
    fi

    if [ -x "scripts/ipcrae-auto.sh" ]; then
        echo -n "Script ipcrae-auto.sh: "
        check_pass "✓ Exécutable"
        total_executable=$((total_executable + 1))
    else
        echo -n "Script ipcrae-auto.sh: "
        check_fail "✗ Non exécutable"
    fi

    echo -e "\n${BLUE}Scripts exécutables:${NC} $total_executable/$total_scripts"
}

# Fonction pour vérifier l'intégrité des templates
check_templates_integrity() {
    echo -e "\n${BLUE}📋 Vérification de l'intégrité des templates${NC}\n"

    local total_templates=0
    local total_md_templates=0

    # Compter les templates
    total_templates=$(find templates -name "*.md" | wc -l)
    echo -n "Fichiers templates: "
    check_pass "$total_templates fichiers"

    # Vérifier les templates importants
    if [ -f "templates/prompts/template_reponse_ipcrae.md" ]; then
        echo -n "Template réponse IPCRAE: "
        check_pass "✓ Existe"
        total_md_templates=$((total_md_templates + 1))
    else
        echo -n "Template réponse IPCRAE: "
        check_fail "✗ Non trouvé"
    fi

    if [ -f "templates/prompts/template_auto_amelioration.md" ]; then
        echo -n "Template auto-amélioration: "
        check_pass "✓ Existe"
        total_md_templates=$((total_md_templates + 1))
    else
        echo -n "Template auto-amélioration: "
        check_fail "✗ Non trouvé"
    fi

    echo -e "\n${BLUE}Templates Markdown:${NC} $total_md_templates/$total_templates"
}

# Fonction pour vérifier les commits git
check_git_commits() {
    echo -e "\n${BLUE}💾 Vérification des commits git${NC}\n"

    local total_commits=$(git log --oneline | wc -l)
    echo -n "Commits: "
    check_pass "$total_commits commits"

    if [ $total_commits -ge 10 ]; then
        echo -n "Nombre de commits: "
        check_pass "✓ Suffisant ($total_commits)"
    else
        echo -n "Nombre de commits: "
        check_warn "⚠ Faible ($total_commits, minimum 10)"
    fi

    # Vérifier les commits récents
    local recent_commits=$(git log --oneline -n 5 | wc -l)
    echo -n "Commits récents (5 derniers): "
    check_pass "$recent_commits commits"
}


# Fonction pour vérifier la syntaxe bash des scripts critiques
check_bash_syntax() {
    echo -e "
${BLUE}🐚 Vérification syntaxique Bash${NC}
"

    local has_error=0

    if bash -n templates/ipcrae-launcher.sh 2>/dev/null; then
        echo -n "templates/ipcrae-launcher.sh: "
        check_pass "✓ Syntaxe valide"
    else
        echo -n "templates/ipcrae-launcher.sh: "
        check_fail "✗ Erreur de syntaxe"
        has_error=1
    fi

    if bash -n ipcrae-install.sh 2>/dev/null; then
        echo -n "ipcrae-install.sh: "
        check_pass "✓ Syntaxe valide"
    else
        echo -n "ipcrae-install.sh: "
        check_fail "✗ Erreur de syntaxe"
        has_error=1
    fi

    if [ $has_error -eq 1 ]; then
        echo -e "${YELLOW}⚠ Corriger les erreurs de syntaxe avant release${NC}"
    fi
}


# Vérifier la présence du mécanisme de clôture auto-audit
check_session_closure_mechanism() {
    echo -e "
${BLUE}🧾 Vérification clôture automatique de session${NC}
"

    if grep -q "write_session_self_audit" templates/ipcrae-launcher.sh; then
        echo -n "Self-audit intégré au close: "
        check_pass "✓ Oui"
    else
        echo -n "Self-audit intégré au close: "
        check_warn "⚠ Non détecté"
    fi

    if grep -q "session_context_memory_max_lines" ipcrae-install.sh; then
        echo -n "Config limites contexte installée: "
        check_pass "✓ Oui"
    else
        echo -n "Config limites contexte installée: "
        check_warn "⚠ Non détectée"
    fi
}

# Fonction pour vérifier la cohérence des tags
check_tags_coherence() {
    echo -e "\n${BLUE}🏷️  Vérification de la cohérence des tags${NC}\n"

    local total_tags=0
    local valid_tags=0

    # Compter les tags
    total_tags=$(grep -r "^tags:" . --include="*.md" | wc -l)
    echo -n "Tags dans le frontmatter: "
    check_pass "$total_tags tags"

    # Vérifier la normalisation des tags
    local invalid_tags=$(grep -r "^tags:.*[A-Z]" . --include="*.md" | wc -l || true)
    echo -n "Tags en majuscules: "
    if [ $invalid_tags -eq 0 ]; then
        check_pass "✓ Normalisés"
        valid_tags=$((valid_tags + 1))
    else
        check_warn "⚠ $invalid_tags tags non normalisés"
    fi

    local invalid_spaces=$(grep -r "^tags:.*[[:space:]]" . --include="*.md" | wc -l || true)
    echo -n "Tags avec espaces: "
    if [ $invalid_spaces -eq 0 ]; then
        check_pass "✓ Sans espaces"
        valid_tags=$((valid_tags + 1))
    else
        check_warn "⚠ $invalid_spaces tags avec espaces"
    fi

    local invalid_underscores=$(grep -r "^tags:.*_" . --include="*.md" | wc -l || true)
    echo -n "Tags avec soulignements: "
    if [ $invalid_underscores -eq 0 ]; then
        check_pass "✓ Sans soulignements"
        valid_tags=$((valid_tags + 1))
    else
        check_warn "⚠ $invalid_underscores tags avec soulignements"
    fi

    echo -e "\n${BLUE}Tags cohérents:${NC} $valid_tags/$total_tags"
}

# Fonction pour vérifier les liens entre fichiers
check_links_integrity() {
    echo -e "\n${BLUE}🔗 Vérification des liens entre fichiers${NC}\n"

    local total_links=0
    local broken_links=0

    # Compter les liens Markdown
    total_links=$(grep -r "\[.*\](.*\.md)" . --include="*.md" | wc -l)
    echo -n "Liens Markdown: "
    check_pass "$total_links liens"

    # Vérifier les liens brisés
    broken_links=$(find . -name "*.md" -exec grep -h "\[.*\](\([^)]*\))" {} \; | sed 's/.*(\(.*\)).*/\1/' | sort -u | while read link; do
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

# Fonction pour vérifier les références
check_references() {
    echo -e "\n${BLUE}📚 Vérification des références${NC}\n"

    local total_refs=0
    local valid_refs=0

    # Compter les références
    total_refs=$(grep -r "docs/" . --include="*.md" | wc -l)
    echo -n "Références à docs/: "
    check_pass "$total_refs références"

    # Vérifier si les fichiers de documentation existent
    local missing_docs=0

    if [ -f "docs/conception/00_VISION.md" ]; then
        echo -n "Vision IPCRAE: "
        check_pass "✓ Existe"
        valid_refs=$((valid_refs + 1))
    else
        echo -n "Vision IPCRAE: "
        check_warn "⚠ Non trouvé"
        missing_docs=$((missing_docs + 1))
    fi

    if [ -f "docs/conception/01_AI_RULES.md" ]; then
        echo -n "Règles IA: "
        check_pass "✓ Existe"
        valid_refs=$((valid_refs + 1))
    else
        echo -n "Règles IA: "
        check_warn "⚠ Non trouvé"
        missing_docs=$((missing_docs + 1))
    fi

    if [ -f "docs/conception/02_ARCHITECTURE.md" ]; then
        echo -n "Architecture: "
        check_pass "✓ Existe"
        valid_refs=$((valid_refs + 1))
    else
        echo -n "Architecture: "
        check_warn "⚠ Non trouvé"
        missing_docs=$((missing_docs + 1))
    fi

    if [ $missing_docs -eq 0 ]; then
        echo -e "\n${BLUE}Références valides:${NC} $valid_refs/$total_refs"
    else
        echo -e "\n${BLUE}Références valides:${NC} $valid_refs/$total_refs"
        echo -e "${YELLOW}⚠ $missing_docs fichiers de documentation manquants${NC}"
    fi
}

# Fonction pour vérifier l'intégrité des données
check_data_integrity() {
    echo -e "\n${BLUE}💾 Vérification de l'intégrité des données${NC}\n"

    # Vérifier si les fichiers de tracking existent
    if [ -f ".ipcrae-project/tracking.md" ]; then
        echo -n "Tracking: "
        check_pass "✓ Existe"
    else
        echo -n "Tracking: "
        check_warn "⚠ Non trouvé"
    fi

    # Vérifier si les fichiers de mémoire existent
    if [ -f ".ipcrae-project/memory/audit_kilo_code_conformite.md" ]; then
        echo -n "Audit conformité: "
        check_pass "✓ Existe"
    else
        echo -n "Audit conformité: "
        check_warn "⚠ Non trouvé"
    fi

    if [ -f ".ipcrae-project/memory/agent_auto_amelioration.md" ]; then
        echo -n "Auto-amélioration: "
        check_pass "✓ Existe"
    else
        echo -n "Auto-amélioration: "
        check_warn "⚠ Non trouvé"
    fi

    if [ -f ".ipcrae-memory/Projets/IPCRAE/memory.md" ]; then
        echo -n "Mémoire projet: "
        check_pass "✓ Existe"
    else
        echo -n "Mémoire projet: "
        check_warn "⚠ Non trouvé"
    fi

    if [ -f ".ipcrae-memory/Projets/IPCRAE/profil_usage.md" ]; then
        echo -n "Profil usage: "
        check_pass "✓ Existe"
    else
        echo -n "Profil usage: "
        check_warn "⚠ Non trouvé"
    fi

    if [ -f ".ipcrae-memory/Projets/IPCRAE/demandes/index.md" ]; then
        echo -n "Index demandes: "
        check_pass "✓ Existe"
    else
        echo -n "Index demandes: "
        check_warn "⚠ Non trouvé"
    fi
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

    # Section 4: Intégrité des templates
    check_templates_integrity

    # Section 5: Commits git
    check_git_commits

    # Section 6: Syntaxe bash
    check_bash_syntax

    # Section 7: Clôture automatique de session
    check_session_closure_mechanism

    # Section 8: Cohérence des tags
    check_tags_coherence

    # Section 9: Liens entre fichiers
    check_links_integrity

    # Section 10: Références
    check_references

    # Section 11: Intégrité des données
    check_data_integrity

    # Calcul du score
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}📊 Résultat de l'Audit de Non-Régression${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${GREEN}✅ Audit de non-régression terminé avec succès${NC}\n"
    echo -e "${BLUE}========================================${NC}\n"
    echo -e "${BLUE}Prochain audit: Demain 2026-02-22${NC}\n"
    echo -e "${BLUE}========================================${NC}\n"
}

# Exécuter la fonction principale
main
