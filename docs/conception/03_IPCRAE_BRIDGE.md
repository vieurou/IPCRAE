# IPCRAE Bridge — Contrat CDE explicite

## 1) Lecture/écriture dans `.ipcrae-memory/`
- Lire : `.ipcrae/context.md`, `.ipcrae/instructions.md`, `memory/<domaine>.md`, `Projets/<projet>/`.
- Écrire : uniquement des connaissances transverses, stables et réutilisables.
- Ne jamais y pousser du debug local, des secrets, ni des brouillons de feature.

## 2) Local projet : `.ipcrae-project/local-notes/`
- Usage : notes volatiles (debug, checklist, hypothèses, traces de session).
- Ces notes sont temporaires et doivent être consolidées ou supprimées.

## 3) Export vers `~/IPCRAE/Projets/<projet>/`
- `index.md` : état global et contexte.
- `tracking.md` : next actions et milestones.
- `memory.md` : synthèse projet consolidée.

## 4) Promotion vers `Knowledge/` (stable)
Promouvoir les patterns/how-to/runbooks réutilisables avec frontmatter canonique :

```yaml
---
type: knowledge
tags: [devops, tls, traefik, reverse-proxy]
project: ipcrae
domain: devops
status: stable
sources:
  - path: docs/conception/02_ARCHITECTURE.md
created: 2026-02-21
updated: 2026-02-21
---
```

## 5) Règle d'or d'exécution
- Cerveau requis pour IA, conception, audits, doctor CDE.
- Build/test/CI restent non bloquants : si cerveau absent, mode dégradé avec warning.
