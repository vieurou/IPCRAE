# IPCRAE Bridge (Local + Global)

## Priorité de lecture recommandée
1. Contexte local projet : `docs/conception/00_VISION.md`, `01_AI_RULES.md`, `02_ARCHITECTURE.md`
2. Contrat CDE projet : `docs/conception/03_IPCRAE_BRIDGE.md`
3. Notes projet locales : `.ipcrae-project/local-notes/` (contexte temporaire)
4. Hub central projet : `.ipcrae-memory/Projets/<projet>/`
5. Connaissance réutilisable : `.ipcrae-memory/Knowledge/` (source tag-first)
6. Mémoire globale : `.ipcrae-memory/memory/`

## Règle d'or (récupération)
- La recherche doit être pilotée par tags/index, pas par parcours manuel de tous les projets.
- Source de vérité des tags : frontmatter YAML des notes Markdown.
- Utiliser `ipcrae tag`, puis `ipcrae index`, puis `ipcrae search`.

## Règle d'or (écriture)
- Spécifique projet → `.ipcrae-project/memory/`
- Réutilisable transverse → `.ipcrae-memory/Knowledge/` avec frontmatter canonique.
- Volatile/debug → `.ipcrae-project/local-notes/`
