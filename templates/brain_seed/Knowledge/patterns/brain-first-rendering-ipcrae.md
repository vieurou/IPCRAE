---
type: knowledge
tags: [ipcrae, redaction, documentation, brain-first, workflow, rendu, ia]
project: IPCRAE
domain: system
status: active
sources:
  - project:IPCRAE/.ipcrae/prompts/core_ai_workflow_ipcra.md
  - vault:memory/system.md
created: 2026-02-23
updated: 2026-02-23
---

# Pattern : Brain-First Rendering (cerveau d'abord, document ensuite)

## Idée

Pour les tâches techniques durables, la séquence la plus robuste est :

1. **Structurer les faits / décisions / artefacts dans le cerveau**
2. **Récupérer ces éléments (plus contexte existant)**
3. **Formuler le document final**

Le document devient une **vue de synthèse**, pas la source de vérité.

## Pourquoi c'est meilleur pour une IA (souvent)

- Réduit la perte d'information lors de l'extraction après coup
- Sépare mieux le durable (mémoire/Knowledge/Process) du temporaire (réponse brute)
- Facilite la vérification de satisfaction (demande ↔ outputs ↔ réponse)
- Permet de réutiliser le contenu pour d'autres rendus (docs, howto, process, réponses)

## Quand l'appliquer

### Recommandé (brain-first)
- demandes multi-étapes
- docs techniques / procédures / howto
- architecture / décisions de méthode
- sessions avec impacts durables (scripts, prompts, process, mémoire)
- tâches nécessitant traçabilité forte

### Optionnel (texte d'abord possible)
- brainstorming léger
- réponse courte non durable
- reformulation simple
- échange conversationnel sans artefact durable

## Workflow hybride recommandé (IPCRAE)

1. Capture de la demande brute (verbatim)
2. Décomposition
3. Écriture des éléments durables (mémoire/Knowledge/Process/tracking)
4. Récupération outillée (`tag-first`, diff, fichiers produits)
5. Rendu document / réponse
6. Réexamen final de satisfaction (boucle fermée)

## Règle pratique

- **Si la demande est durable/technique** : brain-first par défaut
- **Si la demande est triviale** : texte d'abord, puis extraction minimale si besoin
- **En cas de doute** : brain-first (coût initial plus élevé, mais moins de perte)

## Liens

- [[Process/decomposition-demande]]
- [[Process/reexamen-fin-traitement-demande]]
- [[capture-demande-brute]]

