#!/bin/bash

# IPCRAE Capture Request (v2)
#
# Capture une demande brute et la sauvegarde dans l'Inbox avec métadonnées.
# Doc: Knowledge/howto/capture-demande-brute.md

set -euo pipefail

# --- Variables & Constantes ---
if [[ -z "${IPCRAE_ROOT:-}" ]]; then
  IPCRAE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

DEST_DIR="${IPCRAE_ROOT}/Inbox/demandes-brutes"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
DATE_ISO=$(date "+%Y-%m-%d %H:%M")

# --- Fonctions ---
show_help() {
  cat << EOF
Utilisation: $(basename "$0") "demande..." [--project <slug>] [--domain <domaine>] [--title "<titre>"]
       echo "demande..." | $(basename "$0") [--project <slug>] ...

Capture une demande brute et la sauvegarde dans Inbox/demandes-brutes/.

Options:
  --project <slug>    Slug du projet associé.
  --domain <domaine>  Domaine de connaissance associé.
  --title "<titre>"   Titre court pour la demande.
  -h, --help          Affiche cette aide.
EOF
}

# Slugify function
slugify() {
  echo "$1" | iconv -t ascii//TRANSLIT | sed -r 's/[^a-zA-Z0-9]+/-/g' | sed -r 's/^-+\|-+$//g' | tr '[:upper:]' '[:lower:]'
}

# --- Parsing des Arguments ---
PROJECT_SLUG="non-specifie"
DOMAIN="general"
TITLE=""
REQUEST_CONTENT=""

# Gérer l'entrée depuis stdin en premier
if ! [ -t 0 ]; then
    REQUEST_CONTENT=$(cat)
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT_SLUG="$2"
      shift 2
      ;;
    --domain)
      DOMAIN="$2"
      shift 2
      ;;
    --title)
      TITLE="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    -*) # C'est une option non reconnue
      echo "Erreur: Option non reconnue: $1" >&2
      show_help
      exit 1
      ;;
    *) # C'est l'argument positionnel (la demande)
      if [[ -n "$REQUEST_CONTENT" ]]; then
        echo "Erreur: La demande a été fournie à la fois via stdin et en argument." >&2
        exit 1
      fi
      REQUEST_CONTENT="$1"
      shift
      ;;
  esac
done

# Vérifier que le contenu de la requête n'est pas vide
if [[ -z "$REQUEST_CONTENT" ]]; then
    echo "Erreur: Aucune demande fournie." >&2
    show_help
    exit 1
fi

# --- Logique Principale ---

# Créer un titre et un slug si non fournis
if [[ -z "$TITLE" ]]; then
  TITLE=$(echo "$REQUEST_CONTENT" | cut -d ' ' -f 1-5)...
fi
SLUG=$(slugify "$TITLE")

# Construire le nom de fichier
FILENAME="${TIMESTAMP}-${SLUG}.md"
FILE_PATH="${DEST_DIR}/${FILENAME}"

# Créer le dossier s'il n'existe pas
mkdir -p "$DEST_DIR"

# Générer le contenu du fichier avec frontmatter
cat > "$FILE_PATH" << EOF
---
type: demande-brute
date: ${DATE_ISO}
status: en-cours
project: ${PROJECT_SLUG}
domain: ${DOMAIN}
---

# Demande brute — ${TITLE}

## Texte original (VERBATIM)
${REQUEST_CONTENT}

## Traitements effectués
- [ ] ...

## Références
- Fichiers créés :

## Références croisées automatiques (libellés stables)
### Décomposition / exécution
- Plan / décomposition : (lien vers plan publié / tracking / note)
- Réexamen fin de traitement : (OK | partiel | bloqué) — Process/reexamen-fin-traitement-demande

### Artefacts IPCRAE produits
- Fichiers créés/modifiés : (liste concise)
- Knowledge créées : (paths)
- Process créés/modifiés : (paths)
- Mémoire domaine mise à jour : (memory/<domaine>.md + entrée)
- Mémoire système mise à jour : (memory/system.md + entrée)
- Journal mis à jour : (path)
- Tracking projet mis à jour : (path)

### Imports bruts / sources brutes (obligatoire si présent)
- Imports bruts utilisés : (paths exacts, ex: Ressources/..., Inbox/infos à traiter/...)
- Origine des imports bruts : (email, web, dump, notes, etc.)
- Liens vers tâches/artefacts : (Tasks/to_ai/... + Knowledge/... + Process/... + Journal/...)
- Statut d'intégration : (ingéré | partiel | à compacter)

### Git / livraison
- Commits : (hash + message)
- Tags : (session-YYYYMMDD-domaine, etc.)
- PR / merge : (si applicable)

### Satisfaction demande
- Statut de satisfaction : satisfaite | partiellement satisfaite | bloquée
- Points non couverts : (liste ou "aucun")
- Réponse finale : (résumé 3-5 lignes ou lien)
EOF

echo "Demande capturée avec succès dans: ${FILE_PATH}"
