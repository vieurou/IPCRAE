---
type: process
tags: [ai, orchestration, broker, multi-agent, efficiency, quotas]
project: brain-maintenance
domain: devops
status: active
created: 2026-02-25
---

# 🛰️ Orchestration Multi-IA — Broker Stratégique (v1.0)

Ce processus définit comment déléguer les tâches aux différents modèles d'IA pour maximiser la performance et optimiser l'utilisation des quotas (payants et gratuits).

## 🧭 Matrice de Routage IPCRAE

| Type de Tâche | Modèle Recommandé | Accès | Justification |
|---------------|-------------------|-------|---------------|
| **Code Complexe / Archi** | Claude 3.5 Sonnet / Opus | Paid (Claude.ai) | Raisonnement supérieur, artefacts. |
| **Grosse Codebase / Refactor** | Gemini 1.5 Pro (2M context) | Paid (Google AI Plus) | Fenêtre de contexte massive. |
| **Recherche Web / Citations** | Perplexity / Grok | Paid (x.ai) / Free | Actualité temps réel, sources. |
| **Debug Rapide / Shell** | Groq (Llama 3) / Mistral | Free (API / CLI) | Vitesse d'exécution ultra-rapide. |
| **Banalité / Résumé** | ChatGPT (GPT-4o mini) | Free / Paid | Équilibré, fiable pour le tout-venant. |
| **Données Sensibles / Local** | Ollama (Llama3/Gemma2) | Local (Offline) | Confidentialité totale, pas de quota. |

## 🔄 Algorithme de Délégation (Broker-Logic)

1.  **Qualifier** la tâche : Complexité (1-5), Besoin de contexte (Mo/Go), Besoin de temps réel (Oui/Non).
2.  **Sélectionner** le "Tiers" :
    -   *Tiers 1 (Premium)* : Uniquement pour les tâches de niveau 4-5 ou contextes > 100k.
    -   *Tiers 2 (Standard)* : Pour le travail quotidien, prioriser les quotas "Free Tier" de qualité.
    -   *Tiers 3 (Massif/Farming)* : Pour les tâches répétitives (extraction, classification), utiliser les 50+ services gratuits.
3.  **Déléguer** : Utiliser les agents CLI (`claude`, `gemini`) ou le navigateur (`web_fetch`) pour interroger les services externes.
4.  **Consolider** : Récupérer le résultat dans le cerveau IPCRAE.

## 🚜 Stratégie "Free-Quota Farming" (Multi-Comptes)

Pour exploiter les multiples comptes Google et services gratuits :
- **Rotation de profil** : Changer d'API Key ou de session browser pour chaque bloc de 10-20 requêtes.
- **Répartition** : Distribuer les tâches atomiques d'un projet sur plusieurs fournisseurs simultanément.
- **Cache** : Toujours stocker les réponses dans `Knowledge/` pour ne pas ré-interroger inutilement.

## 🛠️ Outils de délégation disponibles
- CLI : `claude`, `gemini`, `vibe`, `aichat`, `ollama`.
- API : `OpenRouter` (Guichet unique).
- Web : `web_fetch` (requêtes directes).
