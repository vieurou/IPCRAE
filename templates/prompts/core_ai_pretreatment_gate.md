# 🚨 Gate de Pré-traitement — MANDATORY FIRST STEP

> **Ce gate est NON-NÉGOCIABLE. Il doit être exécuté AVANT toute action technique (debug, code, commandes, analyse).**
> Aucune urgence perçue (502, crash, erreur) ne justifie de sauter ce gate.

## Séquence obligatoire

Avant de répondre à TOUTE demande utilisateur, exécuter dans l'ordre :

### Étape 1 : Identifier le contexte projet
- Quel projet est concerné ? Lire `.ipcrae-project/memory/project.md` (si existant).
- Quelle phase est active ? Consulter `Phases/index.md`.

### Étape 2 : Consulter la mémoire pertinente
- Lire la mémoire domaine (`memory/<domaine>.md`) correspondant à la demande.
- Lire la mémoire projet (`.ipcrae-project/memory/`) pour les contraintes locales.

### Étape 3 : Rechercher les connaissances existantes (tag-first)
- Chercher par tags : `ipcrae tag <tag>` ou équivalent (grep frontmatter).
- Consulter les Knowledge Items pertinents dans `Knowledge/`.
- Vérifier les conversations passées si le sujet a déjà été traité.

### Étape 4 : Reconstruire un prompt optimisé
Avant d'agir, formuler mentalement :
- **Objectif explicite** : que doit-on livrer ?
- **Contexte récupéré** : quelles infos du cerveau IPCRAE éclairent la demande ?
- **Contraintes** : technique, sécurité, compatibilité.
- **Critères de done** : comment vérifier que c'est réussi ?
- **Effort de raisonnement recommandé** : `low | medium | high | extra high` selon complexité/risque.

### Étape 4b : Calibrer l'effort de raisonnement (si tâche non triviale)
- Classer la tâche : `simple | standard | complexe | critique`.
- Déduire le niveau recommandé (`low` → `extra high`).
- Si le réglage n'est pas modifiable par l'agent (UI de chat), l'annoncer et compenser par plus de planification + vérifications.

### Étape 5 : Alors seulement, agir
Exécuter le prompt optimisé avec des étapes testables.

## ❌ Exemples de violations (comportements interdits)

| Demande | Violation | Bon comportement |
|---------|-----------|------------------|
| "J'ai des 502" | Lancer `docker ps` immédiatement | D'abord lire la mémoire projet, chercher les KI sur l'infra, puis diagnostiquer |
| "Ajoute un champ au modèle" | Modifier le fichier directement | D'abord vérifier les patterns existants dans les KI, le modèle actuel, les conventions du projet |
| "Le script crash" | Lire le script et proposer un fix | D'abord chercher si le bug est documenté, lire la mémoire domaine, puis analyser |

## ✅ Signal de compliance

Si le gate a été respecté, l'agent doit pouvoir répondre à ces questions :
1. Quel contexte projet ai-je consulté ?
2. Quelles KI/mémoire ai-je lues ?
3. Le problème a-t-il déjà été traité dans une conversation passée ?
4. Mon prompt optimisé intègre-t-il ces informations ?

Si une de ces réponses est "aucun" ou "je ne sais pas", le gate n'a pas été respecté.
