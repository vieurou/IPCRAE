#!/bin/bash
# ===========================================================================
# ipcrae-capture-request — Capture une demande utilisateur brute dans le vault
# ===========================================================================
# Usage: ipcrae-capture-request "texte de la demande" [OPTIONS]
# Options:
#   --project <slug>     Projet concerné
#   --domain <domaine>   Domaine (devops|electronique|musique|...)
#   --title <titre>      Titre court (auto-généré si absent)
#   --status <status>    en-cours|traite|en-attente (défaut: en-cours)
# ===========================================================================

set -euo pipefail

IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"
DEST_DIR="${IPCRAE_ROOT}/Inbox/demandes-brutes"

request_text=""
project=""
domain=""
title=""
status="en-cours"

# Parser les arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)  project="${2:-}"; shift 2 ;;
    --domain)   domain="${2:-}"; shift 2 ;;
    --title)    title="${2:-}"; shift 2 ;;
    --status)   status="${2:-}"; shift 2 ;;
    --*)        echo "Option inconnue: $1" >&2; exit 2 ;;
    *)
      if [[ -z "$request_text" ]]; then
        request_text="$1"
      fi
      shift
      ;;
  esac
done

# Lire depuis stdin si pas de texte en argument
if [[ -z "$request_text" ]]; then
  if [[ ! -t 0 ]]; then
    request_text=$(cat)
  else
    echo "Usage: ipcrae-capture-request 'texte de la demande' [--project slug] [--domain domaine]" >&2
    exit 1
  fi
fi

# Générer le titre et le nom de fichier
if [[ -z "$title" ]]; then
  title=$(echo "$request_text" | head -c 60 | tr '\n' ' ' | sed 's/[^a-zA-Z0-9 àâäéèêëïîôùûü]//g' | xargs)
fi

timestamp=$(date +%Y-%m-%d-%H%M%S)
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' àâäéèêëïîôùûü' '-aaaeeeeiiouu' | \
       sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | cut -c1-40)
filename="${timestamp}-${slug:-demande}.md"
filepath="${DEST_DIR}/${filename}"

mkdir -p "$DEST_DIR"

cat > "$filepath" << EOF
---
type: demande-brute
date: $(date '+%Y-%m-%d %H:%M')
status: ${status}
project: ${project:-}
domain: ${domain:-}
---

# Demande brute — ${title}

## Texte original (VERBATIM)

${request_text}

## Traitements effectués
- [ ] (à compléter par l'agent)

## Références croisées automatiques (libellés stables)
> Ne pas renommer les libellés (facilite post-analyse et automatisation)

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

### Git / livraison
- Commits : (hash + message)
- Tags : (session-YYYYMMDD-domaine, etc.)
- PR / merge : (si applicable)

### Satisfaction demande
- Statut de satisfaction : satisfaite | partiellement satisfaite | bloquée
- Points non couverts : (liste ou "aucun")
- Réponse finale : (résumé 3-5 lignes ou lien)
EOF

echo "✓ Demande capturée: $filepath"
echo "$filepath"
