#!/usr/bin/env bash
set -euo pipefail

AGENT="${1:-generic}"
TASK="${2:-}"

if [ -z "$TASK" ]; then
  echo "Usage: ipcrae-prompt-optimize.sh <agent> <task>"
  exit 1
fi

case "$AGENT" in
  claude)
    STYLE="Format XML court. Plan -> Action -> Vérification." ;;
  gemini)
    STYLE="Terminal-first. Sortie en checklist exécutable." ;;
  codex)
    STYLE="Patch minimal + commandes de test + limites." ;;
  *)
    STYLE="Réponse concise en markdown." ;;
esac

cat <<EOF_PROMPT
[IPCRAE::FAST_PROMPT]
Contrainte tokens: réponse <= 180 mots.
Objectif: proposer une action directement exécutable.
Style agent: ${STYLE}
Contexte minimal requis:
1) résultat attendu
2) contrainte bloquante
3) commande/test de validation

Tâche: ${TASK}
EOF_PROMPT
