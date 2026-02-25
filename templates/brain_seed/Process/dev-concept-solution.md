---
type: process
tags: [dev, architecture, conception, solution, process]
domain: devops
status: active
created: 2026-02-22
updated: 2026-02-22
---

# Process — Conception de Solution Logicielle

## Déclencheur
- Nouvelle fonctionnalité non triviale (>1 fichier impacté)
- Refactoring architectural
- Choix entre plusieurs approches techniques
- Avant toute implémentation de script/outil IPCRAE

## Entrées
- Description du besoin fonctionnel (quoi / pourquoi)
- Contraintes (perf, compatibilité, budget, réversibilité)
- Mémoire domaine (`memory/<domaine>.md`)
- Knowledge existante (`ipcrae tag <tag>`)

## Checklist

### Étape 1 : Clarification du besoin
- [ ] Reformuler en 1 phrase : "Ce composant fait X pour que Y puisse Z"
- [ ] Identifier : inputs, outputs, effets de bord
- [ ] Lister les contraintes non-négociables
- [ ] Vérifier si une solution existe déjà (`ipcrae search`)

### Étape 2 : Exploration des options
- [ ] Générer au moins 2 approches alternatives
- [ ] Pour chaque approche : pros/cons, complexité, réversibilité
- [ ] Identifier les risques (sécurité, perf, maintenance)

### Étape 3 : Décision et plan
- [ ] Choisir l'approche (justifier le choix)
- [ ] Décomposer en étapes testables (max 1h par étape)
- [ ] Identifier les dépendances et l'ordre d'implémentation
- [ ] Définir la Definition of Done

### Étape 4 : Documentation avant code
- [ ] Documenter la décision dans `memory/<domaine>.md` (format ### YYYY-MM-DD)
- [ ] Ajouter les tâches dans `Projets/<slug>/tracking.md`
- [ ] Créer une note Knowledge si le pattern est réutilisable

## Sorties
- Plan d'implémentation documenté dans tracking.md
- Entrée datée dans `memory/<domaine>.md`
- Note `Knowledge/patterns/` si applicable

## Definition of Done
- [ ] Besoin reformulé et validé
- [ ] Approche choisie et justifiée
- [ ] Plan décomposé en étapes testables
- [ ] Mémoire et tracking mis à jour

## Agent IA recommandé
Général (Claude Code) — utiliser ce process **avant** d'appeler agent_devops ou agent_electronique

## Process suivant recommandé
`dev-bash-specialist` (si script bash) | `dev-test` (avant merge) | `dev-review` (avant commit)
