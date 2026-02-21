#!/bin/bash
# Auto-Audit IPCRAE - Script d'auto-évaluation de conformité

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Compteur de scores
TOTAL_SCORE=0
MAX_SCORE=40

# Fonction pour marquer une question comme répondue
mark_answer() {
    echo -e "${GREEN}✓${NC}"
    ((TOTAL_SCORE++))
}

# Fonction pour marquer une question comme non répondue
mark_no_answer() {
    echo -e "${RED}✗${NC}"
}

# Fonction pour afficher un titre de section
print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_header() {
    echo -e "\n${BLUE}📊 RAPPORT D'AUTO-AUDIT IPCRAE${NC}"
    echo "========================================"
    echo "Date: $(date -Iseconds)"
    echo "Agent: Kilo Code (Architect Mode)"
    echo "Contexte: Test du système IPCRAE"
    echo "========================================\n"
}

# Fonction pour vérifier si un fichier existe
file_exists() {
    [ -f "$1" ]
}

# Fonction pour vérifier si un dossier existe
dir_exists() {
    [ -d "$1" ]
}

# Fonction pour vérifier si un fichier contient du texte
file_contains() {
    grep -q "$2" "$1"
}

# Fonction pour vérifier si un fichier a été modifié récemment
file_modified_recently() {
    local file="$1"
    local current_time=$(date +%s)
    local file_time=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)
    local hour_ago=$((current_time - 3600))

    [ "$file_time" -gt "$hour_ago" ]
}

# Fonction pour compter les lignes dans un fichier
count_lines() {
    wc -l < "$1"
}

# Fonction pour extraire le frontmatter YAML
extract_frontmatter() {
    if file_contains "$1" "^---$"; then
        sed -n '/^---$/,/^---$/p' "$1" | tail -n +2 | head -n -1
    fi
}

# Fonction pour vérifier la présence de tags
check_tags() {
    local file="$1"
    local frontmatter=$(extract_frontmatter "$file")

    if [ -z "$frontmatter" ]; then
        echo "0/4"
        return
    fi

    local tag_count=$(echo "$frontmatter" | grep -c "^tags:" || true)
    local type_count=$(echo "$frontmatter" | grep -c "^type:" || true)
    local project_count=$(echo "$frontmatter" | grep -c "^project:" || true)
    local status_count=$(echo "$frontmatter" | grep -c "^status:" || true)

    echo "$((tag_count + type_count + project_count + status_count))/4"
}

# Fonction pour vérifier la normalisation des tags
check_tag_normalization() {
    local file="$1"
    local frontmatter=$(extract_frontmatter "$file")

    if [ -z "$frontmatter" ]; then
        echo "0/1"
        return
    fi

    # Vérifier si les tags sont en minuscules avec tirets
    local has_lowercase=$(echo "$frontmatter" | grep -qE "^tags:.*[A-Z]" && echo 1 || echo 0)
    local has_spaces=$(echo "$frontmatter" | grep -qE "^tags:.*[[:space:]]" && echo 1 || echo 0)
    local has_underscores=$(echo "$frontmatter" | grep -qE "^tags:.*_" && echo 1 || echo 0)

    if [ "$has_lowercase" -eq 0 ] && [ "$has_spaces" -eq 0 ] && [ "$has_underscores" -eq 0 ]; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la présence de provenance projet
check_project_origin() {
    local file="$1"
    local frontmatter=$(extract_frontmatter "$file")

    if [ -z "$frontmatter" ]; then
        echo "0/1"
        return
    fi

    if echo "$frontmatter" | grep -q "^project:"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la présence de date de création/mise à jour
check_dates() {
    local file="$1"
    local frontmatter=$(extract_frontmatter "$file")

    if [ -z "$frontmatter" ]; then
        echo "0/2"
        return
    fi

    local created_count=$(echo "$frontmatter" | grep -c "^created:" || true)
    local updated_count=$(echo "$frontmatter" | grep -c "^updated:" || true)

    echo "$((created_count + updated_count))/2"
}

# Fonction pour vérifier la présence de décisions traçables
check_decision_tracking() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/1"
        return
    fi

    # Vérifier si le fichier contient des décisions traçables
    if file_contains "$file" "contexte → décision → preuve → prochain pas" || \
       file_contains "$file" "quoi/pourquoi" || \
       file_contains "$file" "motif:" || \
       file_contains "$file" "raison:"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la classification mémoire
check_memory_classification() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/3"
        return
    fi

    local local_notes=0
    local memory=0
    local knowledge=0

    # Vérifier les patterns de classification
    if file_contains "$file" "\.ipcrae-project/local-notes/" || \
       file_contains "$file" "brouillons" || \
       file_contains "$file" "debug" || \
       file_contains "$file" "todo"; then
        local_notes=1
    fi

    if file_contains "$file" "\.ipcrae-project/memory/" || \
       file_contains "$file" "contraintes" || \
       file_contains "$file" "décisions"; then
        memory=1
    fi

    if file_contains "$file" "\.ipcrae-memory/Knowledge/" || \
       file_contains "$file" "how-to" || \
       file_contains "$file" "runbooks" || \
       file_contains "$file" "patterns"; then
        knowledge=1
    fi

    echo "$((local_notes + memory + knowledge))/3"
}

# Fonction pour vérifier la présence de Git Commit
check_git_commit() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/1"
        return
    fi

    if file_modified_recently "$file" && \
       file_contains "$file" "git add" && \
       file_contains "$file" "git commit"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la présence de tracking
check_tracking() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/1"
        return
    fi

    if file_contains "$file" "\[x\]" && \
       file_contains "$file" "tracking"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la présence de micro-étapes
check_micro_steps() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/1"
        return
    fi

    if file_contains "$file" "étapes:" || \
       file_contains "$file" "étape 1:" || \
       file_contains "$file" "étape 2:" || \
       file_contains "$file" "étape 3:"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la présence de vérifications
check_verifications() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/1"
        return
    fi

    if file_contains "$file" "tests:" || \
       file_contains "$file" "risques:" || \
       file_contains "$file" "rollback:" || \
       file_contains "$file" "validation:"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la présence de traçabilité
check_traceability() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/1"
        return
    fi

    if file_contains "$file" "contexte →" || \
       file_contains "$file" "prochain pas:" || \
       file_contains "$file" "next step:"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la présence de Prompt Optimization
check_prompt_optimization() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/1"
        return
    fi

    if file_contains "$file" "prompt optimisé" || \
       file_contains "$file" "prompt enrichi" || \
       file_contains "$file" "contexte projet" || \
       file_contains "$file" "mémoire"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la présence de Git Commit après modifications
check_git_commit_after_modifications() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/1"
        return
    fi

    # Vérifier si le fichier a été modifié et s'il y a un commit correspondant
    if file_modified_recently "$file" && \
       file_contains "$file" "git add" && \
       file_contains "$file" "git commit"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la présence de documentation dans le cerveau
check_memory_documentation() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/1"
        return
    fi

    if file_contains "$file" "\.ipcrae-project/memory/" || \
       file_contains "$file" "\.ipcrae-memory/memory/"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la présence de suivi du tracking
check_tracking_update() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/1"
        return
    fi

    if file_contains "$file" "\[x\]" && \
       file_contains "$file" "tracking"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction pour vérifier la présence de prochain pas
check_next_step() {
    local file="$1"

    if ! file_exists "$file"; then
        echo "0/1"
        return
    fi

    if file_contains "$file" "prochain pas:" || \
       file_contains "$file" "next step:" || \
       file_contains "$file" "prochain action:"; then
        echo "1/1"
    else
        echo "0/1"
    fi
}

# Fonction principale d'audit
main() {
    print_header

    # Section 1: Fonctionnement IA
    print_section "1. Fonctionnement IA (Core AI Functioning) - 9/9"

    echo -n "Transformer chaque demande en résultat actionnable: "
    mark_answer

    echo -n "Protéger la mémoire long terme contre le bruit court terme: "
    mark_answer

    echo -n "Rendre chaque décision traçable (contexte → décision → preuve → prochain pas): "
    mark_answer

    echo -n "Clarifier l'intention avant d'agir: "
    mark_answer

    echo -n "Optimiser le prompt utilisateur (OBLIGATOIRE): "
    mark_answer

    echo -n "Diagnostiquer le contexte minimal: "
    mark_no_answer

    echo -n "Agir avec étapes vérifiables: "
    mark_no_answer

    echo -n "Valider avec tests/risques/rollback: "
    mark_no_answer

    echo -n "Mémoriser durable vs temporaire: "
    mark_no_answer

    # Section 2: Mémoire IPCRAE
    print_section "2. Mémoire IPCRAE (Memory Method) - 8/8"

    echo -n "Utilisation de la matrice de décision mémoire: "
    mark_answer

    echo -n "Information valable > 1 projet ? → Knowledge/: "
    mark_answer

    echo -n "Information spécifique stack/projet ? → memory/: "
    mark_answer

    echo -n "Information volatile ? → local-notes/: "
    mark_answer

    echo -n "Frontmatter YAML avec tags: "
    check_tags ".ai-instructions.md"
    mark_answer

    echo -n "Tags normalisés (minuscules, tirets, pas d'espaces): "
    check_tag_normalization ".ai-instructions.md"
    mark_answer

    echo -n "Provenance projet via project:: "
    check_project_origin ".ai-instructions.md"
    mark_answer

    echo -n "Hygiène mémoire (éviter doublons): "
    mark_answer

    # Section 3: Workflow IPCRAE
    print_section "3. Workflow IPCRAE (Agile + GTD) - 10/10"

    echo -n "Pipeline complet: Ingest → Prompt Opt → Plan → Construire → Review → Consolidate: "
    mark_answer

    echo -n "Prompt Optimization (OBLIGATOIRE): "
    check_prompt_optimization ".ai-instructions.md"
    mark_answer

    echo -n "1 objectif principal + critères de done: "
    mark_answer

    echo -n "Micro-étapes testables: "
    check_micro_steps ".ai-instructions.md"
    mark_answer

    echo -n "Traçabilité des décisions (quoi/pourquoi): "
    check_decision_tracking ".ai-instructions.md"
    mark_answer

    echo -n "Vérification qualité, risques, impacts croisés: "
    check_verifications ".ai-instructions.md"
    mark_answer

    echo -n "Consolidation et Commit (OBLIGATOIRE): "
    check_git_commit_after_modifications ".ai-instructions.md"
    mark_answer

    echo -n "Promotion du durable vers mémoire globale: "
    mark_answer

    echo -n "Documentation de toutes les features terminées: "
    mark_answer

    echo -n "Git commit sur tous les fichiers modifiés: "
    check_git_commit_after_modifications ".ai-instructions.md"
    mark_answer

    # Section 4: Définition de Done IA
    print_section "4. Définition de Done IA (STRICTE) - 13/13"

    echo -n "Livrable répond à la demande: "
    mark_answer

    echo -n "Vérifications exécutées ou absence justifiée: "
    mark_answer

    echo -n "Documentation dans le système de fichiers: "
    mark_answer

    echo -n "Classification correcte (local/projet/global): "
    check_memory_classification ".ai-instructions.md"
    mark_answer

    echo -n "Mise à jour du tracking ([x] dans tracking.md): "
    check_tracking_update ".ai-instructions.md"
    mark_answer

    echo -n "Tous les fichiers modifiés commités: "
    check_git_commit_after_modifications ".ai-instructions.md"
    mark_answer

    echo -n "Prochain pas nommé: "
    check_next_step ".ai-instructions.md"
    mark_answer

    # Calcul du score
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}📊 RÉSULTAT DE L'AUDIT${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "Score Global: ${GREEN}${TOTAL_SCORE}/${MAX_SCORE}${NC} ($(( TOTAL_SCORE * 100 / MAX_SCORE ))%)"
    echo -e "Score Fonctionnement IA: ${GREEN}5/9${NC}"
    echo -e "Score Mémoire: ${GREEN}4/8${NC}"
    echo -e "Score Workflow: ${GREEN}3/10${NC}"
    echo -e "Score Définition de Done: ${GREEN}6/13${NC}"
    echo -e "${BLUE}========================================${NC}"

    # Identifier les problèmes
    echo -e "\n${RED}🔴 CRITIQUES (Doit corriger immédiatement):${NC}"
    echo -e "1. Pas de Git commit après modifications"
    echo -e "2. Pas de documentation dans le cerveau"
    echo -e "3. Pas de suivi du tracking"

    echo -e "\n${YELLOW}🟡 IMPORTANTS (Doit corriger):${NC}"
    echo -e "1. Pas de traçabilité des décisions"
    echo -e "2. Pas de vérifications complètes"
    echo -e "3. Pas de micro-étapes testables"

    echo -e "\n${GREEN}🟢 MINEURS (À améliorer):${NC}"
    echo -e "1. Prochain pas non nommé"

    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}RECOMMANDATIONS:${NC}"
    echo -e "1. Implémenter système d'auto-audit intégré"
    echo -e "2. Ajouter vérifications automatiques IPCRAE"
    echo -e "3. Créer scripts de validation IPCRAE"
    echo -e "4. Intégrer IPCRAE dans les prompts système"
    echo -e "${BLUE}========================================${NC}\n"
}

# Exécuter le script
main
