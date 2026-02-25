---
type: knowledge
tags: [ipcrae, ingestion, workflow, projet, cerveau-global]
project: IPCRAE
domain: devops
status: draft
sources:
  - project:IPCRAE/templates/prompts/prompt_ingest.md
  - project:IPCRAE/docs/conception/03_IPCRAE_BRIDGE.md
created: 2026-02-21
updated: 2026-02-21
---

# How-to : Ingestion d'un nouveau projet dans le cerveau IPCRAE

## Contexte
Quand un projet local est initialisé avec `ipcrae-addProject`, il faut procéder à une **ingestion IA** pour peupler le cerveau global (`~/IPCRAE`) avec la connaissance extraite du projet.

La commande déclenchante est : `ipcrae ingest <domaine> --project <slug>`

## Workflow ordonné (queue de tâches, exécuter dans cet ordre)

### PHASE 1 — Analyse projet (bloq toutes les autres phases)
1. Lire `README.md`, `docs/conception/00_VISION.md`, `01_AI_RULES.md`, `02_ARCHITECTURE.md`
2. Identifier : langage, stack, architecture, patterns, dettes techniques
3. Lire `ipcrae-install.sh` ou le code source principal
4. Identifier incohérences doc vs code

### PHASE 2 — Référencement cerveau (parallélisable après Phase 1)
5. Mettre à jour `Projets/<slug>/index.md` (domaine, description, next)
6. Mettre à jour `Projets/<slug>/memory.md` (synthèse technique)
7. Mettre à jour `Projets/<slug>/tracking.md` (next actions + milestones)
8. Mettre à jour `.ipcrae/context.md` section "Projets en cours"
9. Mettre à jour `memory/<domaine>.md` (décisions, contraintes, erreurs)

### PHASE 3 — Extraction Knowledge (après Phase 1)
10. Pour chaque pattern/howto/runbook réutilisable identifié : créer `Knowledge/<type>/<nom>.md` avec frontmatter canonique
11. Chaque note Knowledge doit être autonome et taggée

### PHASE 4 — Zettelkasten (après Phase 1)
12. Pour chaque concept atomique universel (pas spécifique au projet) : créer `Zettelkasten/_inbox/<id>-<slug>.md`
13. Chaque note Zettelkasten = une seule idée, formulée dans ses propres mots, liée à d'autres notes

### PHASE 5 — Journal de session
14. Créer `Journal/Daily/<YYYY>/<YYYY-MM-DD>.md` avec entrée de la session d'ingestion
15. Format : ce qui a été fait, ce qui a été appris, prochaine action

### PHASE 6 — Auto-audit qualité (toujours en dernier)
16. Vérifier : ai-je couvert tous les concepts IPCRAE (MOC, Casquette, Objectif, Ressource) ?
17. Vérifier : les fichiers créés ont-ils un frontmatter complet ?
18. Vérifier : les liens Zettelkasten sont-ils cohérents ?
19. Vérifier : tracking.md a-t-il des next actions concrètes ?
20. Proposer des améliorations au prompt d'ingestion si des lacunes ont été détectées

## Checklist Definition of Done

- [ ] `Projets/<slug>/index.md` — domaine + description remplis
- [ ] `Projets/<slug>/memory.md` — synthèse technique présente
- [ ] `Projets/<slug>/tracking.md` — au moins 3 next actions concrètes
- [ ] `memory/<domaine>.md` — au moins 1 entrée datée
- [ ] Au moins 1 note `Knowledge/`
- [ ] Au moins 1 note `Zettelkasten/_inbox/`
- [ ] Journal de session créé
- [ ] `.ipcrae/context.md` mis à jour

## Erreurs à éviter
- Ne pas se contenter d'éditer les docs/conception sans toucher au cerveau global
- Ne pas créer des Knowledge/Zettelkasten sans frontmatter complet
- Ne pas oublier le journal de session (traçabilité)
- Ne pas faire l'auto-audit avant d'avoir fini les phases 2-5
