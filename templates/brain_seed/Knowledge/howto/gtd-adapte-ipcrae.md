---
type: knowledge
tags: [gtd, workflow, ipcrae, capture, clarify, organize, inbox, priorité]
domain: devops
status: active
sources:
  - project:IPCRAE/.ipcrae/context.md
  - project:IPCRAE/Process/session-start.md
  - project:IPCRAE/Process/daily.md
created: 2026-02-22
updated: 2026-02-22
---

# How-to : GTD adapté IPCRAE

## Concept
GTD (Getting Things Done) adapté au contexte IPCRAE : travail solo, assisté IA, vault Markdown versionné. La clé est que **l'IA exécute**, mais **l'humain décide des priorités** via les cycles de revue.

## Workflow quotidien

```
Capturer (Inbox/)
  ↓
Clarifier (actionnable ?)
  ├─ Non → Ressources/ | Someday/Maybe | Supprimer
  └─ Oui → < 2 min ?
       ├─ Oui → Faire maintenant
       └─ Non → Projet (multi-étapes) ou Next Action → Casquette
                Délégable (à l'IA) → ipcrae sprint
```

## Protocole Inbox (décision en < 30s)

```
Item → Actionnable ?
├─ Non → Ressources/ (ref) | Someday/Maybe | Supprimer
└─ Oui → Urgence ?
     ├─ 🔴 Urgent+Important → FAIRE maintenant (ipcrae sprint)
     ├─ 🟠 Important seul   → PLANIFIER (phase/projet tracking)
     ├─ 🟡 Urgent seul      → DÉLÉGUER ou quick-win
     └─ ⚪ Aucun            → Someday/Maybe ou supprimer
```

## Destinations par type

| Type | Destination | Commande |
|------|-------------|---------|
| Note atomique | `Zettelkasten/_inbox/` | `ipcrae zettel "titre"` |
| Connaissance réutilisable | `Knowledge/<type>/` | manuel + `ipcrae index` |
| Référence brute | `Ressources/<domaine>/` | manuel |
| Tâche projet | `Projets/<slug>/tracking.md` | manuel |
| Idée projet | `Projets/<slug>/` → `ipcrae ingest` | `ipcrae ingest --project <slug>` |
| Someday | `Objectifs/someday-maybe.md` | manuel |

## Cycles de revue

| Cycle | Quand | Durée | Déclencheur |
|-------|-------|-------|-------------|
| Daily | Matin | 5 min | `ipcrae daily` |
| Weekly | Dimanche | 30 min | `ipcrae weekly` |
| Monthly | 1er du mois | 1h | `ipcrae monthly` |
| Session | Début/fin IA | 2-5 min | `ipcrae start / close` |

## Différence GTD classique vs IPCRAE
- **Pas de liste de contextes** (lieu/outil) : tout est sur ordinateur
- **IA = délégation** : les tâches complexes vont dans `ipcrae sprint`
- **Vault = trusted system** : tout est dans les fichiers, rien dans la tête
- **Tags = navigation** : pas de hiérarchie rigide, la structure émerge

## Liens
- [[tag-first-navigation]] — Recherche par tags
- [[Process/session-start]] — Démarrage session
- [[Process/daily]] — Cycle quotidien
