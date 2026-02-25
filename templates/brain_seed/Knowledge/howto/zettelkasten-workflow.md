---
type: knowledge
tags: [zettelkasten, workflow, atomicité, liens, moc, permanents, ipcrae]
domain: devops
status: active
sources:
  - project:IPCRAE/.ipcrae/context.md
  - project:IPCRAE/Zettelkasten/MOC/index.md
created: 2026-02-22
updated: 2026-02-22
---

# How-to : Workflow Zettelkasten IPCRAE

## Concept
Un Zettelkasten est un réseau de notes atomiques où la connaissance émerge des **connexions** plutôt que de la hiérarchie. Chaque note = une seule idée, formulée dans ses propres mots.

## 3 Principes fondamentaux

1. **Atomicité** : une note = une seule idée (pas de "notes fourre-tout")
2. **Liens** : chaque note relie à au moins une autre `[[note]]`
3. **Émergence** : pas de plan top-down, la structure naît des connexions

## Différence Ressources vs Zettelkasten
- **Ressources/** = matière brute (extraits, refs, citations sources)
- **Zettelkasten/** = pensée digérée (reformulation dans ses mots)

## Workflow (3 étapes)

```
1. CAPTURER → Inbox/idees/ ou Inbox/infos à traiter/

2. BROUILLON → Zettelkasten/_inbox/<YYYYMMDDHHMM>-<slug>.md
   - Reformuler l'idée dans ses mots
   - Identifier au moins 1 lien [[existant]]
   - Ajouter tags frontmatter

3. VALIDER → Zettelkasten/permanents/<YYYYMMDDHHMM>-<slug>.md
   - Révision qualité (lien + unicité + langage propre)
   - Intégration dans le réseau (MOC si pertinent)
```

## Commandes

```bash
ipcrae zettel "titre"      # Créer une note dans _inbox/
ipcrae moc "thème"         # Créer/ouvrir un MOC
ipcrae moc --auto          # Générer les MOC manquants (clusters de tags)
```

## Format d'une note atomique

```markdown
---
type: zettelkasten
tags: [tag1, tag2]
domain: devops
status: permanent
created: 2026-02-22
updated: 2026-02-22
---

# YYYYMMDDHHMM — Titre court (concept clé)

Corps : une idée, formulée dans ses mots, 3-10 lignes max.

## Liens
- [[note-liee-1]] — raison du lien
- [[note-liee-2]] — raison du lien

## Source
→ `Ressources/<domaine>/source.md`
```

## ID de note : format timestamp
Format : `YYYYMMDDHHMM` — permet tri chronologique et unicité sans conflit.
Ex : `202602221430-moc-generation-automatique.md`

## Maps of Content (MOC)
Les MOC sont des notes d'index thématiques dans `Zettelkasten/MOC/` :
- Créés manuellement : `ipcrae moc "thème"`
- Générés automatiquement : `ipcrae-moc-auto --min-notes 3`
- Mis à jour à chaque `ipcrae close`

## Liens
- [[moc-generation-automatique]] — Comment les MOC sont générés
- [[tag-first-navigation]] — Navigation par tags
- [[Process/session-close]] — Mise à jour après session
