---
type: knowledge
tags: [ipcrae, howto, workflows, gtd]
project: IPCRAE
domain: devops
status: stable
sources:
  - path: docs/workflows.md
  - path: docs/conception/08_COMMANDS_REFERENCE.md
  - path: README.md
created: 2026-02-23
updated: 2026-02-23
---

# How-to — Workflows IPCRAE

## Créer un projet piloté IPCRAE
1. `ipcrae-addProject` dans le repo.
2. Remplir `docs/conception/*`.
3. Vérifier `Projets/<slug>/{index,tracking,memory}.md`.
4. Alimenter Knowledge/memory/Journal.
5. Lancer auto-audit.

## Session canonique
- `ipcrae start`
- `ipcrae work "..."`
- `ipcrae close <domaine> --project <slug>`

## Contrôle qualité
- `ipcrae-audit-check`
- `ipcrae-auto auto-audit --agent <agent> --force`
