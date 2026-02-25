---
type: knowledge
tags: [ipcrae, audit, performance, differentiel]
domain: devops
status: draft
sources:
  - path: Inbox/demandes-brutes/traites/audit-passe-finale-amelioration-2026-02-22.md
  - path: Inbox/demandes-brutes/traites/2026-02-23-vuirifier-uniquement-sections-critiques.md
created: 2026-02-24
updated: 2026-02-24
---

# Audit Incrémental Différentiel (Optimisation C)

## Problème

L'audit complet re-vérifie tous les critères à chaque exécution, même quand rien n'a changé.

## Solution : Mode Différentiel

**Règle** : si dernier audit < 1h ET score > 50/60 → vérifier uniquement sections critiques 1 et 4.

```bash
ipcrae audit --fast   # sections 1+4 uniquement (< 30s)
ipcrae audit --full   # audit complet (toutes sections)
```

**Sections critiques** :
- Section 1 — Synchronisation système (git status, context.md à jour)
- Section 4 — Git & Workflow (commits récents, push fait)

**Impact** : réduction 70% du temps d'exécution pour audits fréquents.

## Cache audit

Stocker dans `.ipcrae/cache/last-audit.json` :
```json
{ "timestamp": "2026-02-24T12:00:00", "score": 58, "sections": {...} }
```

## Voir aussi

- [[howto/verifier-uniquement-sections-critiques-1-4]] — implémentation détaillée (1035 lignes)
- [[patterns/auto-amelioration-ipcrae]] — boucle auto-amélioration
