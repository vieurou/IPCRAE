#!/usr/bin/env bash
set -euo pipefail

QUERY="${*:-}"
if [ -z "$QUERY" ]; then
  echo "Usage: ipcrae-agent-bridge.sh <question>"
  exit 1
fi

run_provider() {
  local provider="$1" prompt="$2"
  case "$provider" in
    claude)
      claude "$prompt" ;;
    gemini)
      gemini "$prompt" ;;
    codex)
      codex "$prompt" ;;
    *)
      return 1 ;;
  esac
}

providers=()
for cmd in claude gemini codex; do
  if command -v "$cmd" >/dev/null 2>&1; then
    providers+=("$cmd")
  fi
done

if [ "${#providers[@]}" -eq 0 ]; then
  echo "No supported AI CLI found (claude/gemini/codex)."
  exit 2
fi

compact_prompt="IPCRAE mode. Réponse concise. Donne seulement actions + risques + prochaine commande.\nQuestion: ${QUERY}"

for p in "${providers[@]}"; do
  echo "\n===== ${p^^} ====="
  if ! run_provider "$p" "$compact_prompt"; then
    echo "[WARN] provider failed: $p"
  fi
done
