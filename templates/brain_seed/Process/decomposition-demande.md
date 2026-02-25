---
type: process
tags: [decomposition, demande, reflexion, pretraitement, ipcrae, meta-cognition, workflow]
domain: all
status: active
created: 2026-02-22
updated: 2026-02-23
---

# Process — Décomposition des Demandes Complexes

## Déclencheur

À exécuter **avant toute demande complexe** (> 2 actions, multi-domaines, ambiguë, ou incluant "continue").

## Étapes

### 1. Capture verbatim (30s)

Si la demande n'est pas encore dans `Inbox/demandes-brutes/`, la capturer :
```bash
ipcrae-capture-request "texte verbatim" --project <slug> --domain <domaine>
```

### 2. Reconstruction du contexte (1 min)

Lire dans cet ordre :
1. `.ipcrae/context.md` → domaine/projet actif
2. `memory/<domaine>.md` → décisions passées pertinentes
3. `Projets/<slug>/tracking.md` → tâches In Progress

### 3. Décomposition en tâches atomiques (2 min)

Appliquer le template de décomposition (cf. `Knowledge/patterns/pretraitement-demande-ipcrae.md`) :
- Identifier l'objectif réel (pas forcément ce qui est dit littéralement)
- Lister les sous-tâches atomiques (une tâche = une action vérifiable)
- Prioriser selon la matrice GTD (🔴🟠🟡⚪)

### 4. Inventaire concepts IPCRAE applicables (1 min)

Cocher les concepts IPCRAE pertinents pour cette demande :
- [ ] GTD workflow (priorisation)
- [ ] Knowledge (notes réutilisables à créer ?)
- [ ] Zettelkasten (insight atomique à capturer ?)
- [ ] Process (process à suivre ou créer ?)
- [ ] Casquette (quel rôle actif ?)
- [ ] Phase (aligné avec phase active ?)
- [ ] Auto-amélioration (audit à faire ?)
- [ ] MOC (cluster de notes à regrouper ?)

### 5. Validation du plan vs IPCRAE (30s)

Vérifier :
- Le plan respecte-t-il les process documentés ? (`Process/index.md`)
- Y a-t-il un Process existant à suivre plutôt qu'improviser ?
- Le plan exploite-t-il tous les concepts IPCRAE pertinents ?
- Des concepts sont-ils explicitement *exclus* ? Pourquoi ?

### 6. Afficher la décomposition à l'utilisateur

Avant d'exécuter, publier le plan structuré pour validation implicite.
(Pas besoin d'attendre une confirmation si le plan est évident.)

### 7. Exécuter par étapes vérifiables

Cocher `[x]` au fil de l'eau dans `tracking.md`, pas en vrac à la fin.

### 8. Réexamen de fin de traitement (boucle fermée)

Avant la réponse finale, relire la demande brute et vérifier la satisfaction complète via :
- `Process/reexamen-fin-traitement-demande.md`

Objectif : confirmer que la demande est satisfaite **après décomposition**, pas seulement que des fichiers ont été modifiés.

## Sorties attendues

- Demande brute capturée dans `Inbox/demandes-brutes/`
- Plan décomposé visible (publié dans la réponse)
- Tâches créées dans `tracking.md` section In Progress
- Concepts IPCRAE non-applicables explicitement exclus (avec raison)
- Réexamen final effectué (demande brute ↔ actions ↔ artefacts ↔ réponse)

## Agent IA recommandé

Tous agents — ce process est universel.

## Liens
- [[Knowledge/patterns/pretraitement-demande-ipcrae]] — Template décomposition
- [[Process/reexamen-fin-traitement-demande]] — Vérification de satisfaction complète avant réponse finale
- [[Process/verification-travail]] — Vérification post-exécution
- [[Process/auto-amelioration]] — Auto-audit post-session
