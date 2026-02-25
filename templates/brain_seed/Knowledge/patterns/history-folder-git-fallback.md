---
type: knowledge
tags: [git, vscode, local-history, rollback, securite]
domain: devops
status: stable
created: 2026-02-24
updated: 2026-02-24
---

# .history/ comme filet de secours Git

## Règle

Le dossier `.history/` (généré par l'extension VS Code "Local History") ne doit
**jamais** être ajouté au `.gitignore`.

## Pourquoi

Il sert de filet de secours local si git est inaccessible ou défaillant :
- remote injoignable (SSH coupé, GitHub down)
- repo corrompu
- commit accidentel sans possibilité de push
- perte d'accès au remote

VS Code sauvegarde automatiquement un historique versionné des fichiers dans `.history/`,
indépendamment de git.

## Convention

- `.history/` → **untracked** (pas dans `.gitignore`, pas commité)
- Présent localement comme sauvegarde d'urgence
- Jamais pushé (contient des états intermédiaires bruyants)

## Contrepartie

Ne pas confondre avec un vrai backup : `.history/` est local uniquement.
Si le disque est perdu → git reste la seule source de vérité.

## Ordre de priorité rollback

1. `git revert` / `git reset` (préféré — versionné, partageable)
2. `.history/` (local — si git inaccessible)
3. Backup disque (dernier recours)
