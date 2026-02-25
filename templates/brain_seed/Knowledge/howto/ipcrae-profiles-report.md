---
type: knowledge
tags: [ipcrae, profils, metriques, reporting]
domain: devops
status: draft
sources:
  - path: Inbox/demandes-brutes/traites/audit-passe-finale-amelioration-2026-02-22.md
created: 2026-02-24
updated: 2026-02-24
---

# Métriques de Performance des Profils (Optimisation B)

## Problème

`profil_usage.md` enregistre les sessions mais ne calcule pas de métriques agrégées. Impossible d'identifier les rôles IA sous-utilisés ou défaillants.

## Solution : Script ipcrae-profiles-report

Analyser `Projets/*/profil_usage.md` pour générer :
- Fréquence d'utilisation par rôle (lead / assistant / domaine)
- Taux de conformité par session (bootstrap validé ou non)
- Rôles jamais utilisés depuis N jours
- Sessions avec écarts par rapport aux conventions

## Format de sortie

```
─── Rapport Profils — 30 derniers jours ───
Sessions total : 12
Rôle le plus actif : devops (8 sessions)
Rôle dormant : finance (0 session > 30j) → ipcrae consolidate finance
Taux conformité bootstrap : 67% (8/12)
```

## Implémentation cible

```bash
ipcrae profiles-report [--days 30] [--project <slug>]
```

Lit : `Projets/*/profil_usage.md` + `memory/*.md` (dates d'entrée)

## Liens

- [[howto/session-protocol-ipcrae]] — protocole de session
- [[howto/ipcrae-agent-bootstrap]] — bootstrap conformité
