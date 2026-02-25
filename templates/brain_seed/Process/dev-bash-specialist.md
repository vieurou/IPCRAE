---
type: process
tags: [dev, bash, shell, script, process]
domain: devops
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Process — Spécialiste Bash / Scripts Shell

## Déclencheur
- Écriture d'un nouveau script shell
- Modification d'un script existant
- Débogage comportement inattendu d'un script
- Avant d'exécuter un script sur le vault ou un système prod

## Entrées
- Objectif du script (une phrase)
- Entrées/sorties attendues
- Environnement cible (bash/zsh, version, OS)
- Contraintes (portabilité, perf, idempotence)

## Checklist

### Étape 1 : Structure obligatoire
- [ ] Shebang strict : `#!/bin/bash` avec `set -euo pipefail`
- [ ] Usage/aide inline (`--help`)
- [ ] Variables capitalisées pour les globales
- [ ] `IPCRAE_ROOT="${IPCRAE_ROOT:-${HOME}/IPCRAE}"` (jamais hardcodé)
- [ ] Fonctions nommées en snake_case

### Étape 2 : Sécurité et robustesse
- [ ] Vérifier existence des fichiers/dossiers avant accès
- [ ] Jamais `rm -rf` sans confirmation ou `--dry-run`
- [ ] Citer les variables : `"$var"` (jamais `$var` non cité)
- [ ] Tester avec `--dry-run` avant exécution réelle
- [ ] Éviter `eval` et injections de commandes

### Étape 3 : Portabilité
- [ ] Tester sur bash 4+ (macOS a bash 3 par défaut → attention)
- [ ] Éviter les extensions non-POSIX si portabilité requise
- [ ] Préférer `command -v` à `which`
- [ ] `declare -A` (associatif) nécessite bash 4+

### Étape 4 : Tests manuels
- [ ] Test chemin nominal (inputs valides)
- [ ] Test cas limites (fichier absent, dossier vide, caractères spéciaux)
- [ ] Test `--dry-run` ne modifie rien
- [ ] Test idempotence (re-run donne même résultat)

### Étape 5 : Installation et documentation
- [ ] `chmod +x` appliqué
- [ ] Copié dans `~/bin/` si commande utilisateur
- [ ] Ajouté à `ipcrae-install.sh` section correspondante
- [ ] Entrée dans `Knowledge/howto/` si comportement non-trivial

## Anti-patterns à éviter
- `set -e` seul sans `-u` et `-o pipefail`
- Parsing d'arguments sans `case/while`
- Hardcoder `$HOME/IPCRAE` → utiliser `$IPCRAE_ROOT`
- `ls | while read` → utiliser `find -print0 | while read -r -d ''`
- `[` au lieu de `[[` dans bash

## Sorties
- Script fonctionnel dans `DEV/IPCRAE/scripts/`
- Installé dans `~/bin/` si commande utilisateur
- Tests passants

## Definition of Done
- [ ] `shellcheck` passe sans erreur (ou warnings justifiés)
- [ ] Tests cas nominaux + limites OK
- [ ] `--dry-run` fonctionnel si script modifie des fichiers
- [ ] Ajouté à l'installateur si distribué

## Agent IA recommandé
Claude Code (général) — expertise bash native

## Process suivant recommandé
`dev-test` → `dev-review`
