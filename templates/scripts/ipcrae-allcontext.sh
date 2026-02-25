#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# IPCRAE AllContext Mode v1.0
# Pipeline d'analyse/ingestion universel
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_VERSION="1.0.0"
IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
IPCRAE_CONFIG="${IPCRAE_ROOT}/.ipcrae/config.yaml"

# ── Couleurs ──────────────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BOLD='\033[1m'; NC='\033[0m'

loginfo()  { printf '%b%s%b\n' "$GREEN"  "$*" "$NC"; }
logwarn()  { printf '%b%s%b\n' "$YELLOW" "$*" "$NC"; }
logerr()   { printf '%b%s%b\n' "$RED"    "$*" "$NC" >&2; }
section()  { printf '\n%b━━ %s ━━%b\n' "$BOLD" "$*" "$NC"; }

# ── Utilitaires ───────────────────────────────────────────────
iso_week() { date +%G-W%V; }
today()    { date +%F; }
year()     { date +%Y; }
now()      { date +"%Y-%m-%d %H:%M"; }

need_root() {
  if [ ! -d "$IPCRAE_ROOT" ]; then
    logerr "IPCRAE_ROOT introuvable: $IPCRAE_ROOT"
    exit 1
  fi
  cd "$IPCRAE_ROOT"
}

# ── Variables globales ───────────────────────────────────────
SHOW_CONTEXT=false
SHOW_EXTRACTED=false
SHOW_PRIORITIZATION=false
SHOW_ALL=false
AGENT=""
REQUEST_TEXT=""
DRY_RUN=false

# ── Fonctions du pipeline ────────────────────────────────────

### T2.1 — Étape 1: Analyse de la demande
analyze_request() {
  local request="$1"
  
  section "Analyse de la demande"
  loginfo "Demande: $request"
  
  # Analyse simple de l'intention
  local intention=""
  local objectives=""
  
  # Détection de mots-clés pour l'intention
  if echo "$request" | grep -qiE "(ajoute|crée|implémente|développe|ajouter|créer|implémenter|développer)"; then
    intention="Feature - Ajout de fonctionnalité"
  elif echo "$request" | grep -qiE "(bug|erreur|problème|fix|corrige|répare|fixer|corriger|réparer)"; then
    intention="Bug - Correction de problème"
  elif echo "$request" | grep -qiE "(audit|revue|review|vérifie|vérifier|check)"; then
    intention="Review - Audit ou revue"
  elif echo "$request" | grep -qiE "(comment|pourquoi|qu'est-ce|qu'est-ce que|comment faire|comment est-ce)"; then
    intention="Question - Recherche d'information"
  elif echo "$request" | grep -qiE "(architecture|design|conception|structure)"; then
    intention="Architecture - Conception système"
  else
    intention="Général - Analyse globale"
  fi
  
  loginfo "Intention détectée: $intention"
  
  # Extraction des objectifs principaux
  objectives=$(echo "$request" | sed 's/\.\+/\n/g' | head -3)
  
  echo "$intention"
}

### T2.2 — Étape 2: Identification des rôles
identify_roles() {
  local request="$1"
  local intention="$2"
  local roles=""
  
  section "Identification des rôles"
  
  # Mapping intention → rôles
  case "$intention" in
    "Feature - Ajout de fonctionnalité")
      if echo "$request" | grep -qiE "(architecture|design|conception|structure)"; then
        roles="Architect,Code"
      else
        roles="Code,Architect"
      fi
      ;;
    "Bug - Correction de problème")
      roles="Debug,Review"
      ;;
    "Review - Audit ou revue")
      roles="Review,Debug"
      ;;
    "Question - Recherche d'information")
      roles="Ask"
      ;;
    "Architecture - Conception système")
      roles="Architect"
      ;;
    *)
      roles="Architect,Code"
      ;;
  esac
  
  # Ajout de rôles secondaires selon les mots-clés
  if echo "$request" | grep -qiE "(test|vérifie|vérifier)"; then
    roles="$roles,Review"
  fi
  
  if echo "$request" | grep -qiE "(automatise|automatise|script|pipeline)"; then
    roles="$roles,Orchestrator"
  fi
  
  loginfo "Rôles suggérés: $roles"
  echo "$roles"
}

### T2.3 — Étape 3: Priorisation de l'information
prioritize_information() {
  local request="$1"
  local intention="$2"
  
  section "Priorisation de l'information"
  
  local priority_docs=""
  
  # Documents toujours prioritaires
  priority_docs="$priority_docs .ipcrae/context.md"
  priority_docs="$priority_docs memory/devops.md"
  
  # Documents selon l'intention
  case "$intention" in
    "Feature - Ajout de fonctionnalité"|"Bug - Correction de problème")
      priority_docs="$priority_docs Projets/IPCRAE/tracking.md"
      priority_docs="$priority_docs Process/index.md"
      ;;
    "Review - Audit ou revue")
      priority_docs="$priority_docs scripts/audit_ipcrae.sh"
      priority_docs="$priority_docs Process/auto-amelioration.md"
      ;;
    "Architecture - Conception système")
      priority_docs="$priority_docs Knowledge/patterns/"
      priority_docs="$priority_docs Process/index.md"
      ;;
  esac
  
  # Documents selon les mots-clés
  if echo "$request" | grep -qiE "(prompt|agent|instruction)"; then
    priority_docs="$priority_docs .ipcrae/prompts/"
  fi
  
  if echo "$request" | grep -qiE "(ingestion|ingest|projet)"; then
    priority_docs="$priority_docs Knowledge/howto/ingestion-projet-ipcrae.md"
  fi
  
  loginfo "Documents prioritaires identifiés:"
  echo "$priority_docs" | tr ' ' '\n' | while read -r doc; do
    [ -n "$doc" ] && loginfo "  • $doc"
  done
  
  echo "$priority_docs"
}

### T2.4 — Étape 4: Extraction des informations
extract_context() {
  local priority_docs="$1"
  local show_context="$2"
  
  section "Extraction du contexte"
  
  local context=""
  local context_count=0
  
  for doc in $priority_docs; do
    if [ -f "$IPCRAE_ROOT/$doc" ]; then
      if [ "$show_context" = true ]; then
        loginfo "Lecture: $doc"
        context="$context\n\n## $doc\n"
        context="$context$(head -50 "$IPCRAE_ROOT/$doc")"
        context_count=$((context_count + 1))
      else
        loginfo "Document trouvé: $doc"
        context_count=$((context_count + 1))
      fi
    elif [ -d "$IPCRAE_ROOT/$doc" ]; then
      if [ "$show_context" = true ]; then
        loginfo "Lecture répertoire: $doc"
        context="$context\n\n## $doc\n"
        context="$context$(ls -la "$IPCRAE_ROOT/$doc" | head -20)"
        context_count=$((context_count + 1))
      else
        loginfo "Répertoire trouvé: $doc"
        context_count=$((context_count + 1))
      fi
    fi
  done
  
  loginfo "Contexte extrait: $context_count documents"
  echo "$context"
}

### T2.5 — Étape 5: Suivi des demandes
track_request() {
  local request="$1"
  local intention="$2"
  local roles="$3"
  local priority_docs="$4"
  
  section "Suivi de la demande"
  
  # Création du répertoire si nécessaire
  mkdir -p "$IPCRAE_ROOT/Projets/IPCRAE/demandes"
  
  # Génération du nom de fichier
  local timestamp
  timestamp=$(date +"%Y-%m-%d_%H%M")
  local filename="${timestamp}_allcontext.md"
  local filepath="$IPCRAE_ROOT/Projets/IPCRAE/demandes/$filename"
  
  # Création du fichier d'analyse
  cat > "$filepath" <<EOF
---
type: analysis
tags: [ipcrae, demande, analyse, allcontext, auto-généré]
project: IPCRAE
domain: system
status: active
created: $(today)
updated: $(today)
---

# Analyse de Demande — AllContext Auto-Généré

## Informations Générales
- **Date**: $(today)
- **Heure**: $(now)
- **Demande**: "$request"
- **Type**: Feature
- **Rôle Principal**: $(echo "$roles" | cut -d',' -f1)
- **Rôles Secondaires**: $(echo "$roles" | cut -d',' -f2- | sed 's/^,//')
- **Priorité**: Normal

## Analyse de la Demande

### Intention
$intention

### Contexte Actuel
- Le mode AllContext est activé
- Le cerveau IPCRAE est analysé
- Les rôles sont identifiés automatiquement

### Besoin
Traiter la demande avec le contexte complet du système IPCRAE

## Résultats

### Rôles Identifiés
$roles

### Documents Prioritaires
$(echo "$priority_docs" | tr ' ' '\n' | sed 's/^/  - /')

## Prochaines Actions
1. Lancer l'agent avec les rôles identifiés
2. Utiliser le contexte extrait pour la décision
3. Suivre l'avancement dans le tracking

---

**Généré par**: \`ipcrae allcontext\`
**Version**: $SCRIPT_VERSION
EOF
  
  loginfo "Fichier d'analyse créé: $filepath"
  
  # Mise à jour de l'index
  update_demandes_index "$filename"
  
  echo "$filepath"
}

### T3.2 — Mise à jour de l'index des demandes
update_demandes_index() {
  local filename="$1"
  local index_file="$IPCRAE_ROOT/Projets/IPCRAE/demandes/index.md"
  
  if [ -f "$index_file" ]; then
    # Ajout à la fin de la section "Demandes du Jour"
    local today_str
    today_str=$(today)
    
    # Vérifier si la section existe
    if ! grep -q "## 📝 Demandes du Jour ($today_str)" "$index_file"; then
      # Créer la section
      sed -i "/## 📋 Demandes du Mois/i ## 📝 Demandes du Jour ($today_str)\n\n### [ ] AllContext Auto-Généré\n- **Date**: $today_str\n- **Heure**: $(date +"%H:%M")\n- **Demande\": \"$REQUEST_TEXT\"\n- **Type**: Feature\n- **Rôle Principal**: $(echo "$roles" | cut -d',' -f1)\n- **Rôles Secondaires**: $(echo "$roles" | cut -d',' -f2- | sed 's/^,//')\n- **Priorité**: Normal\n- **Statut**: ⏳ En cours\n- **Fichier**: \`$filename\`\n\n" "$index_file"
    else
      # Ajouter à la section existante
      sed -i "/## 📝 Demandes du Jour ($today_str)/a ### [ ] AllContext Auto-Généré\n- **Date**: $today_str\n- **Heure**: $(date +"%H:%M")\n- **Demande\": \"$REQUEST_TEXT\"\n- **Type**: Feature\n- **Rôle Principal**: $(echo "$roles" | cut -d',' -f1)\n- **Rôles Secondaires**: $(echo "$roles" | cut -d',' -f2- | sed 's/^,//')\n- **Priorité**: Normal\n- **Statut**: ⏳ En cours\n- **Fichier**: \`$filename\`\n" "$index_file"
    fi
    
    loginfo "Index des demandes mis à jour"
  fi
}

# ── Fonctions d'aide ───────────────────────────────────────
print_help() {
  cat <<EOF
Usage: ipcrae allcontext "<texte>" [OPTIONS]

Pipeline d'analyse/ingestion universel pour IPCRAE.

Arguments:
  "<texte>"                Demande utilisateur à analyser

Options:
  -a, --agent <nom>       Spécifier l'agent (claude|gemini|codex)
  --show-context           Afficher le contexte ingéré
  --show-extracted         Afficher les informations extraites
  --show-prioritization    Afficher la priorisation
  --show-all               Afficher toutes les informations
  --dry-run                Afficher sans créer de fichiers
  -h, --help               Afficher cette aide

Exemples:
  ipcrae allcontext "ajoute une commande pour scanner l'Inbox"
  ipcrae allcontext "implémente le mode auto-amélioration" --show-context
  ipcrae allcontext "audit le système IPCRAE" --show-all
  ipcrae allcontext "crée un pipeline d'ingestion" --agent claude --dry-run

Pipeline:
  1. Analyse de la demande (intention, objectifs)
  2. Identification des rôles (principal, secondaires)
  3. Priorisation de l'information (documents pertinents)
  4. Extraction du contexte (lecture des documents)
  5. Suivi des demandes (création fichier, index)

EOF
}

# ── Main ──────────────────────────────────────────────────────
main() {
  # Parsing des arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      -a|--agent)
        AGENT="$2"
        shift 2
        ;;
      --show-context)
        SHOW_CONTEXT=true
        shift
        ;;
      --show-extracted)
        SHOW_EXTRACTED=true
        shift
        ;;
      --show-prioritization)
        SHOW_PRIORITIZATION=true
        shift
        ;;
      --show-all)
        SHOW_CONTEXT=true
        SHOW_EXTRACTED=true
        SHOW_PRIORITIZATION=true
        SHOW_ALL=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      -h|--help)
        print_help
        exit 0
        ;;
      *)
        if [ -z "$REQUEST_TEXT" ]; then
          REQUEST_TEXT="$1"
        else
          REQUEST_TEXT="$REQUEST_TEXT $1"
        fi
        shift
        ;;
    esac
  done
  
  # Vérification des arguments
  if [ -z "$REQUEST_TEXT" ]; then
    logerr "Erreur: Aucune demande fournie"
    print_help
    exit 1
  fi
  
  need_root
  
  # Affichage du header
  printf '\n%b╔══════════════════════════════════════════════════════════════╗%b\n' "$BOLD" "$NC"
  printf '%b║%b IPCRAE AllContext Mode v%s %b║%b\n' "$BOLD" "$NC" "$SCRIPT_VERSION" "$BOLD" "$NC"
  printf '%b╚══════════════════════════════════════════════════════════════╝%b\n\n' "$BOLD" "$NC"
  
  if [ "$DRY_RUN" = true ]; then
    logwarn "Mode DRY-RUN activé — Aucun fichier ne sera créé"
  fi
  
  # Pipeline AllContext
  local intention
  intention=$(analyze_request "$REQUEST_TEXT")
  
  local roles
  roles=$(identify_roles "$REQUEST_TEXT" "$intention")
  
  local priority_docs
  priority_docs=$(prioritize_information "$REQUEST_TEXT" "$intention")
  
  local context
  context=$(extract_context "$priority_docs" "$SHOW_CONTEXT")
  
  if [ "$SHOW_EXTRACTED" = true ] || [ "$SHOW_ALL" = true ]; then
    section "Contexte extrait"
    printf '%b\n' "$context"
  fi
  
  if [ "$DRY_RUN" = false ]; then
    local analysis_file
    analysis_file=$(track_request "$REQUEST_TEXT" "$intention" "$roles" "$priority_docs")
    
    section "Résultat"
    loginfo "Demande analysée et stockée"
    loginfo "Fichier: $analysis_file"
    
    # Suggestion de commande suivante
    printf '\n%b💡 Commande suggérée:%b\n' "$YELLOW" "$NC"
    printf '  ipcrae work "%s" --agent %s\n\n' "$REQUEST_TEXT" "${AGENT:-$(get_default_provider)}"
  else
    section "Résultat (DRY-RUN)"
    loginfo "Demande analysée (aucun fichier créé)"
    loginfo "Intention: $intention"
    loginfo "Rôles: $roles"
  fi
}

# ── Fonction utilitaire pour le provider par défaut ─────────
get_default_provider() {
  if [ -f "$IPCRAE_CONFIG" ]; then
    grep -E '^default_provider:' "$IPCRAE_CONFIG" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '"' || echo "claude"
  else
    echo "claude"
  fi
}

main "$@"
