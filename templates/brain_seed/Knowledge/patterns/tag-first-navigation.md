---
type: knowledge
tags: [tags, navigation, index, frontmatter, ipcrae, recherche]
domain: devops
status: active
sources:
  - project:IPCRAE/.ipcrae/context.md
  - project:IPCRAE/.ipcrae/cache/tag-index.json
created: 2026-02-22
updated: 2026-02-22
---

# Pattern : Navigation tag-first (vs arborescence)

## Concept
Dans IPCRAE, **on ne cherche pas en parcourant les dossiers**. On cherche par tags, qui sont la source de vérité dans le frontmatter YAML des fichiers Markdown.

## Ordre de recherche (obligatoire)

```
1. ipcrae tag <tag>          → notes indexées avec ce tag exact
2. ipcrae index              → reconstruire le cache si absent/stale
3. ipcrae search <mots|tags> → fallback fulltext si tag inconnu
```

Ne jamais commencer par `ls`, `find`, ou l'exploration manuelle des dossiers.

## Source de vérité : frontmatter YAML

```yaml
---
type: knowledge          # knowledge | zettelkasten | process | moc | project
tags: [bash, ipcrae]     # ← SOURCE DE VÉRITÉ (pas le dossier)
domain: devops           # devops | electronique | musique | maison | ...
project: IPCRAE          # slug projet associé
status: active           # active | draft | archived
sources:
  - project:IPCRAE/...   # référence interne (pas de chemin absolu)
created: 2026-02-22
updated: 2026-02-22
---
```

## Cache : accélération, pas vérité
`.ipcrae/cache/tag-index.json` = cache des tags pour recherche rapide.
- **Ce n'est pas la source de vérité** (le frontmatter l'est)
- Reconstruire avec `ipcrae index` (ou `ipcrae close` le fait automatiquement)
- Format : `{ "tags": { "bash": ["Knowledge/howto/...md", ...] } }`

## Deux types de tags à ne pas confondre

| Type | Où | Rôle | Format |
|------|----|------|--------|
| Frontmatter tag | Fichier .md YAML | Classification sémantique | `tags: [bash, ipcrae]` |
| Git tag annoté | `.git/refs/tags` | Jalon temporel | `session-20260222-devops` |

## Convention `project:` dans sources
```yaml
sources:
  - project:IPCRAE/scripts/ipcrae-moc-auto.sh   # ✅ relatif au vault
  - /home/eric/DEV/IPCRAE/scripts/...            # ❌ chemin absolu machine-specific
```

## Liens
- [[zettelkasten-workflow]] — Notes atomiques avec tags
- [[moc-generation-automatique]] — MOC générés depuis les tags
- [[Process/auto-amelioration]] — Audit qui vérifie la cohérence des tags
