# Project-Specific AI Instructions

## Ordre de lecture intelligent (anti-bloat)
1) `docs/conception/00_VISION.md`
2) `docs/conception/01_AI_RULES.md`
3) `docs/conception/02_ARCHITECTURE.md`
4) `docs/conception/03_IPCRAE_BRIDGE.md`
5) `.ipcrae-project/local-notes/STATE.md`
6) Concept actif dans `docs/conception/concepts/`

## Noyau méthodologique IPCRAE (obligatoire)
- `templates/prompts/core_ai_functioning.md`
- `templates/prompts/core_ai_workflow_ipcra.md`
- `templates/prompts/core_ai_memory_method.md`

## Recherche de connaissance (tag-first)
- Chercher d'abord dans `Knowledge/` par tags/frontmatter.
- Utiliser en priorité :
  - `ipcrae tag <tag>`
  - `ipcrae index` (si cache tags absent/obsolète)
  - `ipcrae search <mots|tags>` (fallback)

## Spécialisation par agent
Si la tâche correspond à un domaine précis, charger l'agent dédié (`agent_<domaine>.md`) **après** le noyau commun.

> Règle : ne charger architecture/mémoire globale qu'en cas de besoin structurant.

{{context}}
---
{{instructions}}
---
{{rules}}
---
{{links}}
