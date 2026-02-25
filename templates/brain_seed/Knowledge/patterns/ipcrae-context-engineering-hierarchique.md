---
type: knowledge
tags: [ipcrae, context-engineering, architecture, performance]
domain: devops
status: draft
sources:
  - path: Inbox/demandes-brutes/traites/audit-passe-finale-amelioration-2026-02-22.md
created: 2026-02-24
updated: 2026-02-24
---

# Context Engineering Hiérarchique (Optimisation F)

## Concept

Remplacer le fichier monolithique `context.md` par un système de **layers** chargés sélectivement selon le besoin de la session.

## Architecture Proposée

```
.ipcrae/context/
├── layers/
│   ├── 00-system.md    # Invariants (structure IPCRAE, conventions) — toujours chargé
│   ├── 10-domain.md    # Domaine actif (devops, musique...) — chargé si domaine actif
│   ├── 20-phase.md     # Phase courante — chargé si phase active
│   ├── 30-project.md   # Projet actif — chargé si projet spécifié
│   └── 40-session.md   # Contexte volatile (debug, hypothèses) — jamais committé
├── compiled/
│   ├── full.md         # Tous layers (audit, documentation)
│   └── compact.md      # Layers 00-30 (sessions courantes)
└── index.yaml          # Quels layers charger selon domaine/phase/projet
```

## Sélection des Layers

```bash
ipcrae start --project megadocker --domain devops
# Charge : 00-system + 10-domain(devops) + 20-phase(active) + 30-project(megadocker)
# Ignore : projets dormants, autres domaines
```

## Bénéfices

| Métrique | Avant | Après |
|----------|-------|-------|
| Contexte injecté | 18 KB | 4-6 KB |
| Pertinence | 65% | 90% |
| Isolation domaines | non | oui |

## Statut

Concept validé, non implémenté. Dépend de [[howto/ipcrae-context-compact]] (prérequis simpler).

## Liens

- [[howto/ipcrae-context-compact]] — version simple (prérequis)
- [[patterns/session-boot-2-couches]] — boot session actuel
