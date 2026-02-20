# Règles de l'IA pour le projet IPCRAE

## 1. Stack Technique & Conventions
- **Langages** : Bash (Bourne Again SHell).
- **Style** : Posix-compliant (si possible) et robuste (`set -euo pipefail`).
- **Tests** : BATS (Bash Automated Testing System) pour la ligne de commande.

## 2. Librairies Interdites / Autorisées
- **Interdit** : Dépendances externes exotiques évitées. Tout doit fonctionner sur Ubuntu/Debian standard (Bash, sed, awk, grep).
- **Autorisé** : Commandes natives UNIX. `python3` ou `curl` utilisés uniquement pour des fallbacks vitaux.

## 3. Workflow de Validation
Tout script doit passer l'analyse syntaxique stricte avec `bash -n script.sh` avant d'être validé.
Les modifications structurelles doivent être testées (dry-run existant `-d`).

