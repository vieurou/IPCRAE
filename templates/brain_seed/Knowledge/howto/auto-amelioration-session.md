---
type: howto
tags: [ipcrae, auto-amelioration, audit, methode, process]
domain: devops
status: active
created: 2026-02-22
updated: 2026-02-22
sources:
  - project:IPCRAE/Process/auto-amelioration.md
  - project:IPCRAE/Process/session-close.md
---

# Howto — Session d'auto-amélioration IPCRAE

## Contexte

Ce guide documente la procédure pour effectuer une session d'auto-amélioration du système IPCRAE selon la méthode v3.3.

## Pré-requis

- `IPCRAE_ROOT` exporté dans le shell
- `ipcrae-audit-check` et `ipcrae-auto-apply` installés dans `~/bin/`
- Mode auto-amélioration activé (fichier `.ipcrae/auto/last_audit_*.txt` présent)

## Étapes clés

### 1. Démarrer la session
```bash
ipcrae start --project IPCRAE --domain devops
```

### 2. Lancer l'audit initial
```bash
IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae-audit-check
```

Identifier les gaps critiques et mineurs. Dans notre cas :
- Score initial : 59/60 (98%)
- Gap unique : 1 demande brute non traitée

### 3. Traiter les gaps identifiés

Pour chaque gap :
- **Gap vault** : Compléter directement le fichier concerné
- **Gap code** : Corriger dans `DEV/IPCRAE/scripts/` → PR → merge immédiat
- **Gap méthode** : Mettre à jour les instructions/prompts → `ipcrae sync`

Exemple de traitement de demande brute :
```bash
# Marquer comme traitée
sed -i 's/status: en-cours/status: traite/' Inbox/demandes-brutes/*.md
# Déplacer vers traitées
mv Inbox/demandes-brutes/2026-02-22-*.md Inbox/demandes-brutes/traites/
```

### 4. Appliquer les corrections automatiques
```bash
IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae-auto-apply --auto
```

### 5. Vérifier l'amélioration
```bash
IPCRAE_ROOT="$IPCRAE_ROOT" ipcrae-audit-check
```

Dans notre cas : Score amélioré à 60/60 (100%)

### 6. Mettre à jour les fichiers obligatoires

- **memory/devops.md** : Ajouter entrée datée
- **Projets/IPCRAE/tracking.md** : Cocher la tâche dans Done
- **Journal/Daily/YYYY/YYYY-MM-DD.md** : Documenter la session

### 7. Clôturer la session
```bash
ipcrae close devops --project IPCRAE
```

## Checklist de qualité

- [x] Score vault calculé avant/après
- [x] Cerveau global vérifié (memory, tracking, journal)
- [x] Gaps identifiés et corrigés
- [x] Corrections automatiques appliquées
- [x] Delta score documenté
- [x] Session clôturée (commit + push + tag)

## Résultats typiques

- **Score initial** : 59/60 (98%)
- **Gap identifié** : 1 demande brute non traitée
- **Actions** : Traitement de la demande + analyse méthode
- **Score final** : 60/60 (100%)
- **Améliorations** : Documentation mise à jour, processus clarifié

## Prochaines étapes recommandées

1. Automatiser le traitement des demandes brutes via script dédié
2. Ajouter des cron jobs pour l'audit quotidien
3. Créer un guide rapide pour les nouveaux utilisateurs
4. Documenter les exemples concrets dans `docs/examples/`

## Voir aussi

- [[Process/auto-amelioration.md]] — Procédure complète
- [[Process/session-close.md]] — Clôture de session
- [[Knowledge/patterns/auto-amelioration-ipcrae.md]] — Pattern d'auto-amélioration