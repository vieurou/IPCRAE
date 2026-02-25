---
type: process
tags: [ipcrae, workflow, pretraitement, agent, methodology]
domain: system
status: active
created: 2026-02-23
updated: 2026-02-25
---

# Process : Pré-traitement des demandes utilisateur (optimisé)

> Procédure récurrente appliquée à toute demande, avec mode normal et mode dégradé.

## Déclencheur
Toute nouvelle demande utilisateur (feature, bug, audit, question, urgence perçue).

## Pipeline

```
Demande reçue
    │
    ├─ 1) Identifier le contexte actif
    │    - repo/projet cible
    │    - phase/objectif en cours
    │
    ├─ 2) Charger la mémoire minimale utile
    │    - memory/<domaine>.md
    │    - .ipcrae-project/memory/
    │
    ├─ 3) Rechercher l'existant (tag-first)
    │    - Knowledge/
    │    - Process/
    │    - décisions déjà documentées
    │
    ├─ 4) Préparer le plan d'exécution
    │    - objectif + contraintes + DoD
    │    - tests/checks à lancer
    │
    └─ 5) Exécuter de façon traçable
         - étapes atomiques
         - mise à jour des artefacts de suivi
         - validation finale
```

## SLA qualité (rapide)
- Pré-traitement terminé en **< 3 minutes** sur tâche standard.
- Pas plus de **5 sources** ouvertes avant de démarrer (sauf cas complexe).
- Chaque livrable inclut au moins **1 vérification** (test, check, commande).

## Critères de validation
- [ ] Contexte projet identifié
- [ ] Mémoire pertinente consultée (ou absence signalée)
- [ ] Recherche d'existant effectuée
- [ ] Plan + DoD définis avant action
- [ ] Vérification finale exécutée

## Mode dégradé
Si mémoire/projet/knowledge manquant :
- Continuer sans bloquer.
- Mentionner explicitement les limites de contexte.
- Proposer une action corrective (ex: seed mémoire, création process/runbook).

## Anti-patterns
- Réagir immédiatement sans vérifier l'existant.
- Ouvrir un trop grand volume de contexte non nécessaire.
- Livrer sans test/check ni preuve.

## Références
- `templates/prompts/core_ai_pretreatment_gate.md`
- `templates/prompts/core_ai_workflow_ipcra.md`
