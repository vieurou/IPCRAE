# Architecture et Décisions Techniques IPCRAE

## 1. Structure Globale
L'application se compose de :
- Un fichier d'installation racine `ipcrae-install.sh`.
- Un dossier `templates/` contennant les exécutables génériques (`ipcrae-launcher.sh` et `ipcrae-init-conception.sh`).
- Un dossier `templates/prompts/` contenant les prompts natifs pour les AI.
Les exécutables sont générés et placés dans `~/bin/`.

## 2. Décisions de Conception (ADR)
- **ADR-001** : Fusion stricte dans `.ipcrae/` pour l'installation, sans multiplier les fichiers cachés.
- **ADR-002** : Extraction des hardcoded prompt templates vers `templates/prompts/` pour isoler le Bash de la logique IA.
- **ADR-003** : Renommage complet IPCRA en IPCRAE pour matérialiser la `v3.1`.

## 3. Schéma de Données / API
- `.ipcrae/config.yaml` : Gère le mapping dynamique du répertoire d'installation `IPCRAE_ROOT` et du `default_provider`.
- `memory/[domaine].md` : Le hub principal d'acquisition de connaissances.

