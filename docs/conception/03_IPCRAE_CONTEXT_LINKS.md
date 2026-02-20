# IPCRAE Context Links (Local + Global)

## Priorité de lecture recommandée
1. Contexte local projet : `docs/conception/00_VISION.md`, `01_AI_RULES.md`, `02_ARCHITECTURE.md`
2. Notes projet locales : `.ipcrae-project/local-notes/` (contexte temporaire de ce repo)
3. Mémoire globale : `.ipcrae-memory/memory/` (source de vérité durable)
4. Historique global : `.ipcrae-memory/Archives/` et `.ipcrae-memory/Journal/`

## Règle d'or
- Le global (`.ipcrae-memory/*`) reste la source de vérité durable.
- Le local (`.ipcrae-project/local-notes/`) sert au contexte court terme du projet.
- Après consolidation, remonter les décisions durables vers la mémoire globale.

## Cadence recommandée
- Fin de session: trier `local-notes/`.
- Fin de feature: promouvoir les décisions durables vers `.ipcrae-memory/memory/`.
- Revue hebdo: archiver le bruit, conserver les apprentissages réutilisables.
