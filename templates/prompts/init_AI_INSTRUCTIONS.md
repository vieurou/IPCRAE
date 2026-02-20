# Project-Specific AI Instructions

## Ordre de lecture intelligent pour l'agent (Évite le Context Bloat)
1) `docs/conception/00_VISION.md` (Compréhension globale)
2) `.ipcra-project/local-notes/STATE.md` (Contexte volatil : où en est-on exactement ?)
3) Le `docs/conception/concepts/` sur lequel on travaille actuellement.

> **RÈGLE ANTI-BLOAT** 
> Tu as accès à la mémoire globale (`.ipcra-memory/memory/`) et à l'architecture (`docs/conception/02_ARCHITECTURE.md`). **Ne les relis pas à chaque prompt**. Ne les ouvre que si tu es face à un problème d'architecture structurant, un pattern inconnu, ou si l'utilisateur te le demande. Pour coder au quotidien, fie-toi à `STATE.md` et au concept en cours.

{{context}}
---
{{instructions}}
---
{{rules}}
---
{{links}}
