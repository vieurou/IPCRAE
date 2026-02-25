---
type: knowledge
tags: [sprint, autonome, tâches, ipcrae, agent, workflow]
domain: devops
status: active
sources:
  - project:IPCRAE/.ipcrae/prompts/prompt_sprint.md
  - project:IPCRAE/Process/session-start.md
created: 2026-02-22
updated: 2026-02-22
---

# How-to : Sprint autonome IPCRAE

## Concept
`ipcrae sprint` collecte les tâches `[ ]` des trackings et les exécute en boucle autonome, sans intervention manuelle entre chaque tâche. C'est la commande pour "donner du travail à l'IA et partir".

## Usage

```bash
# Sprint sur le projet du CWD
ipcrae sprint

# Sprint sur un projet spécifique
ipcrae sprint --project <slug>

# Sprint limité à N tâches
ipcrae sprint --max-tasks 3

# Voir le plan sans exécuter
ipcrae sprint --dry-run

# Exécution sans confirmation
ipcrae sprint --auto
```

## Sources de tâches (par priorité)
1. `Projets/<slug>/tracking.md` (projet du CWD en priorité)
2. `Phases/index.md` (tâches phase active)
3. Tous les trackings de projets actifs (fallback)

## Ce que le sprint fait
1. Collecte les `- [ ]` (non cochées) des sources
2. Déduplique et trie par priorité (🔴 > 🟠 > 🟡 > ⚪)
3. Présente le plan (ou exécute directement avec `--auto`)
4. Exécute chaque tâche, coche `[x]` quand terminé
5. Commit le vault après chaque lot

## Quand utiliser le sprint vs le travail manuel
- **Sprint** : liste de tâches claires, séquentielles, bien définies
- **Travail manuel** : tâches floues, demandant des décisions humaines, architecturales

## Liens
- [[Process/session-start]] — Démarrer avant de sprinter
- [[gtd-adapte-ipcrae]] — Workflow GTD source des tâches
- [[workflow-dev-ipcrae]] — Dev workflow à utiliser pendant le sprint
