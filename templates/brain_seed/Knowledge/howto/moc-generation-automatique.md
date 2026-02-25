---
type: knowledge
tags: [moc, zettelkasten, automatisation, tags, ipcrae, cluster]
domain: devops
status: active
sources:
  - project:IPCRAE/scripts/ipcrae-moc-auto.sh
  - project:IPCRAE/Process/index.md
created: 2026-02-22
updated: 2026-02-22
---

# How-to : Génération automatique de MOC Zettelkasten

## Concept
Les Maps of Content (MOC) doivent émerger naturellement des clusters de tags, pas être créées manuellement. Le script `ipcrae-moc-auto` détecte les tags avec ≥N notes sans MOC et les génère automatiquement.

## Algorithme de détection

```
1. Lire .ipcrae/cache/tag-index.json (reconstruire si stale > 1h)
2. Pour chaque tag avec count ≥ min_notes :
   a. Ignorer : tags avec ':' (project:xxx), méta-tags
   b. Si MOC-<slug>.md absent → CRÉER
   c. Si MOC existe + --update → ajouter notes manquantes
3. Mettre à jour Zettelkasten/MOC/index.md (section "Auto-générés")
```

## Usage

```bash
# Génération standard (≥3 notes)
ipcrae-moc-auto [--min-notes 3] [--update] [$IPCRAE_ROOT]

# Voir ce qui serait créé sans créer
ipcrae-moc-auto --dry-run --min-notes 2

# Forcer un tag spécifique
ipcrae-moc-auto --tag bash

# Mode silencieux (pour ipcrae close)
ipcrae-moc-auto --min-notes 3 --update --quiet
```

## Intégration dans `ipcrae close`
Appelé automatiquement à chaque clôture de session :
```bash
# Dans cmd_close du launcher :
ipcrae-moc-auto --min-notes 3 --update --quiet "$IPCRAE_ROOT" || true
```

## Format du MOC généré

```markdown
---
type: moc
tags: [<tag>, moc]
domain: all
status: active
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# MOC — Tag Name

## Notes liées
- [[note-slug]] — Titre de la note
- [[autre-note]] — Titre

## Sous-thèmes
-

## Résumé
<!-- Synthèse (N notes) -->
```

## Tags filtrés (non candidats MOC)
`example-tag`, `moc`, `type`, `status`, `knowledge`, `process`, `runbook`, `howto`, `pattern`, `daily`, `weekly`, `monthly`, `template`, `demande-brute`, `analysis`

## Prérequis pour que les MOC se peuplent
**Le tag-index doit être alimenté** — ce qui nécessite que les notes Knowledge/Zettelkasten aient des tags frontmatter YAML. Sans Knowledge notes, les MOC restent vides.

## Liens
- [[tag-first-navigation]] — Principe fondamental de recherche par tags
- [[zettelkasten-workflow]] — Workflow complet Zettelkasten
- [[Process/inbox-scan]] — Traitement Inbox
