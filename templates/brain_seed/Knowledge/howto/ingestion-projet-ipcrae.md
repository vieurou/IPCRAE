---
type: knowledge
tags: [ingestion, projet, ipcrae, workflow, knowledge, zettelkasten, hub]
domain: devops
status: active
sources:
  - project:IPCRAE/.ipcrae/prompts/prompt_ingest.md
  - project:IPCRAE/Process/process-ingest-projet.md
created: 2026-02-22
updated: 2026-02-22
---

# How-to : Ingestion d'un nouveau projet dans IPCRAE

## Concept
Quand un nouveau projet entre dans le système (depuis DEV/ ou depuis une idée), `ipcrae ingest` crée toute la structure du cerveau associée : hub, mémoire, tracking, Knowledge, Zettelkasten.

## Déclencheur
- Nouveau repo dans `~/DEV/` à documenter
- Idée de projet dans `Inbox/projets-entrants/`
- Décision de démarrer un nouveau projet

## Commande

```bash
# Depuis le dossier du projet
cd ~/DEV/mon-projet
ipcrae ingest --project mon-projet

# Avec contexte domaine
ipcrae ingest --project mon-projet --domain electronique
```

## 6 Blocs exécutés par prompt_ingest.md

```
BLOC 1 — Analyse
  → Lire documentation, code, README
  → Résumer 5 points clés
  → Identifier domaine, stack, statut

BLOC 2 — Référencement cerveau global
  → Créer Projets/<slug>/index.md
  → Créer Projets/<slug>/memory.md
  → Créer Projets/<slug>/tracking.md

BLOC 2bis — Recherche et mise à jour des Knowledge existantes (CRITIQUE)
  → ipcrae tag <tags-clés-du-projet> → lister notes existantes liées
  → Pour chaque note liée : enrichir, sourcer, lier (NE PAS DUPLIQUER)
  → Marquer outdated les notes dont les infos sont dépassées

BLOC 3 — Extraction Knowledge (nouvelles uniquement)
  → Créer notes Knowledge/ SEULEMENT si pas de note existante sur le sujet
  → Tags cohérents avec le domaine

BLOC 4 — Zettelkasten
  → Créer notes atomiques dans Zettelkasten/_inbox/
  → Liens vers notes existantes

BLOC 5 — Journal de session
  → Entrée Journal/Daily/<YYYY>/<YYYY-MM-DD>.md
  → Tag Git d'ingestion : ingestion-<slug>-YYYYMMDD

BLOC 6 — Auto-audit
  → Vérifier que les 9 critères DoD sont couverts
```

## 9 Critères DoD (Definition of Done)
1. ✅ Hub Projets/<slug>/ créé avec index, memory, tracking
2. ✅ Domaine identifié et mémoire correspondante mise à jour
3. ✅ Knowledge existantes liées vérifiées et mises à jour (BLOC 2bis)
4. ✅ ≥1 note Knowledge/ nouvelle créée (si non couverte) avec frontmatter complet
5. ✅ ≥1 note Zettelkasten/_inbox/ avec lien vers une note existante
6. ✅ Tags cohérents avec le tag-index
7. ✅ Entrée dans context.md (section "Projets en cours")
8. ✅ Journal daily mis à jour
9. ✅ Git tag d'ingestion créé + `ipcrae close` exécuté

## Structure créée

```
Projets/<slug>/
  ├── index.md      ← hub central avec liens
  ├── tracking.md   ← kanban + backlog
  └── memory.md     ← décisions/contraintes projet

Knowledge/howto/<slug>-setup.md
Knowledge/patterns/<slug>-architecture.md
Zettelkasten/_inbox/<YYYYMMDDHHMM>-<slug>.md
```

## Liens
- [[Process/process-ingest-projet]] — Process complet
- [[zettelkasten-workflow]] — Notes Zettelkasten
- [[tag-first-navigation]] — Tags frontmatter
