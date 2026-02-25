---
type: knowledge
tags: [ipcrae, context, optimisation, performance]
domain: devops
status: draft
sources:
  - path: Inbox/demandes-brutes/traites/audit-passe-finale-amelioration-2026-02-22.md
created: 2026-02-24
updated: 2026-02-24
---

# Compression du Contexte IPCRAE (Optimisation A)

## Problème

`context.md` peut devenir volumineux et polluer le contexte des agents, réduisant la précision.

## Solution : Compaction Hiérarchique

1. Séparer contexte **actif** (projets en cours, phase actuelle) du contexte **archivé**
2. Référencer les projets dormants par wikilink `[[project-slug]]` au lieu de contenu complet
3. Générer `context-compact.md` automatiquement lors de `ipcrae sync`

**Impact attendu** : réduction 40-60% taille contexte, amélioration précision agents.

## Implémentation

```bash
# Dans sync_providers() : générer context-compact.md
# Garder uniquement : phase active, projets actifs (status != dormant/archived),
# mémoire domaine courant, top 3 next actions
ipcrae sync  # génère context.md + context-compact.md
```

## KPIs

- Taille contexte agent : 18 KB → objectif 5 KB
- Pertinence réponses : baseline → +20%

## Liens

- [[patterns/workflow-dev-ipcrae]] — workflow de déploiement
- [[howto/verifier-uniquement-sections-critiques-1-4]] — audit incrémental lié
- [[howto/ipcrae-sync-providers]] — sync providers
