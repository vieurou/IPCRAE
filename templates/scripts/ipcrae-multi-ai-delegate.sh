#!/bin/bash
# 🛰️ ipcrae-multi-ai-delegate.sh — Broker Stratégique (v1.0)
# Orchestration de modèles d'IA pour optimiser les quotas (Payant vs Gratuit)

set -e

# --- Configuration ---
# Niveaux de complexité (1-5)
# 1-3: Free/Standard, 4-5: Premium (Paid)

USAGE="Utilisation: ipcrae-multi-ai-delegate [complexité 1-5] "prompt" [--agent custom_agent]"

COMPLEXITY=${1:-1}
PROMPT=$2
CUSTOM_AGENT=$4 # Si --agent est passé

if [[ -z "$PROMPT" ]]; then
    echo "$USAGE"
    exit 1
fi

# --- Matrice de Routage (Logic) ---
AGENT_TO_USE=""

case $COMPLEXITY in
    1|2) # Basique/Rapide
        if command -v vibe &> /dev/null; then
            AGENT_TO_USE="vibe"
        elif command -v gemini &> /dev/null; then
            AGENT_TO_USE="gemini"
        else
            AGENT_TO_USE="claude"
        fi
        ;;
    3) # Standard (Daily)
        if command -v gemini &> /dev/null; then
            AGENT_TO_USE="gemini"
        else
            AGENT_TO_USE="claude"
        fi
        ;;
    4|5) # Premium (Paid Accounts)
        # On priorise Claude (Paid) ou Gemini Pro (Paid)
        if command -v claude &> /dev/null; then
            AGENT_TO_USE="claude"
        else
            AGENT_TO_USE="gemini"
        fi
        ;;
    *)
        AGENT_TO_USE="claude"
        ;;
esac

# Override si l'utilisateur demande un agent spécifique
if [[ -n "$CUSTOM_AGENT" ]]; then
    AGENT_TO_USE=$CUSTOM_AGENT
fi

# --- Exécution de la Délégation ---
echo "🛰️ [Broker] Délégation (Niveau $COMPLEXITY) -> Agent: $AGENT_TO_USE"

case $AGENT_TO_USE in
    claude)
        claude "$PROMPT"
        ;;
    gemini)
        gemini "$PROMPT"
        ;;
    vibe)
        vibe "$PROMPT"
        ;;
    aichat)
        aichat "$PROMPT"
        ;;
    *)
        echo "❌ Erreur: Agent '$AGENT_TO_USE' non supporté ou introuvable."
        exit 1
        ;;
esac
