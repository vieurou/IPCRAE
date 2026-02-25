---
type: knowledge
tags: [ai, delegation, broker, multi-agent, tutorial, cli]
project: brain-maintenance
domain: devops
status: consolidated
sources:
  - vault:Process/multi-ai-broker.md
created: 2026-02-25
updated: 2026-02-25
---

# 🛰️ Guide de Délégation Multi-IA (ipcrae-delegate)

Ce guide explique comment utiliser le script de délégation pour solliciter les différents agents (payants et gratuits) de ton système.

## 🚀 Utilisation Rapide

La commande `ipcrae-delegate` (ou le script `Scripts/ipcrae-multi-ai-delegate.sh`) prend deux arguments principaux :
1.  **Niveau de complexité (1-5)** : Définit le routage.
2.  **Prompt** : La question ou tâche à déléguer.

```bash
# Tâche simple (utilise Vibe ou Gemini Free)
ipcrae-delegate 1 "Résume ce texte en 3 points"

# Tâche standard (utilise Gemini)
ipcrae-delegate 3 "Explique le fonctionnement de Traefik avec Docker"

# Tâche complexe / Archi (utilise Claude Paid)
ipcrae-delegate 5 "Refactorise ce script Python en utilisant des classes et des décorateurs"
```

## 🧭 Matrice de Routage Actuelle

| Niveau | Agent Cible | Justification |
|--------|-------------|---------------|
| **1-2**| `vibe`      | Rapidité, économie de quota premium. |
| **3**  | `gemini`    | Bon compromis performance/quota. |
| **4-5**| `claude`    | Performance supérieure (Paid Account). |

## ⚙️ Paramètres Avancés

### Forcer un agent spécifique
Si tu veux contourner la matrice de routage pour une requête précise :
```bash
ipcrae-delegate 1 "..." --agent gemini
```

## 🔄 Évolution Future (Broker Automatique)

Le script est conçu pour être étendu avec :
- **Rotation de compte Google** : Basculement automatique de l'API Key.
- **aichat integration** : Pour accéder aux 50+ services gratuits via une seule CLI.
- **ollama** : Pour les tâches locales hors-ligne.
