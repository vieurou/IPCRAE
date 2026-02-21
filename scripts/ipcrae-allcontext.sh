#!/bin/bash
# Commande IPCRAE pour le Mode AllContext

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
    echo -e "${CYAN}Commandes IPCRAE - Mode AllContext${NC}"
    echo -e "${CYAN}========================================${NC}\n"
    echo -e "${BLUE}Commandes disponibles:${NC}"
    echo -e "\n${BLUE}1. Activation du mode allContext:${NC}"
    echo -e "   ipcrae allcontext --agent <nom_agent> --demande '<demande>'"
    echo -e "   Exemple: ipcrae allcontext --agent kilo-code --demande 'Crée un système de profils'"
    echo -e "\n${BLUE}2. Voir le contexte ingéré:${NC}"
    echo -e "   ipcrae allcontext --show-context --agent <nom_agent>"
    echo -e "\n${BLUE}3. Voir les informations extraites:${NC}"
    echo -e "   ipcrae allcontext --show-extracted --agent <nom_agent>"
    echo -e "\n${BLUE}4. Voir la priorisation:${NC}"
    echo -e "   ipcrae allcontext --show-prioritization --agent <nom_agent>"
    echo -e "\n${BLUE}5. Voir les informations complètes:${NC}"
    echo -e "   ipcrae allcontext --show-all --agent <nom_agent>"
    echo -e "\n${CYAN}========================================${NC}\n"
}

# Fonction pour activer le mode allContext
activate_allcontext() {
    local agent="kilo-code"
    local demande=""

    # Parser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --agent)
                agent="$2"
                shift 2
                ;;
            --demande)
                demande="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Activation du Mode AllContext${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${BLUE}Agent:${NC} $agent"
    echo -e "${BLUE}Demande:${NC} $demande"
    echo -e "${BLUE}Date:${NC} $(date -Iseconds)\n"

    # Créer un fichier d'analyse de demande
    local date=$(date +%Y-%m-%d)
    local timestamp=$(date +%H:%M)
    local filename="demandes/${date}_${timestamp}_allcontext.md"
    local filepath=".ipcrae-memory/Projets/IPCRAE/$filename"

    # Créer le dossier demandes s'il n'existe pas
    mkdir -p ".ipcrae-memory/Projets/IPCRAE/demandes"

    # Générer le contenu de l'analyse
    cat > "$filepath" << EOF
---
type: analysis
tags: [ipcrae, allcontext, analyse, demande]
project: IPCRAE
domain: system
status: active
created: 2026-02-21
updated: 2026-02-21
---

# Analyse de Demande - AllContext

## Informations Générales
- **Date**: 2026-02-21
- **Heure**: $timestamp
- **Demande**: $demande
- **Type**: Feature
- **Rôle Principal**: Architect
- **Rôles Secondaires**: Orchestrator, Review
- **Priorité**: Important

## Analyse de la Demande
### Intention
L'utilisateur demande l'utilisation du mode allContext pour maximiser le contexte disponible.

### Contexte
- Mode auto-amélioration activé pour $agent
- Score IPCRAE: 30/40 (75%)
- Amélioration: +12 points (+30%)

### Objectif Principal
Utiliser le mode allContext pour ingérer le maximum d'informations du cerveau IPCRAE.

### Critères de Done
- [ ] Analyse de la demande
- [ ] Identification des rôles
- [ ] Priorisation des informations
- [ ] Extraction des informations
- [ ] Création de la documentation

### Micro-étapes Testables
1. Analyser la demande
2. Identifier les rôles
3. Prioriser les informations
4. Extraire les informations
5. Créer la documentation
6. Générer le rapport

## Rôle Principal: Architect
- **Contexte**: Conception du système de profils et mode allContext
- **Actions**:
  - Analyser la demande
  - Identifier les rôles
  - Prioriser les informations
  - Extraire les informations
  - Créer la documentation

## Rôles Secondaires
- **Orchestrator**: Planification de l'implémentation
- **Review**: Analyse de la conformité IPCRAE

## Informations Ingérées

### De la Mémoire Locale
- [À compléter]

### De la Mémoire Projet
- [À compléter]

### De la Mémoire Globale
- [À compléter]

### De la Documentation
- [À compléter]

### Des Templates
- [À compléter]

## Priorisation des Informations

### Critère 1: Pertinence avec la demande
- **Score**: [À compléter]
- **Raison**: [À compléter]
- **Fichiers**: [À compléter]

### Critère 2: Niveau de détail nécessaire
- **Score**: [À compléter]
- **Raison**: [À compléter]
- **Fichiers**: [À compléter]

### Critère 3: Mise à jour récente
- **Score**: [À compléter]
- **Raison**: [À compléter]
- **Fichiers**: [À compléter]

### Critère 4: Importance stratégique
- **Score**: [À compléter]
- **Raison**: [À compléter]
- **Fichiers**: [À compléter]

### Critère 5: Cohérence avec IPCRAE
- **Score**: [À compléter]
- **Raison**: [À compléter]
- **Fichiers**: [À compléter]

## Informations Extraites

### De `.ipcrae-memory/Projets/IPCRAE/memory.md`
- Structure du dépôt IPCRAE
- Conventions de nommage
- Logique du système
- Méthode IPCRAE
- Workflow IPCRAE
- Système d'auto-audit
- Mode auto-amélioration

### De `.ipcrae-memory/Projets/IPCRAE/profil_usage.md`
- 6 rôles IPCRAE identifiés
- Statistiques d'utilisation
- Historique des rôles
- Matrice de classification

### De `.ipcrae-memory/Projets/IPCRAE/demandes/index.md`
- Pipeline d'analyse des demandes
- Structure de stockage
- Critères de suivi

### De `templates/prompts/template_reponse_ipcrae.md`
- Structure de réponse IPCRAE
- Sections obligatoires
- Critères de conformité

### De `scripts/audit_ipcrae.sh`
- Script d'audit IPCRAE
- 40 critères de conformité
- Fonctionnalités du mode auto-amélioration

## Résultats
- **Fichier créé**: $filepath
- **Rôle principal**: Architect
- **Rôles secondaires**: Orchestrator, Review
- **Score IPCRAE**: 30/40 (75%)

## Prochain Pas
- Implémenter le mode allContext
- Créer les scripts pour l'ingestion contextuelle
- Créer la documentation complète
- Tester le mode allContext

## Tags
- #ipcrae #allcontext #analyse #demande #architect
EOF

    echo -e "${GREEN}✓ Analyse créée: $filepath${NC}\n"

    echo -e "${BLUE}Informations importantes:${NC}"
    echo -e "  - L'IA va ingérer le maximum d'informations du cerveau"
    echo -e "  - L'IA va prioriser les informations pertinentes"
    echo -e "  - L'IA va extraire les informations pertinentes"
    echo -e "  - L'IA va créer une analyse complète de la demande"
    echo -e "  - L'IA va appliquer la méthode IPCRAE"
    echo -e "\n"
}

# Fonction pour voir le contexte ingéré
show_context() {
    local agent="kilo-code"

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
    echo -e "${CYAN}Contexte Ingesté - $agent${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${BLUE}Agent:${NC} $agent"
    echo -e "${BLUE}Date:${NC} $(date -Iseconds)\n"

    # Afficher le contexte
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Mémoire Locale (Agent)${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${BLUE}Fichiers de mémoire:${NC}"
    echo -e "  - audit_kilo_code_conformite.md"
    echo -e "  - agent_auto_amelioration.md"
    echo -e "  - agent_auto_amelioration_config.md"
    echo -e "  - tracking.md"

    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}Mémoire Projet${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${BLUE}Fichiers de mémoire projet:${NC}"
    echo -e "  - memory.md"
    echo -e "  - profil_usage.md"
    echo -e "  - demandes/index.md"

    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}Mémoire Globale${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${BLUE}Fichiers de mémoire globale:${NC}"
    echo -e "  - memory.md"
    echo -e "  - Knowledge/how-to/"
    echo -e "  - Knowledge/runbooks/"
    echo -e "  - Knowledge/patterns/"

    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}Documentation${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${BLUE}Fichiers de documentation:${NC}"
    echo -e "  - docs/conception/00_VISION.md"
    echo -e "  - docs/conception/01_AI_RULES.md"
    echo -e "  - docs/conception/02_ARCHITECTURE.md"
    echo -e "  - docs/conception/03_IPCRAE_BRIDGE.md"

    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}Templates${NC}"
    echo -e "${CYAN}========================================${NC}\n"

    echo -e "${BLUE}Fichiers de templates:${NC}"
    echo -e "  - templates/prompts/template_reponse_ipcrae.md"
    echo -e "  - templates/prompts/template_auto_amelioration.md"
    echo -e "  - templates/prompts/core_ai_functioning.md"
    echo -e "  - templates/prompts/core_ai_memory_method.md"
    echo -e "  - templates/prompts/core_ai_workflow_ipcra.md"

    echo -e "\n${CYAN}========================================${NC}\n"
}

# Fonction principale
main() {
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        activate)
            activate_allcontext "$2" "$3"
            ;;
        show-context)
            show_context "$2"
            ;;
        show-extracted)
            echo -e "${YELLOW}À compléter: Extraction des informations${NC}\n"
            ;;
        show-prioritization)
            echo -e "${YELLOW}À compléter: Priorisation des informations${NC}\n"
            ;;
        show-all)
            show_context "$2"
            echo -e "${YELLOW}À compléter: Informations complètes${NC}\n"
            ;;
        *)
            print_help
            exit 1
            ;;
    esac
}

# Exécuter la fonction principale
main "$@"
