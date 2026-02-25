#!/bin/bash
# 🛰️ ipcrae-multi-ai-delegate.sh — Broker Stratégique (v1.1)
# Orchestration de modèles d'IA avec FALLBACK (Repli automatique)

set -e

USAGE="Utilisation: ipcrae-multi-ai-delegate [complexité 1-5] \"prompt\" [--agent custom_agent]"

COMPLEXITY=${1:-1}
PROMPT=$2
CUSTOM_AGENT=$4

if [[ -z "$PROMPT" ]]; then
    echo "$USAGE"
    exit 1
fi

# --- Matrice de Routage (Fallback List) ---
# Format: "agent1 agent2 agent3"
AGENT_LIST=""

case $COMPLEXITY in
    1|2) AGENT_LIST="vibe gemini claude" ;;
    3)   AGENT_LIST="gemini claude vibe" ;;
    4|5) AGENT_LIST="claude gemini vibe" ;;
    *)   AGENT_LIST="claude gemini vibe" ;;
esac

if [[ -n "$CUSTOM_AGENT" ]]; then
    AGENT_LIST="$CUSTOM_AGENT"
fi

# --- Exécution avec Tentatives de Repli ---
SUCCESS=0

for AGENT in $AGENT_LIST; do
    echo "🛰️ [Broker] Tentative (Niveau $COMPLEXITY) -> Agent: $AGENT"
    
    set +e # On autorise l'échec pour le fallback
    case $AGENT in
        claude)
            if command -v claude &> /dev/null; then
                claude "$PROMPT" && SUCCESS=1
            fi
            ;;
        gemini)
            if command -v gemini &> /dev/null; then
                gemini -p "$PROMPT" && SUCCESS=1
            fi
            ;;
        vibe)
            if command -v vibe &> /dev/null; then
                vibe -p "$PROMPT" && SUCCESS=1
            fi
            ;;
    esac
    set -e

    if [[ $SUCCESS -eq 1 ]]; then
        echo "✅ [Broker] Tâche accomplie avec succès par $AGENT."
        exit 0
    else
        echo "⚠️ [Broker] Échec avec $AGENT (Quota ou Erreur), passage au suivant..."
    fi
done

echo "❌ [Broker] Échec critique: Tous les agents de la liste ont échoué."
exit 1
