---
type: process
tags: [ipcrae, workflow, pretraitement, agent, methodology]
domain: system
status: active
created: 2026-02-23
updated: 2026-02-23
---

# Process : Pré-traitement des demandes utilisateur

> Procédure récurrente — s'applique à CHAQUE demande reçue par un agent IA.

## Déclencheur
Toute nouvelle demande utilisateur, quelle que soit son urgence apparente.

## Séquence

```
Demande reçue
    │
    ├─ 1. IDENTIFIER le projet/domaine concerné
    │      → .ipcrae-project/memory/project.md
    │      → Phases/index.md
    │
    ├─ 2. CONSULTER la mémoire
    │      → memory/<domaine>.md
    │      → .ipcrae-project/memory/
    │
    ├─ 3. RECHERCHER les KI (tag-first)
    │      → ipcrae tag <tag>
    │      → Knowledge/
    │      → Conversations passées pertinentes
    │
    ├─ 4. RECONSTRUIRE un prompt optimisé
    │      → Objectif + Contexte + Contraintes + Critères de done
    │
    └─ 5. AGIR sur le prompt optimisé
           → Étapes testables et traçables
```

## Critères de validation
- [ ] Contexte projet consulté
- [ ] Mémoire domaine lue
- [ ] Recherche KI/tags effectuée
- [ ] Prompt optimisé formulé avant action

## Anti-pattern
Ne JAMAIS passer directement de l'étape 1 à l'étape 5 (= réagir sans réfléchir).
L'urgence perçue n'est pas une excuse pour sauter les étapes 2-4.

## Référence
Voir : `templates/prompts/core_ai_pretreatment_gate.md`
