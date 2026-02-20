# Noyau IA — Méthode mémoire (IPCRAE)

## Principe
- **Court terme** : `.ipcrae-project/local-notes/` → brouillons, debug, todo.
- **Projet** : `.ipcrae-project/memory/` → contraintes et décisions propres au repo.
- **Long terme global** : `.ipcrae-memory/memory/` → connaissances réutilisables multi-projets.

## Matrice de décision mémoire
- Information valable > 1 projet ? → `memory/<domaine>.md` global.
- Information spécifique stack/projet ? → `.ipcrae-project/memory/`.
- Information volatile (journal de travail, essais) ? → `local-notes/`.

## Format minimal de mémoire durable
Pour chaque entrée durable :
- **Date**
- **Contexte**
- **Décision / Pattern**
- **Pourquoi**
- **Quand réutiliser**
- **Quand ne PAS réutiliser**

## Hygiène mémoire
- Éviter les doublons entre local et global.
- Supprimer le bruit après consolidation (weekly/monthly).
- Lier vers phase/projet impacté pour navigation rapide.
